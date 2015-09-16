#!/bin/bash
#自动清理生产数据脚本
#每天凌晨清除测试数据
#vim /etc/crontab
#55 03 * * *  winhong /home/winhong/work/clear_db.sh 1>/dev/null 2>&1
cat /home/winhong/work/clear_db1.sh | ssh winhong@192.168.200.33 -tt

