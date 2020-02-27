# Part of the alaterm project, https://github.com/cargocultprog/alaterm/
# This file is: https://raw.githubusercontent.com/cargocultprog/alaterm/master/08-alaterm.bash

echo "$(caller)" | grep -F 00-alaterm.bash >/dev/null 2>&1
if [ "$?" -ne 0 ] ; then
echo "Script 08-alaterm.bash is not stand-alone."
echo "It must be sourced in sequence from 00-alaterm.bash."
echo "Exit." ; exit 1
fi


##############################################################################
## INSTALLER PART 08. Create launch script, and finish.
##############################################################################


create_launchCommand() {
cat << EOC > "$launchCommand" # No hyphen. Unquoted marker.
#!/bin/bash
# This is the launch command for Alaterm, Arch Linux ARM in Termux.
#
construct_prsUser() { # Tells Termux how to launch Arch.
	prsUser="proot --kill-on-exit --link2symlink -v -1 -0 -r $archTop " # zero
	prsUser+="-b /proc -b /system -b /sys -b /dev -b /data -b /vendor "
	[ ! -r /dev/ashmem ] && prsUser+="-b $archTop/tmp:/dev/ashmem " # Probably OK as-is.
	[ ! -r /dev/shm ] && prsUser+="-b $archTop/tmp:/dev/shm " # Probably does not exist, but is expected.
	[ ! -r /proc/stat ] && prsUser+="-b $archTop/var/binds/fakePS:/proc/stat "
	[ ! -r /proc/version ] && prsUser+="-b $archTop/var/binds/fakePV:/proc/version "
	[ -d /sdcard ] && prsUser+="-b /sdcard "
	[ -d /storage ] && prsUser+="-b /storage "
	prsUser+="-b /proc/self/fd/0:/dev/stdin -b /proc/self/fd/1:/dev/stdout -b /proc/self/fd/2:/dev/stderr "
	prsUser+="-w /home "
	prsUser+="/usr/bin/env - TERM=$TERM HOME=/home "
	prsUser+="/bin/su -l user"
}
query_vncserver() { # Arch vncserver conflicts with Termux vncserver.
	# It may be that Termux and Arch can run independent instances of vncserver,
	# because they use different executables, and could use different localhost ports.
	# That would require fancy configuration in both Termux and Arch.
	# But the technology is over my head, and I cannot think of a good reason
	# for having two servers. So this script does not attempt to do it.
	hash vncserver >/dev/null 2>&1
	if [ "$?" -eq 0 ] ; then
		local vrps="$( echo "$(vncserver -list)" | sed 's/.*://g' | sed 's/\s.*$//g' )"
		local vrpn="$( echo $vrps | grep -Eo '[0-9]{1}' )" >/dev/null 2>&1
		if [ "$?" -eq 0 ] ; then # Termux vncserver is on.
			echo -e "$WARNING Termux has its own vncserver active."
			echo "It will conflict with the vncserver launched by Arch."
			echo "What do you wish to do?"
			echo "  k = Kill the Termux vncserver, then continue to launch Arch."
			echo "  x = Exit script. Termux vncserver remains on. Arch will not launch."
			while true ; do
				printf "Now $enter your choice [k|X] : " ; read readvar
				case "$readvar" in
					k*|K* ) vncserver -kill :$vrpn >/dev/null 2>&1
					if [ "$?" -eq 0 ] ; then
						echo "Termux vncserver killed. Continuing to Arch..."
					else
						echo "$PROBLEM Unable to automatically kill the Termux vncserver."
						echo "You may kill it manually, then try again."
						exit 1
					fi
					break ;;
					x|X ) echo "Termux server remains on. Arch will not launch."
					exit 1 ; break ;;
					* ) echo "No default. Choose k or x." ;;
				esac
			done
		fi
	fi
}
query_vncserver
[ "$archTop" = "" ] && archTop=/data/data/com.termux/archx # Developer use.
source "$archTop/status"
hereiam="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$hereiam/10-preparedesktop.bash"
source "$hereiam/11-scripts.bash"
archstatnow="$(stat --format '%a' $archTop)"
if [ "$archstatnow" = "100" ] ; then
	chmod 700 "$archTop"
	echo "INFO: The last time you used Arch, you did not logout correctly."
	echo "That caused a problem. It has now been fixed automatically."
	echo "This launch script will now exit. You may re-launch it."
	echo "Or, if you think the problem was caused by something else,"
	echo "You can use Termux to fix Arch files, before launching Arch."
	exit 1
fi
chmod 100 "$archTop" # Makes Arch / invisible in pcmanfm.
construct_prsUser
echo "unset LD_PRELOAD" > "$HOME/prsTmp"
echo "exec $prsUser" >> "$HOME/prsTmp" # Termux home, not Arch /home.
bash "$HOME/prsTmp" # Launches Arch.
rm -f "$HOME/prsTmp" # After Arch logout.
chmod 700 "$archTop" # Restores ability to edit Arch from Termux.
echo -e "\e[1;33mYou have left Arch, and are now in Termux.\e[0m\n"
##
EOC
}


if [ "$nextPart" = 8 ] ; then
	cd ~
	create_launchCommand
	chmod 755 "$launchCommand"
	cp "$launchCommand" "$PREFIX/bin"
	mv "$launchCommand" "$archTop"
	echo -e "\n\e[1;92mDONE. You can now launch Alaterm:  $launchCommand\e[0m\n"
	let nextPart=9
	echo "let nextPart=9" >> "$archTop/status"
fi



