# Kindle Script Launcher (slauncher)

A script launcher for kindle eink devices.

    Copyright (c) 2025 John Elkins
    Licensed under the MIT License. See project LICENSE file for full license text
    Project: https://github.com/soulfx/slauncher
    Document Revision: 1.0.20250628

## Overvierw

Checks for when "books" are closed. If they are shell scripts, it will execute the shell script.

Provides a way to launch apps and execute pre-configured shell commands directly via the kindle's reader application.

## Quirks

 1. The shell script will launch on exit from reading the shell script, not when entering it.
    
    This was mainly to work around an issue where some qt based apps (like K3Chess) suspended the kindle reader app causing the open/close events to not register correctly.  It's more predictable to have the app launch on exit of the script.
 2. The script launcher must be enabled after each boot by the user.
    
    This step prevents scripts from launching during boot that could cause a crash boot loop which is very difficult to recover from. It is slightly inconvienant to enable it on each restart, but the safety it provides outweighs the annoyance.
    
    A majority of the time the kindle device will just be put to sleep, not shutdown.  If the script launcher is already enabled, when the device goes to sleep and is woke back up it doesn't have to be re-enabled after it wakes up.
 3. Not really a quirk specific to this launcher, and applies to ther other launchers, but this will enable launching commands as the root user on the device.  With that in mind, every precaution should be taken on what commands are entered into the scripts that will be executed by this launcher.
  4. The script uses file polling to check for open/close of book events which is a bit inefficient.  There is no inotify on the device. This may have an impact on battery usage.  The polling frequency is 2 seconds and could be increased if battery impacts are noticed.

## Comparison

This script is an alternative to other launchers for kindle such as KUAL and launchpad.

The main benefits of this script and reason for which it was created are:
 1. No need to remember and enter complex keyboard shortcut key combinations (vs launchpad)
 1. No need to launch another app to run the script (vs KUAL)
 1. No need to worry about developer certificates that expire (vs KUAL)

    see: [Cannot open KUAL; The permissions to open this item have expired](https://www.mobileread.com/forums/showthread.php?t=367665)

## Installation

The installation of this launcher is a manual process at this moment.

### Compatibility

This script launcher is known to work on the following devices.  It will most likely work with other similar kindle devices, but they haven't been tested.

 1. Kindle 3 (Keyboard)

### Prereqs

 1. The kindle device has the USB Network Hack successfully applied
 1. An SSH session has been established to the kindle device
 1. This git repo has been downloaded as a zipfile (it contains all the needed components)
 1. Familiarity with shell commands and linux system administrative concepts 

### Steps

NOTE the following will be consolidated into an installation script at some point.

CAUTION Once the root is mounted as read/write be very careful from that point on to not accidentally delete, change, or modify files that weren't intended to be modified.

 1.  Extract the contents of the slauncher repo zipfile to `/mnt/us/slauncher`.
 2.  Move the scripts directory to documents `mv -i /mnt/us/slauncher/scripts /mnt/us/documents`
 3.  Refresh the Book List `sh "/mnt/us/documents/scripts/Refresh Books.sh.txt"`
 4.  Remount the root as read/write `mntroot rw`
 5.  Install the script launcher service `mv -i /mnt/us/slauncher/service/slauncher /etc/init.d`
 6.  Enable it on startup `cd /etc/rc5.d/ &&  ln -s ../init.d/slauncher S92slauncher`
 7.  Remount the root as read only `mntroot ro`
 8.  Start the script launcher service `/init.d/slauncher start`

## Usage

### Enabling the script launcher

The script launcher is disabled by default on device startup.  See [Quirks #2](#Quirks)

If when launching a script, the message " SLauncher is currently disabled " is displayed at the bottom of the screen, execute the "Enable SLaucher" script to enable it.  It will remain enabled while the device is active and when it re-awakes.

### Launching scripts

 1. From the kindle reader, find the script and click to open
 2. When the script has opened, click back to close the script
 3. When the kindle reader has closed the script, the script launcher service will launch the script.  The message " Running: \<script name here\> . . ." will display at the bottom of the screen.

### Adding new scripts

 1. Place scripts to launch in the `/mnt/us/documents/scripts` directory. They don't need to be under the scripts subdirectory but it can be helpful to keep them all in one spot.
 2. Ensure the script filename ends with `.sh.txt`
 3. Execute the "Refresh Books" script to pick up on the new script in the kindle reader.
