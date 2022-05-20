# Box64 Debian Repository

This is a simple Debian repository for the [box64](https://github.com/ptitSeb/box64) project. New versions are compiled every 24 hours if a new commit on box64's repository has been made, you can find all the debs here: https://github.com/ryanfortner/box64-debs/commits/master

These debs have been compiled using RPiOS arm64 (Debian Buster). They should work on both debian Buster and Bullseye.

### Repository installation
Involves adding .list file and gpg key for added security.
```
sudo wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
wget -O- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/box64-debs-archive-keyring.gpg 
sudo apt update && sudo apt install box64 -y
```

If you don't want to add this apt repository to your system, you can download and install the latest arm64 deb from [here](https://github.com/ryanfortner/box64-debs/tree/master/debian).

### Note for box86

Please note that this repository is *only for box64*. If you would like deb packages for box86, check out Itai's repo: [https://github.com/Itai-Nelken/weekly-box86-debs](https://github.com/Itai-Nelken/weekly-box86-debs)

[![badge](https://github.com/Botspot/pi-apps/blob/master/icons/badge.png?raw=true)](https://github.com/Botspot/pi-apps)  
