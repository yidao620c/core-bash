#!/bin/bash
export DISPLAY=:0
export http_proxy=

HOME="/home/orchard"
SERVER_HOME="/home/orchard"
REMOTE_ADDR="orchard@10.0.0.191"

echo "starting updating..."
cd $HOME/work/mango-ng/
svn update
wait
echo "update finished mango-ng..."
mvn clean test
wait
echo "test finished ..."

ssh -T orchard@10.0.0.191 rm -f $REMOTE_ADDR:$SERVER_HOME/work/power-emailable-report.html
folder_name=$(ls reports/ | tail -n 1)
scp $HOME/work/mango-ng/reports/$folder_name/power-emailable-report.html $REMOTE_ADDR:$SERVER_HOME/work/
wait
echo "report transfer finished"
ssh -T orchard@10.0.0.191 $SERVER_HOME/work/mail_ng.sh
