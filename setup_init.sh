#!/bin/bash
shopt -s -o nounset

# assign default directories if there aren't any
SOURCE_DIRECTORY=${1:-'src'}

sudo apt-get update

# install different packages for VM
sudo dmidecode -t system | grep VirtualBox >> /dev/null
if [ $? = 0 ] ; then
	sudo apt-get install -y iasl acpidump vim git git-email gitk openssh-server tree fwts msmtp meld ibus-chewing unp p7zip-full screen network-manager-openvpn-gnome hexchat hexchat-indicator pastebinit
else
	sudo apt-get install -y iasl acpidump vim git git-email gitk openssh-server tree fwts msmtp meld ibus-chewing unp nautilus-dropbox vlc virtualbox p7zip-full screen youtube-dl network-manager-openvpn-gnome hexchat hexchat-indicator pastebinit
fi

# install Python libs
sudo apt-get install -y python-launchpadlib python3-launchpadlib

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

# skip restricted-extra for VM
sudo dmidecode -t system | grep VirtualBox >> /dev/null
if [ $? != 0 ] ; then
	sudo apt-get install -y ubuntu-restricted-extras
fi

# install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt install -f
rm google-chrome-stable_current_amd64.deb
