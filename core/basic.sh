#!/bin/bash

G_DISTNAME_UBUNTU="ubuntu"
G_DISTNAME_DEBIAN="debain"
G_DISTNAME_CENTOS="centos"
G_DISTNAME_ALPINE="alpine"
G_DISTNAME_REDHAT="redhat"


function get_distname() {
    distname=""
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        # lowwer
        distname=$(echo $ID | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        # lowwer
        distname=$(echo $DISTRIB_ID | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/debian_version ]; then
        echo $G_DISTNAME_DEBIAN
        return 0
    elif [ -f /etc/redhat-release ]; then
        echo $G_DISTNAME_REDHAT
        return 0
    elif [ -f /etc/centos-release ]; then
        echo $G_DISTNAME_CENTOS
        return 0
    elif [ -f /etc/alpine-release ]; then
        echo $G_DISTNAME_ALPINE
        return 0
    else
        echo "Unsupported Linux Distribution"
        return 1
    fi


    if [ "$distname" == $G_DISTNAME_UBUNTU ]; then
        echo $G_DISTNAME_UBUNTU
    elif [ "$distname" == $G_DISTNAME_DEBIAN ]; then
        echo $G_DISTNAME_DEBIAN
    elif [ "$distname" == $G_DISTNAME_CENTOS ]; then
        echo $G_DISTNAME_CENTOS
    elif [ "$distname" == $G_DISTNAME_ALPINE ]; then
        echo $G_DISTNAME_ALPINE
    elif [ "$distname" == $G_DISTNAME_REDHAT ]; then
        echo $G_DISTNAME_REDHAT
    else
        echo "Unsupported Linux Distribution"
        return 1
    fi
}