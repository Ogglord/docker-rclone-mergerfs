# Use phusion/baseimage as base image
FROM phusion/baseimage:master

ENV RemotePath="oggelito:/" \
    ConfigName="rclone.conf" \
    MountCommands=" --allow-other \
	--buffer-size 500M \
	--dir-cache-time 96h \
	--log-level INFO \
	--log-file /opt/rclone/logs/rclone.log \	
	--timeout 1h \
	--umask 002 \
	--rc " \
    UnmountCommands="-uz"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ADD our mergerfs install script
ADD ./install_scripts/get_mergerfs_latest.deb.sh ./

RUN apt-get update -qq && apt-get -y install sudo bash git curl fuse unzip -qq \
  && curl https://rclone.org/install.sh | sudo bash \
  && chmod +x get_mergerfs_latest.deb.sh \
  && ./get_mergerfs_latest.deb.sh \
  && dpkg -i mergerfs_latest.deb > /dev/null

# Clean up APT when done.
RUN apt-get clean -qq && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && rm get_mergerfs_latest.deb.sh \
  && rm mergerfs_latest.deb

## Setup upload script
COPY cron_jobs/* /opt/rclone/scripts/
RUN mkdir -p /opt/rclone/logs \
  && touch /opt/rclone/logs/cron.log \
  && touch /opt/rclone/logs/upload.log \
  && chmod +x /opt/rclone/scripts/upload_cloud

## Setup upload cron job
COPY cron_jobs/cron_upload_cloud /etc/cron.d/cron_upload_cloud
RUN chmod 600 /etc/cron.d/cron_upload_cloud ## important for cron.d jobs!


# setup services

## setup watchtower
RUN mkdir /etc/service/watchtower
COPY services/watchtower.sh /etc/service/watchtower/run
RUN chmod +x /etc/service/watchtower/run

## setup rclone
RUN mkdir /etc/service/rclone
COPY services/rclone.sh /etc/service/rclone/run
RUN chmod +x /etc/service/rclone/run

## setup mergerfs
RUN mkdir /etc/service/mergerfs
COPY services/mergerfs.sh /etc/service/mergerfs/run
RUN chmod +x /etc/service/mergerfs/run

## setup warmup
RUN mkdir /etc/service/warmup
COPY services/warmup.sh /etc/service/warmup/run
RUN chmod +x /etc/service/warmup/run

## setup logrotate
COPY logrotate /etc/logrotate.d/rclone

RUN echo "user_allow_other" >> /etc/fuse.config


RUN mkdir /mnt/cloud ## actual cloud drive, not exposed to host
VOLUME ["/mnt/cache"] ## local cache
VOLUME ["/mnt/merged"] # this is the final volume /mnt/merged hard links will be done on cache only, cron job is pushing files to cloud - ignoring /rtorrent/* dir and .partial~ files
VOLUME ["/config"]

