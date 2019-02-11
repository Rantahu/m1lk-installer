#!/bin/bash

# Spotify Installer for M!Lk
# by s1mb10t3 <s1mb10t3@pm.me>
# License: GNU GPLv3

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
apt-get update
apt-get install spotify-client
