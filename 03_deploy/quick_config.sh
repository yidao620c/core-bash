#!/bin/bash
# author：   Xiong Neng
# email ：   yidao620@gmail.com
# date  ：     2013/07/01

deleteSvn() {
        for file in $*
        do
                echo "filename:$file"
                if [ $file = ".svn" ]; then
                        rm -rf $file
                elif [ -d $file ] && [ $file != "." ] && [ $file != ".." ]; then
                        pushd "$PWD" 1>/dev/null
                        cd $file
                        deleteSvn $(ls -a)
                        popd 1>/dev/null
                fi
        done
}        
          
if [ "$#" -ne 1 ]; then
        echo "param error"
        exit 1
fi           

if [ -z "$1" ];then 
    echo "目标目录是空字符串"
    exit 1
fi  

echo "------------------------------"
echo "发布配置的目录为：$1"
cd "$1"
echo "now I'm in the dir: $1, now it likes: $(ls)---------"
rm -rf *
echo "after rf , $1 likes: $(ls)-----------"
mv /root/config.jar .
echo "after i mv config.jar, it likes: $(ls) -----------"
jar -xvf config.jar
if [ "$?" != "0" ]; then
    echo "木有找到jar命令，我自己去找"
    $(grep "JAVA_HOME=" /etc/init.d/resin | cut -d "=" -f2)/bin/jar -xvf config.jar
fi
wait
echo "after jar config.jar, it likes: $(ls)--------------"
rm -f config.jar
echo "after rm the config.jar, it likes: $(ls)-----------"

cd ~
chown -R www:www "$1"

#delete .svn dir
deleteSvn "$1"
echo "after deleteSvn , it likes : $(ls)"
echo "success...."
exit 0