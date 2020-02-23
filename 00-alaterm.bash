#!/bin/bash
# Part of the alaterm project, https://github.com/cargocultprog/alaterm
declare versionID=1.0.1
# Usage within Termux home on selected Android devices:
# bash alaterm.bash action
#   where action is one of: install remove help
#   abbreviated as: i r h
# Interactive script. Requires meaningful user response from time to time.
# You cannot just launch it and walk away while it works.
#
# Copyright and License at bottom of this file.
#
# * This BASH script installs portions of Arch Linux into the Termux app,
#   for Android-based devices that have an ARM processor.
#   This includes many tablets and Chromebooks, but not all of them.
# * You do not need root access. This script does not enable root access.
# * Installation works with small screens and touchscreen-only devices,
#   but the benefits are best realized when the screen is 10.1 inches or more,
#   and you have a keyboard and mouse.
# * The installation is optimized for ordinary users, rather than programmers.
#   It assumes that you intend to run programs such as GIMP image editor,
#   but you do not intend to setup a file server or upload packages.
# * This is not a dual-boot. Android runs alongside Arch at all times.
#   For example, Android can play Bluetooth music and connect to the Internet,
#   even while you are using a program such as GIMP in Arch.
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
# as long as archTop and launchCommand are different. OK by default.
# 1. Where Arch will be installed. Default: installDirectory=archx
declare installDirectory=archx
#    * In Android, Termux is at /data/data/com.termux directory.
#    * That contains several directories. Among them:
#      /data/data/com.termux/files/usr is where Termux keeps its own programs.
#      /data/data/com.termux/files/home is home, where Termux starts.
#    * If you install to the recommended default location, then
#      /data/data/com.termux/archx will be the Arch / root directory.
#      That root directory will contain Arch /bin, /etc, /home, and so forth.
#    * The alternative, by SDRausty, installs to Termux home/arch.
#    * Advantage of installing to the default location is that
#      Arch will not be accidentally removed, if you clean Termux home.
# 2. To launch Arch from Termux. Default: launchcommand=launcharch
declare launchCommand=launcharch
#    * The alternative script, by SDRausty, uses: startarch
# END OF USER-CUSTOMIZABLE SETTINGS.
##############################################################################


# The various portions are broken into several files, processed in order.
# Although these files have the bash shebang at top, and *.bash extension,
# they are NOT stand-alone. They must be processed using this file as master.
# The developer has a trick for debugging the individual files,
# but you, the user, cannot do it that way.

# When each component finishes, it writes info to a status file that is retained.
# In case of problem, it is possible to examine the status file,
# which will show the last component that completed successfully.
# The status file also holds some variables that are read during install.
# If your installation is interrupted, it will resume from where it left off,
# thanks to data automatically read from the status file.

# Ensure that wget is installed in Termux:
hash wget >/dev/null 2>&1
if [ "$?" -ne 0 ] ; then
	pkg update
	pkg install wget
fi
sleep .2
hash wget >/dev/null 2>&1
if [ "$?" -ne 0 ] ; then
	echo "This script was unable to install the wget package."
	echo "Cannot continue without it. Maybe poor Internet connection?"
	echo "Try again later. Exit."
	exit 1
fi

# If necessary, download the component scripts:
for nn in 01 02 03 04 05 06 07 08 09 10 11 12 13 ; do
	if [ ! -r "$nn-alaterm.bash" ] ;then
		wget https://github.com/cargocultprog/alaterm/raw/$nn-alaterm.bash
	fi
done

# Verify that the component scripts are here:
allhere="yes"
for nn in 01 02 03 04 05 06 07 08 09 10 11 12 13 ; do
	if [ ! -r "$nn-alaterm.bash" ] ;then
		allhere="no"
	fi
done
if [ "$allhere" = "no" ] ; then
	echo "One or more of the component scripts failed to download."
	echo "Wait awhile, then re-launch this script. Exit."
	exit 1
fi

# Process the component scripts:
for nn in 01 02 03 04 05 06 07 08 09 10 11 12 13 ; do
	source "$nn-alaterm.bash"
done


exit 0 # So that the following License is not precessed as script.


************** License applicable to all component files:

alaterm (Arch Linux ARM in Termux)
Copyright 2020 by Robert Allgeyer "cargocultprog"

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
