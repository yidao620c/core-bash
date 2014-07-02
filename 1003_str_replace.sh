#!/bin/bash
# 字符串的替换

stringZ=abcABC123ABCabc

echo ${stringZ/abc/xyz}  # 替换第一次出现的abc
echo ${stringZ//abc/xyz} # 替换所有出现的abc

echo ${stringZ/#abc/xyz} # 从前往后替换第一次出现的abc
echo ${stringZ/%abc/xyz} # 从后往前替换第一次出现的abc

echo ------------------------
echo "$stringZ"
echo -------------------------

match=abc
replacement=000
echo ${stringZ/$match/$replacement}
echo ${stringZ//$match/$replacement}
# Yes!  参数化替换

echo

# 如果没有replacement字符串，那么执行删除操作
echo  ${stringZ/abc}
echo ${stringZ//abc}
