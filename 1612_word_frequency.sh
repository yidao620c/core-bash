#!/bin/bash
# 统计单词的频率

ARGS=1
E_BADARGS=85
E_NOFILE=86

if [[ $# -ne "$ARGS" ]]; then
    echo "Usage: $(basename $0) filename"
    exit $E_BADARGS
fi

if [[ ! -f "$1" ]]; then
    echo "File \"$1\" does not exists."
    exit $E_NOFILE
fi


sed -e 's/\.//g' -e 's/\,//g' -e 's/ /\
/g' "$1" | tr 'A-Z' 'a-z' | sort | uniq -c | sort -nr

exit 0

