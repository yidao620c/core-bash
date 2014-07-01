#!/bin/bash
# 随机数

MAX_COUNT=10
count=1

echo
echo "$MAX_COUNT 个随机数："
echo "---------------------"
while [[ "$count" -lt $MAX_COUNT ]]; do
    number=$RANDOM  # 这个事bash里面伪随机数
    echo $number
    ((count += 1))
done

echo "--------------------"
