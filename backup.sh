#!/bin/bash
shopt -s -o nounset

BACKUP_DIR=backup
DOT_FILE=dot
CONFIG_FILE=config

VSCODE_BACKUP="$BACKUP_DIR/$DOT_FILE/vscode"
VSCODE_CONFIG="$HOME/.config/Code/User"

BACKUP_DIR_LIST=( pulsar mozilla )
BACKUP_DIR_SNAP_LIST=( thunderbird )
BACKUP_FILE_LIST=( msmtprc pwclientrc gnupg ssh vim sesame vimrc lnxpromote \
		   bash_aliases bash_dev bash_igtops bash_kernelops bash_misc bash_servers )
BACKUP_CONFIG_LIST=( ghostty mpv tilix zim )

# create a backup directory
cd $HOME
[ -e $BACKUP_DIR ] || mkdir $BACKUP_DIR

# compress .atom, .mozilla and .thunderbird
echo "creating archives..."

for dir in "${BACKUP_DIR_LIST[@]}"
do
	tar -zcf $BACKUP_DIR/${dir}.tar.gz .${dir}
done

for dir in "${BACKUP_DIR_SNAP_LIST[@]}"
do
	tar -zcf $BACKUP_DIR/${dir}.tar.gz snap/${dir}
done

# copy hidden files
echo "creating target directories..."
[ -e $BACKUP_DIR/$DOT_FILE ] || mkdir $BACKUP_DIR/$DOT_FILE
[ -e $BACKUP_DIR/$DOT_FILE/.config ] || mkdir $BACKUP_DIR/$DOT_FILE/.config

echo "copying dot files and directories..."
for file in "${BACKUP_FILE_LIST[@]}"
do
	[ -f .${file} ] && cp -fp .${file} $BACKUP_DIR/$DOT_FILE
	[ -d .${file} ] && cp -frp .${file} $BACKUP_DIR/$DOT_FILE
done

for file in "${BACKUP_CONFIG_LIST[@]}"
do
	[ -d .config/${file} ] && cp -frp .config/${file} $BACKUP_DIR/$DOT_FILE/.config/
done

echo "copying .gitconfig in each directories..."
[ -e $BACKUP_DIR/$DOT_FILE/gitconfig ] || mkdir $BACKUP_DIR/$DOT_FILE/gitconfig
[ -e .gitconfig ] && cp -fp .gitconfig $BACKUP_DIR/$DOT_FILE/gitconfig/.gitconfig
[ -e src/amd/.gitconfig ] && cp -fp src/amd/.gitconfig $BACKUP_DIR/$DOT_FILE/gitconfig/.gitconfig_amd
[ -e src/personal/.gitconfig ] && cp -fp src/personal/.gitconfig $BACKUP_DIR/$DOT_FILE/gitconfig/.gitconfig_personal

echo "copying VSCode config..."
[ -e "$BACKUP_DIR/$DOT_FILE/vscode" ] || mkdir "$BACKUP_DIR/$DOT_FILE/vscode"
[ -d "$VSCODE_CONFIG" ] && cp -fp "$VSCODE_CONFIG/"*.json "$VSCODE_BACKUP/"
[ -d "$VSCODE_CONFIG/snippets" ] && cp -r "$VSCODE_CONFIG/snippets" "$VSCODE_BACKUP/"

echo "copying config files..."
[ -e $BACKUP_DIR//$CONFIG_FILE ] || mkdir $BACKUP_DIR//$CONFIG_FILE

# backup tilix config
dconf dump /com/gexperts/Tilix/ > $BACKUP_DIR/$CONFIG_FILE/tilix.dconf

echo "compressing hidden and config directories"
cd $BACKUP_DIR
tar -zcf $DOT_FILE.tar.gz $DOT_FILE
tar -zcf $CONFIG_FILE.tar.gz $CONFIG_FILE
rm -rf $DOT_FILE
rm -rf $CONFIG_FILE

