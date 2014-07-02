#!/bin/bash
# 列出目录下的符号链接文件

directory=${a-$(pwd)}

echo "symbolic links in directory \"$directory\""

for file in "$(find $directory -type l)"; do
    echo "$file"
done | sort

exit 0
