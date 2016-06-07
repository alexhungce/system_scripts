#!/bin/bash
shopt -s -o nounset

BACKUP_DIR=backup
DOT_FILE=dot
CONFIG_FILE=config
DEST_DIR=$HOME

BACKUP_DIR_LIST=( atom mozilla thunderbird )
BACKUP_FILE_LIST=( gitconfig msmtprc pwclientrc gnupg ssh xchat2 vim sesame )
BACKUP_CONFIG_LIST=( hexchat )

cd $HOME/$BACKUP_DIR

# copy .atom, .mozilla and .thunderbird
echo "extracting archives..."

for dir in "${BACKUP_DIR_LIST[@]}"
do
	[ -e ${dir}.tar.gz ] && tar -xf ${dir}.tar.gz -C $DEST_DIR
done

echo ""

# move dot files to home directory
echo "copying dot files..."
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

rm -r $DOT_FILE

echo ""

# move config files
echo "copying config files..."
tar -xf $CONFIG_FILE.tar.gz
sudo cp $CONFIG_FILE/pwclient /usr/bin/  # patchwork
sudo cp $CONFIG_FILE/50-marblemouse.conf /usr/share/X11/xorg.conf.d/
rm -r $CONFIG_FILE
