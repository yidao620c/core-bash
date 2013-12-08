#!/bin/bash
# for loop demo
# 循环/etc/passwd文件中的账号

users=$(cut -d ':' -f1 /etc/passwd) #获取账号名称
for  username in $users
do
	id $username
	finger $username
done
