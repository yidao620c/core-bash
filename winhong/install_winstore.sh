#!/bin/bash
# install winstore on winserver/centos7
# author: Xiong Neng

# check mysql ip
if [[ "$#" < 1 ]]; then
    echo "请传入mysql数据库的ip地址参数.."
    exit 1
fi

# 替换group/all中的mysql主机地址
sed -i "/mysql_host:/c mysql_host: \"$1\"" group_vars/all

# check if ansible-playbook is installed
ansible-playbook --version 2>/dev/null
if [[ "$?" != 0 ]]; then
    cd install_ansible/
    yum localinstall -yC --disablerepo=* *.rpm
    cd ..
fi

ansible-playbook -i hosts site.yml

