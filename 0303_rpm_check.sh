#!/bin/bash
# 检查一个rpm是否可安装

SUCCESS=0
E_NO_ARGS=65

if [ -z "$1" ]; then
    echo "usage: `basename $0` rpm-file"
    exit $E_NO_ARGS
fi

{
echo
echo "Archive Description: "
rpm -qpi $1  # 查询文件描述
echo
echo "Achive Listing: "
rpm -qpl $1  # 文件是否可以被安装
if [ "$?" -eq $SUCCESS ]; then
    echo "$1 can be installed."
else
    echo "$1 cannot be installed."
fi
echo
} > "$1.log"
