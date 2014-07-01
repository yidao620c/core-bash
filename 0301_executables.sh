#!/bin/bash
# 在某个目录下面查找可执行文件列表
# ,可以连接字符串

for file in /{,/usr/}bin/*calc
do
    if [ -x "$file" ]
    then
        echo $file
    fi
done
