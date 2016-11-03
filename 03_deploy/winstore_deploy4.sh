#!/bin/bash
# winstore自动打包发布服务
# 在/root/winstore_xn目录里面初始化winstore,winstore-web,winstore-base这3个项目即可
# 确保安装了subversion和cifs-utils

if [ "$#" -ne 1 ]; then
    echo "请输入一个版本号参数"
    exit 1
fi
[[ ! -d winstore-ansible ]] && svn checkout svn://10.0.0.52/product/ceph/trunk/02代码/winstore-ansible --username xiongneng --password xn1016
echo "先从svn获取最新源代码"
cd winstore-ansible
svn update --username xiongneng --password xn1016
cd resource/
tar -zcvf install_rpms.tar.gz install_rpms
tar -zcvf install_more_rpms.tar.gz install_more_rpms
tar -zcvf install_venv.tar.gz install_venv
tar -zcvf install_ceph_rpms.tar.gz install_ceph_rpms
tar -zcvf install_tgt.tar.gz install_tgt
tar -zcvf install_cairo.tar.gz install_cairo
cd ../..
new_file_name=winstore"$1"_install_$(date +"%Y%m%d").tar.gz
tar -czvf ${new_file_name} --exclude=.svn  --exclude=.git --exclude=resource/install_cairo --exclude=resource/install_ceph_rpms --exclude=resource/install_more_rpms --exclude=resource/install_rpms --exclude=resource/install_ceph --exclude=resource/install_tgt --exclude=resource/install_venv winstore-ansible/
echo "打完包后删除里面的tar包"
rm -f winstore-ansible/resource/install_rpms.tar.gz
rm -f winstore-ansible/resource/install_more_rpms.tar.gz
rm -f winstore-ansible/resource/install_venv.tar.gz
rm -f winstore-ansible/resource/install_ceph_rpms.tar.gz
rm -f winstore-ansible/resource/install_tgt.tar.gz
rm -f winstore-ansible/resource/install_cairo.tar.gz
echo "将升级后的包上传至samba服务器"
mount -t cifs -o username="ceshi",password="ceshi" //10.10.161.99/public /mnt/ -o rw
echo "mount success? $?"
/bin/cp "${new_file_name}" /mnt/winhong_ceph/winstore3.6Beta/"${new_file_name}"
rm -f "${new_file_name}"
echo "umount samba服务器"
umount /mnt/
echo "自动发布winstore完成..."


