# Ubuntu docker container is very minimal (only 122 packages are installed)

# Add dependencies expected by scripts
apt update
apt install -y software-properties-common lsb-release \
sudo wget curl build-essential jq autoconf automake \
pkg-config ca-certificates rpm apt-utils \
python3 make gettext pinentry-tty devscripts dpkg-dev \
gcc-11 g++-11

# Install new enough git to run actions/checkout
sudo add-apt-repository ppa:git-core/ppa -y
sudo add-apt-repository ppa:theofficialgman/cmake-bionic -y
sudo apt update
sudo apt install -y git cmake

# Avoid "fatal: detected dubious ownership in repository" error
git config --global --add safe.directory '*'

# Build packages
./create-deb.sh