#!/bin/bash
# install mysql db on winserver/centos
# 可配置主从复制的高可用模式，前提是先配置好ssh无密码访问，并且关闭selinux和防火墙
# author: Xiong Neng
mysql_password="winstore"

servers=($(sed -n '/^[0-9]/p' hosts |awk '{print $1}'))

# check ssh pubkey
if [[ ! -f /root/.ssh/id_rsa.pub ]]; then
    ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa
fi
for s in "${servers[@]}"
do
    ssh $s -o PasswordAuthentication=no -o StrictHostKeyChecking=no &>/dev/null
    if [[ "$?" -ne "0" ]]; then
        echo "请先运行./sshkey.sh 配置无密码访问"
        exit 1
    fi
done

# check if ansible-playbook is installed
ansible-playbook --version 2>/dev/null
if [[ "$?" != 0 ]]; then
    cd install_ansible/
    yum localinstall -yC --disablerepo=* *.rpm
    cd ..
fi

# 先在所有机器上面安装mysql
ansible-playbook -i "localhost," --connection=local mysql.yml


if [[ "${#servers[@]}" -eq "1" ]]; then
    ansible-playbook -i "${servers[0]}," mysql.yml
elif [[ "${#servers[@]}" -gt "1" ]]; then
    ansible-playbook -i "${servers[0]},${servers[1]}" mysql.yml
fi

# 然后执行HA配置
if [[ "${#servers[@]}" -eq "0" ]]; then
    echo "没有slave，无需进行HA配置"
    exit 0
elif [[ "${#servers[@]}" -gt "0" ]]; then
    echo "开始配置slave"
    cat /etc/redhat-release | grep WinServer
    if [[ "$?" == "0" ]]; then
        local_ip=$(ifconfig | grep -A1 xenbr | grep 'inet ' | awk '{print $2}')
    else
        local_ip=$(hostname -I | awk '{print $1}')
    fi

    if [[ "${#servers[@]}" -eq "1" ]]; then
        echo "sh /root/mysql-ansible/resource/shell/mysql_ha.sh ${local_ip} ${servers[0]} 0 ${mysql_password}"
        sh /root/mysql-ansible/resource/shell/mysql_ha.sh ${local_ip} ${servers[0]} 0 "${mysql_password}"
    elif [[ "${#servers[@]}" -gt "1" ]]; then
        echo "sh /root/mysql-ansible/resource/shell/mysql_ha.sh ${local_ip} ${servers[0]} ${servers[1]} ${mysql_password}"
        sh /root/mysql-ansible/resource/shell/mysql_ha.sh ${local_ip} ${servers[0]} ${servers[1]} "${mysql_password}"
    fi
fi

