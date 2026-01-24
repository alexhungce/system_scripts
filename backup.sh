#!/bin/bash
shopt -s -o nounset

BACKUP_DIR=backup
DOT_FILE=dot
CONFIG_FILE=config

VSCODE_BACKUP="$BACKUP_DIR/$DOT_FILE/vscode"
VSCODE_CONFIG="$HOME/.config/Code/User"

BACKUP_DIR_LIST=( pulsar mozilla )
BACKUP_DIR_SNAP_LIST=( thunderbird )
BACKUP_FILE_LIST=( msmtprc pwclientrc gnupg ssh vim vimrc lnxpromote \
		   bash_aliases bash_dev bash_igtops bash_kernelops bash_misc bash_servers )
BACKUP_CONFIG_DIR_LIST=( ghostty kitty mpv tilix zim )
BACKUP_CONFIG_KDE_LIST=( kglobalshortcutsrc kwinrc plasma-org.kde.plasma.desktop-appletsrc \
			 plasmashellrc yakuakerc )

# Helper functions
log() {
    echo -e "\033[1;32m[BACKUP] $1\033[0m"
}

warn() {
    echo -e "\033[1;33m[WARNING] $1\033[0m"
}

log "initializing backup directories..."
cd "$HOME"
mkdir -p "$BACKUP_DIR/$DOT_FILE"/{.config,gitconfig,vscode} "$BACKUP_DIR/$CONFIG_FILE"

# compress .atom, .mozilla and .thunderbird
log "creating application archives..."
for dir in "${BACKUP_DIR_LIST[@]}"
do
	if [ -d ".${dir}" ]; then
		tar -zcf "$BACKUP_DIR/${dir}.tar.gz" ".${dir}"
	else
		warn "Directory .${dir} does not exist, skipping archive."
	fi
done

for dir in "${BACKUP_DIR_SNAP_LIST[@]}"
do
	if [ -d "snap/${dir}" ]; then
		tar -zcf "$BACKUP_DIR/${dir}.tar.gz" "snap/${dir}"
	else
		warn "Directory snap/${dir} does not exist, skipping archive."
	fi
done

log "copying dot files and directories..."
for file in "${BACKUP_FILE_LIST[@]}"
do
	[ -f ".${file}" ] && cp -fp ".${file}" "$BACKUP_DIR/$DOT_FILE"
	[ -d ".${file}" ] && cp -frp ".${file}" "$BACKUP_DIR/$DOT_FILE"
done

for dir in "${BACKUP_CONFIG_DIR_LIST[@]}"
do
	[ -d ".config/${dir}" ] && cp -frp ".config/${dir}" "$BACKUP_DIR/$DOT_FILE/.config/"
done

for file in "${BACKUP_CONFIG_KDE_LIST[@]}"
do
	[ -f ".config/${file}" ] && cp -fp ".config/${file}" "$BACKUP_DIR/$DOT_FILE/.config/"
done

log "copying .gitconfig in all directories..."
[ -e ".gitconfig" ] && cp -fp ".gitconfig" "$BACKUP_DIR/$DOT_FILE/gitconfig/.gitconfig"
[ -e "src/amd/.gitconfig" ] && cp -fp "src/amd/.gitconfig" "$BACKUP_DIR/$DOT_FILE/gitconfig/.gitconfig_amd"
[ -e "src/personal/.gitconfig" ] && cp -fp "src/personal/.gitconfig" "$BACKUP_DIR/$DOT_FILE/gitconfig/.gitconfig_personal"

log "copying VSCode config..."
[ -d "$VSCODE_CONFIG" ] && cp -fp "$VSCODE_CONFIG/"*.json "$VSCODE_BACKUP/"
[ -d "$VSCODE_CONFIG/snippets" ] && cp -r "$VSCODE_CONFIG/snippets" "$VSCODE_BACKUP/"

log "copying application config files..."
dconf dump /com/gexperts/Tilix/ > "$BACKUP_DIR/$CONFIG_FILE/tilix.dconf"

log "finalizing backup archives..."
cd "$BACKUP_DIR"
tar -zcf "$DOT_FILE.tar.gz" "$DOT_FILE"
tar -zcf "$CONFIG_FILE.tar.gz" "$CONFIG_FILE"
rm -rf "$DOT_FILE"
rm -rf "$CONFIG_FILE"

log "Backup completed successfully at $BACKUP_DIR"