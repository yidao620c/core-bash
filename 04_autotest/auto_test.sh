#!/bin/bash
export DISPLAY=:0

HOME="/home/mango"

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
