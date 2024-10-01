#!/bin/bash

g_root_dir=$(cd "$(dirname "$0")"; pwd)
g_core_dir=$g_root_dir/core

. $g_core_dir/basic.sh
. $g_core_dir/ubuntu.sh

g_dry_run=0
g_assume_yes=0
g_no_interaction=0

function check_env {
    if [ $EUID -ne 0 ]; then
        echo "This script must be run as root"
        exit 1
    else
        echo "check Privilege: OK"
    fi

    # check dependencies: apt-transport-https ca-certificates curl gnupg
    failure=0
    for dep in apt-transport-https ca-certificates curl gnupg; do
        if ! dpkg -l | grep -q $dep; then
            echo "check dependency $dep: not found"
            failure=1
        else
            echo "check dependency $dep: OK"
        fi
    done

    return $failure
}

function uninstall {
    dist_name=$1

    if [ $dist_name == $G_DISTNAME_UBUNTU ]; then
        if [ $g_dry_run -ne 1 ]; then
            rm -f /etc/apt/sources.list.d/kubernetes.list
            rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        else
            echo "rm -f /etc/apt/sources.list.d/kubernetes.list"
            echo "rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg"
        fi
    else
        echo "Unsupported Linux Distribution"
        exit 1
    fi

    exit 0
}

function install_deps {
    dist_name=$1

    if [ $dist_name == $G_DISTNAME_UBUNTU ]; then
        apt-get update
        apt-get install -y apt-transport-https ca-certificates curl gnupg
    else
        echo "Unsupported Linux Distribution"
        return 1
    fi

    return 0
}

function add_k8s_repo {
    version=$1
    driver=$2

    # add k8s apt repository
    if [ $driver == "docker" ]; then
        cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] http://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/$version/deb/ /
# deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] http://mirrors.tuna.tsinghua.edu.cn/kubernetes/addons:/cri-o:/stable:/$version/deb/ /
EOF
    elif [ $driver == "crio" ]; then
        cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] http://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/$version/deb/ /
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] http://mirrors.tuna.tsinghua.edu.cn/kubernetes/addons:/cri-o:/stable:/$version/deb/ /
EOF
    fi
}

function install_packages {
    dist_name=$1
    packages=("${@:2}")

    if [ $dist_name == $G_DISTNAME_UBUNTU ]; then
        apt-get update
        apt-get install -y ${packages[@]}
    else
        echo "Unsupported Linux Distribution"
        return 1
    fi
}

function usage {
    cat <<EOF
Usage: $0 [options]
Options:
    -d, --driver <docker|crio>      Specify the driver of k8s, default is 'docker'
    --debug                         Enable debug mode
    --dry-run                       Dry run mode
    -h, --help                      Show this help message and exit
    --no-interaction                No interaction mode
    --package <kubectl|kubeadm>     Install k8s package, can multiple
    --uninstall                     Uninstall repos and keys
    -v, --version <VERSION>         Version of k8s, default is 'v1.30'
    -y, --yes                       Assume yes
EOF
}

# parse args
CONF_DRIVER="docker"
CONF_VERSION="v1.30"
CONF_UNINSTALL=0
declare -a CONF_PACKAGES

while [ $# -gt 0 ]; do
    case $1 in
        -d|--driver)
            shift
            CONF_DRIVER=$1
            shift
            ;;
        --debug)
            set -x
            shift
            ;;
        --dry-run)
            g_dry_run=1
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
        --package)
            shift
            CONF_PACKAGES+=($1)
            shift
            ;;
        --uninstall)
            CONF_UNINSTALL=1
            shift
            ;;
        -v|--version)
            shift
            CONF_VERSION=$1
            shift
            ;;
        -y|--yes)
            g_assume_yes=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# check conf
if [ $CONF_DRIVER != "docker" ] && [ $CONF_DRIVER != "crio" ]; then
    echo "Invalid driver: $CONF_DRIVER"
    usage
    exit 1
fi

# check packages
for pkg in ${CONF_PACKAGES[@]}; do
    if [ $pkg != "kubectl" ] && [ $pkg != "kubeadm" ]; then
        echo "Invalid package: $pkg"
        usage
        exit 1
    fi
done

dist_name=$(get_distname)
echo "Detected Linux Distribution: $dist_name"

if [ $g_no_interaction -eq 1 ]; then
    echo "No interaction mode"
    if [ $dist_name == $G_DISTNAME_UBUNTU ]; then
        ubuntu_no_interactive
    else
        echo "Unsupported Linux Distribution"
        exit 1
    fi
fi

if [ $CONF_UNINSTALL -eq 1 ]; then
    echo "Uninstalling k8s sources and keys"
    uninstall $dist_name
fi

if check_env; then
    echo "Environment check: OK"
else
    echo "Environment check: Failed"
    # ask for installing dependencies
    if [ $g_assume_yes -eq 1 ]; then
        install_deps $dist_name \
            || exit 1
    else
        read -p "Do you want to install dependencies? [Y/n] " choice
        case $choice in
            n|N)
                echo "Abort"
                exit 1
                ;;
            y|Y|"")
                install_deps $dist_name \
                    || exit 1
                ;;
            *)
                echo "Invalid choice"
                exit 1
                ;;
        esac
    fi
fi

# add k8s sources
if [ $dist_name == $G_DISTNAME_UBUNTU ]; then
    # import GPG key
    if [ -e /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
        echo "k8s GPG key already imported, skip"
    else
        # create /etc/apt/keyrings if not exists
        if [ ! -d /etc/apt/keyrings ]; then
            if [ $g_dry_run -ne 1 ]; then
                mkdir -p /etc/apt/keyrings
            else
                echo "mkdir -p /etc/apt/keyrings"
            fi
        fi

        if [ $g_dry_run -ne 1 ]; then
            curl -fsSL https://pkgs.k8s.io/core:/stable:/$CONF_VERSION/deb/Release.key \
                | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        else
            curl -fsSL https://pkgs.k8s.io/core:/stable:/$CONF_VERSION/deb/Release.key > /dev/null
        fi
        
        if [ $? -ne 0 ]; then
            echo "Failed to import k8s GPG key"
            exit 1
        else
            echo "k8s GPG key imported"
        fi

        # allow unprivileged APT programs to read this keyring
        if [ $g_dry_run -ne 1 ]; then
            chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        else
            echo "chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg"
        fi
    fi

    # set k8s sources
    if [ -e /etc/apt/sources.list.d/kubernetes.list ]; then
        echo "k8s sources already set, skip"
    else
        if [ $g_dry_run -ne 1 ]; then
            add_k8s_repo $CONF_VERSION $CONF_DRIVER
        else
            echo "add k8s repository"
        fi
    fi

    if [ $? -ne 0 ]; then
        echo "Failed to add k8s sources"
        exit 1
    else
        echo "k8s sources added"
    fi
else
    echo "Unsupported Linux Distribution";
    exit 1
fi

# install k8s packages
if [ ${#CONF_PACKAGES[@]} -gt 0 ]; then
    install_packages $dist_name ${CONF_PACKAGES[@]}
fi