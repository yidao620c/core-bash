#!/bin/bash
# 列出系统上面所有用户

PASSWD_FILE=/etc/passwd
n=1

for name in $(awk 'BEGIN{FS=":"}{print $1}' $PASSWD_FILE); do
    echo "USER #$n = $name"
    let "n += 1"
done

exit $?
