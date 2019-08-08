#!/bin/sh
# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
#exec /sbin/setuser memcache /usr/bin/memcached >>/var/log/memcached.log 2>&1
echo "Watchtower: Running"

services="rclone mergerfs"

trap 'shutdown' 1 2 3 4 5 15 

shutdown(){
  #printf "\r\nWatchtower: Got kill signal...\r\n"
  exit 1
}

checkservices(){
  for s in $services
	do
	  echo "Checking $s"
	  if ! sv check $s >/dev/null; then
	    return 0
	  fi
	done
  return 1
}


while true
do
	if  checkservices ; then
          printf "\r\nWatchtower: $services are running.\r\n"
	fi

	sleep 1h
done

echo "Watchtower: Stopped"
