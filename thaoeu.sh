#!/usr/bin/env bash

mkdir ~/Picture/posts/$1
cd ~/Template/thaoeu
hugo new posts/$1.md
nvim ~/Template/thaoeu/content/posts/$1.md
