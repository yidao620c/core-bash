#!/bin/bash
export DISPLAY=:0

HOME="/home/mango"

echo "starting auto run test..."
cd $HOME/work/rubyselenium/
svn update
wait
echo "update finished mango..."

rspec testcase -fh > report.html
wait
echo "test finished ..."

tod=$(date +%Y%m%d_%H%M%S)
cp $HOME/work/rubyselenium/report.html $HOME/work/reports/report_$tod.html
