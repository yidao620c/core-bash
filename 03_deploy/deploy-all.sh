#!/bin/bash
# linux 贷快发生产环境自动发布脚本

echo "向各个服务器分发最新的包"
scp /home/winhong/work/zips/fastloan3-back.war winhong@192.168.200.31:/home/winhong/work/zips/
scp /home/winhong/work/zips/fastloan-producer.war winhong@192.168.200.32:/home/winhong/work/zips/
scp /home/winhong/work/zips/fastloan-consumer.jar winhong@192.168.200.34:/home/winhong/work/zips/
scp /home/winhong/work/zips/fastloan-crawler.jar winhong@192.168.200.34:/home/winhong/work/zips/
scp /home/winhong/work/zips/fastloan-datamsg-consumer.jar winhong@192.168.200.34:/home/winhong/work/zips/

echo "包分发完成后开始执行部署..."

nohup sh /home/winhong/work/deploy-front.sh
cat /home/winhong/work/deploy-back.sh | ssh winhong@192.168.200.31 -tt 
cat /home/winhong/work/deploy-producer.sh | ssh winhong@192.168.200.32 -tt  
cat /home/winhong/work/deploy-consumer.sh | ssh winhong@192.168.200.34 -tt 
cat /home/winhong/work/deploy-crawler.sh | ssh winhong@192.168.200.34 -tt
cat /home/winhong/work/deploy-datamsg-consumer.sh | ssh winhong@192.168.200.34 -tt 


echo "全部发布完成 恭喜你 "

