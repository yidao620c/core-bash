#!/bin/bash
# winstore自动打包发布服务
# 在/root/winstore_xn目录里面初始化winstore和winstore-web两个svn项目即可
# 确保安装了subversion和cifs-utils

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

echo "先从samba服务器上面获取最新的安装包"
mount -t cifs -o username="samba",password="samba" //10.10.161.99/public /mnt/ -o rw
echo "$?"
cd /mnt/winhong_ceph/winstore3.0Beta
#file_name=$(ls -l /mnt/*_winhong_winstore3.0_installer.tar.gz | tail -n 1 |rev |cut -d" " -f1|rev| cut -d"/" -f3)
#file_name=$(ls -l *_winhong_winstore3.0_installer*.tar.gz | tail -n 1 | rev |cut -d" " -f1|rev)
os6=$(ls *_winhong_winstore3.*_installer_centos6.tar.gz | tail -n 1)
os7=$(ls *_winhong_winstore3.*_installer_centos7.tar.gz | tail -n 1)
declare -a names=("$os6" "$os7")
for file_name in "${names[@]}"; do
    echo "file_name=${file_name}"
    echo "复制最新的安装包文件"
    cp "/mnt/winhong_ceph/winstore3.0Beta/${file_name}" /root/winstore_xn/

    echo "进入工作目录"
    cd /root/winstore_xn

    time=$(date '+%Y%m%d%H%M%S')

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
    echo "先解压winstore两个代码压缩包"
    tar -zxf winstore_sdsom.tar.gz
    tar -zxf winstore_sdsomweb.tar.gz
    rm -f winstore_sdsom.tar.gz
    rm -f winstore_sdsomweb.tar.gz

    echo "压缩python后台代码"
    cd ..
    /bin/cp -r winstore/* winhong_winstore3.0_installer/opt/sdsom/venv/lib/python2.6/site-packages/sdsom-2.1.0-py2.6.egg/sdsom/
    /bin/cp -r winstore-web/sdsomweb/* winhong_winstore3.0_installer/opt/sdsom/webapp/content/sdsomweb/

    cd winhong_winstore3.0_installer
    tar -zcf winstore_sdsom.tar.gz opt/sdsom/venv/lib/python2.6/site-packages/sdsom-2.1.0-py2.6.egg/sdsom/
    tar -zcf winstore_sdsomweb.tar.gz opt/sdsom/webapp/content/sdsomweb/

    echo "打完新包就删除原来临时文件夹opt/"
    rm -rf opt/
    cd ..

    echo "最后开始打包安装包"
    new_time=$(date '+%Y%m%d')
    new_file_name="${new_time}_winhong_winstore$1${file_name:28}"
    tar -zcf "${new_file_name}" winhong_winstore3.0_installer
    rm -rf winhong_winstore3.0_installer

    echo "将升级后的包上传至samba服务器"
    /bin/cp "${new_file_name}" /mnt/winhong_ceph/winstore3.0Beta/"${new_file_name}"
    rm -f "${new_file_name}"

done

echo "umount samba服务器"
umount /mnt/
echo "自动发布winstore完成..."

