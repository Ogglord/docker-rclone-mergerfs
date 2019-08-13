#!/bin/sh
cd $(dirname $0)
sudo docker build -t oscartest .
