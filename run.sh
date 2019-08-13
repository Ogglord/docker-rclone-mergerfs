sudo docker rm oscartest
sudo docker run --name oscartest -e RemotePath=gdrive:/ --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined -v ~/.config/rclone:/config -v ~/mnt/merged:/mnt/merged:shared -v ~/xtra_disk:/mnt/cache:shared oscartest
