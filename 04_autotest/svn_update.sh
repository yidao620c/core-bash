#!/bin/bash

SERVER_HOME="/home/orchard"
REMOTE_ADDR="orchard@10.0.0.173"

echo "starting to auto publish mango system..."
cd ~/work/mango/
echo "update mango..."
svn update
wait
echo "package mango..."
play clean
wait
rm -rf dist/*
play dist
wait
echo "finished package. then transfer zip to server"

ssh -T orchard@10.0.0.173 rm -rf $SERVER_HOME/download/mango/*
ssh -T orchard@10.0.0.173 rm -rf $SERVER_HOME/download/mango/*
scp dist/mango-1.5.zip $REMOTE_ADDR:$SERVER_HOME/download/mango/
wait
echo "transfer finished."
ssh -T orchard@10.0.0.173 sudo /etc/init.d/mango15 stop
wait
echo "mango stopped"
ssh -T orchard@10.0.0.173 unzip $SERVER_HOME/download/mango/*.zip -d $SERVER_HOME/download/mango 
wait
ssh -T orchard@10.0.0.173 rm -rf $SERVER_HOME/mango-1.5/lib
wait
ssh -T orchard@10.0.0.173 cp -r $SERVER_HOME/download/mango/mango-1.5/lib $SERVER_HOME/mango-1.5
echo "copy lib finished.."
wait
ssh -T orchard@10.0.0.173 sudo /etc/init.d/mango15 start
wait
echo "mango published successfully..."

