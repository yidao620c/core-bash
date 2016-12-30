#!/bin/bash
# install db on winserver/centos
# 可配置主从复制的高可用模式，前提是先配置好ssh无密码访问，并且关闭selinux和防火墙
# author: Xiong Neng
mysql_password="winstore"

usage_exit() {
    echo "Usage:"
    echo "    $0"
    echo "    $0 ha [slave1-ip] [slave2-ip]"
    exit 1
}

# check if ansible-playbook is installed
ansible-playbook --version 2>/dev/null
if [[ "$?" != 0 ]]; then
    cd install_ansible/
    yum localinstall -yC --disablerepo=* *.rpm
    cd ..
fi

# 先在所有机器上面安装mysql
ansible-playbook -i "localhost," --connection=local mysql.yml
if [[ "$#" > 0 ]]; then
    if [[ "$1" != "ha" ]]; then
        usage_exit
    fi
    if [[ "$#" == 2 ]]; then
        ansible-playbook -i "$2," mysql.yml
    elif [[ "$#" -ge 3 ]]; then
        ansible-playbook -i "$2,$3" mysql.yml
    fi
fi

# 然后执行HA配置
if [[ "$#" == 0 || "$#" == 1 ]]; then
    echo "没有slave，无需进行HA配置"
    exit 0
elif [[ "$#" > 1 ]]; then
    echo "开始配置slave"
    cat /etc/redhat-release | grep WinServer
    if [[ "$?" == "0" ]]; then
        local_ip=$(ifconfig | grep -A1 xenbr | grep 'inet ' | awk '{print $2}')
    else
        local_ip=$(hostname -I | awk '{print $1}')
    fi
    if [[ "$#" == 2 ]]; then
        echo "sh /root/mysql-ansible/resource/shell/mysql_ha.sh ${local_ip} $2 0 ${mysql_password}"
        sh /root/mysql-ansible/resource/shell/mysql_ha.sh ${local_ip} $2 0 "${mysql_password}"
    elif [[ "$#" -ge 3 ]]; then
        echo "sh /root/mysql-ansible/resource/shell/mysql_ha.sh ${local_ip} $2 $3 ${mysql_password}"
        sh /root/mysql-ansible/resource/shell/mysql_ha.sh ${local_ip} $2 $3 "${mysql_password}"
    fi
fi
