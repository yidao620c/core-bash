#!/bin/bash
#ping 网络192.168.1.1 ~ 192.168.1.100

network="192.168.0"
for sitenu in $(seq 1 100)
do
	ping -c 1 -w 1 ${network}.${sitenu} &>/dev/null && result=0 || result=1
	if [ "$result" == 0 ]; then
		echo "Server ${network}.${sitenu} is UP"
	fi
done
