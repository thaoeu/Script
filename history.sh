#!/usr/bin/env bash
Name=`uname -n`
Date=`date -d "-1 Day" +%Y%m%d`
history > $Name$Date.txt
#echo $Date
