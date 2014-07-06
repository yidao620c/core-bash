#!/bin/bash
# 利用set重新设置脚本参数

variable="one two three four five"

set -- $variable
firstp=$1
secondp=$2
shift;shift
remainingp="$*"
echo
echo "first is $firstp"
echo "second is $secondp"
echo "remaining are $remainingp"
echo; echo

set -- $variable
echo "fist param is $1"

# unset
set --
echo "first param is $1"

exit 0

