#!/bin/bash
# 自动发布grails工程的小小脚本
# 前提是先将war包放到/root/里面
# author: Xiong Neng
# date: 2013/05/17

echo "开始停止resin服务...."
/etc/init.d/resin stop
echo "成功停止resin服务...."
cd /data/www/
echo "开始新建当前日期文件夹"
today=$(date +%Y%m%d_%H%M)
mkdir $today
cd $today
rm -rf `ls | grep -v '.*\.war'`
mv /root/project.war .
unzip project.war 1>/dev/null 2>&1
rm -f project.war
chown -R www:www *
realpath=$(pwd)
cd ..
if [ -L "html" ]; then
	echo "html链接存在，先删除"
	unlink html
else
	echo "html链接不存在，略过这步"
fi
echo "重新链接html到新的目录"
ln -s ${today}/ html
echo "修改html的权限到www:www"
chown -R www:www html/
chown -h www:www html
echo "开始重新启动resin服务...."
/etc/init.d/resin start 1>/dev/null 2>&1
echo "成功重新启动resin服务...."
exit 0
