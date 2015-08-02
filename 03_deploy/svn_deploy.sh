#!/bin/sh
# linux maven 自动构建脚本

# CHECKOUT PROJECT SOURCE
# svn checkout svn://192.168.1.51/fastloan/trunk/02代码/fastloan-consumer fastloan-consumer2 --username licf --password lcf0623
WORK_DIR=/home/orchard/fastloan_project/fastloan-consumer2
cd $WORK_DIR
echo current dir is `pwd`
svn update --username licf --password lcf0623
PID_FILE=/home/orchard/consumer2.pid
if [[ -f $PID_FILE ]]; then
    pidstr=$(cat $PID_FILE)
    if [[ -n $pidstr ]]; then
        echo "停止java进程...."
        kill -9 $pidstr
    fi
fi

echo "开始修改测试数据库"
jdbc_config="$WORK_DIR/src/main/resources/jdbc.properties"
sed -i "/^jdbc.url=/{s/\/fastloan?/\/fastloan_test_lcf?/}" $jdbc_config

echo "开始修改测试队列"
common_config="$WORK_DIR/src/main/resources/config.properties"
sed -i "/^jms.queue.name=/{s/=.*$/=DATA.INVOICE_TEST/}" $common_config

echo "编译工程..."
mvn clean && mvn compile

echo "最后启动..."
mvn test &
echo $! > /home/orchard/consumer2.pid
echo "successful......"

