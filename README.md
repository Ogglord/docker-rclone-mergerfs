# README
**rclone with a cache overlay**

Useful in a seedbox or similar setup where diskspace is sparse

## Description

This is an proof-of-concept set of scripts that builds a docker image. The container connects to a remote file system using rclone (e.g Google Drive), then overlays that drive with mergerfs local cache.

What this achieves is an exposed volume (***/mnt/merged***) that consists of the remote file system (***/mnt/cloud***) and a local cache (***/mnt/cache***). All write operations are written to the cache. Read operations are directed to wherever the file is located (cloud or cache).

Every hour there is a cron job that transfer the data from the local cache to the remote file system. 

## Instructions
1. Clone the repo
2. Setup the rclone config
3. Review the Dockerfile
4. Build and run

## What's next?
Other docker containers or userspace tools should read and write to ***/mnt/merged***. Reads and writes, even hardlinking can be done on this volume.

## Got a Problem?
Log any issues in the issue tracker here

