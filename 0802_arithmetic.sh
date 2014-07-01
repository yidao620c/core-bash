#!/bin/bash
# 数学运算, 各种括号的使用

n=1; echo -n "$n "

let "n = $n + 1"
echo -n "$n "
: $((n = $n + 1)) # 注意，前面那个:是必须要的
echo -n "$n "
(( n = n + 1 ))  # 两边留空格，简化上面的
echo -n "$n "

n=$(($n + 1))
echo -n "$n "

: $[ n = $n + 1 ]
echo -n "$n "

# 接下来演示C-style的增量写法
let "n++"
echo -n "$n "

(( n++ ))
echo -n "$n "

: $(( n++ ))
echo -n "$n "

: $[ n++ ]
echo -n "$n"

echo

exit 0
