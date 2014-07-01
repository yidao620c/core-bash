#!/bin/bash
# 从/etc/fstab中读取内容

File=/etc/fstab
{
read line1
read line2
} < $File

echo "First line in $File is: $line1"
echo "Second line in $File is: $line2"
exit 0
