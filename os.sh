#!/bin/sh

function get_distname() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo $DISTRIB_ID
    elif [ -f /etc/debian_version ]; then
        echo Debian
    elif [ -f /etc/fedora-release ]; then
        echo Fedora
    elif [ -f /etc/redhat-release ]; then
        echo RedHat
    elif [ -f /etc/centos-release ]; then
        echo CentOS
    else
        echo "Unsupported Linux Distribution"
        exit 1
    fi
}

function usage() {
    cat <<EOF
Usage: $0 [options]
Options:
    -h, --help      Show this help message and exit
    -d, --debug     Enable debug mode
    --dry-run       Dry run mode
EOF
}

# parse args
CONF_DRY_RUN=0

while [ $# -gt 0 ]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -d|--debug)
            set -x
            shift
            ;;
        --dry-run)
            CONF_DRY_RUN=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

dist_name=$(get_distname)

if [ $dist_name == "alpine" ]; then
    echo "Alpine Linux";
    if [ $CONF_DRY_RUN -ne 1 ]; then
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
    fi

    if [ $? -ne 0 ]; then
        echo "Failed to set alpine mirror to https://mirrors.tuna.tsinghua.edu.cn/alpine"
        exit 1
    else 
        echo "Successfully set alpine mirror to https://mirrors.tuna.tsinghua.edu.cn/alpine"
        exit 0
    fi

else
    echo "Unsupported Linux Distribution";
    exit 1
fi