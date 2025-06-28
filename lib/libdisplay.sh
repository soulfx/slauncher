# Copyright (c) 2025 John Elkins
# Licensed under the MIT License. See project LICENSE file for full license text
# Project: https://github.com/soulfx/slauncher
# Version: 1.0.20250627 

# credit for the concept of these functions goes towards dsmid's freedownload hack
# https://www.mobileread.com/forums/showthread.php?t=121008

# these functions were extracted and modified from the freedownload script

_FUNCTIONS=/etc/rc.d/functions
[ -f ${_FUNCTIONS} ] && . ${_FUNCTIONS} # source

_EIPUTS=/usr/sbin/eiputs
[ -f ${_EIPUTS} ] && . ${_EIPUTS} # source

display_init() {
    update_screen_info
    export EI_ROW=39
    export width=49
    [ "$SCREEN_X_RES" == "600" ] || export EI_ROW=28
    [ "$SCREEN_X_RES" == "600" ] || export width=65
}

display() {
  local content="$1"
  [[ "flatten" == "$2" ]] && content="$(echo $content)"
  display_init
  local lines=$(( $(echo "$content" | wc -l) - 1))
  export EI_ROW=$(($EI_ROW-$lines))
  echo "$content" | while read line; do
    puts "$(printf "%${width}s" ' ' )"
    export EI_ROW=$(($EI_ROW-1))
    puts "$(printf "%-${width}s" " $line" || dd bs=1 count=${width})"
  done
}


puts_init
display_init
