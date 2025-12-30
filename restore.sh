#!/bin/bash
shopt -s -o nounset

BACKUP_DIR=backup
DOT_FILE=dot
CONFIG_FILE=config
DEST_DIR=$HOME

VSCODE_BACKUP="$BACKUP_DIR/$DOT_FILE/vscode"
VSCODE_DEST="$HOME/.config/Code/User"

BACKUP_DIR_LIST=( pulsar mozilla )
BACKUP_DIR_SNAP_LIST=( thunderbird )
BACKUP_FILE_LIST=( msmtprc pwclientrc gnupg ssh vim sesame vimrc lnxpromote \
		   bash_aliases bash_dev bash_igtops bash_kernelops bash_misc bash_servers )
BACKUP_CONFIG_LIST=( ghostty mpv tilix zim )

# Helper functions
log() {
    echo -e "\033[1;32m[RESTORE] $1\033[0m"
}

warn() {
    echo -e "\033[1;33m[WARNING] $1\033[0m"
}

cd $HOME/$BACKUP_DIR

log "extracting archives..."
for dir in "${BACKUP_DIR_LIST[@]}"
do
	[ -e ${dir}.tar.gz ] && tar -xf ${dir}.tar.gz -C $DEST_DIR
done

for dir in "${BACKUP_DIR_SNAP_LIST[@]}"
do
	[ -e ${dir}.tar.gz ] && tar -xf ${dir}.tar.gz -C $DEST_DIR/snap/
done

log "copying dot files..."
tar -xf $DOT_FILE.tar.gz

for file in "${BACKUP_FILE_LIST[@]}"
do
	[ -f $DOT_FILE/.${file} ] && cp -f $DOT_FILE/.${file} $DEST_DIR
	[ -d $DOT_FILE/.${file} ] && cp -r $DOT_FILE/.${file} $DEST_DIR
done

for file in "${BACKUP_CONFIG_LIST[@]}"
do
        [ -d $DOT_FILE/.config/${file} ] && cp -f -r $DOT_FILE/.config/${file} $DEST_DIR/.config
done

log "restoring .gitconfig to respective directories..."
mkdir -p "$HOME/src/amd" "$HOME/src/personal"
if [ -e "$DOT_FILE/gitconfig/.gitconfig" ]; then
	cp -fp "$DOT_FILE/gitconfig/.gitconfig" "$HOME/"
	log " Restored ~/.gitconfig"
fi

if [ -e "$DOT_FILE/gitconfig/.gitconfig_amd" ]; then
	cp -fp "$DOT_FILE/gitconfig/.gitconfig_amd" "$HOME/src/amd/.gitconfig"
	log " Restored src/amd/.gitconfig"
fi

if [ -e "$DOT_FILE/gitconfig/.gitconfig_personal" ]; then
	cp -fp "$DOT_FILE/gitconfig/.gitconfig_personal" "$HOME/src/personal/.gitconfig"
	log " Restored src/personal/.gitconfig"
fi

log "restoring VSCode config files..."
if [ -d "$VSCODE_BACKUP" ]; then
	mkdir -p "$VSCODE_DEST/snippets"

	[ -f "$VSCODE_BACKUP/settings.json" ] && cp -fp "$VSCODE_BACKUP/settings.json" "$VSCODE_DEST/"
	[ -f "$VSCODE_BACKUP/keybindings.json" ] && cp -fp "$VSCODE_BACKUP/keybindings.json" "$VSCODE_DEST/"

	if [ -d "$VSCODE_BACKUP/snippets" ]; then
		cp -rfp "$VSCODE_BACKUP/snippets/"* "$VSCODE_DEST/snippets/"
	fi
fi

rm -rf $DOT_FILE

log "copying config files..."
tar -xf $CONFIG_FILE.tar.gz

log "restoring tilix config..."
dconf load /com/gexperts/Tilix/ < $CONFIG_FILE/tilix.dconf
wget -qO $HOME"/.config/tilix/schemes/argonaut.json" https://git.io/v7QV5

rm -rf  $CONFIG_FILE

log "Restore completed successfully"
