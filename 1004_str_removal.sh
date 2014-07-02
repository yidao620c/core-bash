#!/bin/bash
# 字符串删除
stringZ=abcABC123ABCabc
echo ${stringZ#a*C}  # 从前往后删除第一个最短匹配
echo ${stringZ##a*C} # 从前往后删除所有最短匹配

echo ------------------------------
echo ${stringZ%b*c}  # 从后往前删除第一个最长匹配
echo ${stringZ%%b*c} # 从后往前删除所有最长匹配
