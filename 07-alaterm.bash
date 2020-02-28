# Part of the alaterm project, https://github.com/cargocultprog/alaterm/
# This file is: https://raw.githubusercontent.com/cargocultprog/alaterm/master/07-alaterm.bash

echo "$(caller)" | grep -F 00-alaterm.bash >/dev/null 2>&1
if [ "$?" -ne 0 ] ; then
echo "Script 07-alaterm.bash is not stand-alone."
echo "It must be sourced in sequence from 00-alaterm.bash."
echo "Exit." ; exit 1
fi


##############################################################################
## INSTALLER PART 07. Configure LXDE Desktop.
##############################################################################


create_banMenuItems() { # In /usr/local/scripts.
cat << 'EOC' > "ban-menu-items" # No hyphen, quoted marker.
#!/bin/bash
# File ban-menu-items placed in /usr/local/scripts by installation script.
# Prevents useless or redundant applications from appearing on menu.
# Runs during install, launch, and after each pacman install or upgrade.
# Creates or over-writes desktop items in $HOME/.local/applications.
lsa="/home/.local/share/applications"
declare -A nomenu
nomenu[avahi-discover]="Avahi Zeroconf Browser"
nomenu[blocks]="Block Attack!"
nomenu[bssh]="Avahi SSS Server Browser"
nomenu[bvnc]="Avahi VNC Server Browser"
nomenu[checkers]="Checkers"
nomenu[cups]="Manage Printers"
nomenu[fluid]="FLTK GUI Designer"
nomenu[gtk3-demo]="GTK+ Demo"
nomenu[gtk3-icon-browser]="Icon Browser"
nomenu[gtk3-widget-factory]="Widget Factory"
nomenu[io.elementary.granite.demo]="Granite Demo"
nomenu[libfm-pref-apps]="Preferred Applications"
nomenu[libreoffice-base]="LibreOffice Base"
nomenu[libreoffice-calc]="LibreOffice Calc"
nomenu[uxterm]="UXTerm"
nomenu[libreoffice-draw]="LibreOffice Draw"
nomenu[libreoffice-impress]="LibreOffice Impress"
nomenu[libreoffice-math]="LibreOffice Math"
nomenu[lstopo]="Hardware Locality lstopo"
nomenu[lxde-logout]="Logout"
nomenu[lxde-screenlock]="ScreenLock"
nomenu[lxsession-default-apps]="Default applications for LXSession"
nomenu[lxsession-edit]="Shortcut Editor"
nomenu[lxterminal]="LXTerminal"
nomenu[openbox]="Openbox"
nomenu[sudoku]="Sudoku"
nomenu[qv4l2]="Qt V4L2 test Utility"
nomenu[qvidcap]="Qt V4L2 video capture utility"
nomenu[vncviewer]="TigerVNC Viewer"
nomenu[xdvi]="XDvi"
# stackoverflow.com q. 3112687 answers by Paused Until and Michael O:
for i in "${!nomenu[@]}" ; do
	if [ -f "/usr/share/applications/$i.desktop" ] ; then
		echo "[Desktop Entry]" > "$lsa/$i.desktop"
		echo "Name=${nomenu[$i]}" >> "$lsa/$i.desktop"
		echo "Type=Application" >> "$lsa/$i.desktop"
		echo "NoDisplay=true" >> "$lsa/$i.desktop"
	elif [ -f "$lsa/$i.desktop" ] ; then
		rm -f "$lsa/$i.desktop"
	fi
done
##
EOC
}

create_banmenuitemsHook() { # In /etc/pacman.d/hooks.
cat << EOC > banmenuitems.hook # No hyphen. Unquoted marker.
[Trigger]
Type = File
Operation = Install
Operation = Upgrade
Operation = Remove
Target = *

[Action]
Description = Fixing the Menu...
When = PostTransaction
Exec = /usr/local/scripts/ban-menu-items
EOC
}

create_defaultResolution() { # In /usr/local/scripts.
cat << 'EOC' > default-resolution # No hyphen. Quoted marker.
#!/bin/bash
# File /usr/local/scripts/default-resolution
# Created by installation script.
showdrhelp() {
	echo "Usage:  default-resolution WxH"
	echo "where W and H are 3 to 4 digit numbers."
	echo "Installation default is  1280x800"
	echo "This routine changes the default LXDE Desktop resolution."
	echo "Change is not activated until next time alaterm is launched."
	echo "If your desired default is on the LXDE Desktop Menu in"
	echo "Preferences > Monitor Settings, then use the menu instead."
	echo "But if the desired setting is not listed, this command adds it."
}
dnuyou() {
	echo "Did not understand the argument. Try again."
	exit 1
}
oor() {
	echo "Value for width or height is out of range. Try again."
	exit 1
}
if [ "$#" -ne 1 ] || [[ ! "$1" =~ ^[1-9] ]] ; then
	showdrhelp ; exit 0
fi
wxh="$( echo $1 | sed 's/X/x/g' )"
w="$( echo $wxh | sed 's/x.*//g' )"
h="$( echo $wxh | sed 's/^.*x//g' )"
w="$(expr $w + 0 )"
[ "$?" -ne 0 ] && dnuyou
h="$(expr $h + 0 )"
[ "$?" -ne 0 ] && dnuyou
if [ "$w" -lt 480 ] || [ "$w" -gt 9600 ] ; then oor ; fi
if [ "$h" -lt 480 ] || [ "$h" -gt 9600 ] ; then oor ; fi
sed -i "s/^geometry.*/geometry=$wxh/g" ~/.vnc/config
echo "Default screen will be $wxh when you re-launch alaterm."
##
EOC
}

create_mimeappsList() { # In /usr/local/scripts.
cat << 'EOC' > mimeapps-list # No hyphen. Quoted marker.
#!/bin/bash
# File /usr/local/scripts/mimeapps-list created by installer script.
# This selects the simplest default application for the indicated mimetypes,
# In cases where a mimetype might have several choices.
# If a mimetype has only one choice, or choice is indifferent, then it is not listed here.
thisfile="/home/.config/mimeapps.list"
echo "[Default Applications]" > "$thisfile"
if [ -f /usr/bin/ghex ] ; then # Hex editor. Use only if necessary!
	echo "application/x-sharedlib=org.gnome.GHex.desktop;" >> "$thisfile"
fi
if [ -f /usr/bin/leafpad ] ; then # Simple plain text editor.
	echo "inode/x-corrupted=leafpad.desktop;" >> "$thisfile"
	echo "text/plain=leafpad.desktop;" >> "$thisfile"
fi
if [ -f /usr/bin/evince ] ; then # Evince is named Document Viewer in the Menu.
	echo "application/illustrator=org.gnome.Evince.desktop;" >> "$thisfile"
	echo "application/pdf=org.gnome.Evince.desktop;" >> "$thisfile"
	echo "application/postscript=org.gnome.Evince.desktop;" >> "$thisfile"
	echo "image/x-eps=org.gnome.Evince.desktop;" >> "$thisfile"
fi
if [ -f /usr/bin/libreoffice ] ; then
	echo "application/vnd.corel-draw=libreoffice-draw.desktop;" >> "$thisfile"
	echo "image/x-wmf=libreoffice-draw.desktop;" >> "$thisfile"
fi
if [ -f /usr/bin/font-viewer ] ; then # simple font viewer.
	echo "application/x-font-otf=org.gnome.font-viewer.desktop;" >> "$thisfile"
	echo "application/x-font-pcf=org.gnome.font-viewer.desktop;" >> "$thisfile"
	echo "application/x-font-ttf=org.gnome.font-viewer.desktop;" >> "$thisfile"
	echo "application/x-font-type1=org.gnome.font-viewer.desktop;" >> "$thisfile"
	echo "font/otf=org.gnome.font-viewer.desktop;" >> "$thisfile"
	echo "font/ttf=org.gnome.font-viewer.desktop;" >> "$thisfile"
fi
if [ -f /usr/bin/gpicview ] ; then # Simple image viewer.
	echo "image/bmp=gpicview.desktop;" >> "$thisfile"
	echo "image/gif=gpicview.desktop;" >> "$thisfile"
	echo "image/jpeg=gpicview.desktop;" >> "$thisfile"
	echo "image/png=gpicview.desktop;" >> "$thisfile"
	echo "image/svg+xml=gpicview.desktop;" >> "$thisfile"
	echo "image/tiff=gpicview.desktop;" >> "$thisfile"
	echo "image/x-pcx=gpicview.desktop;" >> "$thisfile"
	echo "image/x-portable-bitmap=gpicview.desktop;" >> "$thisfile"
	echo "image/x-portable-graymap=gpicview.desktop;" >> "$thisfile"
	echo "image/x-portable-greymap=gpicview.desktop;" >> "$thisfile"
	echo "image/x-portable-pixmap=gpicview.desktop;" >> "$thisfile"
	echo "image/x-tga=gpicview.desktop;" >> "$thisfile"
	echo "image/heic=gpicview.desktop;" >> "$thisfile"
	echo "image/heif=gpicview.desktop;" >> "$thisfile"
if [ -f /usr/bin/netsurf ] ; then # Browser.
	echo "application/xml=netsurf.desktop;" >> "$thisfile"
	echo "text/html=netsurf.desktop;" >> "$thisfile"
fi
##
EOC
}

create_mimeappslistHook() { # In /etc/pacman.d/hooks/
cat << EOC > mimeappslist.hook # No hyphen. Unquoted marker.
[Trigger]
Type = File
Operation = Install
Operation = Upgrade
Operation = Remove
Target = *

[Action]
Description = Specifying default applications...
When = PostTransaction
Exec = /usr/local/scripts/mimeapps-list
EOC
}

configure_desktop() { # In $alatermTop/home.
	h="$alatermTop/home"
	if [ -f .config/openbox/lxde-rc.xml ] ; then
		cd .config/openbox
		sed -i 's/<number>2<\/number>/<number>1<\/number>/g' lxde-rc.xml 2>/dev/null
		cd "$h"
	fi
	if [ ! -f .config/pcmanfm/LXDE/desktop-items-0.conf ] ; then
		mkdir -p .config/pcmanfm/LXDE
		cd .config/pcmanfm/LXDE
		sed -i 's/show_trash.*/show_trash=0/g' desktop-items-0.conf 2>/dev/null
		sed -i 's/show_documents.*/show_documents=0/g' desktop-items-0.conf 2>/dev/null
		sed -i 's/show_mounts.*/show_mounts=0/g' desktop-items-0.conf 2>/dev/null
		sed -i 's/show_wm_menu.*/show_wm_menu=0/g' desktop-items-0.conf 2>/dev/null
		sed -i 's/desktop_font.*/desktop_font=Sans 12/g' desktop-items-0.conf 2>/dev/null
		cd "$h"
	fi
	if [ ! -f .config/libfm/libfm.conf ] ; then
		mkdir -p .config/libfm
		cd .config/libfm
		sed -i '/.*utoremove.*/d' libfm.conf 2>/dev/null
		sed -i 's/no_usb_trash.*/no_usb_trash=1/g' libfm.conf 2>/dev/null
		sed -i 's/places_home.*/places_home=1/g' libfm.conf 2>/dev/null
		sed -i 's/places_desktop.*/places_desktop=1/g' libfm.conf 2>/dev/null
		sed -i 's/places_unmounted.*/places_unbmounted=0/g' libfm.conf 2>/dev/null
		sed -i 's/places_network.*/places_network=0/g' libfm.conf 2>/dev/null
		sed -i 's/places_root.*/places_root=0/g' libfm.conf 2>/dev/null
		sed -i 's/places_computer.*/places_computer=0/g' libfm.conf 2>/dev/null
		sed -i 's/places_trash.*/places_trash=0/g' libfm.conf 2>/dev/null
		sed -i 's/places_applications.*/places_applications=1/g' libfm.conf 2>/dev/null
		cd "$h"
	fi
	##### Edit ~/.config/openbox/menu.xml
}

create_configPanel() { # In $alatermTop/home.
	# This configures items appearing on the taskbar, removes logout button, and adds help to the menu.
	# Rationale: The default LXDE configuration provides widgets and menu items that are inapplicable here.
	local panels="$alatermTop/home/.config/lxpanel/LXDE/panels"
	mkdir -p "$panels"
	cd "$panels"
	local t="\n "
	local f="\n   "
	local s="\n     "
	local helpicon="/usr/share/icons/Adwaita/64x64/categories/system-help-symbolic.symbolic.png"
	local lxdebackground="/usr/share/lxpanel/images/background.png"
	local lxdeicon="/usr/share/lxde/images/lxde-icon.png"
	rm -f panel
	printf "# File: /home/.config/lxpanel/LXDE/panels/panel\n" >> panel
	printf "# Use preferences dialog in menu to adjust config when you can.\n\n" >> panel
	printf "Global {$t edge=bottom$t align=left$t margin=0$t widthtype=percent$t width=100$t height=26" >> panel
	printf "$t transparent=0$t tintcolor=#000000$t alpha=0$t setdocktype=1$t setpartialstrut=1" >> panel
	printf "$t autohide=0$t heightwhenhidden=0$t usefontcolor=1$t fontcolor=#ffffff" >> panel
	printf "$t background=1$t backgroundfile=$lxdebackground\n}" >> panel
	printf "\nPlugin {$t type=space$t Config {$f Size=2$t }\n}" >> panel
	printf "\nPlugin {$t type=menu$t Config {$f image=$lxdeicon$f system {$f }$f separator {$f }" >> panel
	printf "$f item {$s image=$helpicon$s name=HELP$s action=netsurf /usr/local/help-alaterm.html$f }$t }\n}" >> panel
	printf "\nPlugin {$t type=space$t Config {$f Size=6$t }\n}" >> panel
	printf "\nPlugin {$t type=launchbar$t Config {$f Button {$s id=pcmanfm.desktop$f }$t }\n}" >> panel
	printf "\nPlugin {$t type=space$t Config {$f Size=111$t }\n}" >> panel
	printf "\nPlugin {$t type=taskbar$t expand=1$t Config {$f tooltips=1$f IconsOnly=0$f AcceptSkipPager=1" >> panel
	printf "$f ShowIconified=1$f ShowMapped=1$f ShowAllDesks=0$f UseMouseWheel=1$f UseUrgencyHint=1" >> panel
	printf "$f FlatButton=0$f MaxTaskWidth=150$f spacing=1$t }\n}" >> panel
}

create_configMenusL() { # In $alatermTop/home/.config/menus
cat << 'EOC' > lxde-applications.menu # No hyphen. Quoted marker.
<!DOCTYPE Menu PUBLIC '-//freedesktop//DTD Menu 1.0//EN'
 'http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd'>
<Menu>
    <Name>Applications</Name>
    <MergeFile type='parent'>/etc/xgd/menus/lxde-applications.menu</MergeFile>
</Menu>
EOC
}

create_bookmarks() { # In /home.
	echo "file:///sdcard Android Shared" > .gtk-bookmarks
	echo "file:///storage Removable Media" >> .gtk-bookmarks
	echo "file://$HOME Termux Home" >> .gtk-bookmarks
	echo "trash:/// Trash" >> .gtk-bookmarks
}

download_help() { # In /usr/local
        wget https://raw.githubusercontent.com/cargocultprog/alaterm/master/help-alaterm.html
        if [ "$?" -ne 0 ] ; then
                echo "Unable to download the help file. Not a fatal error. Continuing..."
        else
		gotHelp="yes"
		echo "gotHelp=\"yes\"" >> "$alatermTop/status"
	fi
}


if [ "$nextPart" -eq 7 ] ; then
	cd "$alatermTop/home"
	configure_desktop
	create_configPanel
	create_bookmarks
	mkdir -p "$alatermTop/home/.config/menus"
	cd "$alatermTop/home/.config/menus"
	create_configMenusL
	mkdir -p "$alatermTop/home/.local/share/applications"
	mkdir -p "$alatermTop/usr/local/scripts"
	cd "$alatermTop/usr/local/scripts"
	create_banMenuItems
	chmod 755 ban-menu-items
	create_mimeappsList
	chmod 755 mimeapps-list
	create_defaultResolution
	chmod 755 default-resolution
	if [ "$gotHelp" != "yes" ] ; then
		cd "$alatermTop/usr/local"
		download_help
		chmod 666 help-alaterm.html
	fi
	cd "$alatermTop/etc/pacman.d/hooks"
	create_banmenuitemsHook
	create_mimeappslistHook
	cd "$alatermTop"
	echo "Almost done..."
	let nextPart=8
	echo -e "let nextPart=8" >> status
fi


