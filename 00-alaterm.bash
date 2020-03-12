#!/bin/bash
# Part of the alaterm project, https://github.com/cargocultprog/alaterm/
# This file is: https://raw.githubusercontent.com/cargocultprog/alaterm/master/00-alaterm.bash
declare versionID=1.0.4 # Enhanced March 11, 2020.
# Usage within Termux home on selected Android devices:
# bash alaterm.bash action
#   where action is one of: install remove help
#   abbreviated as: i r h
# Interactive script. Requires meaningful user response from time to time.
# You cannot just launch it and walk away while it works.
#
# Copyright and License at bottom of this file.
#
# * This BASH script installs portions of Arch Linux ARM into the Termux app,
#   for Android-based devices that have an ARM processor.
#   This includes many tablets and Chromebooks, but not all of them.
# * You do not need root access. This script does not enable root access.
# * Installation works with small screens and touchscreen-only devices,
#   but the benefits are best realized when the screen is 10.1 inches or more,
#   and you have a keyboard and mouse.
# * The installation is optimized for ordinary users, rather than programmers.
#   It assumes that you intend to run programs such as GIMP image editor,
#   but you do not intend to setup a file server or upload packages.
# * This is not a dual-boot. Android runs alongside alaterm at all times.
#   For example, Android can play Bluetooth music and connect to the Internet,
#   even while you are using a program such as GIMP in alaterm.
# * If your intended usage is programmer-friendly file server things,
#   then the Termux Arch project by SDRausty is better suited to your needs.
# * This script is compatible only with devices that have an ARM processor,
#   and use the armeabi-v7a or arm64-v8a Android software suite.
#   You do not need to know that info, since it is measured by the script.
#   But if your device does not run Android, or uses an Intel or AMD CPU,
#   then the script will reject your device.
#
##############################################################################
# THESE ARE THE ONLY USER-CUSTOMIZABLE SETTINGS:
# You can install via this script and SDRausty script independently,
# as long as alatermTop and launchCommand are different. OK by default.
# 1. Where alaterm will be installed. Default: installDirectory=alaterm
declare installDirectory=alaterm
#    * In Android, Termux is at /data/data/com.termux directory.
#    * That contains several directories. Among them:
#      /data/data/com.termux/files/usr is where Termux keeps its own programs.
#      /data/data/com.termux/files/home is home, where Termux starts.
#    * If you install to the recommended default location, then
#      /data/data/com.termux/alaterm will be the alaterm / root directory.
#      That root directory will contain alaterm /bin, /etc, /home, and so forth.
#    * The alternative, by SDRausty, installs to Termux home/arch.
#    * Advantage of installing to the default location is that
#      alaterm will not be accidentally removed, if you clean Termux home.
# 2. To launch alaterm from Termux. Default: launchCommand=alaterm
declare launchCommand=alaterm
#    * The alternative script, by SDRausty, uses: startarch
# END OF USER-CUSTOMIZABLE SETTINGS.
##############################################################################
# MAINTAINER NOTE:
# This script recognizes only the armeabi-v7a and arm64-v8a ABI.
# This includes all ARM ABI used as of early 2020, including some Chromebooks.
# No newer ABI have been announced, although this is possible in the future.
# If a newer ABI is released, AND the Arch Linux ARM project has an archive
# compiled for that ABI, then you can attempt to use this script.
# In that case, you will need to edit references to CPUABI, the Arch archive,
# and its md5 checksum. This must be done in all the component scripts.
##############################################################################


# The various portions are broken into several files, processed in order.
# They are NOT stand-alone. They must be processed using this file as master.
# The developer has a trick for debugging the individual files,
# but you, the user, cannot do it that way.

# When each component finishes, it writes info to a status file that is retained.
# In case of problem, it is possible to examine the status file,
# which will show the last component that completed successfully.
# The status file also holds some variables that are read during install.
# If your installation is interrupted, it will resume from where it left off,
# thanks to data automatically read from the status file.

# This script expects an Android file structure, with Termux installed
# in the expected directory. Check this now, and exit if bad.
# Explanation: $termuxTop should be Android /data/data/com.termux, or similar.
declare termuxTop="$HOME/../../" # Highest writeable directory in Termux.
declare pwDir="$PWD"
# Directory containing this script, even if script is called from elsewhere:
# Solution thanks to stackexchange.com question 59895, reply by Dave Dopson.
hereiam="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
declare scriptLocation="$hereiam"
cd "$termuxTop"
termuxTop=`pwd` # Gets the full Android path, without any ../
cd "$pwDir"
declare alatermTop="$termuxTop/$installDirectory"
declare PROBLEM="\e[1;91mPROBLEM.\e[0m" # Bold light red. Use with echo -e
declare WARNING="\e[1;33mWARNING.\e[0m" # Bold yellow. Use with echo -e
declare HELP="\e[1;92mHELP\e[0m" # Bold light green. Use with echo -e
declare enter="\e[1;92menter\e[0m" # Bold light green. Use with echo -e
# If the script cannot write in $termuxTop, then that is a problem:
[ ! -w "$termuxTop" ] && sorry="yes"
# If $termuxTop turns out to be Android root-level, then that is a problem:
[ -w "$termuxTop/acct" ] && sorry="yes"
if [ "$sorry" = "yes" ] ; then
	echo -e "\n$PROBLEM. Termux is not at expected Android location."
	echo "This script cannot install alaterm on your device."
	echo -e "Sorry about that. This script will now exit.\n" ; exit 1
fi

## Show usage, unless exactly one argument provided: i r h v.
show_usage() {
        echo "$(basename $0), version $versionID."
        echo "Installs or removes alaterm within Termux."
	echo "For selected Android devices with ARM processors."
        echo "Usage:  bash $(basename $0) <install|remove|help|version>"
        echo "Exactly one argument required. May abbreviate as: i r h v"
        echo -e "Any choice, except version, gets interactive dialog.\n"
        exit 0
}
[ "$#" -gt 1 ] && show_usage

## What does the user wish to do:
declare actionMode="none"
[[ "$1" =~ ^-*(I|i) ]] && actionMode="install"
[[ "$1" =~ ^-*(R|r) ]] && actionMode="remove"
[[ "$1" =~ ^-*(H|h) ]] && actionMode="help"
[[ "$1" =~ ^-*(V|v) ]] && actionMode="version"
[ "$actionMode" = "version" ] && echo "$(basename $0), version $versionID" && exit 0
[ "$actionMode" = "none" ] && show_usage

## Show help, if requested:
if [ "$actionMode" = "help" ] ; then
	echo "This script installs or removes alaterm: Arch Linux ARM in Termux."
	echo "Your device must run 32-bit or 64-bit Android 8 or later."
	echo "The CPU must be ARM architecture, not Intel or AMD."
	echo "Various screen sizes are supported, with or without touchscreen."
	echo "However, benefits are best with 10.1in screen, keyboard, and mouse."
	echo "At least 3GB internal free space is required for minimal setup."
	echo "Adding useful programs will increase to 4, 5 or more GB."
	echo "Minimum 2GB RAM required. Better with 3GB or more."
	echo "The installation is up-to-date and offers many useful programs."
	echo "Among these are Gimp, Inkscape, LibreOffice, TeXLive with GUI."
	echo "But most audio-video handling should be done with other Android apps."
	echo "This is not a dual-boot. This does not root your device or use root."
	echo "Android runs at all times, so you can multi-task if enough RAM."
	echo "Desktop GUI is LXDE, with menus, right-click capability, and more."
	echo "Keep in mind that your device is not designed for heavy usage!"
	exit 0
fi

## Remove previous installation, if requested.
## Must be same location as the one specified for installatiion:
if [ "$actionMode" = "remove" ] ; then
	if [ ! -d "$alatermTop" ] ; then
		echo -e "$PROBLEM Did not find alaterm at default location $alatermTop."
		echo "Either it was not installed, or was installed  elsewhere."
		echo "If you installed it to a different location, then uninstall manually."
		echo -e "Nothing was removed. This script will now exit.\n"
		exit 1
	else
		echo "Found alaterm at expected location $alatermTop."
		echo "Do you wish to remove it?"
		printf "Now $enter yes or no. Default no. [y|N] : " ; read readvar
		case "$readvar" in
			y*|Y* ) echo "You answered yes. That will remove $alatermTop"
			echo "and also remove any files contained within it."
			printf "Are you sure? Default no. [y|N] : " ; read readnewvar
			case "$readnewvar" in
				y*|Y* ) echo "Now removing prior installation. Takes awhile..."
				rm -r -f "${alatermTop:?}"/* 2>/dev/null
				find  "$alatermTop" -type d -exec chmod 700 {} \; 2>/dev/null
				rm -r -f "$alatermTop" 2>/dev/null
				rm -f "$PREFIX/bin/$launchCommand" 2>/dev/null
				rm -f "$PREFIX/bin/query-tvnc" 2>/dev/null
				sed -i '/alaterm/d' ~/.bashrc 2>/dev/null
				sleep 1
				echo -e "Done. This script will now exit.\n"
				exit 0 ;;
				* ) echo "You did not answer y. Nothing removed."
				echo -e "This script will now exit.\n"
				exit 0 ;;
			esac ;;
			* ) echo "You did not answer y. Nothing removed."
				echo -e "This script will now exit.\n"
				exit 0 ;;
		esac
	fi
fi

## Anything after here, pertains to installation:
if [ "$actionMode" != "install" ] ; then
	echo "Developer: If you see this message, you goofed."
	exit 1
else
	echo -e "Performing preliminary checks on your Termux system..."
fi

## Definition of various variables:
declare wakelockMessage="" # Nonempty if wakelock is started or released.
# CPUABI is the system designation used by Android. Not same as version:
hash getprop >/dev/null 2>&1
if [ "$?" -ne 0 ] ; then
	echo "Must update Termux first..."
	apt-get update && apt-get dist-upgrade -y >/dev/null 2>&1
	if [ "$?" -ne 0 ] ; then
		echo -e "$PROBLEM Could not get update. Check Internet, then try again."
		echo -e "This script will now exit.\n" ; exit 1
	fi
fi
declare CPUABI="$(getprop ro.product.cpu.abi)" >/dev/null 2>&1
declare CPUABI7="armeabi-v7a" # 32-bit. May or may not be Chromebook.
declare CPUABI8="arm64-v8a" # 64-bit. Do not confuse with arm-v8l CPU.
declare isRooted="no" # Issues warning if your device is rooted.
declare termuxProxy="no" # Issues warning if Termux has proxy server.
declare priorInstall="no" # Yes if attempting to over-write previous.
let userSpace=0 # Will become integer GB available for install.
let priorUpdate=0 # Possible future use.
let priorChecktime=0 # Possible future use.
declare termuxPrefix="$PREFIX" # Equivalent of /usr, within Termux.
declare termuxHome="$HOME" # Where Termux is, at start.
let termuxTries=0 # Possibly used when intermittent downloads.
declare tMirror="notSelected" # Temporary choice, not known whether good.
declare chosenMirror="notSelected" # Becomes known good mirror, once found.
declare localArchive="no" # Becomes yes if archive already here.
declare archAr="" # Archive, *.tar.gz file.
declare partialArchive="no" # Yes if download interrupted and re-start.
declare userLocale="en_US" # Default. Measured later. Always UTF-8.
declare prsPre="" # Becomes part of the launch command.
declare prsUser="" # Becomes part of the launch command.
declare gotHelp="no" # Becomes yes when help file installed.
declare gotTCLI="no" # Becomes yes if trash-cli installed.
let processors=0 # Becomes number of processors in CPU: 4, 6, 8.
let nextPart=0 # Keeps track of progress. Recorded in status file.
# Get variables stored by previously running this script, if any:
[ -f "$alatermTop/status" ] && source "$alatermTop/status"

## Compatibility tests:
reject_incompatibleSystem() { # If script does not like your system.
	echo -e "$PROBLEM Your system is not compatible with this script."
	echo "Either it is not one of the selected Android systems,"
	echo "or its software kernel is old, or you have some other software"
	echo "that blocked this script from accessing necessary information."
	echo -e "This script will now exit.\n"
	exit 1
}

caution_rooters() { # This test is not exhaustive.
	ls / >/dev/null 2>&1
	[ "$?" -eq 0 ] && isRooted="yes"
	tsudo ls / >/dev/null 2>&1
	[ "$?" -eq 0 ] && isRooted="yes"
	[ -w /root ] && isRooted="yes"
	if [ "isRooted" = "yes" ] ; then
		echo -e "$WARNING It looks like your device is rooted."
		echo "This script is not intended for rooted devices."
		printf "Do you really wish to install? [y|N] : " ; read readvar
		case "$readvar" in
			y*|Y* ) echo -e "At your request, continuing...\n" ;;
			* ) echo -e "You did not answer yes. This script will now exit.\n" ; exit 1 ;;
		esac
	fi
}

ignore_proxy() { # If Termux has proxy, this script does not copy it.
	for prx in "$PREFIX/etc/profile" "$PREFIX/etc/profile.d/proxy.sh" ; do
		if [ -e "$prx" ] ; then
			grep "proxy" "$prx" | grep "export" > /dev/null
			[ "$?" -eq 0 ] && termuxProxy="ignored"
		fi
	done
	for prx in "~/.profile" "~/.bash_profile" "~/.bashrc" ; do
		if [ -e "$prx" ] ; then
			grep "proxy" "$prx" | grep "export" > /dev/null
			[ "$?" -eq 0 ] && termuxProxy="ignored"
		fi
	done
	if [ "$termuxProxy" = "ignored" ] ; then
		echo -e "$WARNING Looks like you have a Termux proxy server."
		echo -e "This script does not configure alaterm for proxy."
		echo -e "Script will continue. Termux unaffected."
	fi
}

check_ABI() { # Check Android software compatibility.
	local kVer="0"
	local gotMatch=false
	for matchThis in "$CPUABI7" "$CPUABI8" ; do
		[ "$CPUABI" = "$matchThis" ] && gotMatch=true
	done
	[ ! "$gotMatch" ] && reject_incompatibleSystem
	kVer="$(echo "$(uname -r)" | gawk -F'.' '{print $1}')" 2>/dev/null
	if [ "$?" -ne 0 ] ; then
		echo -e "$WARNING Could not get kernel version."
		echo "Script can assume kernel is OK, and continue."
		echo "The result may or may not have problems. Unpredictable."
		printf "Do you wish to continue or not? [y|N] : " ; read rvar
		case "$rvar" in
			y*|Y* ) echo -e "Continuing at your request...\n"
			kVer=4 ;;
			* ) echo -e "You did not request the script to continue. Exiting.\n"
			exit 1 ;;
		esac
	fi
	[ "$kVer" -lt 4 ] && reject_incompatibleSystem # Ignore old products.
}

check_freeSpace() { # Not re-checked later. df -k delivers data in kiloblocks.
	local kBlocks="$(df -k . 2>/dev/null | gawk 'FNR == 2 {print $4}')"
	[ "$kBlocks" = "" ] && kBlocks="$(df -k . 2>/dev/null | gawk 'FNR == 3 {print $3}')"
	[ "$kBlocks" = "" ] && let kBlocks=0
	let spaceK="$(expr $kBlocks + 0)" # Integer, not string.
	let userSpace="$spaceK"/1048576
	if [ "$userSpace" -eq 0 ] ; then
		echo -e "$WARNING Unable to calculate available free space."
		echo "Manually check free space using Android File Manager."
		echo "Do not include removable media."
		echo "You need 3GB minimum, 4GB to be useful, 5GB best."
		echo "You may install [i] or exit [x]. No default."
		while true ; do
			printf "Now $enter your choice. [i|x] : " ; read rvar
			case "$rvar" in
				i*|I* ) userSpace=10000 # Placeholder.
				echo -e "You chose to install. Continuing...\n"
				break ;;
				x|X ) echo -e "Exiting at your request.\n"
				exit 0 ; break ;;
				* ) echo "Bad response. There is no default."
				;;
			esac
		done
	elif [ "$userSpace" -lt 3 ] ; then # Has less than 3Gb available.
		echo -e "$PROBLEM Less than 3GB of free space on device."
		echo -e "Minimum 3GB, 4GB to be useful, 5GB best. No install.\n"
		exit 1
	elif [ "$userSpace" -lt 4 ] ; then # Can install, but not much room.
		echo -e "$WARNING Less than 4Gb of free space on device."
		echo "You have at least 3GB, enough for a minimal desktop."
		echo "But you need 4GB for useful programs, 5GB best."
		echo "You may install [i] or exit [x]. No default."
		while true ; do
			printf "Now $enter your choice. [i|x] : " ; read rvar
			case "$rvar" in
				i*|I* ) echo "You chose to install. Continuing..." ;  break ;;
				x|X ) echo -e "Exiting at your request.\n" ; exit 0 ; break ;;
				* ) echo "Bad response. There is no default." ;;
			esac
		done
	else
		if [ "$userSpace" -ne 10000 ] ; then
			echo "You have at least 4GB free space on device."
			echo -e "That is enough to be useful. Continuing...\n"
		fi
	fi
}

check_priorInstall() { # Warn if existing installation in same location.
	if [ ! -f "$alatermTop/bin/env" ] ; then return ; fi
	if [ ! -f "$alatermTop/bin/pacman" ] ; then return ; fi
	if [ -f "$alatermTop/status" ] ; then return ; fi
	echo -e "$WARNING An installation is already present in $alatermTop."
	echo "If you install, then you will lose the previous installation."
	echo "Nothing will be saved. Do you really wish to install?"
	echo "  y = Yes, install and lose previous installation."
	echo "  n = No, exit without losing previous installation [default]."
	printf "Now $enter your choice [y|N] : " ; read readvar
	case "$readvar" in
		y*|Y* ) echo "You requested a new install, losing previous."
		echo "Are you sure? yes=install. n=keep and exit [default]."
		printf "Now $enter your choice [y|N] : " ; read newreadvar
		case "$newreadvar" in
			y*|Y* ) echo "Removing prior installation. Takes awhile..."
				rm -r -f "${alatermTop:?}"/* 2>/dev/null
				find  "$alatermTop" -type d -exec chmod 700 {} \; 2>/dev/null
				rm -r -f "$alatermTop" 2>/dev/null
				rm -f "$PREFIX/bin/$launchCommand" 2>/dev/null
				rm -f "$PREFIX/bin/query-tvnc" 2>/dev/null
				sed -i '/alaterm/d' ~/.bashrc 2>/dev/null
				priorInstall="yes"
				echo "Prior installation removed. Continuing...\n" ;;
			* ) echo -e "You chose not to continue. Nothing changed. Exiting.\n" ; exit 0 ;;
		esac ;;
			* ) echo -e "You chose not to continue. Nothing changed. Exiting.\n" ; exit 0 ;;
	esac
}

## Define some utility functions:
start_termuxWakeLock() { # Prevents Android deep sleep.
	termux-wake-lock
	if [ "$?" -eq 0 ] ; then
		wakelockMessage=" Starting Termux wakelock."
	else wakelockMessage=""
	fi
}

release_termuxWakeLock() { # Allows Android to deep sleep, when appropriate.
	termux-wake-unlock
	if [ "$?" -eq 0 ] ; then
		wakelockMessage=" Releasing Termux wakelock."
	else wakelockMessage=""
	fi
}

scriptSignal() { # Run on various interrupts. Ensures wakelock is removed.
	release_termuxWakeLock
	echo -e "$WARNING Signal ${?} received."
	echo "This script will now exit.$wakelockMessage"
	echo "You may re-launch script. Resumes where it left off.\n" ; exit 1
}

scriptExit() {
	release_termuxWakeLock
	echo -e "This script will now exit.$wakelockMessage\n"
}

check_connection() { # Function ping works in both Termux and alaterm.
	ping -c 3 -W 5 "$1" >/dev/null 2>/dev/null
	if [ "$?" -ne 0 ]; then
		echo -e "$WARNING Looks like your Internet is disconected."
		echo "Or server at $1 is down."
		printf "Wait awhile. Then $enter when ready : " ; read readvar
		echo "Trying again..."
		ping -c 5 -t 10 "$1" >/dev/null 2>/dev/null
		if [ "$?" -ne 0 ] ; then
			echo -e "$PROBLEM Still no connection."
			echo "Check your Internet, wait, and try again later."
			exit 1
			else echo -e "OK, got $1 this time...\n"
		fi
		else echo -e "Got connection to server $1 ...\n"
	fi
}

complain_downloadFailed() {
	echo -e "\e[1;33mPROBLEM.\e[0m Download was interrupted. Re-try failed."
	echo "Exit this script, wait awhile, then try again."
	echo "Partial progress has been retained. Script resumes where it left off."
	echo "If download was partial, then it will resume where it left off."
	exit 1
}

## Ensure that wakelock is removed if script is interrupted:
trap scriptSignal HUP INT TERM QUIT
trap scriptExit EXIT

## Check that Termux transfer has been enabled:
verify_storageEnabled() { # Needs termux-setup-storage.
	ls ~/storage/downloads/ >/dev/null 2>&1
	if [ "$?" -ne 0 ] ; then
		echo -e "$WARNING You did not enable file transfer."
		echo "Without it, you cannot move files in or out of Termux."
		echo "Or, if you did enable transfer previously,"
		echo "then you moved the folders. Script cannot find them."
		echo "This will be fixed now."
		echo "Be sure to allow Android file sharing permission."
		printf "Hit $enter when you are ready:" ; read readvar
		termux-setup-storage
		if [ "$?" -ne 0 ] ; then
			echo -e "$WARNING Denied storage setup."
			echo "Did you refuse to allow Android permission?"
			echo "Installation script can continue without it."
			echo "Run \"termux-setup-storage\" later."
			echo -e "Continuing...\n"
		fi
	fi
}

update_termuxPackages() { # Needed to provide platform for alaterm.
	echo "Checking if Termux is up-to-date, and upgrading if necessary..."
	check_connection github.com
	apt-get -y update && apt-get -y dist-upgrade
	if [ "$?" -ne 0 ] ; then
		echo -e "$PROBLEM Termux could not be updated."
		echo "Bad Internet connection, or server is erratic."
		echo "Probably a transient issue. Try again in a few minutes."
		exit 1
	fi
}

get_moreTermux() {
	local getThese=""
	for needPkg in wget bsdtar proot nano ; do
		hash "$needPkg" >/dev/null 2>&1
		[ "$?" -ne 0 ] && getThese+="$needPkg "
	done
	if [ "$getThese" != "" ] ; then
		echo "One or more necessary Termux packages is missing."
		echo -e "They will now be downloaded and installed...\n"
		apt-get -y install $getThese 2>/dev/null # No quotes $getThese.
		if [ "$?" -ne 0 ] ; then
			echo -e "\n$PROBLEM Some Termux packages unavailable."
			echo "Bad Internet connection, or server is erratic."
			echo "Probably a transient issue. Try again later."
			exit 1
		else echo -e "Installed Termux packages. Continuing...\n"
		fi
	fi
	if [ "$getThese" != "" ] ; then
		for didItInstall in $getThese ; do # No quotes $getThese.
			hash "$didItInstall" >/dev/null 2>&1
			if [ "$?" -ne 0 ] ; then
				echo -e "$PROBLEM. Having server problems."
				echo -e "Wait awhile, then try again.\n"
				exit 1
			fi
		done
		echo "Successful Termux ugrade. Continuing..."
	fi
}

create_alatermTop() { # Verifies that chosen location can be used.
	mkdir -p "$alatermTop" 2>/dev/null
	if [ "$?" -ne 0 ] ; then
		echo -e "$PROBLEM Could not create the install directory."
		echo -e "Pehaps its parent directory is not writeable."
		echo -e "Try editing this script. Choose a different installDirectory."
		echo -e "This script will now exit.\n"
		exit 1
	fi
}

create_statusFile() { # Records progress of installation, and stores variables.
cat << EOC > status # No hyphen. Unquoted marker.
# File /status created by script during install.
# Records progress of installation by Termux.
# Retains important data for use by alaterm post-install script.
# Do not edit this file unless you know what you are doing.
# DO NOT REMOVE THIS FILE, EVEN AFTER SUCCESSFUL INSTALLATION..
# In case of later patches, the info here is needed.
installerVersion="$versionID"
scriptLocation="$scriptLocation"
termuxTop="$termuxTop"
termuxPrefix="$PREFIX"
termuxHome="$HOME"
termuxLdPreload="$LD_PRELOAD"
alatermTop="$alatermTop" # Where alaterm sits in Android.
launchCommand="$launchCommand" # How to launch alaterm from Termux.
isRooted="$isRooted" # Was a rooted device detected?
termuxProxy="$termuxProxy" # Was a proxy detected?
CPUABI="$CPUABI" # Your device.
CPUABI7="armeabi-v7a" # 32-bit. May or may not be Chromebook.
CPUABI8="arm64-v8a" # 64-bit. Do not confuse with arm-v8l CPU.
userSpace="$userSpace" # Only checked once.
priorInstall="$priorInstall" # If replacing an earlier installation.
let priorUpdate=0 # Possible future use.
let priorChecktime=0 # Possible future use.
EOC
}

## If nextPart is not 0, it means that this portion was already completed:
if [ "$nextPart" -eq 0 ] ; then
	if [ ! -f "$alatermTop/status" ] ; then
		caution_rooters
		ignore_proxy
		check_ABI
		check_freeSpace
		check_priorInstall
		sleep .2
		create_alatermTop
		cd "$alatermTop"
		create_statusFile
		chmod 666 status
		echo -e "Your device passed preliminary inspection. Continuing...\n"
	fi
	update_termuxPackages
	get_moreTermux
	verify_storageEnabled
	sleep .5
	cd "$alatermTop"
	let nextPart=1
	echo -e "let nextPart=1" >> status
fi

cd "$pwDir"

## If necessary, download the component scripts to the current directory:
export mainurl="https://raw.githubusercontent.com/cargocultprog/alaterm/master"
cd "$hereiam"
echo -e "\e[1;92mDownloading scripts from the alaterm repository at GitHub...\e[0m"
for nn in 01 02 03 04 05 06 07 08
do
	if [ ! -r "$nn-alaterm.bash" ] ;then
		wget "$mainurl/$nn-alaterm.bash" >/dev/null 2>&1
	fi
done
if [ ! -r fixexst-scripts.bash ] ; then
	wget "$mainurl/fixexst-scripts.bash" >/dev/null 2>&1
fi

## Verify that the component scripts are here:
allhere="yes"
cd "$hereiam"
for nn in 01 02 03 04 05 06 07 08
do
	if [ ! -r "$nn-alaterm.bash" ] ;then
		allhere="no"
	fi
done
if [ ! -r fixexst-scripts.bash ] ; then
	allhere="no"
fi
if [ "$allhere" = "no" ] ; then
	echo -e "$PROBLEM One or more of the component scripts failed to download."
	echo "Wait awhile, then re-launch this script. Exit."
	exit 1
else
	echo -e "\e[92mGot the scripts. Continuing...\e[0m"
	echo "Android may ask if you wish to stop optimizing battery usage."
	echo "You may allow or deny, but installation is faster if you allow."
fi

## Process the component scripts:
start_termuxWakeLock # Needed from this point. Released by any exit or error.
for nn in 01 02 03 04 05 06 07 08
do
	cd "$hereiam"
	source "$nn-alaterm.bash"
done
# fixexst-scripts.bash is sourced in 08-alaterm.bash.

exit 0 # So that the following License is not precessed as script.


********** License applicable to all component files:

alaterm (Arch Linux ARM in Termux)
Copyright 2020 by Robert Allgeyer, of Aptos California USA "cargocultprog"

MIT LICENSE

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


************** End.
