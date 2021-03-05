#!/usr/bin/env bash

cd ~/Template/gcrl
hugo new post/$1.md
nvim ~/Template/gcrl/content/post/$1.md
