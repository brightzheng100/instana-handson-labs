#!/bin/bash

color_green="\x1b[32m"
color_red="\x1b[31m"
color_yellow="\x1b[33m"
color_end="\x1b[m"

SLEEP_DURATION=1

#
# Logging
#
# Usage: 
#   logme "<COLOR CODE>" "<Message>"
# For example:
#   logme "$color_green" "done"
#
function logme {
  printf "  $1 $2 ${color_end}\n"
}

#
# export $1 with given default value of $2, if $1 doesn't exist or set
# Usage:
#   export_var_with_default <VAR NAME> <VAR'S DEFAULT VALUE> [<1 to FORCE TO SET WITH DEFAULT VALUE>]
#   where
#     $1 - the var name
#     $2 - the var default value
#     $3 - optional, "1" to force set with default value
# Example:
#   export_var_with_default "MY_VAR" "DEFAULT_VALUE"
#
function export_var_with_default() {
  var_name=$1
  var_default_value=$2
  var_force_set=$3

  #echo "params: $var_name, $var_default_value, $var_force_set"
  var_current_value=""
  eval var_current_value='$'"$var_name"

  #echo "before: $var_name = $var_current_value"

  # if $1 doesn't exist or set
  if [[ "x${var_current_value}" == "x" || "${var_force_set}" == "1" ]]; then
    var_current_value="$var_default_value"
  fi
  export $var_name="$var_current_value"
  #echo "after: $var_name = ${var_current_value}"
}

#
# Diplay a progress bar while waiting things, which looks like:
# ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇| 100% - waiting for 2 mins
# Usage:
#   progress-bar <TIME IN MINUTES>
# Example:
#   progress-bar 1
#
function progress-bar {
  local duration
  local columns
  local space_available
  local fit_to_screen  
  local space_reserved

  space_reserved=30                     # reserved width for the message like: | 100% - waiting for 20 mins
  duration=${1}                         # by mins
  duration=$(( duration*60 ));          # convert it to seconds
  if [[ "$__DEBUG__" == "true" ]]; then # this is for debug mode only to accelerate things
    duration=10; 
  fi  
  columns=$(tput cols)
  space_available=$(( columns-space_reserved ))

  if (( duration < space_available )); then 
  	fit_to_screen=1; 
  else 
    fit_to_screen=$(( duration / space_available ));
    fit_to_screen=$((fit_to_screen+1)); 
  fi

  already_done() { for ((done=0; done<(elapsed / fit_to_screen) ; done=done+1 )); do printf "▇"; done }
  remaining() { for (( remain=(elapsed/fit_to_screen) ; remain<(duration/fit_to_screen) ; remain=remain+1 )); do printf " "; done }
  percentage() { printf "| %s%% - waiting for %s mins" $(( ((elapsed)*100)/(duration)*100/100 )) $(( (duration)/60 )); }
  clean_line() { printf "\r"; }

  for (( elapsed=1; elapsed<=duration; elapsed=elapsed+1 )); do
      already_done; remaining; percentage
      sleep "$SLEEP_DURATION"
      clean_line
  done
  clean_line
  printf "\n";
}

#
# export $1 with given default value of $2, if $1 doesn't exist or set
# Usage:
#   export_var_with_default <VAR NAME> <VAR'S DEFAULT VALUE> [<1 to FORCE TO SET WITH DEFAULT VALUE>]
#   where
#     $1 - the var name
#     $2 - the var default value
#     $3 - optional, "1" to force set with default value
# Example:
#   export_var_with_default "MY_VAR" "DEFAULT_VALUE"
#
function export_var_with_default() {
  var_name=$1
  var_default_value=$2
  var_force_set=$3

  #echo "params: $var_name, $var_default_value, $var_force_set"
  var_current_value=""
  eval var_current_value='$'"$var_name"

  #echo "before: $var_name = $var_current_value"

  # if $1 doesn't exist or set
  if [[ "x${var_current_value}" == "x" || "${var_force_set}" == "1" ]]; then
    var_current_value="$var_default_value"
  fi
  export $var_name="$var_current_value"
  #echo "after: $var_name = ${var_current_value}"
}
