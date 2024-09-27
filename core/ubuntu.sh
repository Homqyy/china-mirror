#!/bin/bash

G_UBUNTU_VERSION_2004="20.04"
G_UBUNTU_VERSION_2204="22.04"

# get ubuntu version
function ubuntu_get_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $VERSION_ID
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo $DISTRIB_RELEASE
    else
        echo "Unsupported Linux Distribution"
        exit 1
    fi
}

function ubuntu_backup_repos() {
    [ -f /etc/apt/sources.list ] \
        && mv /etc/apt/sources.list /etc/apt/sources.list.bak
    [ -d /etc/apt/sources.list.d/ ] \
        && mv /etc/apt/sources.list.d/ /etc/apt/sources.list.d.bak \
        && mkdir -p /etc/apt/sources.list.d/
}
