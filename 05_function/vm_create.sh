#!/bin/bash
#create vm_name sr_name template
#xe vm-install new-name-label=centos6_template sr-uuid=fbeda99f-b5a7-3100-5e3d-fbb48a46fca0 template=Other\ install\ media

. counter.sh
. f.sh


vm_create() {
	vm_uuid=`xe vm-install new-name-label=autotest sr-uuid=$1 template-name=$template_name`
	if [ ! $vm_uuid ];then
		log "create vm:fail"
		let "vm_create=vm_create+1"
		replace_p "vm_create" "${vm_create}"
	else
		log "create vm:pass"
		let "vm_create_pass=vm_create_pass+1"
		let "vm_create=vm_create+1"
		replace_p "vm_create" "${vm_create}"
		replace_p "vm_create_pass" "${vm_create_pass}"
	fi
}

main()
{
	sr_uuid=$(echo random_sruuid)
	sr_size=`xe sr-param-get uuid=$sr_uuid param-name=physical-size`
	sr_used=`xe sr-param-get uuid=$sr_uuid param-name=physical-utilisation`
	sr_avail=$[($sr_size - $sr_used) / 1024 / 1024 / 1024]

	if [ $sr_avail -ge 24 ];then
		vm_create $sr_uuid
	fi
}

main