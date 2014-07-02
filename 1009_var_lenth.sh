#!/bin/bash
# 各种变量长度

E_NO_ARGS=65

if [[ $# -eq 0 ]]; then
    echo "please invoke script with params.."
    exit $E_NO_ARGS
fi

var01=abcdEFGH28ij
echo "var01 = ${var01}"
echo "Length of var01 = ${#var01}"

var02="abcd EFGH28ij"
echo "Length of var02 = ${#var02}"

echo "number of commond-line arguments passed to scripts = ${#@}"

exit 0
