#!/bin/bash
# 演示浮点运算，借助bc程序

VAR=$(bc <<< "scale=2;34.29/12.1")
echo "$VAR"
