#!/bin/bash
# shell变量的默认值
# 最常用的两个：
# var = ${str:-expr}, 如果str没有定义或者定义为空字符串，那么var的值就是expr，否则var的值就是str
# var = ${str:=expr}, 如果str没有定义或者定义为空字符串，那么var的值就是expr，否则var的值就是str
# 这个对于var的效果跟上面一样，但是对于str变量，上面那个不会有影响，但是这个会在str无定义或者定位为""的时候将str定义为expr

echo "\${str:-\"test\"} --> ${str:-'test'} and str=$str"
str=''
echo "\${str:-\"test\"} --> ${str:-'test'} and str=$str"
str='cool'
echo "\${str:-\"test\"} --> ${str:-'test'} and str=$str"

echo -------------------------------------------
unset str
echo "\${str:=\"test\"} --> ${str:='test'} and str=$str"
str=''
echo "\${str:=\"test\"} --> ${str:='test'} and str=$str"
str='cool'
echo "\${str:=\"test\"} --> ${str:='test'} and str=$str"
