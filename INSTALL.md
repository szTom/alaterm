## HOW TO INSTALL OR REMOVE ALATERM IN TERMUX

You need the file _00-alaterm.bash_. It will fetch the remaining files,
unless you already have them in the same directory.

### In Termux:
```
pkg install wget
wget https://raw.githubusercontent.com/cargocultprog/alaterm/master/00-alaterm.bash
bash 00-alaterm.bash ACTION
```
where ACTION is one of:  `install  remove  help  version`

_install_
Installs a customized version of Arch Linux ARM within Termux.

_remove_
Removes an existing installation, in the default location.
You will be asked for confirmation.
If you installed somewhere else, the script cannot find it.

_help_
Provides a short help message.

_version_
Provides script version information.



### WHAT INSTALLATION DOES
```
bash 00-alaterm.bash install
```
That is all you need to do. Sit back, and let your device do the thinking.

1. Your device should be plugged into a power supply, or fully charged.
Installation may take 40-60 minutes, and consumes a lot of power.

2. The scripts are designed so that progress is recorded in a status file.
If you are interrupted, perhaps because you must shut down your device
or because you lost Internet connection, then re-launch 00-alaterm.bash.
It will resume where it left off.

3. If necessary, other alaterm scripts are downloaded from the alaterm
project at GitHub. If you unpacked a downloaded *.zip file, then the
local files are used.

4. Your device is examined for compatibility. In most cases, the result
is accept or reject. In some marginal cases, you will be asked whether or not
you wish to install. If your device is accepted, installation continues.

5. The script will request a wakelock. Android may ask if you will allow it
to stop battery optimization. You may allow or deny. The script may complete
faster if you allow. Battery optimization is automatically restored when
the script completes or fails.

6. A large archive is downloaded from the Arch Linux ARM project.
It is about 450MB. After download, its md5sum is checked.

7. After successful download, the archive is unpacked. This step takes time,
but does not provide much feedback. Be patient.

8. The script logs into the unpacked installation as root. Please understand
that this is only root relative to alaterm. It is not Android root. 
The existing Arch Linux ARM files are updated. You may see warnings or
errors regarding Arch attempts to re-create its kernel. Ignore them.
Your installation does not have an Arch kernel, it uses Android kernel.
A new user is created with alaterm administrator privileges.
Then root logs out.

9. The script logs in as the new user. Then it downloads and installs the
LXDE graphical desktop. This is a large download. During installation,
there will be occasional messages about lack of bus connection,
or lack of initialization. Not a problem. Normal for this installation.
If your Internet connection is broken during download, simply wait
awhile then re-launch the install script. It will continue from before.

10. After LXDE is installed, the script creates or edits various files
that configure the desktop and its pre-installed software.

11. The script logs out of alaterm, and creates a launch script for Termux.
You are notified of completion. Termux displays information regarding
how to launch alaterm. The default launch command is:  alaterm

You do not need a password to launch alaterm. You do not need a password
to install or update software. Actually, there is a password (it is password)
but it is applied automatically.

12. When alaterm is launched, you may use the command-line terminal
for some purposes. Installing and removing software is performed via
command line. Some programs use the command line.

To see the LXDE graphical desktop, keep Termux running, and open the
VNC Viewer app. You will see alaterm at 127.0.0.1:5901.
Its password is password.



### UPDATES TO ALATERM

Once alaterm is installed and running, that is all.

It is always possible that something needs to be corrected,
without re-installation. Or, a new capability may appear in Termux,
and that will enable a new capability in alaterm.

You can check for possible new information in the NEWS.md file,
at the alaterm project page on GitHub.



### ABOUT BUGS AND SOFTWARE AVAILABILITY

Please understand that alaterm does not provide software. All it does is
install software provided by the Arch Linux ARM project.

So, if you have a package request, or found a software bug, do not report it
to the alaterm project.

