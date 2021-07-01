#!/usr/bin/env bash

read -p "输入链接：" link
header=`curl -I $link`
echo $header
if [[ $header =~ 'HTTP/1.1 200 OK' ]]; then
	echo 'ok'
else
	echo 'no'
fi
