#!/bin/bash
# winstore自动打包发布服务
# 在/root/winstore_xn目录里面初始化winstore,winstore-web,winstore-base这3个项目即可
# 确保安装了subversion和cifs-utils

if [ "$#" -ne 1 ]; then
    echo "请输入一个版本号参数"
    exit 1
fi

echo "先从svn获取最新源代码"
cd winstore
svn update --username xiongneng --password xn1016
cd ..
cd winstore-web
svn update --username xiongneng --password xn1016
cd ..
cd winstore-base
svn update --username xiongneng --password xn1016
cd ..

mount -t cifs -o username="samba",password="samba" //10.10.161.99/public /mnt/ -o rw
echo "$?"
cd /mnt/winhong_ceph/winstore3.0Beta
os6=$(ls *_winhong_winstore*_installer_centos6.tar.gz | tail -n 1)
os7=$(ls *_winhong_winstore*_installer_centos7.tar.gz | tail -n 1)
declare -a names=("$os6" "$os7")
install_dir="winhong_winstore_installer"

echo "进入工作目录"
cd /root/winstore_xn

time=$(date '+%Y%m%d%H%M%S')

echo "先创建空文件夹$install_dir"
if [ -d "$install_dir" ]; then
echo "installer dir exists..."
rm -rf "${install_dir}/*"
else
echo "installer dir not exists..."
mkdir "$install_dir"
fi
echo "install_dir=$install_dir"
cd ${install_dir}
cp -r ../winstore-base/* .
/bin/cp -r ../winstore/* opt/sdsom/venv/lib/python2.6/site-packages/sdsom-2.1.0-py2.6.egg/sdsom/
/bin/cp -r ../winstore-web/sdsomweb/* opt/sdsom/webapp/content/sdsomweb/

tar -zcf winstore_sdsom.tar.gz opt/sdsom/venv/lib/python2.6/site-packages/sdsom-2.1.0-py2.6.egg/sdsom/
tar -zcf winstore_sdsomweb.tar.gz opt/sdsom/webapp/content/sdsomweb/
rm -rf opt/sdsom/venv/lib/python2.6/site-packages/sdsom-2.1.0-py2.6.egg/sdsom/
rm -rf opt/sdsom/webapp/content/sdsomweb/
tar -zcf winstore_core.tar.gz opt/
echo "打完新包就删除原来文件夹opt/"
rm -rf opt/
cd ..

mv "$install_dir" "${install_dir}_temp"

for file_name in "${names[@]}"; do
    mkdir "$install_dir"
    echo "file_name=${file_name}"
    echo "最后开始打包安装包"
    if [[ $file_name == *"centos6"* ]]; then
        echo "this is for centos6"
	rsync -av --exclude='winhongceph_centos7.2' --exclude='winhongtgt_centos7.2.tar.gz' --exclude='winstore3.0_centos7.2_depend_rpm.tar.gz' "${install_dir}_temp"/ ${install_dir}
	cd ${install_dir}
        cd winhongceph_centos6.8
	tar -zcf winhongceph_centos6.8.tar.gz winhongceph
        mv winhongceph_centos6.8.tar.gz ..
        cd ..
	rm -rf winhongceph_centos6.8
	cd ..
    else
        echo "this is for centos7"
	rsync -av --exclude='winhongceph_centos6.8' --exclude='winhongtgt_centos6.8.tar.gz' --exclude='winstore3.0_centos6.8_depend_rpm.tar.gz' "${install_dir}_temp"/ ${install_dir}
	cd ${install_dir}
        cd winhongceph_centos7.2
	tar -zcf winhongceph_centos7.2.tar.gz winhongceph
        mv winhongceph_centos7.2.tar.gz ..
        cd ..
	rm -rf winhongceph_centos7.2
	cd ..
    fi
    new_time=$(date '+%Y%m%d')
    new_file_name="${new_time}_winhong_winstore$1${file_name:28}"
    tar -zcf "${new_file_name}" "${install_dir}"
    rm -rf ${install_dir}

    echo "将升级后的包上传至samba服务器"
    /bin/cp "${new_file_name}" /mnt/winhong_ceph/winstore3.0Beta/"${new_file_name}"
    rm -f "${new_file_name}"

done

rm -rf "${install_dir}_temp"

echo "umount samba服务器"
umount /mnt/
echo "自动发布winstore完成..."

