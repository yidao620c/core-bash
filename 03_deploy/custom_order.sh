#!/bin/bash
# desc   :   发布订单脚本
# author :   Xiong Neng
# email  :   yidao620@gmail.com
# date   :   2013/07/01

echo "-----准备发订单啦啦啦-----"

if [ "$#" -ne 1 ]; then
	echo "param error"
	exit 1
fi
if [ -z "$1" ];then
    echo "目标目录是空字符串"
    exit 1
fi
echo "订单发布目录是：$1"
cd "$1"

sh order.sh stop

echo "先删除原有的目录中的内容"

rm -rf *

mv /root/order-service-server*.zip .

unzip order-service-server*.zip

rm -f order-service-server*.zip

chown -R www:www *
sh order.sh start 1>/dev/null 2>&1
cd ~

echo "publish success"
