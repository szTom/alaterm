#!/bin/bash
# Usage: Place this script anywhere in alaterm.
# Command:  bash compile-libmad
#
# The libmad distributed by Arch Linux ARM, and installable to alaterm,
# calls for executable stack. That is an Android security policy violation.
# Thus, libmad and any program invoking it will not work in alaterm.
# This script compiles an acceptable version of libmad from source code.
# The compiled version does not call for executable stack, so it works.
#
process_script() {
	if [ -f ~/.source/libmad-compiled/reinstall-libmad ] ; then
		echo "Installable files have been retained from previous build."
		printf "Do you wish to re-install them? [Y|n] : " ; read readvar
		case "$readvar" in
			n*|N* ) printf "Do you wish to re-compile with fresh code? [y|N] : " ; read readv
			case "$readv" in
				y*|Y* ) prepare_libmad ;;
				* ) echo "Nothing to be done. Exit." ; exit 0 ;;
			esac ;;
			* ) bash ~/.source/libmad-compiled/reinstall-libmad ;;
		esac
	else
		printf "This script compiles and installs libmad. Continue? [Y|n] : " ; read readva
		case "$readva" in
			n*|N* ) echo "Exiting at your request." ; exit 0 ;;
			* ) prepare_libmad ;;
		esac
	fi
}

prepare_libmad() {
	if [ -d ~/.source/libmad ] ; then
		cd ~/.source/libmad
		chmod -R 0777 .git 2>/dev/null
		mv .git gone
		rm -r -f gone
		cd ~/.source
		chmod -R 0777 libmad 2>/dev/null
		rm -r -f libmad
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
	echo -e "\e[1;92mDownloading source code for libmad...\e[0m"
	git clone https://github.com/markjeee/libmad.git
	if [ "$?" -ne 0 ] ; then
		echo -e "\e[1;91mPROBLEM.\e[0m Download failed during git clone libmad."
		echo "Wait a minute, then re-run this script to try again."
		exit 1
	fi
	cd ~/.source/libmad
	echo "Patching libmad source code..."
	# Requests for obsolete compiler flag --fforce-mem must be removed:
	[ -f configure.ac ] && sed -i '/fforce-mem/d' configure.ac
	[ -f configure ] && sed -i '/fforce-mem/d' configure
	configure_libmad
}

configure_libmad() {
	echo "Now configuring and compiling libmad. Takes a few minutes..."
	./configure --disable-aso --prefix=/usr
	if [ "$?" -ne 0 ] ; then
		echo -e "\e[1;91mPROBLEM.\e[0m Configuring libmad failed."
		echo -e "Probably a missing package needs to be installed."
		echo -e "Look at the last few lines above this message."
		exit 1
	fi
	build_libmad
}

build_libmad() {
	echo -e "\e[1;92mBuilding libmad code...\e[0m"
	make
	if [ "$?" -ne 0 ] ; then
		echo -e "\e[1;91mPROBLEM.\e[0m Building libmad failed."
		echo -e "Look at the last few lines above."
		exit 1
	fi
	install_libmad
}

install_libmad() {
	echo -e "\e[1;92mInstalling...\e[0m"
	sudo make install
	if [ "$?" -ne 0 ] ; then
		echo -e "\e[1;91mPROBLEM.\e[0m Installing libmad failed."
		echo -e "Look at the last few lines above."
		exit 1
	fi
	retain_compiled
	cd ~/.source/libmad-compiled
	chmod 755 reinstall-libmad
	echo -e "\e[1;92mDONE.\e[0m"
	echo "For best results, logout of alaterm, then re-launch alaterm."
	echo "A copy of the compiled, installable files has been retained."
	echo "If you ever need to re-install them, run compile-libmad again."
	echo "The script will ask whether to re-install or compile fresh."
}

retain_compiled() {
	archive=~/.source/libmad-compiled
	mkdir -p $archive
	cd /usr/lib
	cp libmad.so.0.2.1 $archive
	cp libmad.a $archive
	cp libmad.la $archive
	cd /usr/lib/pkgconfig
	cp mad.pc $archive
	cd /usr/include
	cp mad.h $archive
	cd $archive
	create_reinstall
}

create_reinstall() { # In ~/.source/libmad-compiled
cat << EOC > reinstall-libmad # No hyphen. Unquoted marker.
#!/bin/bash
# Reinstalls pre-compiled libmad.
cd ~/.source/libmad-compiled
cp mad.h /usr/include
cp mad.pc /usr/lib/pkgconfig
cp libmad.a /usr/lib
cp libmad.la /usr/lib
cp libmad.so.0.2.1 /usr/lib
cd /usr/lib
rm -f libmad.so
rm -f libmad.so.0
ln -s libmad.so.0.2.1 libmad.so
ln -s libmad.so.0.2.1 libmad.so.0
echo "DONE."
echo "For best results, logout of alaterm, then re-launch alaterm."
EOC
}


process_script

##

