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

echo "开始重启tomcat服务器..."
/home/orchard/apache-tomcat-8.0.20/bin/catalina.sh stop
/home/orchard/apache-tomcat-8.0.20/bin/catalina.sh start > /dev/null &
echo "自动部署成功！！！"
