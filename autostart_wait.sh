#!/usr/bin/env bash

sleep 2

fcitx &
x0vncserver -display :0 -passwordfile ~/.vnc/passwd &
