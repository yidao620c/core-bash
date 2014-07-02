#!/bin/bash
# c style for loop

LIMIT=10
for ((a=1; a<=LIMIT; a++)); do
    echo -n "$a "
done
echo; echo
for ((a=1, b=1; a<=LIMIT; a++, b++)); do
    echo -n "$a->$b "
done
echo; echo
exit 0
