#!/bin/bash
# 将一段文字，每段最后加一行空行输出显示
# usage: $0 <FILENAME

MINLINE=60

while read line # For as many lines as the input file has ...
do
    echo "$line"
    len=${#line}
    if [[ "$len" -lt "$MINLINE" && "$line" =~ [*{\.}?\"!]$ ]]; then
        echo
    fi
done

exit 0
