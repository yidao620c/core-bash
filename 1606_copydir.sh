#!/bin/bash
# 演示xargs用法

E_NOARGS=85

if [[ -z "$1" ]]; then
	echo "Usage: $(basename $0) directory-to-copy-to."
	exit $E_NOARGS
fi

# -i表示后面的{}代表前面每个xargs参数
# 比如重命名当前目录所有文件
# ls | xargs -t -i mv {} {}.bak
ls . | xargs -i -t cp ./{} $1

exit 0

