#!/bin/bash

# M1Lk Rice Installer
# by Rantahu <rantahu@gmail.com>
# License: GNU GPLv3


[ -z ${dotfiles+x} ] && dotfiles="https://github.com/rantahu/dotfiles.git"
[ -z ${requirements+x} ] && requirements="https://raw.githubusercontent.com/rantahu/m1lk-installer/master/requirements.csv"

### FUNCTIONS
initialCheck() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
  fi
  echo "Checking connection to internet?"
  ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && echo "...ok" || { echo >&2 "Please check your internet connection"; exit 1; }
  echo "Checks done!"
}

install() {
	dialog --title "M1lk Installation" --infobox "Installing \`$1\` ($n of $total). $1 $2." 5 70
	apt-get install "$1" &>/dev/null
}

makeinstall() {
	dir=$(mktemp -d)
	dialog --title "M1lk Installation" --infobox "Installing \`$(basename $1)\` ($n of $total) via \`git\` and \`make\`. $(basename $1) $2." 5 70
	git clone --depth 1 "$1" "$dir" &>/dev/null
	cd "$dir" || exit
	make &>/dev/null
	make install &>/dev/null
	cd /tmp ;
}

installLoop() { \
	([ -f "$requirements" ] && cp "$requirements" /tmp/requirements.csv) || curl -Ls "$requirements" > /tmp/requirements.csv
	total=$(wc -l < /tmp/requirements.csv)
	while IFS=, read -r tag program comment; do
	n=$((n+1))
	case "$tag" in
	"") install "$program" "$comment" ;;
	"*") makeinstall "$program" "$comment" ;;
	esac
	done < /tmp/progs.csv ;
}

### RUNTIME

# Checks
initialCheck

echo "Installing rice my dude..."
apt-get update
apt-get install dialog
install
# dkpt --install <(wget https://raw.githubusercontent.com/maestrogerardo/i3-gaps-deb/master/i3-gaps-deb)
