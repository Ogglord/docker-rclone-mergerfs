#!/bin/sh
echo "Starting rclone!"
ConfigPath="/config/$ConfigName" ## defaults to /config/rclone.conf
Dependencies="myservice"

misdep (){
  echo "Cannot start until myservice is running."
  exit 1
}

shutdown (){
  printf "\r\nGot kill signal...\r\n"
  kill -SIGTERM ${!}  #kill last spawned background process $(pidof rclone)
  fuse_unmount
  echo "Exiting rclone service now"
  exit $?
}

fuse_unmount () {
  echo "Unmounting: fusermount -uz /mnt/mediaefs at: $(date +%Y.%m.%d-%T)"
  fusermount -uz /mnt/mediaefs
}

## check dependencies are running
sv check $Dependencies >/dev/null || misdep

echo "myservice is running"

## graceful shutdown
trap 'shutdown' 1 2 3 4 5 15 

#mount rclone remote and wait
echo "Executing:/usr/bin/rclone --config $ConfigPath mount $RemotePath /mnt/mediaefs $MountCommands"
/usr/bin/rclone --config $ConfigPath mount $RemotePath /mnt/mediaefs $MountCommands &
wait ${!}
echo "rclone crashed at: $(date +%Y.%m.%d-%T)"
fuse_unmount
exit $?
