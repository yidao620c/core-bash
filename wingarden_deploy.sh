#!/bin/bash
# wingarden全自动化部署脚本
# 说明：所有安装函数的第一个参数是被安装服务所在机器的IP地址，
# 第二个参数是NFS服务器的IP地址
#
# 安装前的准备工作：
#  NFS服务器 把安装包解压缩到上面
#  NFS服务器 sudo vim /etc/ssh/sshd_config StrictHostKeyChecking no
#  其他机器 orchard用户加入sudo组，然后在visudo里面把NOPASSWD放开
#  其他机器 已经安装了rpcbind和nfs-common这两个软件
#  其他机器 将NFS服务器上的pub_key一个个的加入authorized_keys文件中


set -e

function sysdb {
    if [[ $# != 2 ]]; then 
        echo "请输入正确的IP地址参数: localhost_ip nfs_ip nats_ip"
        exit 1
    fi
    echo "log sysdb -- 开始部署系统数据库pgsql"
    ssh -l orchard "$1" "
    set -e
    echo '成功登录$1 ，现在开始挂载NFS服务器目录'
    echo '建立客户端的NFS挂载目录'
    if [[ ! -d '/home/orchard/nfs' ]]; then 
        mkdir /home/orchard/nfs
    else echo 'nfs目录存在无需再创建'
    fi
    sudo mount -t nfs $2:/home/public /home/orchard/nfs
    echo '挂载结果: $?'
    cd /home/orchard/nfs/wingarden_install
    ./install.sh sysdb >/dev/null
    wait
    echo '安装sysdb成功后查看'
    if [[ \$(sudo /etc/init.d/postgresql status | grep 'is running') ]]; then
        echo 'postgresql status is running...'
    else
        echo 'Oh, No,,,postgresql wrong.'
        exit 1
    fi
    wait 1
    if [[ \$(sudo /etc/init.d/vcap_redis status | grep 'is running') ]]; then
        echo 'vcap_redis is running..'
    else
        echo 'Oh no, vcap_redis is wrong.'
        exit 1
    fi
    wait 1
    
    cd ~
    echo '结束后卸载nfs';
    sudo umount /home/orchard/nfs;
    echo '卸载结果... $?';
    "
}

function nats {
    if [[ $# != 2 ]]; then 
        echo "请输入正确的IP地址参数: localhost_ip nfs_ip nats_ip"
        exit 1
    fi
    echo "log nats--开始部署Nats组件"
    ssh -l orchard "$1" "
    set -e
    echo '成功登录$1 ，现在开始挂载NFS服务器目录'
    echo '建立客户端的NFS挂载目录'
    if [[ ! -d '/home/orchard/nfs' ]]; then 
        mkdir /home/orchard/nfs
    else echo 'nfs目录存在无需再创建'
    fi
    sudo mount -t nfs $2:/home/public /home/orchard/nfs
    echo '挂载结果: $?'
    cd /home/orchard/nfs/wingarden_install
    ./install.sh nats >/dev/null
    wait
    echo '安装完后开始检查natsserver的状态.'
    if [[ \$(sudo /etc/init.d/nats_server status | grep 'is running') ]]; then
        echo 'Success.'
    else
        echo 'Oh No.... natsserver is wrong.'
        exit 1
    fi

    cd ~
    echo '结束后卸载nfs';
    sudo umount /home/orchard/nfs;
    echo '卸载结果... $?';
    "
}

# $3: nats服务器IP地址
function gorouter {
    if [[ $# != 3 ]]; then 
        echo "请输入正确的IP地址参数: localhost_ip nfs_ip nats_ip"
        exit 1
    fi
    echo "log gorouter -- 开始部署gorouter"
    ssh -l orchard "$1" "
    set -e
    echo '先安装go的编译环境依赖'
    sudo apt-get install -y git mercurial bzr build-essential 1>/dev/null 2>&1
    wait
    echo '开始挂载nfs服务器'
    echo '建立客户端的NFS挂载目录'
    if [[ ! -d '/home/orchard/nfs' ]]; then 
        mkdir /home/orchard/nfs
    else echo 'nfs目录存在无需再创建'
    fi
    sudo mount -t nfs $2:/home/public /home/orchard/nfs
    echo '挂载结果: $?'
    cd /home/orchard/nfs/wingarden_install/router
    tar -zxvf gorouter.tar.gz -C /home/orchard 1>/dev/null
    wait
    echo 'tar finished..'
    sudo sh -c 'echo \"export PATH=/home/orchard/go/bin:\\\$PATH\" >> /etc/profile'
    sudo sh -c 'echo \"export GOPATH=/home/orchard/gopath\" >> /etc/profile'
    source /etc/profile
    echo 'source finished.'
    wait
    go_config='/home/orchard/gopath/src/github.com/cloudfoundry/gorouter/config/config.go'
    sed -i '/defaultNatsConfig = NatsConfig/{n; s/\".*\"/\"$3\"/g;}' \$go_config
    echo 'nats ip替换完成了'
    cd /home/orchard/gopath
    echo '开始编译go'
    go get -v ./src/github.com/cloudfoundry/gorouter/...
    wait
    echo 'go编译完成了..'
    echo '检查go可执行文件'
    if [[ -f /home/orchard/gopath/bin/router ]]; then
        echo 'router可执行文件有了'
    else
        echo 'Oh, No.... router file not exists.'
        exit 1
    fi
    echo 'copy gorouter to init.d directory'
    sudo cp /home/orchard/nfs/wingarden_install/router/gorouter /etc/init.d/
    echo '启动 gorouter..'
    if [[ ! \$(ps aux |grep -v grep  |grep router) ]]; then
        sudo /etc/init.d/gorouter start
        wait
    fi
    echo '检查gorouter启动状态'
    if [[ \$(sudo /etc/init.d/gorouter status | grep 'is running') ]]; then
        echo 'gorouter is running...'
    else
        echo 'Oh, No... gorouter status is wrong.'
        exit 1
    fi
    echo '设置自启动'
    sudo update-rc.d gorouter defaults 20 80
    cd ~
    echo '结束后卸载nfs';
    sudo umount /home/orchard/nfs;
    echo '卸载结果... $?';
    "
}

# cloud_controller 安装
# $3: Nats服务器的IP地址
# $4: 系统数据库Pgsql的IP地址
# $5: domain_name
function cloud_controller {
    if [[ $# != 5 ]]; then
        echo "请输入正确的IP地址参数: localhost_ip nfs_ip nats_ip pgsql_ip domain_name"
        exit 1
    fi
    echo "log cloud_controller -- 开始部署cloud_controller组件"
    ssh -l orchard "$1" "
    set -e
    echo '成功登录$1 ，现在开始挂载NFS服务器目录'
    echo '建立客户端的NFS挂载目录'
    if [[ ! -d '/home/orchard/nfs' ]]; then 
        mkdir /home/orchard/nfs
    else echo 'nfs目录存在无需再创建'
    fi
    sudo mount -t nfs $2:/home/public /home/orchard/nfs
    echo '挂载结果: $?'
    cd /home/orchard/nfs/wingarden_install
    ./install.sh cloud_controller >/dev/null
    wait
    echo '开始修改配置文件cloud_controller.yml'
    cc_config=/home/orchard/cloudfoundry/config/cloud_controller.yml
    echo '修改external_uri地址'
    sed -i '/external_uri:/{s/: .*$/: api.$5/}' \$cc_config
    echo '修改local_route'
    local_route=\$(netstat -rn | grep -w -E '^0.0.0.0' | awk '{print \$2}')
    echo 'local_route=\$local_route'
    sed -i \"/local_route:/{s/: .*$/: \$local_route/}\" \$cc_config
    echo '修改nats的IP地址'
    sed -i '/mbus:/{s/@.*:/@$3:/}' \$cc_config
    echo '修改系统数据库地址'
    sed -i '/database: cloud_controller/{n; s/:.*$/: $4/}' \$cc_config
    echo '修改UAA的url'
    sed -i '/uaa:/{n; n; s/:.*$/: http:\/\/uaa.$5/}' \$cc_config
    echo '修改redis的IP地址'
    sed -i '/^redis:/{n; s/: .*$/: $4/}' \$cc_config
    echo '替换完成了。。。。。。。。。'
    echo '修改vcap_components.'
    echo '{\"components\":[\"cloud_controller\"]}' > /home/orchard/cloudfoundry/config/vcap_components.json
    cd ~
    echo '结束后卸载nfs';
    if [[ \$(lsof | grep /home/orchard/nfs) ]]; then
        sudo kill -9 \$(lsof | grep /home/orchard/nfs | awk '{print \$2}')
    fi
    sudo umount /home/orchard/nfs;
    echo '卸载结果... $?';

    echo '最后启动cloud_controller...'
    sudo /etc/init.d/cloudfoundry start cloud_controller
    wait 
    echo '启动cloud_controller 完成，查看状态'
    sudo /etc/init.d/cloudfoundry status
    "
}

# UAA 安装
# $3: Nats服务器的IP地址
# $4: 系统数据库Pgsql的IP地址
# $5: domain_name
function uaa {
    if [[ $# != 5 ]]; then
        echo "请输入正确的IP地址参数: localhost_ip nfs_ip nats_ip pgsql_ip domain_name"
        exit 1
    fi
    echo "log uaa -- 开始部部署uaa组件"
    ssh -l orchard "$1" "
    set -e
    echo '成功登录$1 ，现在开始挂载NFS服务器目录'
    echo '建立客户端的NFS挂载目录'
    if [[ ! -d '/home/orchard/nfs' ]]; then 
        mkdir /home/orchard/nfs
    else echo 'nfs目录存在无需再创建'
    fi
    sudo mount -t nfs $2:/home/public /home/orchard/nfs
    echo '挂载结果: $?'
    cd /home/orchard/nfs/wingarden_install
    ./install.sh uaa >/dev/null
    wait
    echo '开始修改配置文件uaa.yml'
    cc_config=/home/orchard/cloudfoundry/config/uaa.yml
    echo '修改local_route'
    local_route=\$(netstat -rn | grep -w -E '^0.0.0.0' | awk '{print \$2}')
    echo 'local_route=\$local_route'
    sed -i \"/local_route:/{s/: .*$/: \$local_route/}\" \$cc_config
    echo '修改nats的IP地址'
    sed -i '/mbus:/{s/@.*:/@$3:/}' \$cc_config
    echo '修改系统数据库地址'
    sed -i '/5432\/uaa/{s/\/\/.*:5432/\/\/$4:5432/}' \$cc_config
    sed -i '/5432\/cloud_controller/{s/\/\/.*:5432/\/\/$4:5432/}' \$cc_config
    echo '修改UAA的uris'
    sed -i '/uris:/{n; s/uaa\..*$/uaa.$5/}' \$cc_config
    echo '修改vmc的redirect地址'
    sed -i '/redirect-uri:/{s/^.*$/&,http:\/\/uaa.$5\/redirect\/vmc/}' \$cc_config
    echo '替换完成了。。。。。。。。。'
    echo '修改vcap_components.'
    echo '{\"components\":[\"cloud_controller\",\"uaa\"]}' > /home/orchard/cloudfoundry/config/vcap_components.json
    cd ~
    echo '结束后卸载nfs';
    if [[ \$(lsof | grep /home/orchard/nfs) ]]; then
        sudo kill -9 \$(lsof | grep /home/orchard/nfs | awk '{print \$2}')
    fi
    sudo umount /home/orchard/nfs;
    echo '卸载结果... $?';

    echo '最后启动uaa...'
    sudo /etc/init.d/cloudfoundry start uaa
    wait 
    echo '启动uaa 完成，查看状态'
    sudo /etc/init.d/cloudfoundry status
    "
}

# Stager 安装
# $3: Nats服务器的IP地址
function stager {
    if [[ $# != 3 ]]; then
        echo "请输入正确的IP地址参数: localhost_ip nfs_ip nats_ip"
        exit 1
    fi
    echo "log stager -- 开始部部署stager组件"
    ssh -l orchard "$1" "
    set -e
    echo '成功登录$1 ，现在开始挂载NFS服务器目录'
    echo '建立客户端的NFS挂载目录'
    if [[ ! -d '/home/orchard/nfs' ]]; then 
        mkdir /home/orchard/nfs
    else echo 'nfs目录存在无需再创建'
    fi
    sudo mount -t nfs $2:/home/public /home/orchard/nfs
    echo '挂载结果: $?'
    cd /home/orchard/nfs/wingarden_install
    ./install.sh stager >/dev/null
    wait
    echo '开始修改配置文件stager.yml'
    cc_config=/home/orchard/cloudfoundry/config/stager.yml
    echo '修改nats的IP地址'
    sed -i '/nats_uri:/{s/@.*:/@$3:/}' \$cc_config
    echo '替换完成了。。。。。。。。。'
    echo '修改vcap_components.'
    echo '{\"components\":[\"cloud_controller\",\"uaa\",\"stager\"]}' \\
        > /home/orchard/cloudfoundry/config/vcap_components.json
    cd ~
    echo '结束后卸载nfs';
    if [[ \$(lsof | grep /home/orchard/nfs) ]]; then
        sudo kill -9 \$(lsof | grep /home/orchard/nfs | awk '{print \$2}')
    fi
    sudo umount /home/orchard/nfs;
    echo '卸载结果... $?';

    echo '最后启动stager...'
    sudo /etc/init.d/cloudfoundry start stager
    wait 
    echo '启动stager 完成，查看状态'
    sudo /etc/init.d/cloudfoundry status
    "
}

# HealthManager 安装
# $3: Nats服务器的IP地址
# $4: 系统数据库PGSql服务器的IP地址
function health_manager {
    if [[ $# != 4 ]]; then
        echo "请输入正确的IP地址参数: localhost_ip nfs_ip nats_ip sysdb_ip"
        exit 1
    fi
    echo "log health_manager -- 开始部部署health_manager组件"
    ssh -l orchard "$1" "
    set -e
    echo '成功登录$1 ，现在开始挂载NFS服务器目录'
    echo '建立客户端的NFS挂载目录'
    if [[ ! -d '/home/orchard/nfs' ]]; then 
        mkdir /home/orchard/nfs
    else echo 'nfs目录存在无需再创建'
    fi
    sudo mount -t nfs $2:/home/public /home/orchard/nfs
    echo '挂载结果: $?'
    cd /home/orchard/nfs/wingarden_install
    sh -c './install.sh health_manager >/dev/null'
    wait
    echo '开始修改配置文件health_manager.yml'
    cc_config=/home/orchard/cloudfoundry/config/health_manager.yml
    echo '修改local_route'
    local_route=\$(netstat -rn | grep -w -E '^0.0.0.0' | awk '{print \$2}')
    echo 'local_route=\$local_route'
    sed -i \"/local_route:/{s/: .*$/: \$local_route/}\" \$cc_config
    echo '修改nats的IP地址'
    sed -i '/mbus:/{s/@.*:/@$3:/}' \$cc_config
    echo '修改系统数据库地址'
    sed -i '/database: cloud_controller/{n; s/:.*$/: $4/}' \$cc_config
    echo '替换完成了。。。。。。。。。'
    echo '修改vcap_components.'
    echo '{\"components\":[\"cloud_controller\",\"uaa\",\"stager\",\"health_manager\"]}' \\
        > /home/orchard/cloudfoundry/config/vcap_components.json
    cd ~
    echo '结束后卸载nfs';
    if [[ \$(lsof | grep /home/orchard/nfs) ]]; then
        sudo kill -9 \$(lsof | grep /home/orchard/nfs | awk '{print \$2}')
    fi
    sudo umount /home/orchard/nfs;
    echo '卸载结果... $?';

    echo '最后启动health_manager...'
    sudo sh -c '/etc/init.d/cloudfoundry start health_manager >/dev/null'
    wait 
    echo '启动health_manager 完成，查看状态'
    sudo /etc/init.d/cloudfoundry status
    "
}

# DEA 安装
# $3: Nats服务器的IP地址
# $4: domain_name
function dea {
    if [[ $# != 4 ]]; then
        echo "请输入正确的IP地址参数: localhost_ip nfs_ip nats_ip domain_name"
        exit 1
    fi
    echo "log dea -- 开始部部署dea组件"
    ssh -l orchard "$1" "
    set -e
    echo '成功登录$1 ，现在开始挂载NFS服务器目录'
    echo '建立客户端的NFS挂载目录'
    if [[ ! -d '/home/orchard/nfs' ]]; then 
        mkdir /home/orchard/nfs
    else echo 'nfs目录存在无需再创建'
    fi
    sudo mount -t nfs $2:/home/public /home/orchard/nfs
    echo '挂载结果: $?'
    cd /home/orchard/nfs/wingarden_install
    sh -c './install.sh dea >/dev/null'
    wait
    echo '在secure_path中添加ruby路径'
    add_path='Defaults  secure_path=\"/home/orchard/language/ruby19/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"'
    sudo sh -c 'echo $add_path >> /etc/sudoers'
    echo '开始修改配置文件dea.yml'
    cc_config=/home/orchard/dea/config/dea.yml
    echo '修改local_route'
    local_route=\$(netstat -rn | grep -w -E '^0.0.0.0' | awk '{print \$2}')
    echo 'local_route=\$local_route'
    sed -i \"/local_route:/{s/: .*$/: \$local_route/}\" \$cc_config
    echo '修改nats的IP地址'
    sed -i '/nats_uri:/{s/@.*:/@$3:/}' \$cc_config
    echo '修改domain'
    sed -i '/domain:/{s/:.*$/: $4/}' \$cc_config
    echo '替换完成了。。。。。。。。。'
    cd ~
    echo '结束后卸载nfs';
    if [[ \$(lsof | grep /home/orchard/nfs) ]]; then
        sudo kill -9 \$(lsof | grep /home/orchard/nfs | awk '{print \$2}')
    fi
    sudo umount /home/orchard/nfs;
    echo '卸载结果... $?';

    echo '最后启动dea...'
    sudo sh -c '/etc/init.d/dea start >/dev/null'
    wait 
    echo '启动dea 完成'
    "
}
#sysdb 10.0.0.154 10.0.0.160
#nats 10.0.0.158 10.0.0.160
#gorouter 10.0.0.158 10.0.0.160 10.0.0.158
#cloud_controller 10.0.0.158 10.0.0.160 10.0.0.158 10.0.0.154 wingarden.net
#uaa 10.0.0.158 10.0.0.160 10.0.0.158 10.0.0.154 wingarden.net
#stager 10.0.0.158 10.0.0.160 10.0.0.158
#health_manager 10.0.0.158 10.0.0.160 10.0.0.158 10.0.0.154
dea 10.0.0.158 10.0.0.160 10.0.0.158 wingarden.net

exit 0
