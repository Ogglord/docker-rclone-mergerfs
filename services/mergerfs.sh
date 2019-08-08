#!/bin/sh
Dependencies="rclone"

misdep (){
  echo "MergerFS: Cannot start until $Dependencies is running."
  exit 1
}

shutdown (){
  printf "\r\nMergerFS: Got kill signal...\r\n"
  pid=$(pidof mergerfs)
  kill -TERM $pid
  fuse_unmount "/mnt/cloud"
  fuse_unmount "/mnt/merged"
  echo "MergerFS: Exiting MergerFS watcher"
  exit
}

fuse_unmount () {
	if grep -qs "$1 " /proc/mounts; then
		echo "MergerFS: Unmounting: fusermount -uz $1 at: $(date +%Y.%m.%d-%T)"
		fusermount -uz $1
	else
	    echo "MergerFS: No need to unmount $1"
	fi
}

## graceful shutdown
trap 'shutdown' 1 2 3 4 5 15 

## check dependencies are running
sv check $Dependencies >/dev/null || misdep

echo "MergerFS: Starting in 10 seconds..."
sleep 10 #allow time for rclone to spin up...

if ! grep -qs "/mnt/cloud " /proc/mounts; then
  echo "MergerFS: /mnt/cloud not mounted, cannot proceed..."
  exit $?
fi

echo "MergerFS: Creating drive (/mnt/merged) overlaying (/mnt/cache) and (/mnt/cloud) - writes are directed at /mnt/cache"
mergerfs -o async_read=false,use_ino,allow_other,auto_cache,func.getattr=newest,category.action=all,category.create=ff /mnt/cache:/mnt/cloud /mnt/merged
wait ${!}

while sv check $Dependencies >/dev/null; do
   sleep 30
done

echo "MergerFS: Rclone service stopped. MergerFS watcher stopping at: $(date +%Y.%m.%d-%T)"
fuse_unmount
exit $?


