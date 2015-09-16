#!/bin/bash
# 清除生产的数据

today=`date +%Y%m%d`
echo "先备份几个数据表"
mysqldump -uroot -pmysql fastloan3 t_apply t_hasten t_policy t_product_card t_appointment t_personal_asset t_company_mortgage t_company_debt t_apply_record > /home/winhong/work/dump${today}.sql
echo "开始删除多余数据..."
mysql -uroot -pmysql fastloan3 < /home/winhong/work/clear_db.sql
echo "数据清理成功..."
exit 0

