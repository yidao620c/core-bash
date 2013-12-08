#!/bin/bash
# 统计一个文件中每个单词出现的次数

ARGS=1        #输入参数个数为1,就是一个文件名
E_BADARGS=55  #输入参数错误码
E_NOFILE=56   #输入文件不存在

# 参数个数不为1，返回错误码E_BADARGS
if [ $# -ne "$ARGS" ];then
	echo "Usage: 'basename $0' filename"
	exit $E_BADARGS
fi

# 输入的文件名不存在，返回错误码E_NOFILE
if [ ! -f "$1" ];then
	echo "File \"$1\" does not exists."
	exit $E_NOFILE
fi

# 以下是核心算法
# sed命令用于过滤句号、逗号、分号，当然可以继续加上需要过滤的符号
# sed命令第4个-e选项将单词间的空格转化为换行符
# sort对sed过滤结果排序，每行一个单词
# uniq -c输出重复行的次数，sort -nr 按照出现频率从大到小排序
sed -e 's/[\.\,\:\;\!]/ /g' -e 's/\s\+/ /g' -e 's/\s\+$//g' -e 's/ /\n/g' "$1" | sort | uniq -c | sort -nr

exit 0

