#!/usr/bin/env bash

sudo su<<EOF
	echo $1 > /sys/class/backlight/intel_backlight/brightness
EOF
