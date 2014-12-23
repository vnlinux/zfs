#!/usr/bin/env bash

# set path environment
PATH="/usr/bin:/bin:/usr/sbin:/sbin"

log="/var/log/zsync.log"
[ -f $log ] || touch $log

# set source and destination
src="storage"
dst="backup/storage"
srv="root@10.0.0.30"

# Main
case "$1" in 
	hourly)
		echo "Init"
		;;
	daily)
		echo "Sync"
		;;
	*)
		echo "Usage: zsync.sh {hourly|daily}"
		exit 2
esac

# snapshot name
if [ "$1" = "hourly" ]; then
	time1="%m%d_%H"
	time0="%m%d_%H --date='-1 hour'"
elif [ "$1" = "daily" ]; then
	time1="%m%d"
	time0="%m%d --date='-1 day'"
fi

snap1="$src@$time1"
snap0="$src@$time0"

# run it now
echo "### $time1 ###"                                           >> $log
echo "zfs snapshot $snap1"                                      >> $log
echo "zfs send -i $snap0 $snap1 | ssh $srv zfs recv -v $dst"    >> $log
zfs snapshot $snap1 
zfs send -i $snap0 $snap1 | ssh $srv zfs recv -v $dst 
