#!/bin/bash
# linux maven 贷快发生产环境自动发布脚本
# 这个脚本部署在192.168.203.94机器上面，用于获取最新SVN代码并打包，传输给生产环境
# 参数含义：
# 1：fastloan3-front
# 2：fastloan3-back
# 3：fastloan-producer
# 4：fastloan-consumer
# 5：fastloan-crawler
# 6：fastloan-datamsg-consumer

read -r -p "你确定要发布吗? y/n " response
echo    # (optional) move to a new line
if [[ ! $response =~ ^[Yy]$ ]]
then
    exit 1
fi

WORK_DIR=/home/orchard/deploy
cd $WORK_DIR
echo current dir is `pwd`

echo "先删除服务器上面的包"
ssh -p 10001 winhong@183.232.56.59 'rm -rf /home/winhong/deploy/zips/*'

echo "开始更新源码"
rm -rf zips/*
echo "$# -- $*"
if [[ "$#" == "0" || "$@" =~ "1" ]]; then
  echo "更新工程fastloan3-front开始"
  cd fastloan3-front
  svn update --username licf --password lcf0623
  mvn clean && mvn package -DskipTests=true
  mv target/fastloan3-front.war ../zips/
  cd ..
  echo "开始向服务器传输最新的包fastloan3-front开始"
  scp -P 10001 zips/fastloan3-front.war winhong@183.232.56.59:/home/winhong/work/zips/
  echo "更新工程fastloan3-front结束"
fi

if [[ "$#" == "0" || "$@" =~ "2" ]]; then
  echo "更新工程fastloan3-back开始"
  cd fastloan3-back
  svn update --username licf --password lcf0623
  mvn clean && mvn package -DskipTests=true
  mv target/fastloan3-back.war ../zips/
  cd ..
  echo "开始向服务器传输最新的包fastloan3-back开始"
  scp -P 10001 zips/fastloan3-back.war winhong@183.232.56.59:/home/winhong/work/zips/
  echo "更新工程fastloan3-back结束"
fi

if [[ "$#" == "0" || "$@" =~ "3" ]]; then
  echo "更新工程fastloan-producer开始"
  cd fastloan-producer
  svn update --username licf --password lcf0623
  mvn clean && mvn package -DskipTests=true
  mv target/fastloan-producer.war ../zips/
  cd ..
  echo "开始向服务器传输最新的包fastloan-producer开始"
  scp -P 10001 zips/fastloan-producer.war winhong@183.232.56.59:/home/winhong/work/zips/
  echo "更新工程fastloan-producer结束"
fi

if [[ "$#" == "0" || "$@" =~ "4" ]]; then
  echo "更新工程fastloan-consumer开始"
  cd fastloan-consumer
  svn update --username licf --password lcf0623
  mvn clean && mvn package -DskipTests=true
  mv target/fastloan-consumer.jar ../zips/
  cd ..
  echo "开始向服务器传输最新的包fastloan-consumer开始"
  scp -P 10001 zips/fastloan-consumer.jar winhong@183.232.56.59:/home/winhong/work/zips/
  echo "更新工程fastloan-consumer结束"
fi

if [[ "$#" == "0" || "$@" =~ "5" ]]; then
  echo "更新工程fastloan-crawler开始"
  cd fastloan-crawler
  svn update --username licf --password lcf0623
  mvn clean && mvn package -DskipTests=true
  mv target/fastloan-crawler.jar ../zips/
  cd ..
  echo "开始向服务器传输最新的包fastloan-crawler开始"
  scp -P 10001 zips/fastloan-crawler.jar winhong@183.232.56.59:/home/winhong/work/zips/
  echo "更新工程fastloan-crawler结束"
fi

if [[ "$#" == "0" || "$*" =~ "6" ]]; then
  echo "更新工程fastloan-datamsg-consumer开始"
  cd fastloan-datamsg-consumer
  svn update --username licf --password lcf0623
  mvn clean && mvn package -DskipTests=true
  mv target/fastloan-datamsg-consumer.jar ../zips/
  cd ..
  echo "开始向服务器传输最新的包fastloan-datamsg-consumer开始"
  scp -P 10001 zips/fastloan-datamsg-consumer.jar winhong@183.232.56.59:/home/winhong/work/zips/
  echo "更新工程fastloan-datamsg-consumer结束"
fi

echo "执行远程服务器上面的重新部署脚本"
ssh -p 10001 -tt winhong@183.232.56.59 "/home/winhong/work/deploy-all.sh $@"
echo "完成，请耐心等待服务器自动部署成功..."

