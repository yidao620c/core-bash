#!/bin/bash
# select 显示选择菜单
PS3='Choose your favorite vegetable: '
echo 
select vegetable in "beans" "carrots" "potatoes" "onions" "rutabbgas"; do
    echo
    echo "Your favorite veggle is $vegetable."
    echo "You .."
    echo
    break
done

exit 0
