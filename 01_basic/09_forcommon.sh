#!/bin/bash
# 普通的for循环，用户输入的数值N，计算1+2+...+N

read -p "Please input a number MAX, I will summate 1+2+...+MAX: " max
while [ "$max" -lt 0 ]
do
	echo "You must input a positive number!"
	read -p "Now input again: " max
done
total=0
for ((i=1; i <= $max; i++))
do
	total=$(($total + $i))
done
echo "the total is $total"
