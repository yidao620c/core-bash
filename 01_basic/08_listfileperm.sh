#!/bin/bash
#列出某个目录中所有文件列表的权限

# 先看这个目录是否存在
read -p "请输入一个目录：" dir
if [ "$dir" == "" -o ! -d "$dir" ]; then
	echo "文件夹$dir并不存在，返回"
	exit 1
fi

# 开始测试文件。
filelist=$(ls $dir)
for filename in $filelist
do
	perm=""
	test -r "$dir/$filename" && perm="$perm readable"
	test -w "$dir/$filename" && perm="$perm writable"
	test -x "$dir/$filename" && perm="$perm executable"
	echo "The file $dir/$filename's permission is $perm"
done

echo "end loop..."

