#!/bin/bash

cpa=counter.txt
log_file=tmp/log.log
couter_file=test/counter.txt
sr_dir=sr

getv() {
	vm_create=$(sed -n 's/vm_create=\(.*$\)/\1/p' $cpa)
	vm_create_pass=$(sed -n 's/vm_create_pass=\(.*$\)/\1/p' $cpa)
	declare -a ar
	ar="$vm_create $vm_create_pass"
	echo $ar
}

getv_bykey() {
	r=$(sed -n "s/$1=\(.*$\)/\1/p" $cpa)
	return "$r"
}

log() {
	time_now=$(date "+%Y-%m-%d %H:%M:%S")
	echo "${time_now} $1" >> $log_file
}

replace_p() {
	sed -i "/$1=/{s/$1=.*\$/$1=$2/}" $couter_file
}

random_sruuid {
	# 存储池文件夹
	declare -a srfiles
	srfiles=($(ls $sr_dir))
	rand_str="${srfiles[$[ RANDOM % ${#srfiles[@]} ]]}"
	echo $rand_sr
}

random_vmuuid {
	rand_sr=${echo random_sruuid}
	uuid_file="${sr_dir}/${rand_sr}"
	echo $(file_to_array $uuid_file)
}

file_to_array {
	declare -a b
	b=($(cat "$1"))
	echo ${b[@]}
}

# log "lldasfasdfasdf"
# replace_p vm_reate 33

#declare -a a
#b=`getv`
#a=($b)
#echo ${a[0]}
#echo ${a[1]}
#b=`getv_bykey vm_create`
#echo $b