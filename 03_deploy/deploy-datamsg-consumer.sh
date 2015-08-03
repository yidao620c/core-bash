echo "开始发布fastloan-datamsg-consumer"
ps aux |grep "com.winhong.fastloan.datamsg" |grep -v "grep com.winhong.fastloan.datamsg" |while read line
do
    linewords=($line)
    pid="${linewords[1]}"
    sudo kill -9 $pid
done

echo "覆盖jar文件"
rm -f /home/winhong/work/fastloan-datamsg-consumer.jar
mv /home/winhong/work/zips/fastloan-datamsg-consumer.jar /home/winhong/work/
echo "重启datamsg-datamsg-consumer进程"
java -jar /home/winhong/work/fastloan-datamsg-consumer.jar 1> /dev/null 2>&1 &

echo "完成发布fastloan-datamsg-consumer"


