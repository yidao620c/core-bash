#!/bin/bash
# config osd journal partition
# author: Xiong Neng

echo "最开始要设置OSD状态为noout"
ceph osd set noout

all_osd=($(lsblk |grep "/var/lib/ceph/osd/ceph-" | awk '{print $NF}' | awk -F/ '{print $NF}' | awk -F- '{print $NF}'))

for i in "${all_osd[@]}"; do
	echo "停止需要替换journal的osd"
    /etc/init.d/ceph stop osd."$i"
    echo "下刷journal到osd，使用-i指定需要替换journal的osd的编号"
    ceph-osd -i "$i" --flush-journal
    echo "删除原来的journal"
    rm -rf /var/lib/ceph/osd/ceph-"$i"/journal

    echo "找到这个osd对应的日志分区"
    dev_name=$(lsblk |grep -A1 "/var/lib/ceph/osd/ceph-$i" |sed -n 2p | awk '{print substr($1,3)}')
    partuuid=$(ls -l /dev/disk/by-partuuid/ | grep "/${dev_name}" | awk '{print $9}')

    echo "将这个磁盘的分区链接到原始路径"
    ln -s /dev/disk/by-partuuid/${partuuid} /var/lib/ceph/osd/ceph-"$i"/journal
    echo "${partuuid}" > /var/lib/ceph/osd/ceph-"$i"/journal_uuid
    echo "创建journal"
    ceph-osd -i "$i" --mkjournal
    echo "重启osd"
    /etc/init.d/ceph restart osd."$i"

done

echo "去除noout的标记"
ceph osd unset noout
