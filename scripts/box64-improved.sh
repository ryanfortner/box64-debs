#!/bin/bash

#define variables
DIR="$HOME/Documents/box64-auto-build"
DEBDIR="$HOME/Documents/box64-auto-build/debs"
LATESTCOMMIT="$(cat /home/pi/Documents/box64-auto-build/commit.txt)"
NOWDAY="$(printf '%(%Y-%m-%d)T\n' -1)"
COMMITFILE="/home/pi/Documents/box64-auto-build/commit.txt"
EMAIL="$(cat /home/pi/Documents/box64-auto-build/email)"
GPGPASS="$(cat /home/pi/Documents/box64-auto-build/gpgpass)"

#error function: prints error in red, touches log and exits
function error() {
	echo -e "\e[91m$1\e[39m"
  rm -f $COMMITFILE
  mv /home/pi/Documents/box64-auto-build/commit.txt.bak /home/pi/Documents/box64-auto-build/commit.txt
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

#clone box64 using git, check if it's not the latest commit
cd $DIR && mkdir box64_${NOWDAY} && cd box64_${NOWDAY}
git clone https://github.com/ptitSeb/box64 . || error "Failed to clone box64 repo."
commit="$(bash -c 'git rev-parse HEAD | cur -c 1-8')"
if [ ! -f /home/pi/Documents/box64-auto-build/commit.txt.bak ]; then
  echo "commit.txt.bak not found, creating it now..."
  echo $commit > /home/pi/Documents/box64-auto-build/commit.txt.bak
fi
if [ "$commit" == "$LATESTCOMMIT" ]; then
  cd ~/ && rm -rf /home/pi/Documents/box64-auto-build/box64_${NOWDAY}
  error "Box64 is already up to date. Exiting."
fi
echo "Box64 is not the latest version, compiling now."
echo $commit > /home/pi/Documents/box64-auto-build/commit.txt
echo "Wrote commit to commit.txt file for use during the next compilation."

#compile box64
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DARM_DYNAREC=1 || error "Failed to run cmake."
make -j4 || error "Failed to run make."
BUILDDIR="$(pwd)"

#this function gets the box64 version and commit when it's needed. (Thanks Itai)
function get-box64-version() {
	if [[ $1 == "ver" ]]; then
		BOX64VER="$(./box64 -v | cut -c21-25)"
	elif [[ $1 == "commit" ]]; then
		BOX64COMMIT="$(./box64 -v | cut -c27-34)"
	fi
}

#check if checkinstall is installed
if ! command -v checkinstall > /dev/null; then
  #this package contains everything that's needed for checkinstall
  sudo apt update && sudo apt install gettext || error "Failed to apt update && apt install gettext"
  git clone https://github.com/giuliomoro/checkinstall
  cd checkinstall
  sudo make install
  cd .. && rm -rf checkinstall
fi

#create docs package, postinstall and description
cd $BUILDDIR
mkdir doc-pak
cp $DIR/box64/docs/README.md $BUILDDIR/doc-pak || warning "Failed to add readme to docs"
cp $DIR/box64/docs/CHANGELOG.md $BUILDDIR/doc-pak || warning "Failed to add changelog to docs"
cp $DIR/box64/docs/USAGE.md $BUILDDIR/doc-pak || warning "Failed to add USAGE to docs"
cp $DIR/box64/LICENSE $BUILDDIR/doc-pak || warning "Failed to add license to docs"
echo "Box64 lets you run x86_64 Linux programs (such as games) on non-x86_64 Linux systems, like ARM (host system needs to be 64bit little-endian)">description-pak || error "Failed to create description-pak."
echo "#!/bin/basht
echo 'Restarting systemd-binfmt...'
systemctl restart systemd-binfmt">postinstall-pak || error "Failed to create postinstall-pak!"
get-box64-version ver && get-box64-version commit || error "Failed to get box64 version or commit!"
DEBVER="$(echo "$BOX64VER+$(date +"%F" | sed 's/-//g').$BOX64COMMIT")" || error "Failed to set debver variable."
sudo checkinstall -y -D --pkgversion="$DEBVER" --arch="arm64" --provides="box64" --conflicts="qemu-user-static" --pkgname="box64" --install="no" make install || error "Checkinstall failed to create a deb package."

#remove home directory from the deb if it exists
mkdir -p $DEBDIR/box64_${NOWDAY}
echo $BOX64COMMIT > $DEBDIR/box64-${NOWDAY}/sha1.txt
mv box64*.deb $DEBDIR/box64_${NOWDAY} || sudo mv box64*.deb $DEBDIR/box64_${NOWDAY} || error "Failed to move deb!"
cd $DEBDIR/box64_${NOWDAY}
FILE="$(basename *.deb)" || error "Failed to get deb filename!"
FILEDIR="$(echo $FILE | cut -c1-28)" || error "Failed to generate name for the deb's directory!"
dpkg-deb -R $FILE $FILEDIR || error "Failed to extract the deb!"
rm -r $FILEDIR/home || warning "Couldn't remove home folder from deb."
cd $DEBDIR || error "Failed to change directory to debdir."
tar -cJf box64_${NOWDAY}.tar.xz box64_${NOWDAY}/ || error "Failed to compress to tar format!"

#upload the deb, check for latest git commits first.
cd /home/pi/Documents/box64-debs
git pull origin master || error "Failed to fetch latest changes!"
cp -r $DEBDIR/box64-$NOWDAY/box64* /home/pi/Documents/box64-debs/debian/ || error "Failed to copy to debian/ folder"
cd /home/pi/Documents/box64-debs/debian 
rm $HOME/Documents/box64-debs/debian/Packages || warning "Failed to remove old 'Packages' file!"
rm $HOME/Documents/box64-debs/debian/Packages.gz || warning "Failed to remove old 'Packages.gz' archive!"
rm $HOME/Documents/box64-debs/debian/Release || warning "Failed to remove old 'Release' file!"
rm $HOME/Documents/box64-debs/debian/Release.gpg || warning "Failed to remove old 'Release.gpg' file!"
rm $HOME/Documents/box64-debs/debian/InRelease || warning "Failed to remove old 'InRelease' file!"
dpkg-scanpackages --multiversion . > Packages
gzip -k -f Packages
apt-ftparchive release . > Release
gpg --default-key "${EMAIL}" --batch --pinentry-mode="loopback" --passphrase="$GPGPASS" -abs -o - Release > Release.gpg
gpg --default-key "${EMAIL}" --batch --pinentry-mode="loopback" --passphrase="$GPGPASS" --clearsign -o - Release > InRelease
cd /home/pi/Documents/box64-debs/
git add . || error "Failed to run git add"
git commit -m "Box64 v$BOX64VER was updated to $BOX64COMMIT" || error "Failed to run git commit"
git push origin master || error "Failed to run git push"
cd /home/pi/Documents/box64-auto-build
echo "Today's build has completed successfully."
