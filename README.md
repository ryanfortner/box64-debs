# Box64 Debian Repository

This is a simple Debian repository for the [box64](https://github.com/ptitSeb/box64) project, intended for my own personal use. New versions are compiled every 24 hours if a new commit has been made.

These debs have been compiled using RPiOS arm64 upgraded to debian bullseye. ***There is no guarantee that the debs will work on other systems (for example it may not work on debian buster)***

### Repository installation
Involves adding .list file and gpg key for added security.
```
sudo wget https://box64.armlinux.ml/box64.list -O /etc/apt/sources.list.d/box64.list
wget -qO- https://box64.armlinux.ml/KEY.gpg | sudo apt-key add -
sudo apt update && sudo apt install box64 -y
```

