#!/bin/bash
# Program: shows the scipts name, parameters...
# @author: Xiong Neng
# @date: 2013/15/09
PATH=$PATH:~/bin
export PATH

echo "detect ..."
echo -e "the www, ftp, ssh, mail port will be detect \n"

testing=$(netstat -tnlp | grep ":80 ") #检测port80端口
if [ "${testing}" != "" ]; then
	echo "WWW is running..."
fi
testing=$(netstat -tnlp | grep ":22 ") #检测port22端口
if [ "${testing}" != "" ]; then
	echo "SSH is running..."
fi
testing=$(netstat -tnlp | grep ":21 ") #检测port21端口
if [ "${testing}" != "" ]; then
	echo "FTP is running..."
fi
testing=$(netstat -tnlp | grep ":25 ") #检测port25端口
if [ "${testing}" != "" ]; then
	echo "MAIL is running..."
fi
