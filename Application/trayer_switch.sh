#!/usr/bin/env bash

killall trayer
if [ $? = 0 ];then
	echo "W kill"
else [ $? != 0 ]
	trayer --transparent flase --expand false --align center --width 60 --height 60 --SetDockType false --tint 0x00 &
fi
