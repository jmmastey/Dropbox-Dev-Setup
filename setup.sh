#!/bin/bash
#
# Dropbox Developer PC Setup
# ====================================
# Setup a new developer PC with all the bangles and widgets you're used to.
#

function link_file() { echo "Replacing $1"; rm -rf $1; ln -s $2 $1; chown -h $3:$3 $1; }

dbox=$(pwd)
host=$(hostname)
if [[ "$(whoami)" != "root" ]]; then echo "Sorry, please use this util as root"; exit 1; fi
if [[ !(-f "$dbox/setup.sh") ]]; then echo "Operate the script from the dropbox folder"; exit 1; fi

# sets up the symlinks to portable configuration. use this on a new machine to get back into sync
echo -ne "Select user to replace (caution: very destructive to your system): "
read -e user
if [[ ! $user ]] || [[ !(-d "/home/$user") ]]; then echo "No user info (or wrong info) entered. Aborting linking."; exit 1; fi
home=/home/$user

# install existing packages
aptitude install $(cat packages.txt | tr '\n' ' ')

# install clean home folder replacements
function home_sub() { tgt=`echo $1 | sed -e "s#.*/##"`; link_file "$home/$tgt" "$2/$tgt" "$user"; }
for sub in $(find "./home" -maxdepth 1 -mindepth 1 | grep -v example.ls); do home_sub "$sub" "$dbox/home"; done
for sub in $(find "./machines/$host/home" -maxdepth 1 -mindepth 1 | grep -v example.ls); do home_sub "$sub" "$dbox/machines/$host/home"; done

# /etc replacements 
function etc_sub() { tgt=`echo $1 | sed -e "s#.*/##"`; link_file "/etc/$tgt" "$2/$tgt" "$user"; }
for sub in $(find "./etc" -maxdepth 1 -mindepth 1 | grep -v example.ls); do etc_sub "$sub" "$dbox/etc"; done
for sub in $(find "./machines/$host/etc" -maxdepth 1 -mindepth 1 | grep -v example.ls); do etc_sub "$sub" "$dbox/machines/$host/etc"; done

# local bin replacements
function local_sub() { tgt=`echo $1 | sed -e "s#.*/##"`; link_file "/usr/local/bin/$tgt" "$2/$tgt" "$user"; }
for sub in $(find "./usr/local/bin" -maxdepth 1 -mindepth 1 | grep -v example.ls); do local_sub "$sub" "$dbox/usr/local/bin"; done

# dirty replacements :(
link_file "$home/.ssh/ssh_config" "$dbox/manual/ssh_config" "$user"

# replace www folder
echo "Replacing /var/www/*"
find /var/www/ -maxdepth 1 -type l | xargs rm; ln -s $dbox/www/* /var/www

echo "Completed changes. All files will be synced to dropbox and other developer PCs"
