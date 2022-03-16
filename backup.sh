#!/bin/bash
shopt -s -o nounset

BACKUP_DIR=backup
DOT_FILE=dot
CONFIG_FILE=config

BACKUP_DIR_LIST=( atom mozilla thunderbird )
BACKUP_FILE_LIST=( gitconfig msmtprc pwclientrc gnupg ssh vim sesame vimrc lnxpromote \
		   bash_aliases bash_servers bash_acpiops bash_fwtsops bash_kernelops bash_misc )
BACKUP_CONFIG_LIST=( Atom tilix zim )

# create a backup directory
cd $HOME
[ -e $BACKUP_DIR ] || mkdir $BACKUP_DIR

# compress .atom, .mozilla and .thunderbird
echo "creating archives..."

for dir in "${BACKUP_DIR_LIST[@]}"
do
	tar -zcf $BACKUP_DIR/${dir}.tar.gz .${dir}
done

echo ""

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

echo ""

# copy config files
echo "copying config files..."
[ -e $BACKUP_DIR//$CONFIG_FILE ] || mkdir $BACKUP_DIR//$CONFIG_FILE
cp -fp /usr/bin/pwclient $BACKUP_DIR/$CONFIG_FILE/
cp -fp /usr/bin/get_lplogs.py $BACKUP_DIR/$CONFIG_FILE/
cp -fp /usr/bin/hwe_bug_ops.py $BACKUP_DIR/$CONFIG_FILE/
cp -fp /usr/share/X11/xorg.conf.d/50-marblemouse.conf $BACKUP_DIR/$CONFIG_FILE/
# backup tilix config
dconf dump /com/gexperts/Tilix/ > $BACKUP_DIR/$CONFIG_FILE/tilix.dconf

echo ""

# compress hidden and config directories
cd $BACKUP_DIR
ls ~/Downloads/bug-logs > bugs.lst
tar -zcf $DOT_FILE.tar.gz $DOT_FILE
tar -zcf $CONFIG_FILE.tar.gz $CONFIG_FILE
rm -rf $DOT_FILE
rm -rf $CONFIG_FILE

