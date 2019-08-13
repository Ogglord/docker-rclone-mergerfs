#!/bin/sh

sleep 2
while ! grep -qs "/mnt/cloud " /proc/mounts; do
  sleep 0.5s
  echo -n .
done

echo -n "Warming up cloud directory at: $(date +%Y.%m.%d-%T)"
/usr/bin/rclone rc vfs/refresh recursive=true | jq -r '.result[]' | xargs echo -n
echo "Warmup completed at: $(date +%Y.%m.%d-%T)"

sv stop warmup ## only once....
