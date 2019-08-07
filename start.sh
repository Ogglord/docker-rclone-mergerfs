sudo docker run --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined -v ~/.config/rclone:/config:ro -v /mnt/mediaefs:/mnt/mediaefs oscartest

