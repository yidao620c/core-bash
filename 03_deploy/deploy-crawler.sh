echo "开始发布fastloan-crawler"
echo "kill 爬虫进程..."
ps aux |grep "org.crm" |grep -v "grep org.crm" |while read line
do
    linewords=($line)
    pid="${linewords[1]}"
    sudo kill -9 $pid
done

ps aux |grep "org.gztax" |grep -v "grep org.gztax" |while read line
   do
   linewords=($line)
   pid="${linewords[1]}"
   sudo kill -9 $pid
done

echo "覆盖jar文件"
rm -f /home/winhong/work/fastloan-crawler.jar
mv /home/winhong/work/zips/fastloan-crawler.jar /home/winhong/work/
echo "重启crawler进程"
java -jar /home/winhong/work/fastloan-crawler.jar 1> /dev/null 2>&1 &

echo "完成发布fastloan-crawler"

exit 0
