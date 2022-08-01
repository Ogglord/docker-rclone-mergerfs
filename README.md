# WELCOME

**Description**

This is an proof-of-concept set of scripts that builds a docker image. The container connects to a remote file system using rclone (e.g Google Drive), then overlays that drive with mergerfs local cache.

What this achieves is an exposed volume (***/mnt/merged***) that consists of the remote file system (***/mnt/cloud***) and a local cache (***/mnt/cache***).

Other docker containers or userspace tools should read and write to ***/mnt/merged***. Reads and writes and hardlinking can be done on this volume.

Every hour there is a cron job that transfer the data from the local cache to the remote file system. 

**Instructions**
1. Clone the repo
2. Provide an rclone config
3. Modify the Dockerfile
4. Run it

**Got a Problem?**
Log any issues in the issue tracker here

