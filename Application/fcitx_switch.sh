#!/usr/bin/env bash

killall fcitx
if [ $? = 0 ];then
	echo "W kill"
else [ $? != 0 ]
	fcitx &
fi
