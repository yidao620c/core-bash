#!/bin/bash
# Program: shows the scipts name, parameters...
# @author: Xiong Neng
# @date: 2013/15/09
PATH=$PATH:~/bin
export PATH

#echo "PATH:${PATH}"

read -p "please input Y/N:" yn
if [ "${yn}" == "Y" ] || [ "$yn" == "y" ]; then
	echo "OK, continue"
elif [ "$yn" == "N" ] || [ "$yn" == "n" ]; then
	echo "Oh, interrupt"
else 
	echo "I don't know what ..."
fi
exit 0
