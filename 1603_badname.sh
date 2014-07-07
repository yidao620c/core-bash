#!/bin/bash
# 删除目录下面文件名很奇怪的文件

for filename in *
do
	badname=$(echo "$filename" | sed -n '/[+{;"\=?~()<>&*|$]/p')
	rm $badname 2>/dev/null
done

# 删除含有空格的文件
find . -name "* *" -exec rm -f {} \;

exit 0

# 还有一种方法
# -maxdepth 0 表示find搜索层级只在当前目录下面
find . -name '*[+{;"\\=?~()<>&*|$ ]*' -maxdepth 0 -exec rm -f '{}' \;

