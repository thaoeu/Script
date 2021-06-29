#!/usr/bin/env bash

if [ ! -n "$1" ]; then
	echo "请输入要连接的主机，格式：'user@ip'"
else
scp ~/.ssh/id_rsa.pub $1:~/.ssh/authorized_keys
fi
