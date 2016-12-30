#!/usr/bin/env python
# 清除网络脚本
# author: Xiong Neng

# 先down掉网卡
nic_21=$(ifconfig  | grep ":21: flags=" | awk '{print $1}' | sed 's/\(.*\):/\1/')
nic_22=$(ifconfig  | grep ":22: flags=" | awk '{print $1}' | sed 's/\(.*\):/\1/')

if [[ "$nic_21" != "" ]]; then
    nic_21_real=$(echo $nic_21 | awk -F: '{print $1}')
    ifdown $nic_21
    rm -f /etc/sysconfig/network-scripts/ifcfg-$nic_21
    ifconfig | grep xenbr0
    if [[ "$?" == 0 ]]; then
        echo "DEVICE=$nic_21_real" > /etc/sysconfig/network-scripts/ifcfg-$nic_21_real
    fi
fi

if [[ "$nic_22" != "" ]]; then
    nic_22_real=$(echo $nic_22 | awk -F: '{print $1}')
    ifdown $nic_22
    rm -f /etc/sysconfig/network-scripts/ifcfg-$nic_22
    ifconfig | grep xenbr0
    if [[ "$?" == 0 ]]; then
        echo "DEVICE=$nic_22_real" > /etc/sysconfig/network-scripts/ifcfg-$nic_22_real
    fi
fi

# winserver网络清理
ifconfig | grep xenbr0
if [[ "$?" == 0 ]]; then
    local_ip=$(ifconfig | grep -A1 xenbr0 | grep 'inet ' | awk '{print $2}')

    eth0=$(ifconfig | grep -B1 -m1 "inet $local_ip" | awk '{print $1}' | grep ":" | sed 's/\(.*\):/\1/')
    if [[ "$eth0" != "" ]]; then
        rm -f /etc/sysconfig/network-scripts/ifcfg-$eth0
    fi

    eth1=$(ifconfig | grep -B1 -m2 "inet " |tail -n2 | awk '{print $1}' | grep ":" | sed 's/\(.*\):/\1/')
    if [[ "$eth1" != "" ]]; then
        rm -f /etc/sysconfig/network-scripts/ifcfg-$eth1
    fi
fi

# 重启网络
/etc/init.d/network restart
