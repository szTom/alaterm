## HOW TO INSTALL OR REMOVE ALATERM IN TERMUX

You only need the file _00-alaterm.bash_. It will fetch the remaining files,
unless you already have them in the same directory.

_Requirements:_ Android 8 or later. Tested with Android 9.
ARM CPU 32- or 64-bit. Includes many tablets, phones, and some Chromebooks.
Kernel 4 or later. You almost certainly have this, with recent Android.
3GB free space for minimal setup. 4GB to be useful, 5GB for serious work.
Installation must be to on-board storage. Cannot install to removable media.
Use with rooted devices is possible, but discouraged.
Termux app, and VNC Viewer app. Available at Google Play or F-Droid.
Optional: External keyboard and mouse. Bluetooth works.


### In Termux:
```
pkg install wget
wget https://raw.githubusercontent.com/cargocultprog/alaterm/master/00-alaterm.bash
bash 00-alaterm.bash ACTION
```
where ACTION is one of:  `install  remove  help  version`

_install_
Installs a customized version of Arch Linux ARM within Termux.
Continues a partial installation that was interrupted.
Possibly adds new features (if any) to existing installation.
Does not over-write existing installation without requesting permission.

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
or because you lost Internet connection, then re-launch:
```
bash 00-alaterm.bash install
```
It will resume where it left off.

3. If necessary, other alaterm scripts are downloaded from GitHub.
If you unpacked a downloaded *.zip file, then the local files are used.

4. Your device is examined for compatibility.
In most cases, the result is accept or reject.
In some marginal cases, you will be asked whether or not you wish to install.
If your device is accepted, installation continues.

5. The script will request a wakelock.
Android may ask if you will allow it to stop battery optimization.
You may allow or deny. The script may complete faster if you allow.
Battery optimization is restored when the script completes or fails.

6. A large archive is downloaded from the Arch Linux ARM project.
It is about 450MB. After download, its md5sum is checked.

7. After successful download, the archive is unpacked into _proot_ susbsystem.
This step takes time, but does not provide much feedback. Be patient.

8. The script logs into the unpacked installation as root.
This is only root relative to alaterm. It is not Android root. 
The existing Arch Linux ARM files are updated.
Ignore warnings or errors regarding Arch attempts to re-create its kernel.
Your installation does not have an Arch kernel. It uses Android kernel.
A new user is created with alaterm administrator privileges.
Then root logs out.

9. The script logs in as the new user.
It downloads and installs the LXDE graphical desktop. Download is large.
Ignore messages about lack of bus connection, or lack of initialization.
If your Internet connection is broken during download, simply wait
awhile then re-launch the install script. It will continue from before.

10. After LXDE is installed, the script creates or edits various files
that configure the desktop and its pre-installed software.

11. The script logs out of alaterm, and creates a launch script for Termux.
Termux displays information regarding how to launch alaterm.
The default launch command is:  _alaterm_
You do not need a password to launch alaterm.
You do not need a password to install or update software.
Actually, the password is _ password_ and is applied automatically.

12. When alaterm is launched, it may be used by command-line, GUI, or both.
Installing and removing software is performed via command line.
Some optional programs, such as _ffmpeg_ and _imagemagick_, use the command line.
To see the LXDE graphical desktop, you must launch the VNC Viewer app.
Keep Termux running. You will see alaterm at 127.0.0.1:5901 in VNC Viewer.
Its password is _password_.
The initial desktop has wallpaper, taskbar, Menu, File Manager.
If you use a mouse, right-click is enabled for context menus.



### UPDATES TO ALATERM

Once alaterm is installed and running, that is all you need to do.
Programs such as _gimp_ and _libreoffice-still_ are installed via command line.

It is always possible that something needs to be corrected,
without re-installation. Or, a new capability may appear in Termux,
and that will enable a new capability in alaterm.

You can check for possible new information in the NEWS.md file,
at the alaterm project page on GitHub.

If you re-run `bash 00-alaterm.bash install` with an existing installation,
then any non-destructive updates will be automatically applied.


### WHERE ALATERM IS INSTALLED

Termux home, where it opens, is Android `/data/data/com.termux/files/home`.
Termux keeps its programs in `/data/data/com.termux/files/usr`.
The above directory is known as `$PREFIX` in Termux (but not in alaterm).
Default alaterm installation is to `/data/data/com.termux/alaterm`.
So alaterm is neither in Termux home, nor in Termux $PREFIX.
Benefits: If you ever clean out Termux home or $PREFIX, alaterm remains.
A copy of its launch script is at `/data/data/com.termux/alaterm/alaterm`.
If necessary, you may copy the launch script to `$PREFIX/bin`.


### ABOUT BUGS AND SOFTWARE AVAILABILITY

Please understand that alaterm does not provide software.
All it does is install software provided by the Arch Linux ARM project.

If you have a request, or found a software bug, _do not_ report it here.

If you found a bug in the installation script, then _do_ report it here.

Alaterm is not configured for multimedia. Absence of audio is not a bug. 

