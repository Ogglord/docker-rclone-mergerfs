#!/bin/sh
# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
#exec /sbin/setuser memcache /usr/bin/memcached >>/var/log/memcached.log 2>&1
echo "Welcome to Oscars Service"

trap 'shutdown' 1 2 3 4 5 15 

shutdown(){
  printf "\r\nGot kill signal...\r\n"
  exit 1
}

number=0
while [ "$number" -lt 10 ]
do
        printf "\r\n%d" "$number"
        number=`expr $number + 1 `
	sleep 1
done
echo "Service is choosing to exit after 1 minute"
