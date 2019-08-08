#!/bin/sh

sleep 5
while ! grep -qs "/mnt/cloud " /proc/mounts; do
  sleep 5
done

echo "Warming up cloud directory at: $(date +%Y.%m.%d-%T)"
/usr/bin/rclone rc vfs/refresh recursive=true
echo "Warmup completed at: $(date +%Y.%m.%d-%T)"

sv stop warmup ## only once....
