#!/bin/bash
# 生成一个8位的随机字符串

#if [[ -n "$1" ]]; then
#    str0="$1" # 第一个参数
#else
#    str0="$$" # 否则使用当前脚本PID
#fi

POS=2  # 从第二个位置开始
LEN=8  # 截取8个字符

# md5摘要算法
str1=$( echo "$RANDOM" | md5sum | md5sum  )

randstring="${str1:$POS:$LEN}"

echo "$randstring"

exit $?  # 前面运行命令返回码退出
