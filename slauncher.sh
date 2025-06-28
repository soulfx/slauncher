#!/bin/sh

# Copyright (c) 2025 John Elkins
# Licensed under the MIT License. See project LICENSE file for full license text
# Project: https://github.com/soulfx/slauncher
# Version: 1.0.20250627 

# DEBUG
# uncomment to debug the script execution
#set -x

# SOURCE
# source in external libraries
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib/libdisplay.sh" # source in the display library

# USER CONFIG
# -----------------------------------------------------------------------------
# edit the following if needed

# the location of the reader.pref file
# this file is updated with the last book file when books are opened and closed
pref_file="/mnt/us/system/com.amazon.ebook.booklet.reader/reader.pref"

# name of script that will enable SLauncher after boot. No other scripts will
# run until a script with this name is read. This helps avoid boot crash loops
# where slauncher tries to launch a script that crashes the system during boot
enable_script="Enable SLauncher"

# how often to check the preference file in seconds 
pref_file_check="2"

# the file pattern to look for to determine if the book is a script
script_pattern=".sh.txt"

# RUNTIME VARS
# -----------------------------------------------------------------------------
# the following vars are populated during runtime, below are the defaults

# flag that will be toggled to "true" when the $enable_script is run
enabled="false"

last_read="" # the last read "book" as tracked in the pref_file
script_name="" # the name of the last read script without the path or extension
event_count="-1" # the number of events on the same book
prev_last_read="" # the previous value of $last_read before the current one

pref_time="0" # the current timestamp of the last change to the pref_file
prev_pref_time="0" # the previous value of pref_time before the current one

# FUNCTIONS
# -----------------------------------------------------------------------------
# the following functions are executed during runtime

# update pref_time with unix timestamp of the last change on the pref_file
update_pref_time() {
    prev_pref_time="$pref_time"
    pref_time=$(stat -c %Z "$pref_file")
    if [ "$prev_pref_time" == "0" ]; then
        prev_pref_time="$pref_time"
    fi
}

# update last_read with the LAST_BOOK_READ value from the pref_file
update_last_read() {
    prev_last_read="$last_read"
    last_read=$(cat "$pref_file" | grep "LAST" | cut -d "=" -f2)
    if [ "$prev_last_read" == "" ]; then
        prev_last_read="$last_read"
    fi
    script_name="$(basename "$last_read" $script_pattern)"
}

# return error code 0 if the $last_read matches the $script_pattern, 1 otherwise
is_script() {
    case $last_read in
        *$script_pattern) return 0;;
        *) return 1;;
    esac
}

# return error code 0 if the pref_time is different than the prev_pref_time
is_changed() {
    [ "$prev_pref_time" != "$pref_time" ]
}

# check if the last_read file has been closed, it'll be the second event
is_closed() {
    if [ "$last_read" == "$prev_last_read" ]; then
        event_count=$(expr $event_count + 1)
        event_count=$(expr $event_count % 2)
        if [ "$event_count" == "1" ]; then
            return 0
        fi
    else
        event_count=0
    fi
    return 1
}

is_enabled() {
    if [ "$enabled" == "true" ]; then
        return 0
    fi

    if [ "$script_name" == "$enable_script" ]; then
        enabled="true"
        return 0
    fi
    
    # else
    display " SLauncher is currently disabled "
    return 1
}

# check if the last_read file is a script, and launch it when it gets closed
launch_last_script() {
    update_pref_time
    if is_changed; then
      update_last_read
      if is_script && is_closed && is_enabled; then
          display " Running: $script_name . . . "
          sh "$last_read"
      fi
    fi
}

# MAIN
# -----------------------------------------------------------------------------
# the following is the main entry point

main() {

    # main loop
    while true; do
        launch_last_script
        sleep $pref_file_check
    done
}

main
