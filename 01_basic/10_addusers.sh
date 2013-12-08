#!/bin/bash
#新增加几个用来测试磁盘配额quota的用户

echo "先增加quotagrp用户组"
groupadd quotagrp
echo "然后开始增加5个测试用户"
for ((i=1; i<=5; i++))
do
	eachuser=quser$i
	useradd -g quotagrp $eachuser 
	echo "password" | passwd --stdin $eachuser
done
echo "successfully add quota users"
