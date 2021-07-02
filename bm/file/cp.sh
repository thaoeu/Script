#!/usr/bin/env bash

for line in $(cat $1)
do
	cp $line ../uml
# echo $line
done

