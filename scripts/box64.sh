#!/bin/bash

DIR="$HOME/Documents/box64-auto-build"
DEBDIR="$HOME/Documents/box64-auto-build/debs"

function error() {
	echo -e "\e[91m$1\e[39m"
    echo "[ $(date) ] | ERROR | $1" >> $DIR/box64.log
	exit 1
 	break
}

function warning() {
	echo -e "$(tput setaf 3)$(tput bold)$1$(tput sgr 0)"
    echo "[ $(date) ] | WARNING | $1" >> $DIR/box64.log
}

function compile-box64(){
	echo "Compiling box64..."
	cd ~/Documents/box64-auto-build || error "Failed to change directory!"
	git clone https://github.com/ptitSeb/box64 || error "Failed to git clone box86 repo!"
	cd box64 || error "Failed to change directory!73)"
	commit="$(bash -c 'git rev-parse HEAD | cut -c 1-8')"
	committed="$(cat /home/pi/Documents/box64-auto-build/commit.txt)"
	if [ "$commit" == "$committed" ]; then
		echo "ERROR! Box64 is already up to date! deleting folder and exiting"
    		cd ~/ && rm -rf /home/pi/Documents/box64-auto-build/box64
		exit
	fi
	echo $commit > /home/pi/Documents/box64-auto-build/commit.txt
	mkdir build; cd build; cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DARM_DYNAREC=1 || error "Failed to run cmake!"
	make -j4 || error "Failed to run make!75)"
	BUILDDIR="$(pwd)" || error "Failed to set BUILDDIR variable!"
}

function get-box64-version() {
	if [[ $1 == "ver" ]]; then
		BOX64VER="$(./box64 -v | cut -c21-25)"
	elif [[ $1 == "commit" ]]; then
		BOX64COMMIT="$(./box64 -v | cut -c27-34)"
	fi
}

function package-box64() {
	cd $BUILDDIR || error "Failed to change directory to $BUILDDIR!"
	mkdir doc-pak || error "Failed to create doc-pak!"
	cp $DIR/box64/docs/README.md $BUILDDIR/doc-pak || error "Failed to copy README.md to doc-pak!"
	cp $DIR/box64/docs/CHANGELOG.md $BUILDDIR/doc-pak || error "Failed to copy CHANGELOG.md to doc-pak!"
	cp $DIR/box64/docs/USAGE.md $BUILDDIR/doc-pak || error "Failed to copy USAGE.md to doc-pak!"
	cp $DIR/box64/docs/LICENSE $BUILDDIR/doc-pak || error "Failed to copy LICENSE to doc-pak!"
	
	echo "Box64 lets you run x86_64 Linux programs (such as games) on non-x86_64 Linux systems, like ARM (host system needs to be 64bit little-endian)">description-pak || error "Failed to create description-pak!"
	echo "#!/bin/bash
	echo 'Restarting systemd-binfmt...'
	systemctl restart systemd-binfmt">postinstall-pak || error "Failed to create postinstall-pak!"
	
	get-box64-version ver  || error "Failed to get box86 version!110)"
	get-box64-version commit || error "Failed to get box86 commit (sha1)!111)"
	DEBVER="$(echo "$BOX64VER+$(date +"%F" | sed 's/-//g').$BOX64COMMIT")" || error "Failed to generate box86 version for the deb!"
	sudo checkinstall -y -D --pkgversion="$DEBVER" --arch="arm64" --provides="box64" --conflicts="qemu-user-static" --pkgname="box64" --install="no" make install || error "Failed to run checkinstall!"
}

function clean-up() {
	NOWDAY="$(printf '%(%Y-%m-%d)T\n' -1)" || error 'Failed to get current date!'
	mkdir -p $DEBDIR/box64-$NOWDAY || error "Failed to create folder for deb!"
	echo $BOX64COMMIT > $DEBDIR/box64-$NOWDAY/sha1.txt || error "Failed to write box86 commit (sha1) to sha1.txt!"
	mv box64*.deb $DEBDIR/box64-$NOWDAY || sudo mv box64*.deb $DEBDIR/box64-$NOWDAY || error "Failed to move deb!"
	# Remove the home directory from the deb if it exists
	cd $DEBDIR/box64-$NOWDAY || error "Failed to change directory to $DEBDIR/box64-$NOWDAY!"
	FILE="$(basename *.deb)" || error "Failed to get deb filename!"
	FILEDIR="$(echo $FILE | cut -c1-28)" || error "Failed to generate name for directory for the deb!"
	dpkg-deb -R $FILE $FILEDIR || error "Failed to extract the deb!"
	rm -r $FILEDIR/home || warning "Failed to remove home folder from deb!"
	rm -f $FILE || error "Failed to remove old deb!"
	dpkg-deb -b $FILEDIR $FILE || error "Failed to repack the deb!"
	rm -r $FILEDIR || error "Failed to remove temporary deb directory!"
	cd $DEBDIR || error "Failed to change directory to $DEBDIR!"
	tar -cJf box64-$NOWDAY.tar.xz box64-$NOWDAY/ || error "Failed to compress today's build into a tar.xz archive!"
	cd $DIR || error "Failed to change directory to $DIR!"
	sudo rm -rf box64 || error "Failed to remove box86 folder!"
}

function upload-deb() {
	EMAIL="$(cat /home/pi/Documents/box64-auto-build/email)"
	GPGPASS="$(cat /home/pi/Documents/box64-auto-build/gpgpass)"
	cp -r $DEBDIR/box64-$NOWDAY/box64* /home/pi/Documents/box64-debs/debian/ || error "Failed to copy new deb!"
	cd /home/pi/Documents/box64-debs/debian/
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
	git add .
	git commit -m "Box64 v$BOX64VER was updated to $BOX64COMMIT"
	git push origin master
	cd /home/pi/Documents/box64-auto-build
	rm -rf $DEBDIR/* || warning "Failed to remove the contents of the debs folder!"
}

# Run everything #
echo "compile time!"
compile-box64 || error "Failed to run compile-box64 function!"
package-box64 || error "Failed to run package-box64 function!"
clean-up || error "Failed to run clean-up function!"
clear -x
touch box64.log
TIME="$(date)"
echo "
=============================
$TIME
=============================" >> box64.log
NOWTIME="$(date +"%T")"
echo "[$NOWTIME | $NOWDAY] build and packaging complete." >> box64.log
upload-deb || error "Failed to upload deb!"
NOWTIME="$(date +"%T")"
echo "[$NOWTIME | $NOWDAY] uploading complete." >> box64.log
#echo $commit > /home/pi/Documents/box64-auto-build/commit.txt

