echo "开始发布fastloan-consumer"
echo "先kill java进程..."
ps aux |grep java |grep -v "grep java" |while read line
do
    linewords=($line)
    pid="${linewords[1]}"
    sudo kill -9 $pid
done
echo "覆盖jar文件"
rm -f /home/winhong/work/fastloan-consumer.jar
mv /home/winhong/work/zips/fastloan-consumer.jar /home/winhong/work/
echo "重启consumer进程"
java -jar /home/winhong/work/fastloan-consumer.jar 1> /dev/null 2>&1 &

echo "完成发布fastloan-consumer"


