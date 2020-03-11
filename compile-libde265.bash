#!/bin/bash
# Usage: Download this file to any location in alaterm.
# Command:  bash compile-libde265.bash
#
# The heic/heif format, also known as h265, is used by some products
# such as Apple phones. Recent Android also understands this format.
# Although h265 support is built into Arch Linux ARM (used by alaterm),
# the distributed libde265 violates an Android security policy,
# executable stack. Easy to fix by re-compile.
#
process_script() {
	gdk-pixbuf-query-loaders 2>/dev/null | grep image/heif >/dev/null 2>&1
	if [ "$?" -eq 0 ] ; then
		echo "It looks like heif/heic support is already enabled."
		echo "You may not need to run this script."
		printf "Do you wish to build the source code, or exit? [b|X] : " ; read readv
		case "$readv" in
			b*|B* ) true ;;
			* ) echo "You did not request build. Exit." ; exit 0 ;;
		esac
	fi
	if [ -f ~/.source/libde265-compiled/reinstall-libde265 ] ; then
		echo "Installable files have been retained from previous build."
		printf "Do you wish to re-install them? [Y|n] : " ; read readvar
		case "$readvar" in
			n*|N* ) printf "Do you wish to re-compile with fresh code? [y|N] : " ; read readv
			case "$readv" in
				y*|Y* ) prepare_libde265 ;;
				* ) echo "Nothing to be done. Exit." ; exit 0 ;;
			esac ;;
			* ) bash ~/.source/libde265-compiled/reinstall-libde265 ;;
		esac
	else
		echo "This script compiles and installs libde265."
		printf "It will take about 25 minutes. Continue? [Y|n] : " ; read readvv
		case "$readvv" in
			n*|N* ) echo "Exiting at your request." ; exit 0 ;;
			* ) prepare_libde265 ;;
		esac
	fi
}

prepare_libde265() {
	if [ -d ~/.source/libde265 ] ; then
		cd ~/.source/libde265
		chmod -R 0777 .git 2>/dev/null
		mv .git gone
		rm -r -f gone
		cd ~/.source
		chmod -R 0777 libde265 2>/dev/null
		rm -r -f libde265
	fi
	mkdir -p ~/.source
	cd ~/.source
	setup_compiler
}

setup_compiler() {
	echo -e "\e[1;92mChecking for compiler system and dependencies...\e[0m"
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
	get_sourcecode
}

scriptSignal() { # Run on various interrupts. Ensures wakelock is removed.
	termux-wake-unlock
	echo -e "\e[1;33mWARNING.\e[0m Signal ${?} received."
	exit 1
}

scriptExit() {
	termux-wake-unlock
	echo -e "This script will now exit.\n"
}

get_sourcecode() {
	echo -e "\e[1;92mInstalling support programs...\e[0m"
	sudo pacman -S --noconfirm --needed gdk-pixbuf2 sdl imagemagick
	echo -e "\e[1;92mDownloading source code for libde265...\e[0m"
	cd ~/.source
	git clone https://github.com/strukturag/libde265.git
	configure_libde265
}

configure_libde265() {
	# Ensure that wakelock is removed if script is interrupted:
	trap scriptSignal HUP INT TERM QUIT
	trap scriptExit EXIT
	termux-wake-lock 2>/dev/null
	sleep 1
	cd ~/.source/libde265
	echo -e "\e[1;92mConfiguring libde265 code. Takes about 3 minutes...\e[0m"
	./autogen.sh
	if [ "$?" -ne 0 ] ; then
		echo "Failure during autogen. Inspect above lines to identify the problem"
		exit 1
	fi
	./configure --disable-sherlock265 --disable-arm --prefix=/usr
	if [ "$?" -ne 0 ] ; then
		echo "Failure during configure. Inspect above lines to identify the problem"
		exit 1
	fi
	build_libde265
}

build_libde265() {
	echo -e "\e[1;92mBuilding libde265 code. Takes about 22 minutes...\e[0m"
	make 2>builderror | grep -F make[
	if [ "$?" -ne 0 ] ; then
		echo -e "\e[1;91mPROBLEM.\e[0m Building libde265 failed."
		echo -e "Error messages are in file ~/libde265/builderror."
		echo -e "Look at the last few lines of that file."
		exit 1
	fi
	install_libde265
}

install_libde265() {
	echo -e "\e[1;92mInstalling...\e[0m"
	sudo make install
	if [ "$?" -ne 0 ] ; then
		echo -e "\e[1;91mPROBLEM.\e[0m Installing libde265 failed."
		echo -e "Look at the last few lines above."
		exit 1
	fi
	retain_compiled
	cd ~/.source/libde265-compiled
	chmod 755 reinstall-libde265
	echo -e "\e[1;92mDONE.\e[0m"
	echo "For best results, logout of alaterm, then re-launch alaterm."
	echo "A copy of the compiled, installable files has been retained."
	echo "If you ever need to re-install them, run compile-libde265 again."
	echo "The script will ask whether to re-install or compile fresh."
}

retain_compiled() {
	archive=~/.source/libde265-compiled
	mkdir -p $archive
	cp /usr/bin/dec265 $archive
	cp /usr/bin/hdrcopy $archive
	cp /usr/bin/enc265 $archive
	cp /usr/bin/acceleration-speed $archive
	cp /usr/bin/bjoentegaard $archive
	cp /usr/bin/block-rate-estim $archive
	cp /usr/bin/gen-enc-table $archive
	cp /usr/bin/rd-curves $archive
	cp /usr/bin/tests $archive
	cp /usr/bin/yuv-distortion $archive
	cp /usr/include/libde265/de265.h $archive
	cp /usr/include/libde265/de265-version.h $archive
	cp /usr/lib/libde265.a $archive
	cp /usr/lib/libde265.la $archive
	cp /usr/lib/libde265.so.0.0.12 $archive
	cd $archive
	create_reinstall
}

create_reinstall() { # In ~/.source/libde265-compiled
cat << EOC > reinstall-libde265 # No hyphen. Unquoted marker.
#!/bin/bash
# Reinstalls pre-compiled libde265.
cd ~/.source/libde265-compiled
cp dec265 /usr/bin
cp hdrcopy /usr/bin
cp enc265 /usr/bin
cp acceleration-speed /usr/bin
cp bjoentegaard /usr/bin
cp block-rate-estim /usr/bin
cp gen-enc-table /usr/bin
cp rd-curves /usr/bin
cp tests /usr/bin
cp yuv-distortion /usr/bin
mkdir -p /usr/include/libde265
cp de265.h /usr/include/libde265
cp de265-version.h /usr/include/libde265
cp libde265.a /usr/lib
cp libde265.la /usr/lib
cp libde265.so.0.0.12 /usr/lib
cd /usr/lib
rm -f libde265.so
rm -f libde265.so.0
ln -s libde265.so.0.0.12 libde265.so
ln -s libde265.so.0.0.12 libde265.so.0
echo "DONE."
echo "For best results, logout of alaterm, then re-launch alaterm."
EOC
}


process_script

##
