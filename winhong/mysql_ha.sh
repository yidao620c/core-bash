#!/bin/bash
# mysql主从复制高可用
# mysql_ha.sh master_ip slave1_ip slave2_ip mysql_password
# yum remove -y {mysql-community-server,mysql-community-devel,mysql-community-client,mysql-community-commonmysql-community-libs}
# rm -rf {/usr/lib64/mysql,/etc/my.cnf,/root/.mysql_history,/var/lib/mysql}
# author: Xiong Neng

master_ip="$1"
slave1_ip="$2"
slave2_ip="$3"
mysql_password="$4"

echo "=====================先配置主DB服务器==================="

cat /etc/my.cnf | grep "server_id"
if [[ "$?" != "0" ]]; then
    sed -i '/\[mysqld\]/a\skip-name-resolve\nserver_id = 1\nlog-bin=mysql3306-bin' /etc/my.cnf
fi
systemctl restart mysqld.service

echo "================开始更新mysql配置============================"
if [[ "$slave1_ip" != "0" ]]; then
    mysql -uroot -p"${mysql_password}" <<EOF
    GRANT REPLICATION SLAVE,RELOAD,SUPER ON *.* TO 'slave1'@'${slave1_ip}' IDENTIFIED BY 'winstore';
    FLUSH PRIVILEGES;
EOF
fi
if [[ "$slave2_ip" != "0" ]]; then
    mysql -uroot -p"${mysql_password}" <<EOF
    GRANT REPLICATION SLAVE,RELOAD,SUPER ON *.* TO 'slave2'@'${slave2_ip}' IDENTIFIED BY 'winstore';
    FLUSH PRIVILEGES;
EOF
fi
echo "================查看master状态============================"
r=($(mysql -uroot -p"${mysql_password}" -e "show master status;" 2>/dev/null | grep "mysql3306-bin"))
binlog=${r[0]}
position=${r[1]}
echo "===============锁表============================"
mysql -uroot -p"${mysql_password}" -e "flush tables with read lock;"
echo "===============主库备份============================"
mysqldump -uroot -p"${mysql_password}" --all-databases > /tmp/mysql.sql
echo "===============解锁表============================"
mysql -uroot -p"${mysql_password}" -e "unlock tables;"
echo "===============ssh执行从表操作============================"
if [[ "$slave1_ip" != "0" ]]; then
    echo "===============复制mysql.sql文件到从表${slave1_ip}主机============="
    scp /tmp/mysql.sql root@"$slave1_ip":/tmp
    echo "===============从表${slave1_ip}:修改配置文件===================="
    ssh "$slave1_ip" "cat /etc/my.cnf" | grep "server_id"
    if [[ "$?" != "0" ]]; then
        ssh "$slave1_ip" "sed -i '/\[mysqld\]/a\server_id = 2' /etc/my.cnf"
    fi
    echo "===============从表${slave1_ip}:重启mysql===================="
    ssh "$slave1_ip" "systemctl restart mysqld.service"
    echo "===============从表${slave1_ip}:还原mysql.sql===================="
    ssh "$slave1_ip" "mysql -uroot -p${mysql_password} < /tmp/mysql.sql"
    echo "===============从表${slave1_ip}:更改master_host===================="
    ssh "$slave1_ip" "mysql -uroot -p${mysql_password} -e \"change master to master_host='$master_ip',master_user='slave1',master_password='winstore',master_port=3306,master_log_file='${binlog}',master_log_pos=${position};\""
    echo "===============从表${slave1_ip}:启动slave===================="
    ssh "$slave1_ip" "mysql -uroot -p${mysql_password} -e \"start slave;\""
    echo "===============从表${slave1_ip}:查看slave状态===================="
    check_result=$(ssh "$slave1_ip" "mysql -uroot -p${mysql_password} -e \"show slave status\G;\"")
    echo "===============从表${slave1_ip}:检查slave状态是否正确输出===================="
    echo "${check_result}" | grep "Slave_IO_Running: Yes"
    if [[ "$?" != "0" ]]; then
        echo "检查出错了。。。$slave1_ip Slave_IO_Running: Yes"
        exit 1
    fi
    echo "${check_result}" | grep "Slave_SQL_Running: Yes"
    if [[ "$?" != "0" ]]; then
        echo "检查出错了。。。$slave1_ip Slave_SQL_Running: Yes"
        exit 1
    fi
fi
if [[ "$slave2_ip" != "0" ]]; then
    echo "===============复制mysql.sql文件到从表${slave2_ip}主机============="
    scp /tmp/mysql.sql root@"$slave2_ip":/tmp
    echo "===============从表${slave2_ip}:修改配置文件===================="
    ssh "$slave2_ip" "cat /etc/my.cnf" | grep "server_id"
    if [[ "$?" != "0" ]]; then
        ssh "$slave2_ip" "sed -i '/\[mysqld\]/a\server_id = 3' /etc/my.cnf"
    fi
    echo "===============从表${slave2_ip}:重启mysql===================="
    ssh "$slave2_ip" "systemctl restart mysqld.service"
    echo "===============从表${slave2_ip}:还原mysql.sql===================="
    ssh "$slave2_ip" "mysql -uroot -p${mysql_password} < /tmp/mysql.sql"
    echo "===============从表${slave2_ip}:更改master_host===================="
    ssh "$slave2_ip" "mysql -uroot -p${mysql_password} -e \"change master to master_host='$master_ip',master_user='slave2',master_password='winstore',master_port=3306,master_log_file='${binlog}',master_log_pos=${position};\""
    echo "===============从表${slave2_ip}:启动slave===================="
    ssh "$slave2_ip" "mysql -uroot -p${mysql_password} -e \"start slave;\""
    echo "===============从表${slave2_ip}:查看slave状态===================="
    check_result=$(ssh "$slave2_ip" "mysql -uroot -p${mysql_password} -e \"show slave status\G;\"")
    echo "===============从表${slave2_ip}:检查slave状态是否正确输出===================="
    echo "${check_result}" | grep "Slave_IO_Running: Yes Error."
    if [[ "$?" != "0" ]]; then
        echo "检查出错了。。。$slave2_ip Slave_IO_Running: Yes Error"
        exit 1
    fi
    echo "${check_result}" | grep "Slave_SQL_Running: Yes Error"
    if [[ "$?" != "0" ]]; then
        echo "检查出错了。。。$slave2_ip Slave_SQL_Running: Yes Error"
        exit 1
    fi
fi


