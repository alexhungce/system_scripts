#!/bin/bash
shopt -s -o nounset

generic_install_packages () {
	sudo apt install -y acpi \
			    acpica-tools \
			    avahi-daemon \
			    bat \
			    btop \
			    crudini \
			    curl \
			    fd-find \
			    fzf \
			    git \
			    git-email \
			    gitk \
			    htop \
			    iw \
			    lm-sensors \
			    libfuse-dev \
			    nvme-cli \
			    nvtop \
			    openssh-server \
			    openconnect \
			    p7zip-full \
			    pastebinit \
			    plocate \
			    python3-github \
			    python3-gpg \
			    python3-virtualenv \
			    screen \
			    shellcheck \
			    tree \
			    unifdef \
			    unp \
			    vim
}

destkop_install_packages () {
	sudo apt install -y drm-info \
			    deluge \
			    ibus-chewing \
			    linux-tools-generic \
			    linux-tools-`uname -r` \
			    meld \
			    mpv \
			    numix-gtk-theme \
			    numix-icon-theme-circle \
			    powertop \
			    preload \
			    remmina \
			    simple-scan \
			    thunderbird \
			    tilix \
			    ubuntu-restricted-addons \
			    vlc \
			    zim

	# install snap packages
	sudo snap install multipass

	# install Google Chrome
	if ! which google-chrome > /dev/null ; then
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo dpkg -i google-chrome-stable_current_amd64.deb
		sudo apt install -f -y
		rm google-chrome-stable_current_amd64.deb
	fi
}

destkop_install_minimal_packages () {
	sudo apt install -y drm-info \
			    linux-tools-generic \
			    linux-tools-`uname -r` \
			    meld \
			    tilix
}

server_install_packages() {
	sudo apt install -y docker.io
	sudo usermod -aG docker $USER
}

build_install_packages() {
	# install packages for linux kernel
	sudo apt -y install bison \
			    build-essential \
			    ccache \
			    debhelper-compat \
			    fakeroot \
			    flex \
			    gawk \
			    libelf-dev \
			    libncurses5-dev \
			    libssl-dev

	# install packages for igt-gpu-tools
	sudo apt -y install libdrm-dev \
			    libkmod-dev \
			    libproc2-dev \
			    libdw-dev \
			    libpixman-1-dev \
			    libcairo2-dev \
			    libudev-dev \
			    meson
}

replace_snap_firefox_with_deb () {
	sudo snap remove firefox
	sudo add-apt-repository ppa:mozillateam/ppa -y
	# Pin the Firefox package to prefer the PPA version
	echo 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001' | sudo tee /etc/apt/preferences.d/mozilla-firefox
	sudo apt update
	sudo apt install -y firefox
}

install_packages () {
	# update source list and source code list
	sudo sed -i s/ca.archive.ubuntu.com/mirror.it.ubc.ca/g /etc/apt/sources.list.d/ubuntu.sources
	sudo sed -i 's/deb/deb deb-src/g' /etc/apt/sources.list.d/ubuntu.sources
	sudo apt update && sudo apt -y upgrade

	generic_install_packages

	if dpkg -l | grep -q ubuntu-desktop ; then
		# Get the system manufacturer
		MANUFACTURER=$(sudo dmidecode -s system-manufacturer 2>/dev/null)
		if [[ "$MANUFACTURER" == "AMD" ]]; then
			destkop_install_minimal_packages
		else
			destkop_install_packages
		fi
	else
		server_install_packages
	fi

	# setup build environments
	build_install_packages

	# replace snap firefox with deb
	replace_snap_firefox_with_deb

	# remove pre-installed applications
	sudo apt purge -y chromium-browser rhythmbox transmission-common aisleriot \
			gnome-mahjongg gnome-mines gnome-sudoku totem

	sudo apt -y autoremove
}

gnome_config () {
	# install applications for Gnome DE
	sudo apt install -y network-manager-openvpn-gnome gnome-shell-extensions \
			    gnome-shell-extension-manager gnome-tweaks gnome-weather

	# disable natural scrolling
	gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

	# set wheel scroll
	gsettings set org.gnome.desktop.peripherals.trackball scroll-wheel-emulation-button 8

	# hide desktop icons
	gsettings set org.gnome.shell.extensions.ding show-home false
	gsettings set org.gnome.shell.extensions.ding show-trash false

	# hide dock icons
	gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
	gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
}

system_config () {
	# disable crash report / apport
	sudo rm /var/crash/*
	sudo sed -i -e s/^enabled\=1$/enabled\=0/ /etc/default/apport

	# blacklist webcam for security
	echo "blacklist uvcvideo" | sudo tee -a /etc/modprobe.d/blacklist.conf

	# desktop only below
	if ! dpkg -l ubuntu-desktop &> /dev/null ; then
		return
	fi

	# create "Shared" and "tmp" directories
	cd $HOME
	[ -e Shared ] || mkdir Shared
	[ -e tmp ] || mkdir tmp

	gnome_config

	# setup for tilix
	if which tilix > /dev/null ; then
		sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh
	fi
}

# assign default directories if there aren't any
SOURCE_DIRECTORY=${1:-'src'}

# install packages based on system configs
install_packages

# configuration based on desktop
system_config

# download source code
cd $HOME
[ -e $SOURCE_DIRECTORY ] || mkdir $SOURCE_DIRECTORY
cd $SOURCE_DIRECTORY

[ -e source_scripts ] || git clone https://github.com/alexhungce/source_scripts.git
[ -e system_scripts ] || git clone https://github.com/alexhungce/system_scripts.git
