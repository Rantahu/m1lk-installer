#!/bin/bash

# M!Lk Rice Installer
# by Rantahu <rantahu@gmail.com>
# License: GNU GPLv3

### Vars
[ -z ${dotfiles+x} ] && dotfiles="https://github.com/rantahu/dotfiles.git"
[ -z ${requirements+x} ] && requirements="https://raw.githubusercontent.com/rantahu/m1lk-installer/master/requirements.csv"

### FUNCTIONS
initialCheck() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
  fi
  echo -ne "Checking connection to internet..."
  ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && echo " Ok!" || { echo >&2 "Please check your internet connection"; exit 1; }
  echo "Checks done!"
}

install() {
	echo -ne "M!lk Installation - Installing \`$1\` ($n of $total). $1 $2..."
  apt-get install "$1" &> /dev/null
  echo " Done!"
}

makeInstall() {
	dir=$(mktemp -d)
	echo -ne "M!lk Installation - Installing \`$(basename $1)\` ($n of $total) via \`git\` and \`make\`. $(basename $1) $2."
	git clone --depth 1 "$1" "$dir" &>/dev/null
	cd "$dir" || exit
	make &>/dev/null
	make install &>/dev/null
	cd /tmp ;
}


gitInstall() {
  echo -ne "M!lk Installation - Installing \`$(basename $1)\` ($n of $total) via \`git\` and \`make\`. $(basename $1) $2."
  cd /home/"$user" &&  git clone "$1"
}

installPackages() { \
	([ -f "$requirements" ] && cp "$requirements" /tmp/requirements.csv) || curl -Ls "$requirements" > /tmp/requirements.csv
	total=$(wc -l < /tmp/requirements.csv)
	while IFS=, read -r tag program comment; do
	n=$((n+1))
	case "$tag" in
	"") install "$program" "$comment" ;;
	"*") makeInstall "$program" "$comment" ;;
  "g") gitInstall "$program" "$comment" ;;
	esac
  done < /tmp/requirements.csv ;
}

installRice() {
	echo -ne "Downloading and installing config files..."
	git clone "$1" /tmp/dotfiles &>/dev/null
	mkdir -p "$2"
	cp -rT /tmp/dotfiles/. "$2"
  echo " Done"
}

### RUNTIME

# Checks
initialCheck
echo "Updating APT..."
# apt-get update &>/dev/null
echo "Which user do you want this rice to be installed on?"
read user
echo "Installing required packages..."
installPackages
echo "Installing RICE..."
installRice "$dotfiles" "/home/$user/.config"
# dkpt --install <(wget https://raw.githubusercontent.com/maestrogerardo/i3-gaps-deb/master/i3-gaps-deb)
