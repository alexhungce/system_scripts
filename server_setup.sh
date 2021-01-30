#!/bin/bash
shopt -s -o nounset

# assign default directories if there aren't any
SOURCE_DIRECTORY=${1:-'src'}

sudo sed -i s/archive.ubuntu.com/mirror.it.ubc.ca/g /etc/apt/sources.list
sudo sed -i s/security.ubuntu.com/mirror.it.ubc.ca/g /etc/apt/sources.list

sudo sed -i '4,20s/# deb-src/deb-src/' /etc/apt/sources.list

sudo apt update && sudo apt -y upgrade

sudo apt install -y acpica-tools acpi vim git git-email openssh-server tree \
		    powertop msmtp meld unp p7zip-full pastebinit curl shellcheck screen \
		    avahi-daemon

# install Python libs
sudo apt install -y python3-launchpadlib

cd $HOME
[ -e $SOURCE_DIRECTORY ] || (mkdir $SOURCE_DIRECTORY && cd $SOURCE_DIRECTORY)

# get source code
[ -e source_scripts ] || git clone https://github.com/alexhungce/source_scripts.git
[ -e system_scripts ] || git clone https://github.com/alexhungce/system_scripts.git

# disable crash report / apport
sudo rm /var/crash/*
sudo sed -i -e s/^enabled\=1$/enabled\=0/ /etc/default/apport

# blacklist webcam for security
echo "blacklist uvcvideo" | sudo tee -a /etc/modprobe.d/blacklist.conf

sudo apt -y autoremove

# for faster boot time
sudo systemctl mask NetworkManager-wait-online.service
