#!/bin/bash
# if条件句中直接用grep判断

VAR="adfatxtfd"
if echo "$VAR" | grep -q txt; then
    echo "$VAR contains substring \"txt\""
else
    echo "$VAR doesn't contain substring ..."
fi

VAR="adfatytfd"
if echo "$VAR" | grep -q txt; then
    echo "$VAR contains substring \"txt\""
else
    echo "$VAR doesn't contain substring ..."
fi


