#!/bin/bash

# M!Lk Rice Installer
# by s1mb10t3 <s1mb10t3@pm.me>
# License: GNU GPLv3

### Vars
[ -z ${dotfiles+x} ] && dotfiles="https://github.com/s1mb10t3/dotfiles.git"
[ -z ${requirements+x} ] && requirements="https://raw.githubusercontent.com/s1mb10t3/m1lk-installer/master/requirements.csv"

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

userCheck() {
  echo "Which user do you want this rice to be installed on?"
  while true; do
    read user
    if id "$user" >/dev/null 2>$user; then
      rm $user
      break
    else
      echo "User \`$user\` does not exist... Please enter a user that exist..."
    fi
  done
}


install() {
	echo -ne "M!lk Installation - Installing \`$1\` ($n of $total). $1 $2..."
  apt-get -y --force-yes install "$1" &>/dev/null
  echo " Done!"
}

makeInstall() {
	dir=$(mktemp -d)
	echo -ne "M!lk Installation - Installing \`$(basename $1)\` ($n of $total) via \`git\` and \`make\`. $(basename $1) $2."
	sudo -u "$user" git clone --depth 1 "$1" "$dir" &>/dev/null
	cd "$dir" || exit
	make &>/dev/null
	make install &>/dev/null
	cd /tmp ;
}


gitInstall() {
  echo -ne "M!lk Installation - Installing \`$(basename $1)\` ($n of $total) via \`git\` and \`make\`. $(basename $1) $2."
  cd /home/"$user" && sudo -u "$user"  git clone "$4"
}

debInstall() {
  echo -ne "M!lk Installation - Installing \`$1\` ($n of $total). $1 $2..."
  wget -O /tmp/"$1" "$3" && dpkg -i /tmp/"$1"
}

tarInstall() {
  echo "noot"
}

installPackages() { \
	([ -f "$requirements" ] && cp "$requirements" /tmp/requirements.csv) || curl -Ls "$requirements" > /tmp/requirements.csv
	total=$(wc -l < /tmp/requirements.csv)
	while IFS=, read -r tag program comment url options; do
	n=$((n+1))
	case "$tag" in
	"") install "$program" "$comment" "$options";;
  "git") gitInstall "$program" "$comment" "$url" "$options";;
  "deb") debInstall "$program" "$comment" "$url" "$options";;
  "tar") tarInstall "$program" "$comment" "$url" "$options";;
	esac
  done < /tmp/requirements.csv ;
}

installRice() {
	echo -ne "Downloading and installing config files..."
	sudo -u "$user" git clone "$1" /tmp/dotfiles &>/dev/null
	sudo -u "$user" mkdir -p "$2"
	sudo -u "$user" cp -rf /tmp/dotfiles/i3 /tmp/dotfiles/compton \
                  /tmp/dotfiles/qutebrowser /tmp/dotfiles/rofi \
                  /tmp/dotfiles/colorcheatsheet.css /tmp/dotfiles/gtk-3.0 "$2"
  cp -f /tmp/dotfiles/grub /etc/default/
  cp -f /tmp/dotfiles/images/grub.png /usr/share/images/
  update-grub
  echo " Done"
}

installi3Gaps() {
  echo "Installing i3-Gaps and it's dependencies"
  apt-get -y --force-yes install libxcb-keysyms1-dev libpango1.0-dev \
          libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev \
          libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev \
          libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev \
          libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0-dev &>/dev/null
  sudo -u "$user" git clone https://www.github.com/Airblader/i3 /tmp/i3-gaps &>/dev/null
  cd /tmp/i3-gaps
  autoreconf --force --install &>/dev/null
  rm -rf build/
  sudo -u "$user" mkdir -p build && cd build/ &>/dev/null
  ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers &>/dev/null
  make &>/dev/null
  make install &>/dev/null
}

optionalInstall(){
  # TO DO:
  #
  # Ask user to install extra optional programs
  echo "noot"
}

### RUNTIME

# Checks
initialCheck
echo "Updating APT..."
apt-get -y --force-yes update &>/dev/null
apt-get -y --force-yes install curl git dh-autoreconf &>/dev/null
userCheck
installi3Gaps
echo "Installing required packages..."
installPackages
apt -y --force-yes autoremove &>/dev/null
echo "Installing RICE..."
installRice "$dotfiles" "/home/$user/.config"
