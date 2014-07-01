#!/bin/bash
# 随机抽取扑克牌

Suites="
Clubs
Diamonds
Hearts
Spades
"

Denominations="
2
3
4
5
6
7
8
9
10
Jack
Queen
King
Ace
"

suite=($Suites)  #把字符串转换成array
denomination=($Denominations)

num_suites=${#suite[*]}
num_denominations=${#denomination[*]}

echo -n "${denomination[$((RANDOM % num_denominations))]} of "
echo ${suite[$((RANDOM % num_suites))]}

exit 0
