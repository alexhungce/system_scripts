#!/bin/bash
shopt -s -o nounset

# assign default directories if there aren't any
SOURCE_DIRECTORY=${1:-'src'}

sudo apt update && sudo apt -y upgrade

sudo apt install -y acpica-tools vim git git-email gitk openssh-server tree \
		    fwts msmtp meld ibus-chewing unp p7zip-full pastebinit \
		    network-manager-openvpn-gnome firefox thunderbird tilix \
		    zim curl

# install Python libs
sudo apt install -y python3-launchpadlib

cd $HOME
[ -e $SOURCE_DIRECTORY ] || mkdir $SOURCE_DIRECTORY
cd $SOURCE_DIRECTORY

# get source code
[ -e source_scripts ] || git clone https://github.com/alexhungce/source_scripts.git
[ -e system_scripts ] || git clone https://github.com/alexhungce/system_scripts.git
[ -e script-fwts ] || git clone https://github.com/alexhungce/script-fwts.git

# create "Shared" directory for VMs
cd $HOME
[ -e Shared ] || mkdir Shared

# disable crash report / apport
sudo rm /var/crash/*
sudo sed -i -e s/^enabled\=1$/enabled\=0/ /etc/default/apport

# blacklist webcam for security
echo "blacklist uvcvideo" | sudo tee -a /etc/modprobe.d/blacklist.conf

# install different packages if not in VirtualBox
sudo dmidecode -t system | grep -n VirtualBox
if [ $? != 0 ] ; then
	sudo apt install -y nautilus-dropbox vlc youtube-dl acpi deluge \
			    hexchat hexchat-indicator powertop \
			    ubuntu-restricted-addons steam
fi

# remove pre-installed applications
sudo apt purge -y chromium-browser rhythmbox transmission-common

# install Google Chrome
if ! which google-chrome > /dev/null ; then
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i google-chrome-stable_current_amd64.deb
	sudo apt install -f -y
	rm google-chrome-stable_current_amd64.deb
fi

# install spotify
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt update && sudo apt install spotify-client

# install applications for Gnome DE
sudo apt install -y gnome-tweaks chrome-gnome-shell

# setup for tilix
if which tilix > /dev/null ; then
	sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh
fi

sudo apt -y autoremov

gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
