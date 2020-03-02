# Part of the alaterm project, https://github.com/cargocultprog/alaterm/
# This file is: https://raw.githubusercontent.com/cargocultprog/alaterm/master/05-alaterm.bash

echo "$(caller)" | grep -F 00-alaterm.bash >/dev/null 2>&1
if [ "$?" -ne 0 ] ; then
echo "Script 05-alaterm.bash is not stand-alone."
echo "It must be sourced in sequence from 00-alaterm.bash."
echo "Exit." ; exit 1
fi


##############################################################################
## INSTALLER PART 05. /etc/bash.bashrc, root/.bash_profile, root/.bashrc
##############################################################################


construct_prsPre() { # Only used during post-install routines.
	prsPre="proot --kill-on-exit --link2symlink -v -1 -0 -r $alatermTop " # 0 is zero.
	prsPre+="-b /proc -b /dev -b /sys -b /data "
	[ ! -r /dev/ashmem ] && prsPre+="-b $alatermTop/tmp:/dev/ashmem " # Probably OK as-is.
	[ ! -r /dev/shm ] && prsPre+="-b $alatermTop/tmp:/dev/shm " # Probably does not exist, but is expected.
	[ ! -r /proc/stat ] && prsPre+="-b $alatermTop/var/binds/fakePS:/proc/stat "
	[ ! -r /proc/version ] && prsPre+="-b $alatermTop/var/binds/fakePV:/proc/version "
	prsPre+="-w /root "
	prsPre+="/usr/bin/env - TERM=$TERM HOME=/root TMPDIR=/tmp "
	prsPre+="/bin/bash -l"
}

create_etcBashBashrc() { # In /etc. Over-writes original.
cat << EOC > "bash.bashrc" # No hyphen. Unquoted marker.
# File /etc/.bash.bashrc
# Created by installation script. Replaced original file.
export THOME="$HOME" # Termux home directory, seen from within alaterm.
export TUSR="$PREFIX" # This is the usr directory in Termux.
export ALATERMDIR="$alatermTop" # As seen from outside alaterm, by Termux.
export EDITOR=/usr/bin/nano
export BROWSER=/usr/bin/netsurf
export ANDROID_DATA=/data
export ANDROID_ROOT=/system
$(env | grep BOOTCLASSPATH) >/dev/null 2>&1
export BOOTCLASSPATH # Android *.jar files accessible to Termux.
export EXTERNAL_STORAGE=/sdcard # Actually onboard storage, not removable.
export TLDPRE="$PREFIX/lib/libtermux-exec.so" # Termux LD_PRELOAD.
export TMPDIR=/tmp
# Clear left-over tmp:
rm -f /tmp/.*lock*
rm -r -f /tmp/.*X11*
rm -r -f /tmp/*
rm -f /tmp/*
export DISPLAY=:1
shopt -s checkwinsize
# Corrects for overly-enthusiastic removal of unused locales:
touch /usr/share/locale/locale.alias
# Make annoying and useless desktop message go away:
rm -f /etc/xdg/autostart/lxpolkit.desktop
[ -f /usr/bin/lxpolkit ] && mv -f /usr/bin/lxpolkit /usr/bin/lxpolit.bak
# Ensure that /usr/local/bin, /usr/local/scripts, ~/bin, and Termux are in PATH:
echo "\$PATH" | grep "local/bin" >/dev/null 2>&1
if [ "\$?" -ne 0 ] ; then PATH="/usr/local/bin:\$PATH" ; export PATH ; fi
echo "\$PATH" | grep "local/scripts" >/dev/null 2>&1
if [ "\$?" -ne 0 ] ; then PATH="/usr/local/scripts:\$PATH" ; export PATH ; fi
echo "\$PATH" | grep "files/usr/bin" >/dev/null 2>&1
if [ "\$?" -ne 0 ] ; then PATH="\$PATH:/data/data/com.termux/files/usr/bin" ; export PATH ; fi
echo "\$PATH" | grep "\$HOME/bin" >/dev/null 2>&1
if [ "\$?" -ne 0 ] ; then PATH="\$HOME/bin:\$PATH" ; export PATH ; fi
# Aliases:
alias top='/system/bin/top'
alias ps='/system/bin/ps'
alias ls='ls --color=auto'
alias pacman='sudo pacman'
alias fc-cache='sudo fc-cache'
alias vncviewer='echo -e "\e[33mYou need to use the separate VNC Viewer app.\e[0m" \#'
usepacman() {
        echo "In alatermm, use pacman for package management."
}
alias apt='usepacman #'
alias apt-get='usepacman #'
alias aptitude='usepacman #'
alias dpkg='usepacman #'
alias pkg='usepacman #'
##
EOC
}

create_rootBashProfile() { # In /root.
cat << EOC > .bash_profile # No hyphen. Unquoted marker.
# File /root/.bash_profile created by install script.
[ -f ~/.bashrc ] && . ~/.bashrc
EOC
}

## Functions within function.
create_rootBashrc() { # In alaterm /root. Will be replaced later in this script.
cat << 'EOC' > ".bashrc" # No hyphen, quoted marker.
# File /root/.bashrc
# Created by installation script. Over-wrote original.
# Ensure that wakelock is removed if script is interrupted:
preconfSignal() {
	echo -e "PROBLEM. alaterm pre-configuration was interrupted."
	echo -e "Script will exit now. You will be returned to Termux.\n"
	exit 71
}
preconfExit() {
	local badstuff="$?"
	if [ "$badstuff" -ne 0 ] && [ "$badstuff" -ne 71 ] ; then
		echo -e "PROBLEM. Something caused preconfigure to exit early."
	echo -e "Exit code $badstuff."
	echo -e "Script will exit now. You will be returned to Termux.\n"
	fi
}
trap preconfSignal HUP INT TERM QUIT
trap preconfExit EXIT
#
source /status || exit 71
if [ "$localeGenerated" != "yes" ] ; then
	locale-gen
	chmod 644 /etc/environment
	chmod 644 /etc/locale.conf
	echo -e "localeGenerated=\"yes\"" >> /status
fi
cd /etc
if [ -f moto ] ; then
	chmod 666 moto && echo "" > moto && chmod 644 moto
fi
if [ -f motd ] ; then
	chmod 666 motd && echo "" > motd && chmod 644 motd
fi
if [ "$alarmDeleted" != "yes" ] ; then
	cd /home
	[ -d alarm ] && chmod 777 alarm
	rm -r -f alarm 2>/dev/null
	cd /root
	userdel alarm >/dev/null 2>&1
	echo -e "Deleted built-in default user..."
	echo -e "alarmDeleted=\"yes\"" >> /status
fi
cd /root
if [ "$userAdded" != "yes" ] ; then
	# stackoverflow.com q. 2150882 answer by Damien:
	useradd -M -d /home -p $(openssl passwd -1 password) user
	echo -e "Added new user..."
	echo "userAdded=\"yes\"" >> /status
fi
echo "localhost" > /etc/hostname 2>/dev/null # Over-writes existing.
echo "Pre-configuration..."
if [ "$pacmanPopulated" != "yes" ] ; then
	sleep .5
	echo -e "Initializing pacman package manager:\n"
	pacman-key --init && pacman-key --populate archlinuxarm
	if [ "$?" -ne 0 ] ; then
		exit 72
	else
		echo -e "pacmanPopulated=\"yes\"" >> /status
	fi
fi
if [ "$removedUseless" != "yes" ] ; then
	# For bare-metal support, Linux packages are required, but proot is less than bare-metal!
	# Unlike a booted distributing Arch in proot cannot compile kernel modules.
	if [ "$CPUABI" = "$CPUABI7" ] ; then
		pacman -Rc linux-armv7 linux-firmware --noconfirm >/dev/null 2>&1
	fi
	if [ "$CPUABI" = "$CPUABI8" ] ; then
		pacman -Rc linux-aarch64 linux-firmware --noconfirm >/dev/null 2>&1
	fi
	sleep .5
	pacman -Qdtq | pacman -Rc - --noconfirm >/dev/null 2>&1 # Autoremoves orphan stuff.
	sleep .5
	pacman -Qdtq | pacman -Rc - --noconfirm >/dev/null 2>&1 # Yes, again.
	sleep .5
	if [ "$CPUABI" = "$CPUABI7" ] ; then
		sed -i 's/^#IgnorePkg.*/IgnorePkg = linux-armv7 linux-firmware/g' /etc/pacman.conf
	fi
	if [ "$CPUABI" = "$CPUABI8" ] ; then
		sed -i 's/^#IgnorePkg.*/IgnorePkg = linux-aarch64 linux-firmware/g' /etc/pacman.conf
	fi
	sleep .2
	rm -r -f /boot/*
	rm -r -f /usr/lib/firmware
	rm -r -f /usr/lib/modules
	echo "Removed packages irrelevant in proot..."
	echo -e "removedUseless=\"yes\"" >> /status
fi
if [ "$updgradedArch" != "yes" ] ; then
	sleep .5
	echo -e "Upgrading installed packages:\n"
	pacman -Syuq --noconfirm
	if [ "$?" -ne 0 ] ; then
		exit 73
	else
		echo -e "upgradedArch=\"yes\"" >> /status
	fi
	echo -e "Upgrade complete..."
fi
if [ "$gotSudo" != "yes" ] ; then
	sleep .5
	pacman -Sq --noconfirm sudo
	if [ "$?" -ne 0 ] ; then
		exit 74
	else
		# Add user to sudoers, no password:
		sleep .5
		cd /etc
		if [ -f sudoers ] ; then # File should be there.
			chmod 666 sudoers
			echo -e "Defaults lecture=\"never\"" >> sudoers
			echo -e "Defaults targetpw" >> sudoers
			echo -e "user ALL=\x28ALL\x29 NOPASSWD: ALL" >> sudoers
			chmod 440 sudoers
			echo "Set disable_coredump false" >> sudo.conf
			chmod 644 sudo.conf
		fi
		echo "gotSudo=\"yes\"" >> /status
	fi
	echo "Added sudo..."
	#
	echo "alias pacman='sudo pacman'" >> /etc/bash.bashrc
	echo "alias fc-cache='sudo fc-cache'" >> /etc/bash.bashrc
	echo "alias vncviewer='echo -e \"\e[33mYou need to use the separate VNC Viewer app.\e[0m\" \#'" >> /etc/bash.bashrc
	echo "##" >> /etc/bash.bashrc
fi
sleep 1
logout # Returns to Termux script.
EOC
}
# End functions within function.

recreate_rootBashrc() { # In alaterm /root.
cat << 'EOC' > ".bashrc" # No hyphen, quoted marker.
# File /root/.bashrc
# Created by installation script.
rm -f /root/.bash_history
export PS1='\e[1;38;5;75m[alaterm:\e[1;91mroot\e[1;38;5;75m@\W]#\e[0m '
echo -e "\e[33mOnly use root if necessary. Root is within alaterm, not Android."
echo -e "To leave root and return to ordinary alaterm user:  exit\e[0m"
alias su='exit #'
#
## Your custom commands, if any, go below:

##
EOC
}

create_userBashProfile() { # In /home.
	echo "[ -f ~/.bashrc ] && . ~/.bashrc" > .bash_profile
}

## Functions within function.
create_userBashrc() { # In /home. Used in the next part of script. Then changed.
cat << 'EOC' > .bashrc # No hyphen, quoted marker.
# File $HOME/.bashrc
export PS1='\e[1;38;5;195m[alatermUser@\W]$\e[0m '
export DISPLAY=:1
source /status
getThese="nano wget python python-xdg python2-xdg python2-numpy python2-lxml pygtk tk"
getThese+=" ghostscript tigervnc lxde evince poppler-data pstoedit poppler-glib pkgfile pigz freeglut"
getThese+=" xterm gpicview netsurf leafpad geany geany-plugins ghex man"
getThese+=" gnome-calculator gnome-font-viewer libraw libwmf openexr openjpeg2"
pacman -Ss -q trash-cli >/dev/null # In case this package is unavailable.
if [ "$?" -eq 0 ] ; then
	getThese+=" trash-cli"
	gotTCLI="yes"
else
	gotTCLI="no"
fi
if [ "$gotThem" != "yes" ] ; then
	echo "Downloading new packages for LXDE Desktop..."
	pacman -Sq --noconfirm --needed $getThese
	if [ "$?" -ne 0 ] ; then
		exit 82
	else
		sleep 1
		echo "Completed installation of new packages."
		echo -e "gotThem=\"yes\"" >> /status
	fi
	##### Might want to double-check.
fi
sleep 1
pacman -Rsc lxmusic --noconfirm >/dev/null 2>&1
create_userVncConfig() { # In /home/.vnc.
	echo "# File /home/.vnc/config created by installation script." > config
	echo "# You may edit the following geometry to suit your needs." >> config
	echo "# Format is geometry=widthxheight" >> config
	echo "# where width and height are three or four digit numbers." >> config
	echo "# Landscape mode, like a laptop, has width greater than height." >> config
	echo "# Portrait mode, like a phone, has height greater than width." >> config
	echo "# Default 1280x800 works for many screens in the 8 to 10.1 inch range." >> config
	echo "# This may be less than the full pixel resolution, but same aspect ratio." >> config
	echo "# For example, 1280x800 works with 1920x1200 screens." >> config
	echo "# If you edit the geometry, the result will not immediately appear." >> config
	echo "# It will be activated the next time you launch alaterm." >> config
	echo "# This geometry may be over-ridden by the LXDE Desktop Menu" >> config
	echo "# using Preferences > Monitor Settings." >> config
	echo "# Also see file ~/.config/autostart/lxrandr-autostart.desktop" >> config
	echo "# but do not edit that other file. It is automatically generated." >> config
	echo "# Do not put any space in front of the geometry string." >> config
	echo "" >> config
	echo "geometry=1280x800" >> config
	echo "" >> config
}
create_userVncPassword() { # In /home/.vnc. The VNC password is:  password
	echo -e -n "\xDB\xD8\x3C\xFD\x72\x7A\x14\x58" > passwd
}
create_userVncXstartup() { # In /home/.vnc.
	echo "#!/bin/sh" > xstartup
	echo "# File /home/.vnc/xstartup created by post-install script." >> xstartup
	echo "unset SESSION_MANAGER" >> xstartup
	echo "unset DBUS_SESSION_BUS_ADDRESS" >> xstartup
	echo "if [ -x /etc/X11/xinit/xinitrc ] ; then" >> xstartup
	echo -e "\texec /etc/X11/xinit/xinitrc" >> xstartup
	echo "elif [ -f /etc/X11/xinit/xinitrc ] ; then" >> xstartup
	echo -e "\texec bash /etc/X11/xinit/xinitrc" >> xstartup
	echo "fi" >> xstartup
	echo "if [ -r /home/.Xresources ] ; then" >> xstartup
	echo -e "\thash xrdb" >> xstartup
	echo -e "\t[ \"\$?\" -eq 0 ] && xrdb /home/.Xresources 2>/dev/null" >> xstartup
	echo "fi" >> xstartup
	echo "#" >> xstartup
	echo "startlxde &" >> xstartup
	echo "##" >> xstartup
}
if [ "$configuredVnc" != "yes" ] ; then
	echo "Configuring vncserver."
	mkdir -p /home/.vnc
        cd /home/.vnc
        create_userVncConfig
        create_userVncPassword
        chmod 600 passwd
        create_userVncXstartup
        chmod 755 xstartup
	echo -e "configuredVnc=\"yes\"" >> /status
fi
sleep 0.5
logout # Returns to Termux script.
EOC
}
## End functions within function.


create_trashReadme() { # In /home/.local/share/Trash.
cat << 'EOC' > README-IMPORTANT # No hyphen. Quoted marker
## README-IMPORTANT for TRASH, also known as RUBBISH.
# You do not have a graphical Trash bin. Android blocks it.
# The Trash directory exists. Use these command-line tools:
# To Trash files and/or folders:
trash-put # choose items to be trashed
# To empty Trash. Permanently deletes contents:
trash-empty
# To discover the contents of Trash:
trash-list
# To restore items, after using trash-list:
trash-restore # items to be restored
# To permanently delete specific items,
# without emptying the entire Trash bin:
trash-rm # choose items to be deleted
##
EOC
}


if [ "$nextPart" -eq 5 ] ; then
	mkdir -p "$alatermTop/home/.local/share/applications"
	cd "$alatermTop/etc"
	chmod 666 pacman.conf
	sed -i '/^#Color/s/^#//' pacman.conf 2>/dev/null
	chmod 644 pacman.conf
	chmod 666 bash.bashrc
	create_etcBashBashrc
	chmod 644 bash.bashrc
	cd "$alatermTop/root"
	create_rootBashProfile
	chmod 644 .bash_profile
	create_rootBashrc
	chmod 666 .bashrc
	cd "$HOME" # Termux home. Ensures being outside alaterm.
	construct_prsPre
	echo "unset LD_PRELOAD" > "$HOME/prsTmp"
	echo "exec $prsPre" >> "$HOME/prsTmp" # Termux home, not alaterm /home.
	bash "$HOME/prsTmp"
	ecodeb="$?"
	if [ "$ecodeb" -ne 0 ] ; then
		echo -e "$PROBLEM Code $ecodeb. The alaterm pre-configure was interrupted."
		echo "Poor Internet connection, or server maintenance."
		echo "Wait awhile, then try again. Script resumes where it left off."
		rm -f "$HOME/prsTmp"
		exit 1
	fi
	rm -f "$HOME/prsTmp"
	echo -e "alias pacman='sudo pacman'\n##" >> "$alatermTop/etc/bash.bashrc"
	cd "$alatermTop/root"
	recreate_rootBashrc
	chmod 644 .bashrc
	cd "$alatermTop/etc"
	cd "$alatermTop/home"
	create_userBashProfile
	chmod 666 .bash_profile
	create_userBashrc
	chmod 666 .bashrc
	mkdir -p ".local/share/Trash/files"
	mkdir -p ".local/share/Trash/info"
	if [ "$gotTCLI" = "yes" ] ; then
		cd ".local/share/Trash"
		create_trashReadme
	fi
	cd "$alatermTop"
	mkdir -p var/android/dalvik-cache # Possibly not needed.
	mkdir -p usr/var/android/dalvik-cache # Possibly not needed.
	echo "Pre-configuration done."
	sleep .5
	let nextPart=6
	echo "let nextPart=6" >> status
fi


