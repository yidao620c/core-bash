#!/bin/bash
# 根据名字kill掉进程，运行这个特别小心

E_BADARGS=66

if [[ -z "$1" ]]; then
    echo "Usage: $(basename $0) process_to_kill"
    exit $E_BADARGS
fi

PROCESS_NAME="$1"
ps ax |grep "$PROCESS_NAME" | awk '{print $1}' | xargs -i kill {} #2&>/dev/null

exit $?
