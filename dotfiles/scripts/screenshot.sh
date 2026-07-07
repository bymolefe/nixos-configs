#!/usr/bin/env bash

## A shell script to automate taking screenshots
# - using hyprshot and satty

# some useful definitions
scrPath="$HOME/Pictures/screenshots"
fileName="$(date +%F_%T)"
dsc="/dev/null"
mode=$1

lockfile="/tmp/screenshot.lock"

if [ -e "$lockfile" ]; then
  notify-send -h int:transient:1 "Screenshot" "A screenshot process already exists"
  exit 1
else
  touch "$lockfile"
  trap "rm -fv $lockfile" EXIT
fi

# ensure screenshots directory exits
if [[ ! -d "$scrPath" ]]; then
  echo "screenshot:: Screenshot path does not exist"
  echo "$(mkdir -vp "$scrPath")"
fi

# array of commands and usage
declare -A commands=(
  ["region"]="Select a region to capture"
  ["window"]="Capture a specific window"
  ["monitor"]="A fullscreen capture"
)

# capture the screen with specified mode and open it in satty
capture() {
  # $z : freezes the screen if mode = region
  # $act : specifies the active monitor if mode = monitor
  hyprshot $z $act -m $mode --r | tee >(wl-copy) | satty --filename - --output-filename "$scrPath/$fileName.png" 2>$dsc
}

# handle parameters
case "$mode" in
window)
  capture $mode
  ;;
output)
  act="-m active" # will later decide if i want this feature
  capture $mode $act
  ;;
region)
  z="-z"
  capture $mode $z
  ;;
"" | *)
  echo "Screenshot:: invalid parameters passed"
  echo "Usage:: "

  for command in "${!commands[@]}"; do
    printf "\t%-10s %s\n" "$command" "${commands[$command]}"
  done
  exit 1
  ;;
esac
