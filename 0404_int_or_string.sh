#!/bin/bash
# bash变量是没有类型的
echo '----------------'
echo $*
a=1234
let "a += 1"
echo "a=$a"
echo 
b=${a/12/aa} #替换
echo "b=$b"
