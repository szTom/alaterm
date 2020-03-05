# File compile-libde265.bash for alaterm.
# Usage: Download this file to any location in alaterm.
# Command:  bash compile-libde265.bash
#
# The heic/heif format, also known as h265, is used by some products
# such as Apple phones. Recent Android also understands this format.
# Although h265 support is built into Arch Linux ARM (used by alaterm),
# the distributed libde265 violates an Android security policy.
# Not a big deal. Easy to fix be re-compile.
#
# This script installs the compiler, libde265 source code, and support.
# It automatically compiles, installas, and tests the installation.
# When finished, the source code is discarded.
# The compiler is still installed. May as well leave it there.
#
sudo gdk-pixbuf-query-loaders 2>/dev/null | grep image/heif >/dev/null 2>&1
if [ "$?" -eq 0 ] ; then
	echo "It looks like heif/heic support is already enabled."
	echo "You do not need to run this script."
	exit 0
else
	echo "This script compiles and installs a fresh version of libde265."
	printf "Do you wish to continue? Takes about 25 minutes. [y|N] : " ; read readvar
	case "$readvar" in
		y*|Y* ) true ;;
		* ) echo "You did not answer y. Exit." ; exit 0 ;;
	esac
fi
echo -e "\e[1;92mChecking for Arch compiler system and dependencies...\e[0m"
sudo pacman -Syu --noconfirm
if [ "$?" -ne 0 ] ; then
	echo -e "\e[1;91mPROBLEM.\e[0m Download failed during pacman update."
	echo "Wait a minute, then re-run this script to try again."
	exit 1
fi
sudo pacman -S --noconfirm --needed base-devel git pax-utils
if [ "$?" -ne 0 ] ; then
	echo -e "\e[1;91mPROBLEM.\e[0m New package download failed."
	echo "Wait a minute, then re-run this script to try again."
	exit 1
fi
echo -e "\e[1;92mIf you saw a number of warnings above, just ignore them.\e[0m"
scriptSignal() { # Run on various interrupts. Ensures wakelock is removed.
	termux-wake-unlock
	echo -e "\e[1;33mWARNING.\e[0m Signal ${?} received."
	exit 1
}
scriptExit() {
	termux-wake-unlock
	echo -e "This script will now exit.\n"
}
# Ensure that wakelock is removed if script is interrupted:
trap scriptSignal HUP INT TERM QUIT
trap scriptExit EXIT
cd ~
termux-wake-lock
sleep 1
sudo pacman -S --noconfirm --needed gdk-pixbuf2 sdl imagemagick
echo -e "\e[1;92mIf you saw a number of warnings above, just ignore them.\e[0m"
echo -e "\e[1;92mDownloading source code for libde265...\e[0m"
git clone https://github.com/strukturag/libde265.git
cd libde265*
echo -e "\e[1;92mConfiguring libde265 code. Takes about 3 minutes...\e[0m"
./autogen.sh
./configure --disable-sherlock265 --disable-arm --prefix=/usr
echo -e "\e[1;92mBuilding libde265 code. Takes about 22 minutes...\e[0m"
make 2>builderror | grep -F make[
if [ "$?" -ne 0 ] ; then
	echo -e "\e[1;91mPROBLEM.\e[0m Building libde265 failed."
	echo -e "Error messages are in file ~/libde265/builderror."
	echo -e "Look at the last few lines of that file."
	exit 1
fi
echo -e "\e[1;92mInstalling libde265. Takes about 1 minute...\e[0m"
sudo make install >/dev/null 2>builderror
if [ "$?" -ne 0 ] ; then
	echo -e "\e[1;91mPROBLEM.\e[0m Installing libde265 failed."
	echo -e "Did you chmod /usr to be read-only?"
	echo -e "Error messages are in file ~/libde265/builderror."
	echo -e "Look at the last few lines of that file."
	exit 1
fi
sudo gdk-pixbuf-query-loaders --update-cache >/dev/null 2>&1
gdk-pixbuf-query-loaders 2>/dev/null | grep image/heif >/dev/null 2>&1
if [ "$?" -eq 0 ] ;then
	echo -e "Quick test: \e[1;92mPassed.\e[0m"
	echo "You can now open the common heic/heif formats, but not all of them."
else
	echo -e "Quick test: \e[1;33mFailed.\e[0m Reason for failure unknown."
fi
cd ~
rm -r -f libde265*
echo -e "DONE.\n"
##
