# Part of the alaterm project, https://github.com/cargocultprog/alaterm/
# This file is: https://raw.githubusercontent.com/cargocultprog/alaterm/master/01-alaterm.bash

echo "$(caller)" | grep -F 00-alaterm.bash >/dev/null 2>&1
if [ "$?" -ne 0 ] ; then
echo "Script 01-alaterm.bash is not stand-alone."
echo "It must be sourced in sequence from 00-alaterm.bash."
echo "Exit." ; exit 1
fi


##############################################################################
## INSTALLER PART 01. Installer: Download Arch Linux ARM.
##############################################################################


select_architecture() { # Must be ARM processor, running Android.
	if [ "$CPUABI" = "$CPUABI7" ] ; then
		local gotCheet="$(getprop ro.product.device)" >/dev/null 2>&1
		if [[ "$gotCheet" =~ _cheet ]] ; then # Chromebook: eve_cheets
			archAr="ArchLinuxARM-armv7-chromebook-latest.tar.gz"
		else
			archAr="ArchLinuxARM-armv7-latest.tar.gz"
		fi
	elif [ "$CPUABI" = "$CPUABI8" ] ; then
		archAr="ArchLinuxARM-aarch64-latest.tar.gz"
	elif [ "$CPUABI" = "$CPUABIalt" ] ; then
		archAr="$archivealt"
	else
		echo -e "$PROBLEM Did not match device to compatible ABI."
		echo "Device must have an ARM processor, not Intel or AMD."
		echo "Must run Android 8 or later, not Windows or iOS."
		echo "Either 32-bit or 64-bit, kernel 4 or later."
		echo "Maybe the architecture is newer that the ones known?"
		echo "If that is the case, there is a possible solution:"
		echo "Check online with the Arch Linux ARM project."
		echo "If there is a newer architecture, edit this script."
		echo "Look near the top of script, for variables CPUABI-alt."
		echo "Also look for archive-alt."
		echo "Edit as necessary. Then try the edited script."
		echo -e "If that fails, then there is no other solution.\n"
		exit 1
	fi
}

find_localArchive() { # If archive and md5 in same directory as this script.
	if [ "$partialArchive" = "yes" ] ; then
		localArchive="no"
	elif [ -f "$alatermTop/$archAr" ] && [ -f "$alatermTop/$archAr.md5" ] ; then
		localArchive="yes"
	fi
}

# When the os.archlinuxarm.org web page is requested by wget,
# the downloaded file is HTML, not very useful. Tossed to /dev/null.
# But wget writes its log to stderr unless redirected by the -o option.
# Here, -o captures the log as file archMirrorInfo.
# The responding server, which was chosen via geolocation,
# is on the line beginning with Location:
# and can be isolated as the second entry on that line, using awk.
select_geoMirror() {
	check_connection os.archlinuxarm.org
	touch archMirrorInfo # File must exist before wget can write there.
	local how="--tries=3 --waitretry=10 os.archlinuxarm.org"
	wget -v -O /dev/null -o archMirrorInfo $how
	if [ "$?" -eq 0 ] ; then
		tMirror="$(grep Location: archMirrorInfo | awk {'print $2'})"
		echo -e "Using geographically chosen mirror $tMirror\n"
	else
		echo "Was unable to contact geographic mirror list. Instead:"
		select_otherMirror
	fi
	rm -f archMirrorInfo
}

select_otherMirror() { # If previous selection fails.
	echo "You may manually select a mirror from this short list."
	echo "Language does not matter. Your choices are:"
	echo "  1 = Aachen, Germany."
	echo "  2 = Miami, Florida, USA"
	echo "  3 = Sao Paolo, Brazil"
	echo "  4 = Johannesburg, South Africa"
	echo "  5 = Sydney, Australia"
	echo "  6 = New Taipei City, Taiwan"
	echo "  7 = Budapest, Hungary"
	echo "  Anything else will do nothing, and exit the script."
	printf "Now $enter your choice [1-7] : " ; read readvar
	case "$readvar" in
		1 ) tMirror="de3.mirror.archlinuxarm.org" ;;
		2 ) tMirror="fl.us.mirror.archlinuxarm.org" ;;
		3 ) tMirror="br2.mirror.archlinuxarm.org" ;;
		4 ) tMirror="za.mirror.archlinuxarm.org" ;;
		5 ) tMirror="au.mirror.archlinuxarm.org" ;;
		6 ) tMirror="tw.mirror.archlinuxarm.org" ;;
		7 ) tMirror="hu.mirror.archlinuxarm.org" ;;
		* ) echo "You did not select a mirror. Try again later."
		exit 1 ;;
	esac
	echo -e "Using manually selected mirror $tMirror\n"
}

download_archive() { # Currently in $alatermTop.
	echo -e "Attempting to download $archAr and its md5 file...\n"
	local md="$tMirror/os/$archAr.md5"
	local ar="$tMirror/os/$archAr"
	wget -c --show-progress --tries=4 --waitretry=5 $md $ar
	if [ "$?" -ne 0 ] ; then
		echo -e "$WARNING Download incomplete or unsuccessful."
		echo "Poor Internet connection, server problem, or chance."
		echo "Here are your choices:"
		echo "  r = Retry now. Might work, might not."
		echo "      Retains partial download. Completed if possible."
		echo "  m = Manually choose different mirror, and try again."
		echo "      Discards partial download. Gets fresh download."
		echo "  x = Exit script. Wait awhile, and try again."
		echo "      Retains partial download. Completed if possible."
		while true ; do
			printf "Now $enter your choice. [r|m|x] : " ; read rv
			case "$rv" in
				r*|R* ) retry_downloadNow ; break ;;
				m*|M* ) select_otherMirror ; break ;;
				x|X ) echo "Will resume download later."
				echo "partialArchive=\"yes\"" >> status
				exit 1 ; break ;;
				* ) echo "No default. You must choose." ;;
			esac
		done
	else echo "partialArchive=\"no\"" >> status
	fi
}

retry_downloadNow() { # Currently in $alatermTop.
	echo "Re-try of current mirror..."
	sleep 4
	download_archive
}

check_archive() { # Currently in $alatermTop.
	echo "Now checking md5 sum..."
	if md5sum -c "$archAr.md5" >/dev/null ; then
		echo -e "Successful md5 check. Continuing...\n"
	else
		echo -e "$PROBLEM Failed md5 check. Cannot continue."
		if [ "$localArchive" = "yes" ] ; then
			echo "Perhaps your stored archive was incomplete."
		else
			echo "Wait a few minutes and re-try."
		fi
		echo -e "Bad files removed. Re-try for fresh download.\n"
		rm -f "$archAr" "$archAr.md5" 2>/dev/null # Discard.
		exit 1
	fi
}


if [ "$nextPart" -eq 1 ] ; then
	cd "$alatermTop"
	select_architecture
	find_localArchive
	if [ "$localArchive" = "yes" ] ; then
		echo "Found the required archive and md5 already downloaded."
		check_archive
	else
		select_geoMirror # Allows manual choice, if geo fails.
		download_archive
		check_archive
		chosenMirror="$tMirror"
	fi
	sleep .5
	echo -e "archAr=\"$archAr\"" >> status
	echo -e "localArchive=\"$localArchive\"" >> status
	echo -e "chosenMirror=\"$chosenMirror\"" >> status
	let nextPart=2
	echo -e "let nextPart=2" >> status
fi


