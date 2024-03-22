#!/bin/bash

# check pip version is 10.0.0 or later

if pip --version | grep -qE "pip [1-9][0-9]\.[^.]+\.[^.]+"; then
    pip -q config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
        || echo "Failed to set pypi mirror to https://pypi.tuna.tsinghua.edu.cn/simple"
    echo "Successfully set pypi mirror to https://pypi.tuna.tsinghua.edu.cn/simple"
else
    echo "pip version must be 10.0.0 or later"
    exit 1
fi
