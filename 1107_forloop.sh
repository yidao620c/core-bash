#!/bin/bash
# for 循环举例

NUMBERS="9 8 3 37.44"

for num in $NUMBERS; do
    echo -n "$num -> "
done

echo
exit 0
