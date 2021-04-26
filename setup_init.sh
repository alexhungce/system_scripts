#!/bin/bash
shopt -s -o nounset

# assign default directories if there aren't any
SOURCE_DIRECTORY=${1:-'src'}

sudo sed -i s/ca.archive.ubuntu.com/mirror.it.ubc.ca/g /etc/apt/sources.list
sudo sed -i s/security.ubuntu.com/mirror.it.ubc.ca/g /etc/apt/sources.list

sudo sed -i '4,20s/# deb-src/deb-src/' /etc/apt/sources.list

sudo apt update && sudo apt -y upgrade

sudo apt install -y acpica-tools vim git git-email gitk openssh-server tree \
		    fwts msmtp meld ibus-chewing unp p7zip-full pastebinit \
		    network-manager-openvpn-gnome firefox thunderbird tilix \
		    zim curl numix-gtk-theme numix-icon-theme-circle \
		    shellcheck linux-tools-generic linux-tools-`uname -r` \
		    screen docker.io preload

sudo usermod -aG docker $USER

# install Python libs
sudo apt install -y python3-launchpadlib python3-yapf

# install multipass
sudo snap install multipass

cd $HOME
[ -e $SOURCE_DIRECTORY ] || mkdir $SOURCE_DIRECTORY
cd $SOURCE_DIRECTORY

# get source code
[ -e source_scripts ] || git clone https://github.com/alexhungce/source_scripts.git
[ -e system_scripts ] || git clone https://github.com/alexhungce/system_scripts.git

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
			    powertop ubuntu-restricted-addons steam \
			    avahi-daemon

	# install spotify
	curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
	echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
	sudo apt update && sudo apt install -y spotify-client

fi

# remove pre-installed applications
sudo apt purge -y chromium-browser rhythmbox transmission-common aisleriot gnome-mahjongg gnome-mines gnome-sudoku

# install Google Chrome
if ! which google-chrome > /dev/null ; then
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i google-chrome-stable_current_amd64.deb
	sudo apt install -f -y
	rm google-chrome-stable_current_amd64.deb
fi

# install atom
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" | sudo tee /etc/apt/sources.list.d/atom.list
sudo apt update && sudo apt install -y atom

# install applications for Gnome DE
sudo apt install -y gnome-tweaks chrome-gnome-shell

# setup for tilix
if which tilix > /dev/null ; then
	sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh
fi

sudo apt -y autoremove

# disable natural scrolling
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

# for faster boot time
sudo systemctl mask NetworkManager-wait-online.service
