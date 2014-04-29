#!/bin/bash
export DISPLAY=:0

HOME="/home/mango"
SERVER_HOME="/home/orchard"
REMOTE_ADDR="orchard@10.0.0.191"

echo "starting auto run test..."
rm -f $HOME/work/rubyselenium/config/config.yml
cd $HOME/work/rubyselenium/
svn update
wait
echo "update finished mango..."
cp -f $HOME/work/rubyselenium/config/config_cool.yml $HOME/work/rubyselenium/config/config.yml
rspec testcase -fh > report.html
wait
echo "test finished ..."

tod=$(date +%Y%m%d)
cp -f $HOME/work/rubyselenium/report.html $HOME/work/reports/report_$tod.html
ssh -T orchard@10.0.0.191 rm -f $REMOTE_ADDR:$SERVER_HOME/work/report.html
scp $HOME/work/rubyselenium/report.html $REMOTE_ADDR:$SERVER_HOME/work/
wait
echo "report transfer finished"
ssh -T orchard@10.0.0.191 $SERVER_HOME/work/mail.sh
