#!/bin/sh
echo "rclone: Starting..."
ConfigPath="/config/$ConfigName" ## defaults to /config/rclone.conf
Dependencies=""

# export all variables to etc/env - so cron can read them properly
env >> /etc/environment

misdep (){
  echo "rclone: Cannot start until $Dependencies is running."
  exit 1
}

shutdown (){
  printf "\r\nrclone: Got kill signal...\r\n"
  pid=$(pidof rclone)
  kill -TERM $pid
  fuse_unmount "/mnt/cloud"
  echo "rclone: Exiting rclone service now."
  exit $?
}

fuse_unmount () {
	if grep -qs "$1 " /proc/mounts; then
		echo "rclone: Unmounting: fusermount -uz $1 at: $(date +%Y.%m.%d-%T)"
		fusermount -uz $1
	else
	    echo "rclone: No need to unmount $1"
	fi
}

###check dependencies are running
##sv check $Dependencies >/dev/null || misdep
##echo "rclone: dependencies are all running..."

## graceful shutdown
trap 'shutdown' 1 2 3 4 5 15 

#mount
echo "rclone: Executing:/usr/bin/rclone --config $ConfigPath mount $RemotePath /mnt/cloud $MountCommands"
/usr/bin/rclone --config $ConfigPath mount $RemotePath /mnt/cloud $MountCommands &
wait ${!}

echo "rclone: Crashed at: $(date +%Y.%m.%d-%T)"
fuse_unmount "/mnt/cloud"
exit $?
