# Part of the alaterm project, https://github.com/cargocultprog/alaterm/
# This file is: https://raw.githubusercontent.com/cargocultprog/alaterm/master/02-alaterm.bash

echo "$(caller)" | grep -F 00-alaterm.bash >/dev/null 2>&1
if [ "$?" -ne 0 ] ; then
echo "Script 02-alaterm.bash is not stand-alone."
echo "It must be sourced in sequence from 00-alaterm.bash."
echo "Exit." ; exit 1
fi


##############################################################################
## INSTALLER PART 02. Unpack the Arch archive in proot.
##############################################################################


## Unpack the archive:
unpack_archive() { # Currently in $archTop.
	# Create directories that may be missing from the archive:
	echo "Now unpacking the Arch archive. This is a lengthy operation."
	echo "There may be 5 to 10 minutes without feedback here."
	echo -e "\e[1;92mThe script did not hang. Be patient...\e[0m\n"
	unset LD_PRELOAD
	local ouch="no"
	proot --link2symlink -v -1 -0 bsdtar -xpf "$archAr"
	[ "$?" -ne 0 ] && ouch="yes"
	export LD_PRELOAD=$PREFIX/lib/libtermux-exec.so
	if [ "$ouch" = "yes" ] ; then
		echo -e "$PROBLEM Something went wrong during unpack."
		echo "Are you sure you have enough free space within Termux?"
		echo "Did you move the downloaded archive?"
		echo -e "Whatever the cause, this script cannot continue."
		echo "The problematic archive and md5 have been removed.\n"
		rm -f "$archTop/$archAr" ; rm -f "$archTop/$archAr.md5"
		exit 1
	fi
}

copy_mirror() { # Currently in $archTop.
	# The download mirror for *tar.gz archive is known-good. Tell Arch:
	if [ "$localArchive" = "no" ] && [ "$chosenMirror" != "notSelected" ]
	then
		echo "# Mirror when Arch archive was downloaded:" > mirrorlist
		echo -e "Server = $chosenMirror\$arch/\$repo\n" >> mirrorlist
		if [ -f "etc/pacman.d/mirrorlist" ] ; then
			cat "etc/pacman.d/mirrorlist" >> mirrorlist
		fi
		mv mirrorlist "etc/pacman.d/"
	fi
}

copy_resolvConf() { # Currently in $archTop.
	mkdir -p "run/systemd/resolve"
	if [ -s "$PREFIX/etc/resolv.conf" ] ; then # Use whatever Termux uses.
		cp -f "$PREFIX/etc/resolv.conf" "run/systemd/resolve/"
	else # Use Google DNS.
		echo "nameserver 8.8.8.8" > "run/systemd/resolve/resolv.conf"
		echo "nameserver 8.8.4.4" >> "run/systemd/resolve/resolv.conf"
	fi
}

create_optReadme() { # In $archTop/opt.
	echo -e "# File $archTop/opt/README created by installation script.\n" > README
	echo "# Anything within /opt is not part of the Arch distribution.\n" >> README
	echo "# If you compile code, you may install to /usr/local or to /opt." >> README
	echo -e "# PATH includes /usr/local, but not /opt unless you add it.\n\n##" >> README
}

create_usrLocalReadme() { # In $archTop/usr/local.
	echo -e "# File $archTop/usr/local/README created by installation script.\n" > README
	echo "# Directory /usr/local is empty when unpacked from the Arch archive." >> README
	echo "# The installer script added the scripts and HELP-FILES directories." >> README
	echo "# The scripts directory is required. You may add to it, but not delete it.\n" >> README
	echo "# If you compile code, you may install to /usr/local or to /opt." >> README
	echo -e "# PATH includes /usr/local, but not /opt unless you add it.\n\n##" >> README
}

create_usrLocalScriptsReadme() { # In $archTop/usr/local/scripts.
	echo -e "# File $archTop/usr/local/scripts/README created by installation script.\n" > README
	echo "# The installer placed a number of useful scripts in this directory." >> README
	echo "Some are invoked silently and automatically during certain operations." >> README
	echo "Others are utilities that you may optionally run from time to time." >> README
	echo "You may add your own scripts here, but do not delete the ones installed." >> README
	echo "This directory is on the PATH environment.\n\n##" >> README
}


if [ "$nextPart" -eq 2 ] ; then
	cd "$archTop"
	if [ -f "$archAr" ] ; then
		unpack_archive
	else
		echo -e "$PROBLEM Where did the downloaded archive go?\n"
		exit 1
	fi
	cd "$archTop"
	mkdir -p etc/pacman.d/hooks
	mkdir -p sys
	mkdir -p system
	mkdir -p "$archTop/opt"
	cd "$archTop/opt"
	create_optReadme
	mkdir -p "$archTop/usr/local/scripts"
	cd "$archTop/usr/local/scripts"
	create_usrLocalScriptsReadme
	cd "$archTop/usr/local"
	create_usrLocalReadme
	cd "$archTop"
	copy_mirror
	copy_resolvConf
	sleep .5
	rm -f "$archAr" ; rm -f "$archAr.md5"
	echo "Successfully unpacked. Continuing..."
	let nextPart=3
	echo -e "let nextPart=3" >> status
fi


