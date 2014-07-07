#!/bin/bash
export DISPLAY=:0
export http_proxy=

HOME="/home/orchard"
SERVER_HOME="/home/orchard"
REMOTE_ADDR="orchard@10.0.0.191"
MANGO_ADDR="mango@10.0.0.175"

echo "starting updating..."
cd $HOME/work/mango-ng/
svn update
wait
echo "update finished mango-ng..."
echo "start to clear output dir..."
rm -rf $HOME/work/mango-ng/reports/*
rm -rf $HOME/work/mango-ng/test-output/perfect/*
echo "end clearing output..."
mvn clean test
wait
echo "test finished ..."

#ssh -T orchard@10.0.0.191 rm -f $REMOTE_ADDR:$SERVER_HOME/work/emailable-report.html
#folder_name=$(ls reports/ | tail -n 1)
#scp $HOME/work/mango-ng/reports/$folder_name/emailable-report.html $REMOTE_ADDR:$SERVER_HOME/work/
echo "start to update the nginx report files."
cd $HOME/work/mango-ng/test-output/perfect/
tar -jcvf $HOME/work/reports.tar.bz2 *
cd -
ssh -T $MANGO_ADDR rm -rf /data/html/reports/*
scp $HOME/work/reports.tar.bz2 $MANGO_ADDR:/data/html/reports/
ssh -T $MANGO_ADDR tar -jxvf /data/html/reports/reports.tar.bz2 -C /data/html/reports/ 
echo "report transfer finished"
#ssh -T orchard@10.0.0.191 $SERVER_HOME/work/mail_ng.sh
