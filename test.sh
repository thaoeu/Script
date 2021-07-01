#!/usr/bin/env bash

Dir=$1
echo $Dir

for Name in `find ${Dir} -type f -size +0 -name "*.mp3"`; do

#	echo $Name
StartTimeY=`echo ${Name} | cut -c 6-9`;
StartTimeM=`echo $Name | cut -c 10-11`;
StartTimeD=`echo $Name | cut -c 12-13`;
StartTime=`echo $StartTimeY-$StartTimeM-$StartTimeD`
FileId=`echo ${Name} | cut -c 6-30`;
FileName=`echo $Name | cut -c 6-`;
#	echo $FileId
#	echo $StartTime
#echo ${Url}

Url='http://121.229.54.24:19089/callrecord/add?uid=lkxiaoshan&startTime='$StartTime'%2010:00:00&endTime='$StartTime'%2010:00:01&callId='$FileId'&peerNumber=12345678910&corpId=bluemine&fileName='$FileName'&channel=2&strero=2'
curl -s ${Url}
#	echo $FileName
done
