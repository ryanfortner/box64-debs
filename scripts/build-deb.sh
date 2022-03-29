#!/bin/bash

#error function: prints error in red, touches log and exits
function error() {
	echo -e "\e[91m$1\e[39m"
	rm -f $COMMITFILE
	mv /github/workspace/build-data/commit.txt.bak /github/workspace/build-data/commit.txt
	exit 1
 	break
}

#warning function: prints error in yellow, touches log and continues (thanks Itai)
function warning() {
	echo -e "$(tput setaf 3)$(tput bold)$1$(tput sgr 0)"
}

printf "Checking if you are online..."
wget -q --spider http://github.com
if [ $? -eq 0 ]; then
  echo "Online. Continuing."
else
  error "Offline. Go connect to the internet then run the script again. (could not resolve github.com)"
fi

#clone box64 using git, write the commit to commit.txt
mkdir -p /github/workspace/build-output
cd /github/workspace/build-output || error "Failed to enter /github/workspace/build-output directory!"
rm -rf ./box64/
rm -rf ./*.deb
git clone https://github.com/ptitSeb/box64 || error "Failed to clone box64 repo."
cd ./box64/ || error "Failed to enter box64 directory for some reason!"
commit="$(bash -c 'git rev-parse HEAD | cut -c 1-8')"
echo $commit > /github/workspace/build-data/commit.txt

#compile box64
mkdir ./build/ && cd ./build/
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DARM_DYNAREC=1 || error "Failed to run cmake."
make -j4 || error "Failed to run make."

#this function gets the box64 version and commit when it's needed. (Thanks Itai)
function get-box64-version() {
	if [[ $1 == "ver" ]]; then
		BOX64VER="$(./box64 -v | grep Box64 | cut -c 21-25)"
	elif [[ $1 == "commit" ]]; then
		BOX64COMMIT="$(cat /github/workspace/build-data/commit.txt)"
	fi
}

#check if checkinstall is installed
if ! command -v checkinstall > /dev/null; then
  #this package contains everything that's needed for checkinstall
  sudo apt update && sudo apt install gettext -y || error "Failed to apt update && apt install gettext"
  git clone https://github.com/giuliomoro/checkinstall
  cd checkinstall
  sudo make install
  cd .. && rm -rf checkinstall
fi

#create docs package, postinstall and description
cd /github/workspace/build-output/box64/build
mkdir doc-pak
cp ../docs/README.md doc-pak/ || warning "Failed to add readme to docs"
cp ../docs/CHANGELOG.md doc-pak/ || warning "Failed to add changelog to docs"
cp ../docs/USAGE.md doc-pak/ || warning "Failed to add USAGE to docs"
cp ../LICENSE doc-pak/ || warning "Failed to add license to docs"
echo "Box64 lets you run x86_64 Linux programs (such as games) on non-x86_64 Linux systems, like ARM (host system needs to be 64bit little-endian)">description-pak || error "Failed to create description-pak."
echo "#!/bin/bash
echo 'Restarting systemd-binfmt...'
systemctl restart systemd-binfmt || true">postinstall-pak || error "Failed to create postinstall-pak!"
get-box64-version ver && get-box64-version commit || error "Failed to get box64 version or commit!"
DEBVER="$(echo "$BOX64VER+$(date +"%F" | sed 's/-//g').$BOX64COMMIT")" || error "Failed to set debver variable."
sudo checkinstall -y -D --pkgversion="$DEBVER" --arch="arm64" --provides="box64" --conflicts="qemu-user-static" --pkgname="box64" --install="no" make install || error "Checkinstall failed to create a deb package."

cd /github/workspace/build-output
cp ./box64/build/*.deb . || error "Failed to copy deb!"
rm -rf ./box64/
echo "Done!"
