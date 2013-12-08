#!/bin/bash
# desc   :   发布处理器脚本
# author :   Xiong Neng
# email  :   yidao620@gmail.com
# date   :   2013/07/01

echo "-----准备发处理器啦啦啦-----"

if [ "$#" -ne 1 ]; then
	echo "param error"
	exit 1
fi
if [ -z "$1" ];then
    echo "目标目录是空字符串"
    exit 1
fi

echo "处理器发布目录为：$1"
cd "$1"
if [ -d "temp" ]
then
    echo "temp exists. good!"
    rm -rf temp/*
else
  mkdir temp
fi

mv process.jar temp
cd temp
jar -xvf process.jar
if [ "$?" != "0" ]; then
    echo "木有找到jar命令，我自己去找"
    $(grep "JAVA_HOME=" /etc/init.d/resin | cut -d "=" -f2)/bin/jar -xvf process.jar
fi
echo "在temp中解压缩完成"

# echo "先删除原有的目录中的文件"
# rm -rf $(ls | grep -v 'process.jar')

chown -R www:www *

echo "开始执行run.sh了，哈哈哈哈"
sh run.sh 1>/dev/null 2>&1
cd ~
echo "publish success"