#!/bin/bash
# Program: shows the scipts name, parameters...
# @author: Xiong Neng
# @date: 2013/15/09
PATH=$PATH:~/bin
export PATH

#echo "PATH:${PATH}"
#if [ "$1" == "hello" ]; then
#	echo "Hello, how are you!!!"
#elif [ "$1" == "" ]; then
#	echo "you must input something, ex> {$0 param}"
#else 
#	echo "wrong param, you must input hello"
#fi
case ${1} in
	"hello")
		echo "hello, how are you..."
		;;
	"hi")
		echo "hi, how are you..."
		;;
	*)
		echo "unknow..."
		exit 1
		;;
esac
