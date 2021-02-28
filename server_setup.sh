#!/bin/bash
shopt -s -o nounset

# assign default directories if there aren't any
SOURCE_DIRECTORY=${1:-'src'}

sudo sed -i s/archive.ubuntu.com/mirror.it.ubc.ca/g /etc/apt/sources.list
sudo sed -i s/security.ubuntu.com/mirror.it.ubc.ca/g /etc/apt/sources.list

sudo sed -i '4,20s/# deb-src/deb-src/' /etc/apt/sources.list

sudo apt update && sudo apt -y upgrade

sudo apt install -y acpica-tools vim git git-email openssh-server tree \
		    powertop msmtp unp p7zip-full pastebinit curl \
		    shellcheck linux-tools-generic linux-tools-`uname -r` \
		    screen avahi-daemon docker.io

sudo usermod -aG docker $USER

cd $HOME
[ -e $SOURCE_DIRECTORY ] || mkdir $SOURCE_DIRECTORY
cd $SOURCE_DIRECTORY

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

# for Raspberry Pi
if grep -q Raspberry /proc/cpuinfo ; then
	# overclock
	if [ -f /boot/firmware/usercfg.txt ] ; then
		echo -e "\n[pi4]\nover_voltage=6\narm_freq=2147" | sudo tee -a /boot/firmware/usercfg.txt
	else
		echo -e "\n[pi4]\nover_voltage=6\narm_freq=2147" | sudo tee -a /boot/firmware/config.txt
	fi
fi
