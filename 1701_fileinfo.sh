#!/bin/bash
# 显示文件的各种信息

case "$1" in
    "" ) echo "请输入文件名"; exit 1;;
esac

FILENAME="$1"
file_name=$(stat -c%n "$FILENAME")  # 文件名
file_owner=$(stat -c%U "$FILENAME") # 文件所有者
file_size=$(stat -c%s "$FILENAME")  # 文件大小
file_nodes=$(stat -c%i "$FILENAME") # inode
file_type=$(stat -c%F "$FILENAME")  # 文件类型
file_access_rights=$(stat -c%A "$FILENAME") # 文件访问权限

echo "文件名：        $file_name"
echo "文件所有者：    $file_owner"
echo "文件大小：      $file_size"
echo "文件inode：     $file_nodes"
echo "文件类型：      $file_type"
echo "文件访问权限：  $file_access_rights"
exit 0
