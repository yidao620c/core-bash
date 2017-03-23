#!/bin/bash
# disk partion
# usage: ./disk_partion.sh sdb 3 10

if [[ "$#" < 3 ]]; then
    echo "usage: $0 disk total_num part_size(GB)"
    exit 1
fi

divice_name="$1"
disk="/dev/$1"   # 设备名如/dev/sdb
total_num="$2"   # 新增分区数量如 2
part_size="$3"   # 每个分区大小(GB)
parted $disk print | grep "Partition Table: gpt" 1>/dev/null
if [[ "$?" != "0" ]]; then
    # 转换成gpt先
    parted $disk mklabel gpt
fi
# sector size (bytes)
sector_size=$(sgdisk -p $disk | grep "Logical sector size" | awk '{print $4}')
# 已经分区数量
pnum=$(sgdisk -p $disk | grep -A1 "Start (sector)" |wc -l)
# 新分区号
nextp=1
# 新分区start扇区号
start=0
# 记录新创建的分区
declare -a new_parts
# randstr=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
# tmpfile="/tmp/${divice_name}_${randstr}"
if [[ "$pnum" -le "1" ]]; then
    # echo "这是一个全新的盘..."
    start=$(sgdisk -p $disk | grep "First usable sector is" | awk -F, '{print $1}' | awk '{print $NF}')
else
    # echo "这个盘已经有分区了，在后面继续分区..."
    for e in $(sgdisk -p $disk | sed -n '/Start (sector)/,$p' | sed -n '2,$p' | awk '{print $3}')
    do
        if [[ "$start" -lt "$e" ]]; then
            start="$e"
        fi
    done

    (( start++ ))

    for e in $(sgdisk -p $disk | sed -n '/Start (sector)/,$p' | sed -n '2,$p' | awk '{print $1}')
    do
        if [[ "$nextp" -lt "$e" ]]; then
            nextp="$e"
        fi
    done
    (( nextp++ ))
fi
# 需要的扇区个数
(( sector_num = part_size*1024*1024*1024/sector_size ))
(( end = start + sector_num - 1 ))

# 开始连续分区
for (( i = 0; i < total_num; i++ )); do
    # echo "开始划分第$((i+1))个分区"
    j_name="ceph journal ${divice_name} ${nextp}"
    sgdisk -n ${nextp}:${start}:${end} -t ${nextp}:45b0969e-9b03-4f30-b4c6-b4b80ceff106 -p $disk 1>/dev/null
    sgdisk -c ${nextp}:"${j_name}" $disk 1>/dev/null
    # 分区名写入tmpfile
    each_partname=$(blkid | grep "PARTLABEL=\"${j_name}\"" | awk '{print $1}' | awk '{print substr($0, 1, length($0)-1)}')
    new_parts["$i"]="${each_partname}"
    (( nextp++ ))
    (( start = end + 1 ))
    (( end = start + sector_num - 1 ))
done
echo "${new_parts[@]}"

