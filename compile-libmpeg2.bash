#!/bin/bash
# Usage: Place this script anywhere in alaterm.
# Command:  bash compile-libmpeg2
#
# The libmpeg2 distributed by Arch Linux ARM, and installable to alaterm,
# calls for executable stack. That is an Android security policy violation.
# Thus, libmpeg2 and any program invoking it will not work in alaterm.
# This script compiles an acceptable version of libmpeg2 from source code.
# The compiled version does not call for executable stack, so it works.
#
process_script() {
	if [ -f ~/.source/libmpeg2-compiled/reinstall-libmpeg2 ] ; then
		echo "Installable files have been retained from previous build."
		printf "Do you wish to re-install them? [Y|n] : " ; read readvar
		case "$readvar" in
			n*|N* ) printf "Do you wish to re-compile with fresh code? [y|N] : " ; read readv
			case "$readv" in
				y*|Y* ) prepare_libmpeg2 ;;
				* ) echo "Nothing to be done. Exit." ; exit 0 ;;
			esac ;;
			* ) bash ~/.source/libmpeg2-compiled/reinstall-libmpeg2 ;;
		esac
	else
		printf "This script compiles and installs libmpeg2. Continue? [Y|n] : " ; read readva
		case "$readva" in
			n*|N* ) echo "Exiting at your request." ; exit 0 ;;
			* ) prepare_libmpeg2 ;;
		esac
	fi
}

prepare_libmpeg2() {
	if [ -d ~/.source/libmpeg2 ] ; then
		cd ~/.source/libmpeg2
		chmod -R 0777 .git 2>/dev/null
		mv .git gone
		rm -r -f gone
		cd ~/.source
		chmod -R 0777 libmpeg2 2>/dev/null
		rm -r -f libmpeg2
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

get_sourcecode() {
	echo -e "\e[1;92mDownloading source code for libmpeg2...\e[0m"
	git clone https://github.com/cisco-open-source/libmpeg2.git
	if [ "$?" -ne 0 ] ; then
		echo -e "\e[1;91mPROBLEM.\e[0m Download failed during git clone libmpeg2."
		echo "Wait a minute, then re-run this script to try again."
		exit 1
	fi
	cd ~/.source/libmpeg2
	echo "Patching libmpeg2 source code..."
	# Many thanks to contributors at https://wiki.gentoo.org/wiki/Hardened/GNU_stack_quickstart for this:
	if [ -f libmpeg2/motion_comp_arm_s.S ] ; then
		grep -F GNU-stack libmpeg2/motion_comp_arm_s.S >/dev/null 2>&1
		if [ "$?" -ne 0 ] ; then
			echo "#if defined(__linux__) && defined(__ELF__)" >> libmpeg2/motion_comp_arm_s.S
			echo ".section .note.GNU-stack,\"\",%progbits" >> libmpeg2/motion_comp_arm_s.S
			echo "#endif" >> libmpeg2/motion_comp_arm_s.S
		fi
	fi
	configure_libmpeg2
}

configure_libmpeg2() {
	echo "Now configuring and compiling libmpeg2. Takes a few minutes..."
	./configure --prefix=/usr
	if [ "$?" -ne 0 ] ; then
		echo -e "\e[1;91mPROBLEM.\e[0m Configuring libmpeg2 failed."
		echo -e "Probably a missing package needs to be installed."
		echo -e "Look at the last few lines above this message."
		exit 1
	fi
	build_libmpeg2
}

build_libmpeg2() {
	echo -e "\e[1;92mBuilding libmpeg2 code...\e[0m"
	make
	if [ "$?" -ne 0 ] ; then
		echo -e "\e[1;91mPROBLEM.\e[0m Building libmpeg2 failed."
		echo -e "Look at the last few lines above."
		exit 1
	fi
	install_libmpeg2
}

install_libmpeg2() {
	echo -e "\e[1;92mInstalling...\e[0m"
	sudo make install
	if [ "$?" -ne 0 ] ; then
		echo -e "\e[1;91mPROBLEM.\e[0m Installing libmpeg2 failed."
		echo -e "Look at the last few lines above."
		exit 1
	fi
	retain_compiled
	cd ~/.source/libmpeg2-compiled
	chmod 755 reinstall-libmpeg2
	echo -e "\e[1;92mDONE.\e[0m"
	echo "For best results, logout of alaterm, then re-launch alaterm."
	echo "A copy of the compiled, installable files has been retained."
	echo "If you ever need to re-install them, run compile-libmpeg2 again."
	echo "The script will ask whether to re-install or compile fresh."
}

retain_compiled() {
	archive=~/.source/libmpeg2-compiled
	mkdir -p $archive
	cd /usr/bin
	cp corrupt_mpeg2 $archive
	cp extract_mpeg2 $archive
	cp mpeg2dec $archive
	cd /usr/lib
	cp libmpeg2.a $archive
	cp libmpeg2.la $archive
	cp libmpeg2.so.0.1.0 $archive
	cp libmpeg2convert.so.0.0.0 $archive
	cp libmpeg2convert.a $archive
	cp libmpeg2convert.la $archive
	cd /usr/lib/pkgconfig
	cp libmpeg2.pc $archive
	cp libmpeg2convert.pc $archive
	cd /usr/include/mpeg2dec
	cp mpeg2.h $archive
	cp mpeg2convert.h $archive
	cd $archive
	create_reinstall
}

create_reinstall() { # In ~/.source/libmpeg2-compiled
cat << EOC > reinstall-libmpeg2 # No hyphen. Unquoted marker.
#!/bin/bash
# Reinstalls pre-compiled libmpeg2.
cd ~/.source/libmpeg2-compiled
cp corrupt_mpeg2 /usr/bin
cp extract_mpeg2 /usr/bin
cp mpeg2dec /usr/bin
mkdir -p /usr/include/mpeg2dec
cp mpeg2.h /usr/include/mpeg2dec
cp mpeg2convert.h /usr/include/mpeg2dec
cp libmpeg2.pc /usr/lib/pkgconfig
cp libmpeg2convert.pc /usr/lib/pkgconfig
cp libmpeg2.a /usr/lib
cp libmpeg2.la /usr/lib
cp libmpeg2.so.0.1.0 /usr/lib
cp libmpeg2convert.a /usr/lib
cp libmpeg2convert.la /usr/lib
cp libmpeg2convert.so.0.0.0 /usr/lib
cd /usr/lib
rm -f libmpeg2.so
rm -f libmpeg2.so.0
ln -s libmpeg2.so.0.1.0 libmpeg2.so
ln -s libmpeg2.so.0.1.0 libmpeg2.so.0
rm -f libmpeg2convert.so
rm -f libmpeg2convert.so.0
ln -s libmpeg2convert.so.0.0.0 libmpeg2convert.so
ln -s libmpeg2convert.so.0.0.0 libmpeg2convert.so.0
echo "DONE."
echo "For best results, logout of Arch, then re-launch Arch."
EOC
}


process_script

##
