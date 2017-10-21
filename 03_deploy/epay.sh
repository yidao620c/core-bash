#!/bin/bash
# 云彩付自动更新发布脚本
# 先clone相应的分支下来：
# git clone -b data ssh://git@120.24.173.142:7999/epay/clouds-epay-web.git clouds-epay-web-data
# 各个运行环境的配置yml文件分开了

function start {
    profile="$1"
    jarfile=$(ls target/*.jar)
    echo "启动环境profile=${profile}"
    stop $profile $jarfile
    branch=$(git branch |awk '{print $2}')
    git pull origin ${branch}
    echo "更新完代码开始重新打包"
    mvn clean && mvn clean && mvn package -DskipTests=true
    if [[ "$?" != "0" ]]; then
        echo "编译出错，退出！"
        exit 1
    fi
    echo "nohup java -jar -Dspring.profiles.active=${profile} ${jarfile} >/dev/null 2>&1 &"
    nohup java -jar -Dspring.profiles.active=${profile} ${jarfile} >/dev/null 2>&1 &
    echo "启动应用中，请查看日志文件..."
    exit 0
}

function stop {
    profile="$1"
    jarfile="$2"
    ps aux | grep "${jarfile}" | grep "spring.profiles.active=${profile}" | grep -v grep > /dev/null
    if [[ "$?" == "0" ]]; then
        echo "该应用还在跑，我先停了它"
        pid=$(ps aux | grep "${jarfile}" | grep "spring.profiles.active=${profile}" | grep -v grep |awk '{print $2}')
        if [[ "$pid" != "" ]]; then
            kill -9 $pid
        fi
        echo "停止应用成功..."
    fi
}

if [[ "$1" == "start" ]]; then
    if [[ "$#" < 2 ]]; then
        echo "请输入正确参数：./epay.sh start {profile}"
        exit 1
    fi
    start $2
elif [[ "$1" == "stop" ]]; then
    if [[ "$#" < 2 ]]; then
        echo "请输入正确参数：./epay.sh stop  {profile}"
        exit 1
    fi
    jarfile=$(ls target/*.jar)
    stop $2 $jarfile
else
    echo "参数错误，使用方法：{}参数是必填的，[]参数可选"
    echo "./epay.sh start {profile}    # 启动应用，{profile}运行环境"
    echo "./epay.sh stop  {profile}    # 停止应用，{profile}运行环境"
    exit 1
fi
