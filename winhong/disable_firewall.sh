#!/bin/bash
# 禁用防火墙和selinux
# author: Xiong Neng

if [[ "$#" -ne "1" ]]; then
    systemctl disable firewalld
    systemctl stop firewalld
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
else
    server_ip="$1"
ssh root@${server_ip} <<EOF
    systemctl disable firewalld
    systemctl stop firewalld
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
EOF

fi


