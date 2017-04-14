#!/bin/bash
# install winstore on winserver/centos7
# author: Xiong Neng

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

ip a | grep "xenbr"
if [[ "$?" == 0 ]]; then
    local_ip=$(ip a | grep -A2 xenbr | grep 'inet ' | awk '{print $2}' |awk -F/ '{print $1}')
else
    local_ip=$(ip a | grep -A2 ": <BROADCAST" | grep 'inet ' | awk '{print $2}' |awk -F/ '{print $1}' | head -n 1)
fi
echo "${local_ip}" > resource/winstore/etc/default/test.txt

# check mysql ip
if [[ "$#" < 1 ]]; then
    echo "使用本地ip作为mysql主库地址.."
    mysql_ip="${local_ip}"
else
    mysql_ip="$1"
fi

# 替换group/all中的mysql主机地址
sed -i "/mysql_host:/c mysql_host: \"${mysql_ip}\"" group_vars/all

# check if ansible-playbook is installed
ansible-playbook --version 2>/dev/null
if [[ "$?" != 0 ]]; then
    cd install_ansible/
    yum localinstall -yC --disablerepo=* *.rpm
    cd ..
    sed -i "/deprecation_warnings = True/c deprecation_warnings = False" /etc/ansible/ansible.cfg
    sed -i "/command_warnings = False/c command_warnings = False" /etc/ansible/ansible.cfg
fi


ansible-playbook -i hosts site.yml

