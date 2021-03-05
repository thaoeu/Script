#!/usr/bin/env bash

killall keynav
if [ $? = 0 ];then
	echo "was kill"
else [ $? != 0 ]
	keynav &
fi
