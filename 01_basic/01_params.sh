#!/bin/bash
# Program: shows the scipts name, parameters...
# @author: Xiong Neng
# @date: 2013/15/09
PATH=$PATH:~/bin
export PATH

echo "PATH:${PATH}"

echo "The script name is ${0}"
echo "Total parameters is $#"
[ "$#" -lt 2 ] && echo "too less params" && exit 0
echo "Your params are '$@'"
echo "The 1st parameter is $1"
echo "the 2nc parameter is $2"

