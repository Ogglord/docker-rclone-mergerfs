# Use phusion/baseimage as base image
FROM phusion/baseimage:master

ENV RemotePath="oggelito:/" \
    ConfigName="rclone.conf" \
    MountCommands="--allow-other --allow-non-empty" \
    UnmountCommands="-u -z"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update && \
      apt-get -y install sudo

# install the stuff we need ...
RUN install_clean bash git curl fuse unzip \
  && curl https://rclone.org/install.sh | sudo bash
  
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# setup services

## setup myservice (mock service..)
RUN mkdir /etc/service/myservice
COPY myservice.sh /etc/service/myservice/run
RUN chmod +x /etc/service/myservice/run

## setup rclone
RUN mkdir /etc/service/rclone
COPY rclone.sh /etc/service/rclone/run
RUN chmod +x /etc/service/rclone/run

VOLUME ["/mnt"]
VOLUME ["/config"]

#sudo docker run --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined -v ~/.config/rclone:/config:ro -v /mnt/mediaefs:/mnt/mediaefs oscartest
