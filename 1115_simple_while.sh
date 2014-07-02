#!/bin/bash
# while循环

var0=0
LIMIT=10
while [[ "$var0" -le "$LIMIT" ]]; do
    echo -n "$var0 "
    ((var0++))
done
echo
echo ---------------------------------

var0=0
while ((var0 <= LIMIT)); do
    echo -n "$var0 "
    ((var0++))
done
echo
exit 0
