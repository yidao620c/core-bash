#!/bin/bash
# winstore自动打包发布服务
# 在/root/winstore_xn目录里面初始化winstore和winstore-web两个svn项目即可
# 确保安装了subversion和cifs-utils

echo "先从samba服务器上面获取最新的安装包"
mount -t cifs -o username="samba",password="samba" //10.10.161.99/public /mnt/ -o rw
echo "$?"
cd /mnt/winhong_ceph/winstore3.0Beta
#file_name=$(ls -l /mnt/*_winhong_winstore3.0_installer.tar.gz | tail -n 1 |rev |cut -d" " -f1|rev| cut -d"/" -f3)
file_name=$(ls -l *_winhong_winstore3.0_installer.tar.gz | tail -n 1 | rev |cut -d" " -f1|rev)
echo "file_name=${file_name}"
echo "复制最新的安装包文件"
cp "/mnt/winhong_ceph/winstore3.0Beta/${file_name}" /root/winstore_xn/

echo "进入工作目录"
cd /root/winstore_xn

svn_sdsom_pre="/root/winstore_xn/winstore"
sdsom_pre="/opt/sdsom/venv/lib/python2.6/site-packages/sdsom-2.1.0-py2.6.egg/sdsom"

svn_sdsomweb_pre="/root/winstore_xn/winstore-web"
sdsomweb_pre="/opt/sdsom/webapp/content"

time=$(date '+%Y%m%d%H%M%S')

echo "保留上一个版本源码，方便后面打patch"
cp -r winstore winstore_orig
cp -r winstore-web winstore-web_orig

echo "svn更新最新代码"
cd winstore
svn update --username xiongneng --password xn1016
cd ..
cd winstore-web
svn update --username xiongneng --password xn1016
cd ..

echo "先解压缩安装包"
tar -zxf "${file_name}"
rm -f "${file_name}"
cd winhong_winstore3.0_installer/
tar xf winstore3.0_winhongpatch.tar.gz

cd ..
echo "生成sdsom补丁"
diff -Nurp --exclude="*.pyc" --exclude=".svn" /root/winstore_xn/winstore_orig /root/winstore_xn/winstore > "sdsom${time}.patch"
echo "生成sdsomweb补丁"
diff -Nurp --exclude="*.pyc" --exclude=".svn" /root/winstore_xn/winstore-web_orig /root/winstore_xn/winstore-web > "sdsomweb${time}.patch"

echo "打完patch后就删除orig文件夹"
rm -rf /root/winstore_xn/winstore_orig/ /root/winstore_xn/winstore-web_orig/

echo "补丁文件前缀替换"
sed -i "s:${svn_sdsom_pre}:${sdsom_pre}:g" "sdsom${time}.patch"
sed -i "s:${svn_sdsomweb_pre}:${sdsomweb_pre}:g" "sdsomweb${time}.patch"
echo "将补丁文件放入相应的安装包文件夹中"
mv sdsom*.patch winhong_winstore3.0_installer/winstore3.0_winhongpatch

echo "开始打包patch文件夹"
cd winhong_winstore3.0_installer
rm -f winstore3.0_winhongpatch.tar.gz
tar -cf winstore3.0_winhongpatch.tar.gz winstore3.0_winhongpatch
rm -rf winstore3.0_winhongpatch

echo "开始修改install脚本"
p1="patch -N -p0 < \${preDir}/winstore3.0_winhongpatch/sdsom${time}.patch"
p2="patch -N -p0 < \${preDir}/winstore3.0_winhongpatch/sdsomweb${time}.patch"
sed -i "/for iscsi export all lun/i\ \ \ \ ${p1}" install_local.sh
sed -i "/for iscsi export all lun/i\ \ \ \ ${p2}" install_local.sh

echo "最后开始打包安装包"
cd ..
new_time=$(date '+%Y%m%d')
new_file_name="${new_time}_winhong_winstore3.0_installer.tar.gz"
tar -zcf "${new_file_name}" winhong_winstore3.0_installer
rm -rf winhong_winstore3.0_installer

echo "将升级后的包上传至samba服务器"
/bin/cp "${new_file_name}" /mnt/winhong_ceph/winstore3.0Beta/"${new_file_name}"
rm -f "${new_file_name}"

echo "umount samba服务器"
umount /mnt/
echo "自动发布winstore完成..."

