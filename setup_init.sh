#!/bin/bash
shopt -s -o nounset

# assign default directories if there aren't any
SOURCE_DIRECTORY=${1:-'src'}

sudo apt update

sudo apt install -y acpica-tools vim git git-email gitk openssh-server tree fwts msmtp meld ibus-chewing unp p7zip-full network-manager-openvpn-gnome pastebinit

# install Python libs
sudo apt install -y python-launchpadlib python3-launchpadlib

cd $HOME
[ -e $SOURCE_DIRECTORY ] || mkdir $SOURCE_DIRECTORY
cd $SOURCE_DIRECTORY

# get source code
git clone https://github.com/alexhungce/source_scripts.git
git clone https://github.com/alexhungce/system_scripts.git
git clone https://github.com/alexhungce/script-fwts.git

# create "Shared" directory for VMs
cd $HOME
mkdir Shared

# disable crash report / apport
sudo rm /var/crash/*
sudo sed -i -e s/^enabled\=1$/enabled\=0/ /etc/default/apport

# install different packages if not in VirtualBox
sudo dmidecode -t system | grep -n VirtualBox
if [ $? != 0 ] ; then
	sudo apt install -y nautilus-dropbox vlc virtualbox youtube-dl hexchat hexchat-indicator powertop ubuntu-restricted-extras acpi
fi

# install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt install -f
rm google-chrome-stable_current_amd64.deb
