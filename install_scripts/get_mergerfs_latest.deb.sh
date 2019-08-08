#!/bin/sh

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

rlsv=$(get_latest_release "trapexit/mergerfs")

url="https://github.com/trapexit/mergerfs/releases/download/$rlsv/mergerfs_$rlsv.ubuntu-$(lsb_release -cs)_amd64.deb"

echo "Downloading $url"
curl -L -o mergerfs_latest.deb "$url"
