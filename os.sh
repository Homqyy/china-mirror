#!/bin/bash

g_root_dir=$(cd "$(dirname "$0")"; pwd)
g_core_dir=$g_root_dir/core

. $g_core_dir/basic.sh

function usage {
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

echo "Detected Linux Distribution: $dist_name"

if [ $dist_name == $G_DISTNAME_ALPINE ]; then
    if [ $CONF_DRY_RUN -ne 1 ]; then
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
    else
        echo "Dry run mode"
    fi

    if [ $? -ne 0 ]; then
        echo "Failed to set alpine mirror to https://mirrors.tuna.tsinghua.edu.cn/alpine"
        exit 1
    else 
        echo "Successfully set alpine mirror to https://mirrors.tuna.tsinghua.edu.cn/alpine"
        exit 0
    fi
elif [ $dist_name == $G_DISTNAME_UBUNTU ]; then
    . $g_core_dir/ubuntu.sh

    version=$(ubuntu_get_version)

    if [ $CONF_DRY_RUN -ne 1 ]; then
        # 22.04
        if [ "$version" == "$G_UBUNTU_VERSION_2204" ]; then
            ubuntu_backup_repos

            cat > /etc/apt/sources.list <<EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# # deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
EOF
        elif [ "$version" == "$G_UBUNTU_VERSION_2004" ]; then
            ubuntu_backup_repos

            cat > /etc/apt/sources.list <<EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
deb http://security.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
# # deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
EOF
        else
            echo "Unsupported Ubuntu Version: $version"
            exit 1
        fi
    else
        echo "Dry run mode"
    fi

    if [ $? -ne 0 ]; then
        echo "Failed to set ubuntu mirror to https://mirrors.tuna.tsinghua.edu.cn/ubuntu"
        exit 1
    else 
        echo "Successfully set ubuntu mirror to https://mirrors.tuna.tsinghua.edu.cn/ubuntu"
        exit 0
    fi
else
    echo "Unsupported Linux Distribution";
    exit 1
fi