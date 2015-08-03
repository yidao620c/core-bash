echo "开始发布fastloan-producer"
echo "先kill tomcat进程..."
ps aux |grep tomcat |grep -v "grep tomcat" |while read line
do
    linewords=($line)
    pid="${linewords[1]}"
    sudo kill -9 $pid
done
echo "解压覆盖文件"
unzip -o /home/winhong/work/zips/fastloan-producer.war -d /home/winhong/lib/apache-tomcat-8.0.24/webapps/ROOT/
echo "修改配置文件"
jdbc_config='/home/winhong/lib/apache-tomcat-8.0.24/webapps/ROOT/WEB-INF/classes/jdbc.properties'
sed -i "/^jdbc.url=/ c jdbc.url=jdbc:mysql://192.168.200.33:3306/fastloan3?useUnicode=true&characterEncoding=utf8" $jdbc_config
log4j_config='/home/winhong/lib/apache-tomcat-8.0.24/webapps/ROOT/WEB-INF/classes/log4j.properties'
sed -i "/^log4j.appender.toFile.file=/ c log4j.appender.toFile.file=/var/log/fastloan/fastloan-producer.log" $log4j_config
sed -i "/log4j.threshold/ c log4j.threshold=INFO" $log4j_config
common_config='/home/winhong/lib/apache-tomcat-8.0.24/webapps/ROOT/WEB-INF/classes/config.properties'
sed -i "/^jms.broker.url=/ c tcp://192.168.200.33:61616" $common_config
sed -i "/^jms.queue.name=/ c jms.queue.name=DATA.INVOICE" $common_config
sed -i "/^upload.path=/ c upload.path=/var/data/files/" $common_config
sed -i "/^download_dir=/ c download_dir=/var/data/" $common_config
echo "重启tomcat服务器"
/home/winhong/lib/apache-tomcat-8.0.24/bin/catalina.sh start 1> /dev/null 2>&1 

echo "完成发布fastloan-producer"


exit 0
