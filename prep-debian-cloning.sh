#!/bin/bash

# prep ubuntu for cloning
# details: https://www.reddit.com/r/Proxmox/comments/plct2v/are_there_any_current_guides_on_templatingcloning/

this_file=${0##*/}
this_user=$SUDO_USER

id

if [ `id -u` -ne 0 ]; then
	echo Need sudo
	exit 1
fi

cd ~

wget -O run_first.sh "https://github.com/teaberryou/homelab/blob/14390402378ae09c07db72619e57ba46d0a66bf9/run_first.sh?raw=true"
chmod +rwx run_first.sh
chown $this_user:$this_user run_first.sh

#wget https://script_server/scripts/sshd_config

#cat sshd_config > /etc/ssh/sshd_config
#rm sshd_config

#update apt-cache
apt update
apt -y full-upgrade

#install packages
apt install -y qemu-guest-agent chrony

#flush the logs
logrotate -f /etc/logrotate.conf

#Stop services for cleanup
service rsyslog stop

#clear audit logs
if [ -f /var/log/audit/audit.log ]; then
    cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
    cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    cat /dev/null > /var/log/lastlog
fi

#reset machine-id
if [ -f /etc/machine-id ]; then
    cat /dev/null > /etc/machine-id
fi
if [ -f /var/lib/dbus/machine-id ]; then
    cat /dev/null > /var/lib/dbus/machine-id
fi

#cleanup persistent udev rules
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    rm /etc/udev/rules.d/70-persistent-net.rules
fi

#cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

#cleanup current ssh keys
rm -f /etc/ssh/ssh_host_*

#cleanup apt
apt clean
apt autoremove

rm ~/$this_file
