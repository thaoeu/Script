#!/usr/bin/env bash

pactl set-sink-volume @DEFAULT_SINK@ +1%
bash ~/Script/WM/dwm-bar.sh
