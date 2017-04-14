#!/usr/bin/env python
# 清除网络脚本
# author: Xiong Neng

# 如果是新的系统，不需要清除网络就返回
if [[ "$#" > 0 && "$1" -eq "true" ]]; then
    echo "clean system, exit"
    exit 0
fi

# 先down掉网卡
nic_21=$(ip a |grep -E "secondary.*:21" | awk {'print $NF'})
nic_22=$(ip a |grep -E "secondary.*:22" | awk {'print $NF'})

if [[ "$nic_21" != "" ]]; then
    nic_21_real=$(echo $nic_21 | awk -F: '{print $1}')
    ifdown $nic_21
    rm -f /etc/sysconfig/network-scripts/ifcfg-$nic_21
    ip a | grep "xenbr"
    if [[ "$?" == 0 ]]; then
        echo "DEVICE=$nic_21_real" > /etc/sysconfig/network-scripts/ifcfg-$nic_21_real
    fi
fi

if [[ "$nic_22" != "" ]]; then
    nic_22_real=$(echo $nic_22 | awk -F: '{print $1}')
    ifdown $nic_22
    rm -f /etc/sysconfig/network-scripts/ifcfg-$nic_22
    ip a | grep "xenbr"
    if [[ "$?" == 0 ]]; then
        echo "DEVICE=$nic_22_real" > /etc/sysconfig/network-scripts/ifcfg-$nic_22_real
    fi
fi

# winserver网络清理
ip a | grep "xenbr"
if [[ "$?" == 0 ]]; then
    local_ip=$(ip a | grep -A2 xenbr | grep 'inet ' | awk '{print $2}' |awk -F/ '{print $1}')
    eth0=$(ip a | grep -B2  "inet $local_ip" |head -n1 |awk '{print $2}' |awk -F: '{print $1}')
    if [[ "$eth0" != "" && "$eth0" != *"xenbr"* ]]; then
        rm -f /etc/sysconfig/network-scripts/ifcfg-$eth0
    fi
    #eth1=$(ip a |grep "state UP" | grep -v " master " |awk '{print $2}' |awk -F: '{print $1}')
    #if [[ "$eth1" != "" ]]; then
    #    echo "DEVICE=$eth1" > /etc/sysconfig/network-scripts/ifcfg-$eth1
    #fi
fi

# 重启网络
/etc/init.d/network restart
