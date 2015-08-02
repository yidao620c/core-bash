#!/bin/bash
# linux maven 贷快发生产环境自动发布脚本
# 这个脚本部署在192.168.203.94机器上面，用于获取最新SVN代码并打包，传输给生产环境

WORK_DIR=/home/orchard/deploy
cd $WORK_DIR
echo current dir is `pwd`

echo "开始更新源码"
rm -rf zips/*

echo "更新工程fastloan3-front开始"
cd fastloan3-front
svn update --username licf --password lcf0623
mvn clean && mvn package -DskipTests=true
mv target/fastloan3-front.war ../zips/
cd ..
echo "更新工程fastloan3-front结束"

echo "更新工程fastloan3-back开始"
cd fastloan3-back
svn update --username licf --password lcf0623
mvn clean && mvn package -DskipTests=true
mv target/fastloan3-back.war ../zips/
cd ..
echo "更新工程fastloan3-back结束"

echo "更新工程fastloan-producer开始"
cd fastloan-producer
svn update --username licf --password lcf0623
mvn clean && mvn package -DskipTests=true
mv target/fastloan-producer.war ../zips/
cd ..
echo "更新工程fastloan-producer结束"


echo "更新工程fastloan-consumer开始"
cd fastloan-consumer
svn update --username licf --password lcf0623
mvn clean && mvn package -DskipTests=true
mv target/fastloan-consumer.jar ../zips/
cd ..
echo "更新工程fastloan-consumer结束"

echo "开始向服务器传输最新的包开始"
ssh -p 10001 winhong@183.232.56.59 'rm -rf /home/orchard/deploy/zips/*'
scp -P 10001 zips/* winhong@183.232.56.59:/home/winhong/work/zips/
echo "开始向服务器传输最新的包结束"

echo "执行远程服务器上面的重新部署脚本"
ssh -p 10001 winhong@183.232.56.59 '/home/winhong/work/deploy-all.sh'
echo "完成，请耐心等待服务器自动部署成功..."

