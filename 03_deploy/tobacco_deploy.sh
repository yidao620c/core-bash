#!/bin/sh
# tobacco工程的自动发布
# CHECKOUT PROJECT SOURCE
echo "先kill tomcat进程..."
ps aux |grep tomcat |grep -v "grep tomcat" |while read line
do
    linewords=($line)
    pid="${linewords[1]}"
    sudo kill -9 $pid
done
WORK_DIR=/home/orchard/work/tobacco
cd $WORK_DIR
echo current dir is `pwd`
echo "开始pull 最新源码，打包并且替换..."
git pull
mvn clean && mvn package -DskipTests=true  
rm -rf /home/orchard/apache-tomcat-8.0.20/webapps/ROOT/*
unzip target/tobacco.war -d /home/orchard/apache-tomcat-8.0.20/webapps/ROOT
#echo "开始修改测试数据库"
#jdbc_config='/home/orchard/apache-tomcat-8.0.20/webapps/fastloan_test/WEB-INF/classes/jdbc.properties'
#sed -i "/^jdbc.url=/{s/\/fastloan.*?/\/fastloan_test?/}" $jdbc_config

echo "开始重启tomcat服务器..."
/home/orchard/apache-tomcat-8.0.20/bin/catalina.sh start > /dev/null &
echo "自动部署成功！！！"

