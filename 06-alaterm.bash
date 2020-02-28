# Part of the alaterm project, https://github.com/cargocultprog/alaterm/
# This file is: https://raw.githubusercontent.com/cargocultprog/alaterm/master/06-alaterm.bash

echo "$(caller)" | grep -F 00-alaterm.bash >/dev/null 2>&1
if [ "$?" -ne 0 ] ; then
echo "Script 06-alaterm.bash is not stand-alone."
echo "It must be sourced in sequence from 00-alaterm.bash."
echo "Exit." ; exit 1
fi


##############################################################################
## INSTALLER PART 06. Get Arch Linux ARM packages for the LXDE Desktop.
##############################################################################


construct_prsUser() { # Tells Termux how to launch alaterm.
	prsUser="proot --kill-on-exit --link2symlink -v -1 -0 -r $alatermTop " # zero
	prsUser+="-b /proc -b /system -b /sys -b /dev -b /data -b /vendor "
	[ ! -r /dev/ashmem ] && prsUser+="-b $alatermTop/tmp:/dev/ashmem " # Probably OK as-is.
	[ ! -r /dev/shm ] && prsUser+="-b $alatermTop/tmp:/dev/shm " # Probably does not exist, but is expected.
	[ ! -r /proc/stat ] && prsUser+="-b $alatermTop/var/binds/fakePS:/proc/stat "
	[ ! -r /proc/version ] && prsUser+="-b $alatermTop/var/binds/fakePV:/proc/version "
	[ -d /sdcard ] && prsUser+="-b /sdcard "
	[ -d /storage ] && prsUser+="-b /storage "
	prsUser+="-b /proc/self/fd/0:/dev/stdin -b /proc/self/fd/1:/dev/stdout -b /proc/self/fd/2:/dev/stderr "
	prsUser+="-w /home "
	prsUser+="/usr/bin/env - TERM=$TERM HOME=/home "
	prsUser+="/bin/su -l user"
}

edit_etcProfile() {
	echo "# Added by installer script:" >> "$alatermTop/etc/profile"
	echo "PATH=/usr/local/scripts:\$PATH:/data/data/com.termux/files/usr/bin" >> "$alatermTop/etc/profile"
	echo "export PATH" >> "$alatermTop/etc/profile"
	echo "##" >> "$alatermTop/etc/profile"
}

recreate_userBashProfile() { # In /home.
cat << 'EOC' > .bash_profile # No hyphen. Quoted marker.
# File /home/.bash_profile created by installation script.
# Note that certain definitions, for all users, are in /etc/bash.bashrc.
# Normally, you do not change anything in this file.
# User customization goes in file /home/.bashrc.
rm -r -f ~/.cache
mkdir -p ~/.cache
echo "This ~/.cache directory is emptied at each login." > ~/.cache/1-README
echo "Do not put anything here, if you need it later." >> ~/.cache/1-README
echo "Anything in ~/.cache was created at current login" >> ~/.cache/1-README
echo "and may increase during your current session." >> ~/.cache/1-README
rm -f ~/.bash_history
rm -f ~/.cache/lxsession/LXDE/run.log
if [ -f ~/.Xauthority ] ; then
        rm -f ~/.Xauthority
        touch ~/.Xauthority
fi
if [ -f ~/.X11authority ] ; then
        rm -f ~/.X11authority
        touch ~/.X11authority
fi
rm -f ~/.ICEauthority
rm -f ~/.vnc/localhost*
export DISPLAY=:1
echo -e "\e[1;92mStarting alaterm. Just a moment...\e[0m"
ban-menu-items 2>/dev/null
edit-mimeinfo-cache 2>/dev/null
if [ -w "/bin/vncserver" ] ; then
	[ -f "/bin/vncserver.bak" ] || cp "/bin/vncserver" "/bin/vncserver.bak"
	if [ -f ~/.vnc/xstartup ] ; then
		newhost="New \$host:\$displayNumber at 127.0.0.1:590\$displayNumber.\\n"
		newhost+="LXDE Desktop is visible in VNC Viewer app. Password: password\\n"
		newhost+="To leave alaterm and return to Termux: logout\\\n"
		sed -i "/.*warn.*desktop is.*/c\warn \"$newhost\";" "/bin/vncserver"
	fi
	sed -i '/.*warn.*applications specified in.*/c\warn "\\n";' "/bin/vncserver"
	sed -i '/.*warn.*og file is.*/c\warn "\\n";' "/bin/vncserver"
	sed -i 's/^warn "\\n";//g' "/bin/vncserver"
fi
printf "\e[92m"
vncserver
printf "\e[0m"
sleep .2
# ps and top work best if the Android system is used:
if [ -f /usr/bin/ps ] && [ ! -L /usr/bin/ps ] ; then
	mv /usr/bin/ps /usr/bin/ps.arch
	ln -s /system/bin/ps /usr/bin/ps
fi
if [ -f /usr/bin/top ] && [ ! -L /usr/bin/top ] ; then
	mv /usr/bin/top /usr/bin/top.arch
	ln -s /system/bin/top /usr/bin/top
fi
#
[ -f ~/.bashrc ] && . ~/.bashrc # Ensure that .bashrc is sourced both login and non-login.
#
# Normally, you should not change this file.
# If you have any user-specific modifications, put them in /home/.bashrc.
##
EOC
}

recreate_userBashrc() { # In /home.
cat << 'EOC' > .bashrc # No hyphen, quoted marker.
# File /home/.bashrc created by installation script.
# Most initialization code is in file /etc/bash.bashrc or ~/.bash_profile.
# But do not edit those files unless absolutely necessary.
export PS1='\e[1;38;5;75m[alaterm:$(whoami)@\W]$\e[0m '
##
# If you have any custom login code, put it below:


##
EOC
}

create_etcBashlogout() { # In /etc.
cat << EOC > bash.bash_logout # No hyphen. Unquoted marker.
# File /etc/bash.bash_logout created by installer script.
chmod 755 "$alatermTop" # Restores ability to edit alaterm from Termux.
echo -e "\e[1;33mYou have left alaterm, and are now in Termux.\e[0m\n"
##
EOC
}

if [ "$nextPart" -eq 6 ] ; then
	cd "$HOME" # Termux home. Ensures being outside alaterm.
	echo "Creating the LXDE graphical desktop..."
	construct_prsUser
	echo "unset LD_PRELOAD" > "$HOME/prsTmp"
	echo "exec $prsUser" >> "$HOME/prsTmp" # Termux home, not alaterm /home.
	bash "$HOME/prsTmp"
	if [ "$?" -ne 0 ] ; then
		echo -e "$PROBLEM Code $?. Desktop preparation was interrupted."
		echo "Poor Internet connection, or server maintenance."
		echo "Wait awhile, then try again. Script resumes where it left off."
		rm -f "$HOME/prsTmp"
	exit 1
	fi
	rm -f "$HOME/prsTmp"
	cd "$alatermTop/home"
	edit_etcProfile
	recreate_userBashProfile
	recreate_userBashrc
	cp .bash_profile "$alatermTop/etc/skel"
	cp .bashrc "$alatermTop/etc/skel"
	cd "$alatermTop/etc"
	create_etcBashlogout
	chmod 755 bash.bash_logout
	cd "$alatermTop"
	let nextPart=7
	echo "let nextPart=7" >> status
fi


