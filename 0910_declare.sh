#!/bin/bash
# 演示declare的用法
# declare -r var1  只读变量
# declare -i var1  整型变量
# declare -a var1  数组变量
# declare -x var1=$var2  var1赋值并且export到环境变量中

func1() {
    echo "this is a function...."
}

declare -f  #显示以上定义的函数列表
echo

declare -i var1
var1=443
echo "var1 is $var1"
var1=var1+1
echo "var1 is $var1"
echo 

declare -r var2=234.55
#....
