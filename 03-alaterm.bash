# Part of the alaterm project, https://github.com/cargocultprog/alaterm/
# This file is: https://raw.githubusercontent.com/cargocultprog/alaterm/master/03-alaterm.bash

echo "$(caller)" | grep -F 00-alaterm.bash >/dev/null 2>&1
if [ "$?" -ne 0 ] ; then
echo "Script 03-alaterm.bash is not stand-alone."
echo "It must be sourced in sequence from 00-alaterm.bash."
echo "Exit." ; exit 1
fi


##############################################################################
## INSTALLER PART 03. Set Locale.
##############################################################################


# Locale is of form xy_AB where xy is lowercase letters = language code,
# and AB is uppercase letters = geographic variant.
# There are other codes for special locales, not recognized here.
# This can be stored in several different parameters, depending on system.
# The following code hunts through the parameters, by priority.
# Default is en_US if nothing else is found.
# On my device, the locale is named en-US when it should be en_US instead.
# If necessary, this is corrected by sed.

find_locale() {
	local ul="$(getprop user.language)"
	local ur="$getprop user.region)"
	local psla="$(getprop persist.sys.language)"
	local psc="$(getprop persist.sys.country)"
	local rpll="$(getprop ro.product.locale.language)"
	local rplr="$(getprop ro.product.locale.region)"
	local pslo="$(getprop persist.sys.locale)"
	local rpl="$(getprop ro.product.locale)"
	if [ "$ul" != "" ] && [ "$ur" != "" ] ; then
		userLocale="$ul"_"$ur"
	elif [ "$psla" != "" ] && [ "$psc" != "" ] ; then
		userLocale="$psla"_"$psc"
	elif [ "$rpll" != "" ] && [ "$rplr" != "" ] ; then
		userLocale="$rpll"_"$rplr"
	elif [[ "$pslo" =~ *_* ]] ; then # underscore
		userLocale="$pslo"
	elif [[ "$pslo" =~ *-* ]] ; then # hyphen
		userLocale="$($pslo | sed 's/-/_/')"
	elif [[ "$rpl" =~ *_* ]] ; then # underscore
		userLocale="$rpl"
	elif [[ "$rpl" =~ *-* ]] ; then # hyphen
		userLocale="$($rpl | sed 's/-/_/')"
	else
		userLocale="en_US" # Default.
	fi
	echo -e "alaterm will use locale $userLocale with UTF-8 encoding.\n"
	# alaterm has /etc/locale.gen, a commented-out list of available locales.
	# This uncomments the line corresponding to the above locale:
	local lg="$alatermTop/etc/locale.gen"
	if [ -w "$lg" ] ; then
		sed -i "/\\#$userLocale.UTF-8 UTF-8/{s/#//g;s/@/-at-/g;}" "$lg"
	else echo "$userLocale.UTF-8 UTF-8" > "$lg"
	fi
}

create_etcLocaleConf() {
# Create etc/locale.conf and request UTF-8 encoding.
# Knowledgeable power users can change lines, from within alaterm.
cat << EOC > "$alatermTop/etc/locale.conf" # No hyphen, unquoted marker.
#  File /etc/locale.conf created from Termux during alaterm installation.
LANG="$userLocale.UTF-8"
# If you need to customize any of the following, do it here,
# then run locale-gen.
#LC_ADDRESS="$userLocale.UTF-8"
#LC_COLLATE="$userLocale.UTF-8"
#LC_CTYPE="$userLocale.UTF-8"
#LC_IDENTIFICATION="$userLocale.UTF-8"
#LC_MEASUREMENT="$userLocale.UTF-8"
#LC_MESSAGES="$userLocale.UTF-8"
#LC_MONETARY="$userLocale.UTF-8"
#LC_NAME="$userLocale.UTF-8"
# Fallback, if a package using gettext does not have chosen locale:
LANGUAGE="$userLocale.UTF-8:en_US:en_GB:en"
# LC_ALL is not set here. Do not set it.
##
EOC
}


if [ "$nextPart" -eq 3 ] ; then
	find_locale
	create_etcLocaleConf
	sleep .5
	declare -g LANG="$userLocale.UTF-8"
	cd "$alatermTop"
	echo "# Locale will use UTF-8 encoding." >> status
	echo -e "userLocale=\"$userLocale\"" >> status
	echo "Set locale. Continuing..."
	let nextPart=4
	echo -e "let nextPart=4" >> status
fi


