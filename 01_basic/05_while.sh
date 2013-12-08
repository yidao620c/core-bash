#!/bin/bash
# while loop demo
# sum the 1+2+3+4....+100
s=0
i=0
while [ "${i}" != "100" ]
do
	i=$((${i} + 1)) #每次i都加1
	s=$(($s + $i))  #每次累加一次i
done
echo "the result of '1+2+3+4+...+100' is $s"
