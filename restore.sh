#!/bin/bash
shopt -s -o nounset

BACKUP_DIR=backup
DOT_FILE=dot
CONFIG_FILE=config
DEST_DIR=$HOME

BACKUP_DIR_LIST=( pulsar mozilla thunderbird )
BACKUP_FILE_LIST=( gitconfig msmtprc pwclientrc gnupg ssh vim sesame vimrc lnxpromote \
		   bash_aliases bash_dev bash_igtops bash_kernelops bash_misc bash_servers )
BACKUP_CONFIG_LIST=( mpv tilix zim )

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

rm -rf $DOT_FILE

echo ""

# move config files
echo "copying config files..."
tar -xf $CONFIG_FILE.tar.gz
sudo cp $CONFIG_FILE/pwclient /usr/bin/  # patchwork

# Logitech Marble mouse
sudo cp $CONFIG_FILE/50-marblemouse.conf /usr/share/X11/xorg.conf.d/

# backup tilix config
dconf load /com/gexperts/Tilix/ < $CONFIG_FILE/tilix.dconf
wget -qO $HOME"/.config/tilix/schemes/argonaut.json" https://git.io/v7QV5

if [ -e /usr/share/X11/xorg.conf.d/40-libinput.conf ] ; then
	if ! grep -q "Marble Mouse" /usr/share/X11/xorg.conf.d/40-libinput.conf ; then
		cp /usr/share/X11/xorg.conf.d/40-libinput.conf .
		cat <<- EOF >> 40-libinput.conf

		Section "InputClass"
		        Identifier      "Marble Mouse"
		        MatchProduct    "Logitech USB Trackball"
		        Driver          "libinput"
		        Option          "ScrollMethod" "button"
		        Option          "ScrollButton" "8"
		        Option          "MiddleEmulation" "on"
		EndSection
		EOF
		sudo mv 40-libinput.conf /usr/share/X11/xorg.conf.d/40-libinput.conf
	fi
fi


rm -rf  $CONFIG_FILE
