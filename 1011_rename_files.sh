#!/bin/bash
# 批量重命名文件名

E_BAD_ARGS=65

case $# in
    0|1)
    echo "Usage: $(basename $0) old_file_suffix new_file_suffix"
    exit $E_BAD_ARGS
    ;;
esac

for filename in *.$1; do
    mv $filename ${filename%$1}$2
done

exit 0
