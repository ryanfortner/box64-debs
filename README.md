# box64-debs

This is a simple Debian repository for the [box64](https://github.com/ptitSeb/box64) project. New versions are compiled every 24 hours if a new commit on the master repository has been made.

These debs have been compiled using various target CPUs and systems. You can see all the available pkgs below.

## Package List
Package Name | Notes | Install Command |
------------ | ------------- | ------------- |
| box64 | Box64 built for RPI4ARM64 target. | `sudo apt install box64` |
| box64-rpi3arm64 | Box64 built for RPI3ARM64 target. | `sudo apt install box64-rpi3arm64` |
| box64-generic-arm | Box64 built for generic ARM systems. | `sudo apt install box64-generic-arm` |
| box64-tegrax1 | Box64 built for Tegra X1 systems. | `sudo apt install box64-tegrax1` |
| box64-rk3588 | Box64 built for rk3588 cpu target. | `sudo apt install box64-rk3588` |
| box64-rk3399 | Box64 built for rk3399 cpu target. | `sudo apt install box64-rk3399` |
| box64-rk3326 | Box64 built for rk3326 cpu target. | `sudo apt install box64-rk3326` |

Want me to build for more platforms? Open an issue. 

### Repository installation
Involves adding .list file and gpg key for added security.
```
sudo wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
wget -O- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/box64-debs-archive-keyring.gpg 
sudo apt update
```
If you don't want to add this apt repository to your system, you can download and install the latest arm64 deb from [here](https://github.com/ryanfortner/box64-debs/tree/master/debian).

### CN mirror installation
Only for users in CN areas where GitHub is blocked.
```
sudo wget https://code.gitlink.org.cn/shenmo7192/box64-debs/raw/branch/master/box64-CN.list -O /etc/apt/sources.list.d/box64.list
wget -O- https://code.gitlink.org.cn/shenmo7192/box64-debs/raw/branch/master/KEY.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/box64-debs-archive-keyring.gpg 
sudo apt update
```
Alternatively, download the latest arm64 deb from [here](https://code.gitlink.org.cn/shenmo7192/box64-debs/src/branch/master/debian).

### Note for box86

Please note that this repository is *only for box64*. If you would like deb packages for box86, check out [box86-debs](https://github.com/ryanfortner/box86-debs).

[![badge](https://github.com/Botspot/pi-apps/blob/master/icons/badge.png?raw=true)](https://github.com/Botspot/pi-apps)  
