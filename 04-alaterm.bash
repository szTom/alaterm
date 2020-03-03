# Part of the alaterm project, https://github.com/cargocultprog/alaterm/
# This file is: https://raw.githubusercontent.com/cargocultprog/alaterm/master/04-alaterm.bash
#

echo "$(caller)" | grep -F 00-alaterm.bash >/dev/null 2>&1
if [ "$?" -ne 0 ] ; then
echo "Script 04-alaterm.bash is not stand-alone."
echo "It must be sourced in sequence from 00-alaterm.bash."
echo "Exit." ; exit 1
fi


##############################################################################
## INSTALLER PART 04. Create fake bind files.
##############################################################################


# Some applications want access to processes or devices concealed by Android.
# This problem can often be solved by fake responses, via the bind mechanism.
# Caution: Since these are fake, anything needing real responses may fail.

create_fakePS() { # Takes one argument: 4 6 or 8.
	[ "$1" = "0" ] && return # Did not get a useful result.
	local fc="1111111 1111111 1111111 1111111 1111111 1111111 1111111 0 0 0"
	local ff="cpu 4444444 4444444 4444444 4444444 4444444 4444444 4444444 0 0 0"
	local fs="cpu 6666666 6666666 6666666 6666666 6666666 6666666 6666666 0 0 0"
	local fe="cpu 8888888 8888888 8888888 8888888 8888888 8888888 8888888 0 0 0"
	local cpu=""
	local cpiv="cpu0 $fc\ncpu1 $fc\ncpu2 $fc\ncpu3 $fc"
	case "$1" in
		4 ) cpu="$ff\n$cpiv" ;;
		6 ) cpu="$fs\n$cpiv\ncpu4 $fc\ncpu5 $fc" ;;
		8 ) cpu="$fe\n$cpiv\ncpu4 $fc\ncpu5 $fc\ncpu6 $fc\ncpu7 $fc"  ;;
		* ) echo "Error creating fakePS." ; exit 1 ;;
	esac
	local intr="intr 123456789"
	local -i n=0
	while [ $n -lt 500 ] ; do
		intr+=" 0"
		let n=n+1
	done
	printf "$cpu\n" > "$alatermTop/var/binds/fakePS"
	printf "$intr\n" >> "$alatermTop/var/binds/fakePS"
	printf "ctxt 1234567890\n" >> "$alatermTop/var/binds/fakePS"
	printf "btime 1234567890\n" >> "$alatermTop/var/binds/fakePS"
	printf "processes 1234567\n" >> "$alatermTop/var/binds/fakePS"
	printf "procs_running 3\n" >> "$alatermTop/var/binds/fakePS"
	printf "procs_blocked 0\n" >> "$alatermTop/var/binds/fakePS"
	printf "softirq 23456789 12345 1234567 234567 3456 56789 45678 123456 24680 13579\n" >> "$alatermTop/var/binds/fakePS"
}

count_processors() { # This picks the appropriate size, counting from 0:
	grep cessor /proc/cpuinfo >lpa 2>/dev/null
	cat lpa | sed '/model/d' | sed '/name/d' > lpb
	cat lpb | sed 's/[^0-9]*//g' > lpc
	cat lpc | tr -d '\n' > lpd
	lastProc="$(cat lpd | tail -c 1)" 2>/dev/null
	if [ "$?" -ne 0 ] || [[ "$lastProc" -le 3 ]] ; then
		processors=4
	elif [[ "$lastProc" -le 5 ]] ; then
		processors=6
	elif [[ "$lastProc" -le 7 ]] ; then
		processors=8
	else
		processors=0 # That is, this routine failed.
	fi
	rm -f lpa lpb lpc lpd
}

create_fakePV() {
cat << 'EOC' > "$alatermTop/var/binds/fakePV" # No hyphen, quoted marker.
Linux version 4.14.15 (user@fake.example.com)
(gcc version 8.2.1 20180730 (Android Linux 9.1.1))
#1 Wed Dec 12 12:34:50 PST 2018
EOC
}


if [ "$nextPart" -eq 4 ] ; then
	mkdir -p "$alatermTop/var/binds"
	cd "$alatermTop"
        if [ ! -r /proc/stat ] ; then
		count_processors
		create_fakePS "$processors"
	fi
	echo "let processors=$processors" >> status
	if [ ! -r /proc/version ] ; then
		create_fakePV
	fi
	sleep .5
	echo "Created fake binds. Continuing..."
	let nextPart=5
	echo "let nextPart=5" >> status
fi


