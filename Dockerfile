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
    MoveCommands="--fast-list --transfers=4 --checkers=8 --tpslimit=10 --max-backlog 200000 \
  --drive-chunk-size=16M --verbose --delete-empty-src-dirs" \
    UnmountCommands="-uz" \
    PUID="1000" \
    PGID="1000"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN echo "Installing sudo" && apt-get update -qq && apt-get -y install sudo -qq

RUN echo "Creating user \"docker\"" \
  && umask 002 \
  && groupadd -f -g "$PGID" docker \
  && useradd --no-log-init -g "$PGID" -u "$PUID" -d /home -s /bin/false docker \
  && adduser docker sudo \
  && mkdir -p /home \
  && chown docker:docker /home \
  && echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker
# ADD our mergerfs install script
ADD ./install_scripts/get_mergerfs_latest.deb.sh ./home/

RUN sudo apt-get -y install bash git curl fuse unzip jq -qq \
  && cd /home \
  && curl https://rclone.org/install.sh | sudo bash \
  && sudo chmod +x get_mergerfs_latest.deb.sh \
  && ./get_mergerfs_latest.deb.sh \
  && sudo dpkg -i mergerfs_latest.deb 
#> /dev/null

# Clean up APT when done.
RUN sudo apt-get clean -qq && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && rm /home/get_mergerfs_latest.deb.sh \
  && rm /home/mergerfs_latest.deb

## Setup upload script
COPY cron_jobs/* /opt/rclone/scripts/
RUN sudo mkdir -p /opt/rclone/logs \
  && sudo chmod +x /opt/rclone/scripts/upload_cloud /opt/rclone/scripts/manual_upload_cloud \
  && sudo chown -R docker:docker /opt/rclone/ /opt/rclone/logs


## Setup upload cron job
COPY cron_jobs/cron_upload_cloud /etc/cron.d/cron_upload_cloud
RUN sudo chmod 600 /etc/cron.d/cron_upload_cloud ## important for cron.d jobs!

## Setup logging redirect to stdout
RUN sudo sed -i '/^filter f_syslog3/d' /etc/syslog-ng/syslog-ng.conf #remove the filter since we are replacing it
COPY syslog.rclone.conf /etc/syslog-ng/conf.d/syslog.rclone.conf


# setup services
USER root
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

## create  our mount points owned by docker user
RUN echo "user_allow_other" >> /etc/fuse.conf \
  && sudo mkdir -p /mnt/cloud \
  && sudo chown -R docker:docker /mnt/cloud

VOLUME ["/mnt/cache"] ## local cache
VOLUME ["/mnt/merged"] # this is the final volume /mnt/merged hard links will be done on cache only, cron job is pushing files to cloud - ignoring /rtorrent/* dir and .partial~ files
VOLUME ["/config"]

