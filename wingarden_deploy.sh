#!/bin/bash
# wingarden全自动化部署脚本

set -e

# sysdb安装函数
# 第一个参数是sysdb的IP地址，
# 第二个参数是NFS的服务器IP
# 第三个参数是
function sysdb {
    if [[ $# != 2 ]]; then 
        echo "请输入两个IP地址啊: sysdb_ip nfs_ip"
        exit 1
    fi
    echo "log001--开始部署系统数据库pgsql"
    ssh -l orchard "$1" "
    echo '成功登录$1 ，现在开始挂载NFS服务器目录'
    echo '建立客户端的NFS挂载目录'
    if [[ ! -d '/home/orchard/nfs' ]]; then 
        mkdir /home/orchard/nfs
    else echo 'nfs目录存在无需再创建'
    fi
    sudo mount -t nfs $2:/home/public /home/orchard/nfs
    echo '挂载结果: $?'
    cd /home/orchard/nfs/wingarden_install
    ./install.sh sysdb
    wait
    #echo '安装sysdb成功后查看'
    #if [[ $(sudo /etc/init.d/postgresql status | grep 'is running') ]]; then
    #    echo 'postgresql status is running...'
    #else
    #    echo 'Oh, No,,,postgresql wrong.'
    #    exit 1
    #fi
    #wait 1
    #if [[ $(sudo /etc/init.d/vcap_redis status | grep 'is running') ]]; then
    #    echo 'vcap_redis is running..'
    #else
    #    echo 'Oh no, vcap_redis is wrong.'
    #    exit 1
    #fi
    #wait 1
    
    cd ~
    echo '结束后卸载nfs';
    sudo umount /home/orchard/nfs;
    echo '卸载结果... $?';
    "
}

sysdb $1 $2
exit 0
