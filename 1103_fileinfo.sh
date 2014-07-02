#!/bin/bash
# 显示文件信息，for循环的使用

FILES="/usr/sbin/accept
/usr/sbin/pwck
/usr/sbin/chroot
/usr/bin/fackfile
/sbin/badblocks
/sbin/ypbing
"
echo

for file in $FILES; do
    if [[ ! -e "$file" ]]; then
        echo "$file does not exist."; echo
        continue
    fi

    ls -l $file |awk '{ print $8 "       file size: "$5""}'
    whatis $(basename $file)

    echo
done

colors="red yellow blue"
for c in $colors; do
    echo $c
done
exit 0

