#!/bin/bash

g_root_dir=$(cd "$(dirname "$0")"; pwd)
g_core_dir=$g_root_dir/core
g_assets_dir=$g_root_dir/assets

. $g_core_dir/basic.sh
. $g_core_dir/ubuntu.sh

g_dry_run=0
g_no_interaction=0

# Functions ##################################################################

function check_env {
    if [ $EUID -ne 0 ]; then
        echo "This script must be run as root"
        exit 1
    else
        echo "check Privilege: OK"
    fi
}

function install_for_ubuntu {
    # remove old versions
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; 
    do 
        apt-get remove -y $pkg > /dev/null 2>&1; 
    done

    # install dependencies
    apt-get update \
        && apt-get install -y ca-certificates curl gnupg

    if [ $? -ne 0 ]; then
        echo "Failed to install dependencies"
        return 1
    else
        echo "Dependencies installed successfully"
    fi

    # add docker apt repository
    if [ ! -d /etc/apt/keyrings ]; then
        mkdir -m 0755 -p /etc/apt/keyrings
    fi

    if [ -f "/etc/apt/keyrings/docker.gpg" ]; then
        rm -f /etc/apt/keyrings/docker.gpg
    fi

    # test download.docker.com is available
    if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg > /dev/null; then
        # use official docker gpg key
        echo "Use official docker gpg key"

        cat $g_assets_dir/docker.gpg.pem \
            | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    else
        install -m 0755 -d /etc/apt/keyrings \
            && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
                | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
            && chmod a+r /etc/apt/keyrings/docker.gpg
    fi

    if [ $? -ne 0 ]; then
        echo "Failed to download docker gpg key"
        return 1
    else
        echo "Docker gpg key downloaded successfully"
    fi

    if [ -f "/etc/apt/sources.list.d/docker.list" ]; then
        echo "docker apt repository already exists: /etc/apt/sources.list.d/docker.list"
    else
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] http://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
            "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
            tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi

    if [ $? -ne 0 ]; then
        echo "Failed to add docker apt repository"
        return 1
    else
        echo "Docker apt repository added successfully"
    fi

    # install docker
    apt-get update \
        && apt-get install -y \
            docker-ce \
            docker-ce-cli \
            containerd.io \
            docker-buildx-plugin \
            docker-compose-plugin

    if [ $? -ne 0 ]; then
        echo "Failed to install docker"
        return 1
    else
        echo "Docker installed successfully"
    fi

    return 0
}

function usage {
    cat <<EOF
Usage: $0 [options]
Options:
    --debug                         Enable debug mode
    --no-interaction                No interaction mode
    -h, --help                      Display this help and exit
EOF
}

# Main #######################################################################

# parse command line arguments

while [ $# -gt 0 ]; do
    case $1 in
        --debug)
            set -x
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --no-interaction)
            g_no_interaction=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

check_env

dist_name=$(get_distname)

echo "Detected distribution: $dist_name"

if [ $dist_name == $G_DISTNAME_UBUNTU ]; then
    if [ $g_no_interaction -eq 1 ]; then
        echo "No interaction mode"
        ubuntu_no_interactive
    fi

    install_for_ubuntu

    if [ $? -eq 0 ]; then
        echo "Docker CE installed successfully"
    else
        echo "Failed to install Docker CE"
        exit 1
    fi
else
    echo "Unsupported distribution: $dist_name"
    exit 1
fi
