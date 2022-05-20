#!/bin/bash

DIRECTORY="/github/workspace"
DEBIAN_FRONTEND=noninteractive

LATESTCOMMIT=`cat $DIRECTORY/commit.txt`

function error() {
	echo -e "\e[91m$1\e[39m"
    rm -f $COMMITFILE
    rm -rf $DIRECTORY/box64
	exit 1
 	break
}

rm -rf $DIRECTORY/box64

cd $DIRECTORY

# install dependencies
apt-get update
apt-get install wget git build-essential python3 make gettext pinentry-tty sudo devscripts dpkg-dev -y || error "Failed to install dependencies"
git clone https://github.com/giuliomoro/checkinstall || error "Failed to clone checkinstall repo"
cd checkinstall
sudo make install || error "Failed to run make install for Checkinstall!"
cd .. && rm -rf checkinstall
wget http://apt.raspbian-addons.org/debian/pool/main/c/cmake/cmake_3.21.3-15.1_arm64.deb || error "Failed to download updated cmake package!"
sudo apt install -yf ./cmake_3.21.3-15.1_arm64.deb
rm -rf cmake_3.21.3-15.1_arm64.deb

rm -rf box64

git clone https://github.com/ptitSeb/box64 || error "Failed to download box64 repo"
cd box64
commit="$(bash -c 'git rev-parse HEAD | cut -c 1-7')"
if [ "$commit" == "$LATESTCOMMIT" ]; then
  error "Box64 is already up to date. Exiting."
fi
echo "Box64 is not the latest version, compiling now."
echo $commit > $DIRECTORY/commit.txt
echo "Wrote commit to commit.txt file for use during the next compilation."
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DARM_DYNAREC=1 || error "Failed to run cmake."
make -j4 || error "Failed to run make."

function get-box64-version() {
	if [[ $1 == "ver" ]]; then
		export BOX64VER="$(./box64 -v | cut -c21-25)"
	elif [[ $1 == "commit" ]]; then
		export BOX64COMMIT="$commit"
	fi
}

get-box64-version ver  || error "Failed to get box64 version!"
get-box64-version commit || error "Failed to get box64 commit!"
DEBVER="$(echo "$BOX64VER+$(date +"%F" | sed 's/-//g').$BOX64COMMIT")" || error "Failed to set debver variable."

mkdir doc-pak || error "Failed to create doc-pak dir."
cp ../docs/README.md ./doc-pak || warning "Failed to add readme to docs"
cp ../docs/CHANGELOG.md ./doc-pak || error "Failed to add changelog to docs"
cp ../docs/USAGE.md ./doc-pak || error "Failed to add USAGE to docs"
cp ../LICENSE ./doc-pak || error "Failed to add license to docs"
echo "Box64 lets you run x86_64 Linux programs (such as games) on non-x86_64 Linux systems, like ARM (host system needs to be 64bit little-endian)">description-pak || error "Failed to create description-pak."
echo "#!/bin/bash
echo 'Restarting systemd-binfmt...'
systemctl restart systemd-binfmt" > postinstall-pak || error "Failed to create postinstall-pak!"

sudo checkinstall -y -D --pkgversion="$DEBVER" --arch="arm64" --provides="box64" --conflicts="qemu-user-static" --pkgname="box64" --install="no" make install || error "Checkinstall failed to create a deb package."

cd $DIRECTORY
mv box64/build/*.deb ./debian/ || error "Failed to move deb to debian folder."

rm -rf $DIRECTORY/box64

echo "Script complete."