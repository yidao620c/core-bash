#!/bin/bash
# This is a mail program to send test report to someone

#echo "It is cool, hah~" | mutt -s "mango测试报表-$(date +%Y年%m月%d日)" \
#    xiongneng@gzhdi.com  -c guoly@gzhdi.com -a /home/orchard/work/report.html
echo "It is cool, hah~" | mutt -s "mango测试报表-$(date +%Y年%m月%d日)" \
    xiongneng@gzhdi.com  -a /home/orchard/work/report.html
