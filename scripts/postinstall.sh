set_synaptics()
{
    cat << EOF > ${DESTDIR}/etc/X11/xorg.conf.d/50-synaptics.conf 
# Example xorg.conf.d snippet that assigns the touchpad driver
# to all touchpads. See xorg.conf.d(5) for more information on
# InputClass.
# DO NOT EDIT THIS FILE, your distribution will likely overwrite
# it when updating. Copy (and rename) this file into
# /etc/X11/xorg.conf.d first.
# Additional options may be added in the form of
#   Option "OptionName" "value"
#
Section "InputClass"
        Identifier "touchpad catchall"
        Driver "synaptics"
        MatchIsTouchpad "on"
        Option "TapButton1" "1"
        Option "TapButton2" "2"
        Option "TapButton3" "3"
# This option is recommend on all Linux systems using evdev, but cannot be
# enabled by default. See the following link for details:
# http://who-t.blogspot.com/2010/11/how-to-ignore-configuration-errors.html
        MatchDevicePath "/dev/input/event*"
EndSection

Section "InputClass"
        Identifier "touchpad ignore duplicates"
        MatchIsTouchpad "on"
        MatchOS "Linux"
        MatchDevicePath "/dev/input/mouse*"
        Option "Ignore" "on"
EndSection

# This option enables the bottom right corner to be a right button on
# non-synaptics clickpads.
# This option is only interpreted by clickpads.
Section "InputClass"
        Identifier "Default clickpad buttons"
        MatchDriver "synaptics"
        Option "SoftButtonAreas" "50% 0 82% 0 0 0 0 0"
EndSection

# This option disables software buttons on Apple touchpads.
# This option is only interpreted by clickpads.
Section "InputClass"
        Identifier "Disable clickpad buttons on Apple touchpads"
        MatchProduct "Apple|bcm5974"
        MatchDriver "synaptics"
        Option "SoftButtonAreas" "0 0 0 0 0 0 0 0"
EndSection
EOF

}

gnome_settings(){
	# Set Adwaita cursor theme
	chroot ${DESTDIR} ln -s /usr/share/icons/Adwaita /usr/share/icons/default

	# Set gsettings input-source
	if [[ "${KEYBOARD_VARIANT}" != '' ]];then
		sed -i "s/'us'/'${KEYBOARD_LAYOUT}+${KEYBOARD_VARIANT}'/" /usr/share/cnchi/scripts/set-settings
	else
		sed -i "s/'us'/'${KEYBOARD_LAYOUT}'/" /usr/share/cnchi/scripts/set-settings
        fi
	# Set gsettings
	cp /usr/share/cnchi/scripts/set-settings ${DESTDIR}/usr/bin/set-settings
	mkdir -p ${DESTDIR}/var/run/dbus
	mount -o bind /var/run/dbus ${DESTDIR}/var/run/dbus
	chroot ${DESTDIR} su -c "/usr/bin/set-settings ${DESKTOP}" ${USER_NAME} >/dev/null 2>&1

	# Set gdm shell logo
	cp /usr/share/antergos/logo.png ${DESTDIR}/usr/share/antergos/
	chroot ${DESTDIR} sudo -u gdm dbus-launch gsettings set org.gnome.login-screen logo "/usr/share/antergos/logo.png" >/dev/null 2>&1

	rm ${DESTDIR}/usr/bin/set-settings

	# Set skel directory
	cp -R ${DESTDIR}/home/${USER_NAME}/.config ${DESTDIR}/etc/skel

	## Set defaults directories
	chroot ${DESTDIR} su -c xdg-user-dirs-update ${USER_NAME}
	}

cinnamon_settings(){
	# Set Adwaita cursor theme
	chroot ${DESTDIR} ln -s /usr/share/icons/Adwaita /usr/share/icons/default

	# Set gsettings input-source
	if [[ "${KEYBOARD_VARIANT}" != '' ]];then
		sed -i "s/'us'/'${KEYBOARD_LAYOUT}+${KEYBOARD_VARIANT}'/" /usr/share/cnchi/scripts/set-settings
	else
		sed -i "s/'us'/'${KEYBOARD_LAYOUT}'/" /usr/share/cnchi/scripts/set-settings
        fi
	# copy antergos menu icon
	mkdir -p ${DESTDIR}/usr/share/antergos/
	cp /usr/share/antergos/antergos-menu.png ${DESTDIR}/usr/share/antergos/antergos-menu.png

	# Set gsettings
	cp /usr/share/cnchi/scripts/set-settings ${DESTDIR}/usr/bin/set-settings
	mkdir -p ${DESTDIR}/var/run/dbus
	mount -o bind /var/run/dbus ${DESTDIR}/var/run/dbus
	chroot ${DESTDIR} su -c "/usr/bin/set-settings ${DESKTOP}" ${USER_NAME} >/dev/null 2>&1
	rm ${DESTDIR}/usr/bin/set-settings

	# Set Cinnamon in .dmrc
	echo "[Desktop]" > ${DESTDIR}/home/${USER_NAME}/.dmrc
	echo "Session=cinnamon" >> ${DESTDIR}/home/${USER_NAME}/.dmrc

	# Set skel directory
	cp -R ${DESTDIR}/home/${USER_NAME}/.config ${DESTDIR}/etc/skel

	## Set defaults directories
	chroot ${DESTDIR} su -c xdg-user-dirs-update ${USER_NAME}
}

xfce_settings(){
	# Set Adwaita cursor theme
	chroot ${DESTDIR} ln -s /usr/share/icons/Adwaita /usr/share/icons/default

	# copy antergos menu icon
	mkdir -p ${DESTDIR}/usr/share/antergos/
	cp /usr/share/antergos/antergos-menu.png ${DESTDIR}/usr/share/antergos/antergos-menu.png

	# Set settings
	mkdir -p ${DESTDIR}/home/${USER_NAME}/.config/xfce4/xfconf/xfce-perchannel-xml
	cp -R ${DESTDIR}/etc/xdg/xfce4/panel ${DESTDIR}/etc/xdg/xfce4/helpers.rc ${DESTDIR}/home/${USER_NAME}/.config/xfce4
	sed -i "s/WebBrowser=firefox/WebBrowser=chromium/" ${DESTDIR}/home/${USER_NAME}/.config/xfce4/helpers.rc
	chroot ${DESTDIR} chown -R ${USER_NAME}:users /home/${USER_NAME}/.config
	cp /usr/share/cnchi/scripts/set-settings ${DESTDIR}/usr/bin/set-settings
	mkdir -p ${DESTDIR}/var/run/dbus
	mount -o bind /var/run/dbus ${DESTDIR}/var/run/dbus
	chroot ${DESTDIR} su -c "/usr/bin/set-settings ${DESKTOP}" ${USER_NAME} >/dev/null 2>&1
	rm ${DESTDIR}/usr/bin/set-settings

	# Set skel directory
	cp -R ${DESTDIR}/home/${USER_NAME}/.config ${DESTDIR}/etc/skel

	## Set defaults directories
	chroot ${DESTDIR} su -c xdg-user-dirs-update ${USER_NAME}

	# Set xfce in .dmrc
	echo "[Desktop]" > ${DESTDIR}/home/${USER_NAME}/.dmrc
	echo "Session=xfce" >> ${DESTDIR}/home/${USER_NAME}/.dmrc
}

openbox_settings(){
	# Set Adwaita cursor theme
	chroot ${DESTDIR} ln -s /usr/share/icons/Adwaita /usr/share/icons/default

	# copy antergos menu icon
	mkdir -p ${DESTDIR}/usr/share/antergos/
	cp /usr/share/antergos/antergos-menu.png ${DESTDIR}/usr/share/antergos/antergos-menu.png

	# Set settings
    
    # Get zip file from github, unzip it and copy all setup files in their right places.
    mkdir -p ${DESTDIR}/tmp
    wget -q -O ${DESTDIR}/tmp/master.zip "https://github.com/Antergos/openbox-setup/archive/master.zip"
    unzip -d ${DESTDIR}/tmp ${DESTDIR}/tmp/master.zip
    # copy slim theme
    mkdir -p ${DESTDIR}/usr/share/slim/themes/antergos-slim
    cp ${DESTDIR}/tmp/openbox-setup-master/antergos-slim/* ${DESTDIR}/usr/share/slim/themes/antergos-slim
    # copy home files
    cp ${DESTDIR}/tmp/openbox-setup-master/gtkrc-2.0 ${DESTDIR}/home/${USER_NAME}/.gtkrc-2.0
	chroot ${DESTDIR} chown -R ${USER_NAME}:users /home/${USER_NAME}/.gtkrc-2.0  
    cp ${DESTDIR}/tmp/openbox-setup-master/xinitrc ${DESTDIR}/home/${USER_NAME}/.xinitrc
    chroot ${DESTDIR} chown -R ${USER_NAME}:users /home/${USER_NAME}/.xinitrc
    
    # copy .config files
    mkdir -p ${DESTDIR}/home/${USER_NAME}/.config
    cp -R ${DESTDIR}/tmp/openbox-setup-master/config/* ${DESTDIR}/home/${USER_NAME}/.config
    # copy /etc setup files
    cp -R ${DESTDIR}/tmp/openbox-setup-master/etc/* ${DESTDIR}/etc
	
    chroot ${DESTDIR} chown -R ${USER_NAME}:users /home/${USER_NAME}/.config
	cp /usr/share/cnchi/scripts/set-settings ${DESTDIR}/usr/bin/set-settings
	mkdir -p ${DESTDIR}/var/run/dbus
	mount -o bind /var/run/dbus ${DESTDIR}/var/run/dbus
	chroot ${DESTDIR} su -c "/usr/bin/set-settings ${DESKTOP}" ${USER_NAME} >/dev/null 2>&1
	rm ${DESTDIR}/usr/bin/set-settings
    
    # remove leftovers
    rm -f ${DESTDIR}/tmp/master.zip
    rm -rf ${DESTDIR}/tmp/openbox-setup-master

	# Set skel directory
	cp -R ${DESTDIR}/home/${USER_NAME}/.config ${DESTDIR}/etc/skel

	## Set defaults directories
	#chroot ${DESTDIR} su -c xdg-user-dirs-update ${USER_NAME}

	# Set openbox in .dmrc
	echo "[Desktop]" > ${DESTDIR}/home/${USER_NAME}/.dmrc
	echo "Session=openbox" >> ${DESTDIR}/home/${USER_NAME}/.dmrc
}

razor_settings(){
	# Set theme
	mkdir -p ${DESTDIR}/home/${USER_NAME}/.config/razor/razor-panel
	echo "[General]" > ${DESTDIR}/home/${USER_NAME}/.config/razor/razor.conf
	echo "__userfile__=true" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/razor.conf
	echo "icon_theme=Faenza" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/razor.conf
	echo "theme=ambiance" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/razor.conf

	# Set panel launchers
	echo "[quicklaunch]" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/razor-panel/panel.conf
	echo "apps\1\desktop=/usr/share/applications/razor-config.desktop" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/razor-panel/panel.conf
	echo "apps\size=3" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/razor-panel/panel.conf
	echo "apps\2\desktop=/usr/share/applications/kde4/konsole.desktop" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/razor-panel/panel.conf
	echo "apps\3\desktop=/usr/share/applications/chromium.desktop" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/razor-panel/panel.conf

	# Set Wallpaper
	echo "[razor]" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/desktop.conf
	echo "screens\size=1" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/desktop.conf
	echo "screens\1\desktops\1\wallpaper_type=pixmap" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/desktop.conf
	echo "screens\1\desktops\1\wallpaper=/usr/share/antergos/wallpapers/antergos-wallpaper.png" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/desktop.conf
	echo "screens\1\desktops\1\keep_aspect_ratio=false" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/desktop.conf
	echo "screens\1\desktops\size=1" >> ${DESTDIR}/home/${USER_NAME}/.config/razor/desktop.conf

	# Set Razor in .dmrc
	echo "[Desktop]" > ${DESTDIR}/home/${USER_NAME}/.dmrc
	echo "Session=razor" >> ${DESTDIR}/home/${USER_NAME}/.dmrc
	
	chroot ${DESTDIR} chown -R ${USER_NAME}:users /home/${USER_NAME}/.config
}

kde_settings() {

	# Set KDE in .dmrc
	echo "[Desktop]" > ${DESTDIR}/home/${USER_NAME}/.dmrc
	echo "Session=kde-plasma" >> ${DESTDIR}/home/${USER_NAME}/.dmrc
	
	# Get zip file from github, unzip it and copy all setup files in their right places.
	cd /tmp
	rm -R ${DESTDIR}/usr/share/apps/desktoptheme/slim-glow/lancelot
    wget -q "https://github.com/lots0logs/kde-setup/archive/master.zip"
    unzip -o -qq /tmp/master.zip
    cd kde-setup-master
    usr_old=dustin
    grep -lr -e "${usr_old}" | xargs sed -i "s|${usr_old}|${USER_NAME}|g"
    cd /tmp/kde-setup-master
    mv home/user home/${USER_NAME}
    cp -R home ${DESTDIR}
    cp -R usr ${DESTDIR}
    chroot ${DESTDIR} ln -s /home/${USER_NAME}/.gtkrc-2.0 /home/${USER_NAME}/.gtkrc-2.0-kde4

	# Set Root environment
	cd /tmp/kde-setup-master
	usr_nm=${USER_NAME}
	usr_new=root
    grep -lr -e "${usr_nm}" | xargs sed -i "s|${usr_nm}|${usr_new}|g"
    cd /tmp/kde-setup-master
    mv home/${USER_NAME} home/root
    cp -R home/root ${DESTDIR}
    chroot ${DESTDIR} ln -s /home/root/.gtkrc-2.0 /home/root/.gtkrc-2.0-kde4

	## Set defaults directories
	chroot ${DESTDIR} su -c xdg-user-dirs-update
	
	# Fix Permissions
	chroot ${DESTDIR} chown -R ${USER_NAME}:users /home/${USER_NAME}

}

mate_settings() {

    # Set gsettings input-source
	if [[ "${KEYBOARD_VARIANT}" != '' ]];then
		sed -i "s/'us'/'${KEYBOARD_LAYOUT}+${KEYBOARD_VARIANT}'/" /usr/share/cnchi/scripts/set-settings
	else
		sed -i "s/'us'/'${KEYBOARD_LAYOUT}'/" /usr/share/cnchi/scripts/set-settings
        fi

    # Set gsettings
    # Set gsettings
	cp /usr/share/cnchi/scripts/set-settings ${DESTDIR}/usr/bin/set-settings
	mkdir -p ${DESTDIR}/var/run/dbus
	mount -o bind /var/run/dbus ${DESTDIR}/var/run/dbus
	chroot ${DESTDIR} su -c "/usr/bin/set-settings ${DESKTOP}" ${USER_NAME} >/dev/null 2>&1
	rm ${DESTDIR}/usr/bin/set-settings


	## Set defaults directories
	chroot ${DESTDIR} su -c xdg-user-dirs-update ${USER_NAME}

	# Set mate in .dmrc
	echo "[Desktop]" > ${DESTDIR}/home/${USER_NAME}/.dmrc
	echo "Session=mate-session" >> ${DESTDIR}/home/${USER_NAME}/.dmrc

	# Set skel directory
	cp -R ${DESTDIR}/home/${USER_NAME}/.config ${DESTDIR}/etc/skel

}
nox_settings(){
	echo "Done"
}

desktop_files() {
    cat << EOF > ${DESTDIR}/usr/share/applications/antergos-wiki.desktop
[Desktop Entry]
Type=Application
Name=Antergos Wiki
GenericName=Online Documentation
Comment=Online documention for Antergos Users.
Exec=xdg-open http://wiki.antergos.com/
Icon=info
Terminal=false
StartupNotify=false
Categories=Application;System;Documentation;
EOF

    cat << EOF > ${DESTDIR}/usr/share/applications/antergos-forum.desktop
[Desktop Entry]
Type=Application
Name=Antergos Forum
GenericName=User Support
Comment=User support and discussion forum.
Exec=xdg-open http://forum.antergos.com/
Icon=help
Terminal=false
StartupNotify=false
Categories=Application;System;Documentation;
EOF

}
postinstall(){
	USER_NAME=$1
	DESTDIR=$2
	DESKTOP=$3
	KEYBOARD_LAYOUT=$4
	KEYBOARD_VARIANT=$5
	# Specific user configurations

	## Set desktop-specific settings
	"${DESKTOP}_settings"

	## Unmute alsa channels
	chroot ${DESTDIR} amixer -c 0 set Master playback 50% unmute>/dev/null 2>&1

	# Fix transmission leftover
    if [ -f ${DESTDIR}/usr/lib/tmpfiles.d/transmission.conf ];
    then
	    mv ${DESTDIR}/usr/lib/tmpfiles.d/transmission.conf ${DESTDIR}/usr/lib/tmpfiles.d/transmission.conf.backup
    fi

	# Configure touchpad. Skip with base installs
	if [[ $DESKTOP != 'nox' ]];then
		set_synaptics

		# Create desktop files for Wiki and Forum.
	    desktop_files
	fi

	# Set Antergos name in filesystem files
	cp /etc/arch-release ${DESTDIR}/etc
	cp -f /etc/os-release ${DESTDIR}/etc/os-release
	
}

touch /tmp/.postinstall.lock
postinstall $1 $2 $3 $4 $5
rm /tmp/.postinstall.lock
