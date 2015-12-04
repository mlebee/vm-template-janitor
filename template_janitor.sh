#!/bin/sh
set -e
# template_janitor.sh
# This script is meant for quick & easy cleanup of a Virtual Machine before converting it to template via
#    'curl -sSL https://raw.githubusercontent.com/mlebee/vm-template-janitor/master/template_janitor.sh | sh'

do_cleanup() {

## check if user is ROOT
[ "$USER" = "root" ] || { echo "You must be ROOT!"; exit 1; }


## echo WARNING
echo
echo "#############################################################################"
echo "WARNING: You are about to clean this machine before converting it to template"
echo "#############################################################################"
echo
echo "You may press Ctrl+C now to abort this script."
( set -x; sleep 20 )
echo
## begin cleaning
echo "Cleaning started"

# remove monit id & state files
echo " * remove monit id & state files"
rm -f /var/lib/monit/monit.state
rm -f /var/lib/monit/monit.id

# clean apt cache
echo " * clean apt cache"
apt-get  clean

# force the logs to rotate and delete
echo " * force the logs to rotate"
/usr/sbin/logrotate -f /etc/logrotate.conf
echo " * delete old logs"
find /var/log/ -type f -name "*.0" -exec rm {} \;
find /var/log/ -type f -name "*.1" -exec rm {} \;
find /var/log/ -type f -name "*.gz" -exec rm {} \;

# clear lastlog & wtmp.
echo " * clear lastlog & wtmp"
cat /dev/null > /var/log/lastlog
cat /dev/null > /var/log/wtmp

# clear temp file
echo " * clear temp file"
rm -rf /tmp/*
rm -rf /var/tmp/*

# remove the udev persistent device rules
echo " * remove the udev persistent device rules"
rm -f /etc/udev/rules.d/70*

# backup rc.local
echo " * copy rc.local"
cp /etc/rc.local /etc/rc.local.orig

# ssh cleanup
echo " * ssh cleanup"
rm -f /etc/ssh/ssh_host*

# create temporary rc.local 
echo " * create temporary rc.local"
sed -i '$ i dpkg-reconfigure openssh-server\nmv /etc/rc.local.orig /etc/rc.local' /etc/rc.local

# remove history
echo " * remove users history"
rm -f /home/*/.bash_history
echo " * remove root history"
rm -f ~/.bash_history && unset HISTFILE

## end cleaning
echo "Cleaning finished"

## Shutdown
echo
echo "#############################################################################"
echo "LAST STEP: shutdown this server!"
echo "#############################################################################"
echo
echo "You may press Ctrl+C now to abort this script."
( set -x; sleep 20 )
echo
shutdown -h now "Server is going down"
}

# wrapped up in a function so that we have some protection against only getting
# half the file during "curl | sh"
do_cleanup
