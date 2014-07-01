#!/bin/bash
# 检查脚本的参数个数

E_WRONG_ARGS=85
script_params="-a -h -m -z"  # -a=all, -h=help, etc

if [ $# -ne 3 ]
then
    echo "usage: `basename $0` $script_params"
    exit $E_WRONG_ARGS
fi

