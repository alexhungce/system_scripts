#!/bin/bash
shopt -s -o nounset

# Helper Functions
log() {
	echo -e "\033[1;32m[SETUP] $1\033[0m"
}

warn() {
	echo -e "\033[1;33m[WARNING] $1\033[0m"
}

is_desktop() {
	dpkg -l | grep -q ubuntu-desktop
}

is_gnome() {
	dpkg -l | grep -q gnome-shell
}

is_kde() {
	dpkg -l | grep -q plasma-desktop
}

update_sources() {
	log "Updating APT sources..."

	local source_file="/etc/apt/sources.list.d/ubuntu.sources"
	if [ -f "$source_file" ]; then
		sudo sed -i 's/\(ca\.\)\?archive\.ubuntu\.com/mirror.it.ubc.ca/g' "$source_file"

		if ! grep -q "deb-src" "$source_file"; then
			sudo sed -i 's/deb/deb deb-src/g' "$source_file"
		fi
	else
		warn "$source_file not found. Skipping source modification."
	fi

	sudo apt update && sudo apt -y upgrade
}

cleanup_system() {
	log "Removing unused packages..."

	sudo apt purge -y chromium-browser rhythmbox transmission-common aisleriot \
			gnome-mahjongg gnome-mines gnome-sudoku totem
	sudo apt -y autoremove
}

# Installation Functions
install_chrome() {
	if ! command -v google-chrome > /dev/null; then
		log "Installing Google Chrome..."
		local deb_file="/tmp/google-chrome-stable_current_amd64.deb"
		wget -O "$deb_file" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo apt install -y "$deb_file"
		rm "$deb_file"
	else
		log "Google Chrome is already installed."
	fi
}

install_ghostty() {
	log "Installing Ghostty Terminal..."
	curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh | sudo bash

	local source_file="com.mitchellh.ghostty.desktop"
	if [ -f "/usr/share/applications/$source_file" ]; then
		mkdir -p ~/.local/share/applications/
		cp "/usr/share/applications/$source_file" ~/.local/share/applications/
		sed -i 's/Icon=com.mitchellh.ghostty/Icon=utilities-terminal/' ~/.local/share/applications/"$source_file"

		# Refresh the desktop database so GNOME sees the change immediately
		update-desktop-database ~/.local/share/applications/
	else
		warn "Ghostty desktop file not found. Skipping icon customization."
	fi
}

install_generic_packages () {
	log "Installing generic packages..."

	sudo apt install -y acpi \
			    avahi-daemon \
			    bat \
			    btop \
			    crudini \
			    curl \
			    fd-find \
			    fzf \
			    git \
			    git-email \
			    git-lfs \
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
			    pipx \
			    python3-github \
			    python3-gpg \
			    python3-virtualenv \
			    radeontop \
			    screen \
			    shellcheck \
			    sshfs \
			    sshpass \
			    tree \
			    unifdef \
			    unp \
			    vim

	# install python packages
	pipx install pwclient
}

install_desktop_packages () {
	log "Installing desktop packages..."

	sudo apt install -y drm-info \
			    fcitx5 \
			    fcitx5-chinese-addons \
			    fcitx5-chewing \
			    linux-tools-generic \
			    linux-tools-`uname -r` \
			    meld \
			    mpv \
			    powertop \
			    preload \
			    remmina \
			    thunderbird \
			    vlc \
			    wl-clipboard \
			    zim

	# install snap packages
	sudo snap install multipass

	# cd to /tmp for downloads and installations
	pushd /tmp
	install_ghostty
	install_chrome
	popd
}

install_desktop_minimal_packages () {
	log "Installing minimal desktop packages..."

	sudo apt install -y drm-info \
			    linux-tools-generic \
			    linux-tools-`uname -r` \
			    meld \
			    tilix \
			    wl-clipboard
}

install_docker() {
	log "Installing Docker..."

	sudo apt install -y docker.io
	if ! groups "$USER" | grep -q docker; then
		sudo usermod -aG docker "$USER"
	fi
}

install_build_packages() {
	log "Installing build packages..."

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

install_packages () {
	install_generic_packages

	if is_desktop ; then
		# Get the system manufacturer
		MANUFACTURER=$(sudo dmidecode -s system-manufacturer 2>/dev/null)
		if [[ "$MANUFACTURER" == "AMD" ]]; then
			install_desktop_minimal_packages
		else
			install_desktop_packages
		fi
	else
		install_docker
	fi

	# setup build environments
	install_build_packages
}

configure_gnome () {
	log "Configuring GNOME..."

	# install applications for Gnome DE
	sudo apt install -y deluge \
			    gnome-shell-extension-manager \
			    gnome-shell-extensions \
			    gnome-tweaks \
			    gnome-weather \
			    ibus-chewing \
			    network-manager-openvpn-gnome \
			    numix-gtk-theme \
			    numix-icon-theme-circle \
			    simple-scan \
			    tilix \
			    ubuntu-restricted-addons

	# disable natural scrolling
	gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

	# set wheel scroll
	gsettings set org.gnome.desktop.peripherals.trackball scroll-wheel-emulation-button 8

	# hide desktop icons
	if gsettings list-schemas | grep -q "org.gnome.shell.extensions.ding"; then
		gsettings set org.gnome.shell.extensions.ding show-home false
		gsettings set org.gnome.shell.extensions.ding show-trash false
	fi

	# hide dock icons
	if gsettings list-schemas | grep -q "org.gnome.shell.extensions.dash-to-dock"; then
		gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
		gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
	fi
}

configure_kde () {
	log "Configuring KDE..."

	# install applications for KDE DE
	sudo apt install -y kubuntu-restricted-addons \
			    qbittorrent \
			    skanlite \
			    yakuake
}

configure_system () {
	log "Applying system configs..."

	# disable crash report / apport
	sudo rm /var/crash/*
	sudo sed -i -e s/^enabled\=1$/enabled\=0/ /etc/default/apport

	# blacklist webcam for security
	if ! grep -q "blacklist uvcvideo" /etc/modprobe.d/blacklist.conf; then
		echo "blacklist uvcvideo" | sudo tee -a /etc/modprobe.d/blacklist.conf
	fi

	# desktop only below
	if ! dpkg -l | grep -q ubuntu-desktop ; then
		return
	fi

	# create "Shared" and "tmp" directories
	mkdir -p "$HOME/Shared" "$HOME/tmp"

	if is_gnome; then
		configure_gnome
	fi

	if is_kde; then
		configure_kde
	fi

	# setup for tilix
	if command -v tilix > /dev/null; then
		if [ ! -f /etc/profile.d/vte.sh ]; then
			sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh
		fi
	fi
}

setup_git_repos() {
	log "Setting up Git Repositories..."

	mkdir -p "$HOME/$SOURCE_DIRECTORY/$PERSONAL_DIRECTORY"
	cd "$HOME/$SOURCE_DIRECTORY/$PERSONAL_DIRECTORY" || exit 1

	if [ ! -d "source_scripts" ]; then
		git clone https://github.com/alexhungce/source_scripts.git
	else
		log "source_scripts already exists."
	fi

	if [ ! -d "system_scripts" ]; then
		git clone https://github.com/alexhungce/system_scripts.git
	else
		log "system_scripts already exists."
	fi
}

# assign default directories if there aren't any
SOURCE_DIRECTORY=${1:-'src'}
PERSONAL_DIRECTORY='personal'

# update source list and source code list
update_sources

# install packages based on system configs
install_packages

# remove pre-installed applications
cleanup_system

# configuration based on desktop
configure_system

# download source code
setup_git_repos

log "Setup Complete!"
