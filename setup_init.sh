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

install_kitty() {
	if ! command -v kitty > /dev/null; then
		log "Installing Kitty Terminal..."
		curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

		# Desktop integration on Linux (official method on https://sw.kovidgoyal.net/kitty/binary/)
		# Create symbolic links to add kitty and kitten to PATH
		mkdir -p ~/.local/bin
		ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/

		# Place the kitty.desktop file somewhere it can be found by the OS
		mkdir -p ~/.local/share/applications/
		cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
		cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/

		# Update the paths to the kitty and its icon in the kitty.desktop file(s)
		# more icons can be found @ https://sw.kovidgoyal.net/kitty/faq/
		sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
		sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

		update-desktop-database ~/.local/share/applications/
	else
		log "Kitty Terminal is already installed."
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

	# install uv
	curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_desktop_packages () {
	log "Installing desktop packages..."

	sudo apt install -y drm-info \
			    fcitx5 \
			    fcitx5-chinese-addons \
			    fcitx5-chewing \
			    fonts-jetbrains-mono \
			    linux-tools-generic \
			    linux-tools-`uname -r` \
			    meld \
			    mpv \
			    powertop \
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
	install_kitty
	install_chrome
	popd
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
}

install_packages () {
	install_generic_packages

	if is_desktop ; then
		install_desktop_packages
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
			    network-manager-openvpn-gnome \
			    numix-gtk-theme \
			    numix-icon-theme-circle \
			    simple-scan \
			    ubuntu-restricted-addons

	# disable natural scrolling
	if [ "$(gsettings get org.gnome.desktop.peripherals.touchpad natural-scroll)" != "false" ]; then
		gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
	fi

	# enable middle-click paste
	if [ "$(gsettings get org.gnome.desktop.interface gtk-enable-primary-paste)" != "true" ]; then
		gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true
	fi

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

setup_dev() {
	log "Setting up Development Environment..."

	echo "fs.inotify.max_user_watches = 524288" | sudo tee /etc/sysctl.d/60-inotify.conf
	sudo sysctl -p /etc/sysctl.d/60-inotify.conf

	# Configure ccache
	ccache -M 50G
	ccache --set-config=sloppiness=include_file_mtime,include_file_ctime	# clear with "ccache -c"
	ccache --set-config=compression=true
	ccache --set-config=compression_level=1
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

# setup for development environment
setup_dev

log "Setup Complete!"
