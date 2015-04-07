#!/bin/sh
# linux maven 自动构建脚本

# CHECKOUT PROJECT SOURCE
WORK_DIR=/home/orchard/fastloan_project/fastloan
cd $WORK_DIR
echo current dir is `pwd`
svn update --username licf --password lcf0623
mvn clean && mvn package
rm -rf /home/orchard/apache-tomcat-8.0.20/webapps/ROOT/*
unzip target/*.war -d /home/orchard/apache-tomcat-8.0.20/webapps/ROOT/
echo "开始修改测试数据库"
jdbc_config='/home/orchard/apache-tomcat-8.0.20/webapps/ROOT/WEB-INF/classes/jdbc.properties'
sed -i "/^jdbc.url=/{s/\/fastloan?/\/fastloan_test?/}" $jdbc_config
echo "先kill tomcat进程..."
ps aux |grep tomcat |grep -v "grep tomcat" |while read line
do
    linewords=($line)
    pid="${linewords[1]}"
    sudo kill -9 $pid
done

echo "开始重启tomcat服务器..."
#/home/orchard/apache-tomcat-8.0.20/bin/catalina.sh stop
/home/orchard/apache-tomcat-8.0.20/bin/catalina.sh start > /dev/null &
echo "自动部署成功！！！"
