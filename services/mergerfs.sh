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
  wait $pid
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

echo "MergerFS: Starting in 8 seconds..."
sleep 8 #allow time for rclone to spin up...

if ! grep -qs "/mnt/cloud " /proc/mounts; then
  echo "MergerFS: /mnt/cloud not mounted, cannot proceed..."
  exit $?
fi

target=/mnt/merged/
if find "$target" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    echo "MergerFS: Error! Target drive '$target' is not empty - fix and restart container..."
    exit 126
else
    echo "MergerFS: OK: Target '$target' is empty or not a directory"
fi

echo "MergerFS: Creating drive (/mnt/merged) overlaying (/mnt/cache) and (/mnt/cloud) - writes are directed at /mnt/cache"
mergerfs -o async_read=false,use_ino,allow_other,auto_cache,func.getattr=newest,category.action=all,category.create=ff /mnt/cache:/mnt/cloud /mnt/merged
wait ${!}

#test write
if dd if=/dev/urandom bs=1024 count=5 of=/mnt/merged/.write_test.partial~ status=none &>/dev/null; then
  echo -n "MergerFS: Write OK. "
else
  echo -n "MergerFS: Write FAIL! "
fi

#directory list
if find "$target" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    echo "Read OK"
else
    echo "Read FAIL! $target listing returned null..."
fi


while sv check $Dependencies >/dev/null; do
   sleep 10
done

echo "MergerFS: Rclone service stopped. MergerFS watcher stopping at: $(date +%Y.%m.%d-%T)"
fuse_unmount "/mnt/merged"
exit $?


