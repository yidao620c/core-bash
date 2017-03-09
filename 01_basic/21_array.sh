#!/bin/bash
# Program:
# multiple lines to array
# one line to array
# @author: Xiong Neng
# @date: 2017/03/09

# 命令返回的多行变成数组，一行一个数组项
N=0
lsblk |grep -E ".*disk" | while read line
do
    a[$N]="$line"
    echo "$N = $line"     #to confirm the entry
    let "N= $N + 1"
done
echo "${a[0]}"
echo "${a[1]}"

# 单行返回变成数组，空格隔开

b=($(ls))
echo "${b[0]}"
echo "${b[1]}"
