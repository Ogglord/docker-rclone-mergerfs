sudo docker rm oscartest
sudo docker run --name oscartest --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined -v ~/.config/rclone:/config -v /mnt/merged:/mnt/merged:shared -v /mnt/cache:/mnt/cache:shared oscartest
