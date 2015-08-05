#!/bin/bash
# linux 贷快发生产环境自动发布脚本
# 参数含义：
# 1：fastloan3-front
# 2：fastloan3-back
# 3：fastloan-producer
# 4：fastloan-consumer
# 5：fastloan-crawler
# 6：fastloan-datamsg-consumer

echo "向各个服务器分发最新的包"
if [[ "$#" == "0" || "$@" =~ "2" ]]; then
  scp /home/winhong/work/zips/fastloan3-back.war winhong@192.168.200.31:/home/winhong/work/zips/
fi
if [[ "$#" == "0" || "$@" =~ "3" ]]; then
  scp /home/winhong/work/zips/fastloan-producer.war winhong@192.168.200.32:/home/winhong/work/zips/
fi
if [[ "$#" == "0" || "$@" =~ "4" ]]; then
  scp /home/winhong/work/zips/fastloan-consumer.jar winhong@192.168.200.34:/home/winhong/work/zips/
fi
if [[ "$#" == "0" || "$@" =~ "5" ]]; then
  scp /home/winhong/work/zips/fastloan-crawler.jar winhong@192.168.200.34:/home/winhong/work/zips/
fi
if [[ "$#" == "0" || "$@" =~ "6" ]]; then
  scp /home/winhong/work/zips/fastloan-datamsg-consumer.jar winhong@192.168.200.34:/home/winhong/work/zips/
fi

echo "包分发完成后开始执行部署..."

if [[ "$#" == "0" || "$@" =~ "1" ]]; then
  nohup sh /home/winhong/work/deploy-front.sh
fi
if [[ "$#" == "0" || "$@" =~ "2" ]]; then
  cat /home/winhong/work/deploy-back.sh | ssh winhong@192.168.200.31 -tt
fi
if [[ "$#" == "0" || "$@" =~ "3" ]]; then
  cat /home/winhong/work/deploy-producer.sh | ssh winhong@192.168.200.32 -tt
fi
if [[ "$#" == "0" || "$@" =~ "4" ]]; then
  cat /home/winhong/work/deploy-consumer.sh | ssh winhong@192.168.200.34 -tt
fi
if [[ "$#" == "0" || "$@" =~ "5" ]]; then
  cat /home/winhong/work/deploy-crawler.sh | ssh winhong@192.168.200.34 -tt
fi
if [[ "$#" == "0" || "$@" =~ "6" ]]; then
  cat /home/winhong/work/deploy-datamsg-consumer.sh | ssh winhong@192.168.200.34 -tt
fi

echo "全部发布完成 恭喜你 "

