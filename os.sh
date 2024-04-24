#!/sbin/bash

############################ Main             ############################

os_name=`uname -s`
dist_name=`cat /etc/*-release | grep "^ID=" | cut -d= -f2 | tr -d '"'`;

if [ $dist_name == "alpine" ]; then
    echo "Alpine Linux";
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
        && echo "Successfully set alpine mirror to https://mirrors.tuna.tsinghua.edu.cn/alpine"
    exit 0
else
    echo "Unsupported Linux Distribution";
    exit 1
fi