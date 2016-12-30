#!/bin/bash
# winstore自动打包发布服务
# 确保安装了subversion和cifs-utils

if [[ "$#" < 1 ]]; then
    echo "请输入一个版本号参数"
    exit 1
fi
[[ ! -d winstore-ansible ]] && svn checkout svn://10.0.0.52/product/ceph/trunk/02代码/winstore-ansible --username xiongneng --password xn1016
echo "先从svn获取最新源代码"
cd winstore-ansible
svn update --username xiongneng --password xn1016
cd resource/
tar -zcvf install_rpms.tar.gz install_rpms
tar -zcvf install_yum.tar.gz install_yum
tar -zcvf install_more_rpms.tar.gz install_more_rpms
tar -zcvf install_venv.tar.gz install_venv
tar -zcvf install_ceph_rpms.tar.gz install_ceph_rpms
tar -zcvf install_tgt.tar.gz install_tgt
tar -zcvf install_cairo.tar.gz install_cairo
cd ../..
echo "为脚本增加可执行权限"
chmod +x winstore-ansible/*.sh
chmod +x winstore-ansible/*.exp

mount -t cifs -o username="ceshi",password="ceshi" //10.10.161.99/public /mnt/ -o rw
echo "mount success? $?"

echo "开始打包winstore..."
new_file_name=winstore"$1"_install_$(date +"%Y%m%d")_svn.tar.gz
tar -cpzvf ${new_file_name} --exclude=.svn  --exclude=.git --exclude=install_mysql.sh --exclude=mysql.yml --exclude=resource/install_cairo --exclude=resource/install_ceph_rpms --exclude=resource/install_more_rpms --exclude=resource/install_mysql_rpms --exclude=resource/install_rpms --exclude=resource/install_yum --exclude=resource/install_ceph --exclude=resource/install_tgt --exclude=resource/install_venv winstore-ansible/
echo "打完包后删除里面的tar包"
rm -f winstore-ansible/resource/install_rpms.tar.gz
rm -f winstore-ansible/resource/install_yum.tar.gz
rm -f winstore-ansible/resource/install_more_rpms.tar.gz
rm -f winstore-ansible/resource/install_venv.tar.gz
rm -f winstore-ansible/resource/install_ceph_rpms.tar.gz
rm -f winstore-ansible/resource/install_tgt.tar.gz
rm -f winstore-ansible/resource/install_cairo.tar.gz
echo "将升级后的包上传至samba服务器"
/bin/cp "${new_file_name}" /mnt/winhong_ceph/winstore3.6Beta/"${new_file_name}"
rm -f "${new_file_name}"

if [[ "$#" > 1 && "$2" == "mysql" ]]; then
    echo "开始打包mysql..."
    cd winstore-ansible/resource
    tar -zcvf install_mysql_rpms.tar.gz install_mysql_rpms
    cd ../..
    new_file_name=mysql_install_$(date +"%Y%m%d")_svn.tar.gz
    tar -cpzvf ${new_file_name}  winstore-ansible/install_mysql.sh winstore-ansible/mysql.yml winstore-ansible/group_vars winstore-ansible/install_ansible winstore-ansible/resource/install_mysql_rpms.tar.gz winstore-ansible/resource/shell/mysql.sh winstore-ansible/resource/shell/mysql_ha.sh
    echo "打完包后删除里面的tar包"
    rm -f winstore-ansible/resource/install_mysql_rpms.tar.gz
    echo "将升级后的包上传至samba服务器"
    mkdir mysql-ansible
    tar zxf "${new_file_name}" -C mysql-ansible --strip 1
    tar zcf "${new_file_name}" mysql-ansible
    rm -rf mysql-ansible
    /bin/cp "${new_file_name}" /mnt/winhong_ceph/winstore3.6Beta/"${new_file_name}"
    rm -f "${new_file_name}"
fi

echo "umount samba服务器"
umount /mnt/
echo "自动发布winstore完成..."


