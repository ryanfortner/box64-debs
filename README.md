# box64-debs

This is a simple Debian repository for the [box64](https://github.com/ptitSeb/box64) project. New versions are compiled every 24 hours if a new commit on the master repository has been made.

These debs have been compiled using various target CPUs and systems. You can see all the available pkgs below.

All packages built on Ubuntu Focal and are compatible with gcc-9 and higher.

### Repository installation
Involves adding .list file and gpg key for added security. Most users will just need the generic arm64 package, `box64`, but please see the package list below if you have a specifically supported system (Raspberry Pi, ROCKchip, etc...)
```
sudo wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg 
sudo apt update && sudo apt install box64 -y
```
If you don't want to add this apt repository to your system, you can download and install the latest arm64 deb from [here](https://github.com/ryanfortner/box64-debs/tree/master/debian).

<details>
<summary>CN mirror installation (click to expand)</summary>
<br>

Only for users in CN areas where GitHub is blocked. ***Disclaimer: I do not run this, use at your own risk***
```
sudo wget https://cdn05042023.gitlink.org.cn/shenmo7192/box64-debs/raw/branch/master/box64-CN.list -O /etc/apt/sources.list.d/box64.list
wget -qO- https://cdn05042023.gitlink.org.cn/shenmo7192/box64-debs/raw/branch/master/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg 
sudo apt update
```
Alternatively, download the latest arm64 deb from [here](https://cdn05042023.gitlink.org.cn/shenmo7192/box64-debs/src/branch/master/debian).

</details>

### Package List
Package Name | Notes | Install Command |
------------ | ------------- | ------------- |
| box64 | Box64 built for generic ARM 64-bit systems. Older builds for this target were under box64-generic-arm or box64-arm64. | `sudo apt install box64` |
| box64-rpi4arm64 | Box64 built for RPI4ARM64 target. | `sudo apt install box64-rpi4arm64` |
| box64-rpi3arm64 | Box64 built for RPI3ARM64 target. | `sudo apt install box64-rpi3arm64` |
| box64-tegrax1 | Box64 built for Tegra X1 systems. | `sudo apt install box64-tegrax1` |
| box64-rk3399 | Box64 built for rk3399 cpu target. | `sudo apt install box64-rk3399` |
| box64-android | Box64 built with the `-DBAD_SIGNAL=ON` flag | `sudo apt install box64-android` |
| box64-rk3588  | Box64 built for rk3588 cpu target. | `sudo apt install box64-rk3588` |
| box64-rpi5arm64  | Built for Raspberry Pi 5 (4K page size) | `sudo apt install box64-rpi5arm64` |
| box64-rpi5arm64ps16k  | Built for Raspberry Pi 5 (16K page size) | `sudo apt install box64-rpi5arm64ps16k` |
| box64-lx2160a  | Built for SolidRun LX2160A Honeycomb (see [#24](https://github.com/ryanfortner/box64-debs/issues/24)) | `sudo apt install box64-lx2160a` |
| box64-tegra-t194  | | `sudo apt install box64-tegra-t194` |
| box64-m1  | Built for Asahi Linux (M1 macs) | `sudo apt isntall box64-m1` |

Want me to build for more platforms? Open an issue. 

### Note for box86

Please note that this repository is *only for box64*. If you would like deb packages for box86, check out [box86-debs](https://github.com/ryanfortner/box86-debs).

[![badge](https://github.com/Botspot/pi-apps/blob/master/icons/badge.png?raw=true)](https://github.com/Botspot/pi-apps)  
