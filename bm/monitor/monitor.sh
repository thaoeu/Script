#!/usr/bin/env bash

if [ ! -n "$1" ]; then
	echo "请输入要查询的客户id"
else

# 获取符合条件的结果数
c=`ps -ef | grep $1 | grep -v "grep" | wc -l`
if [ $c -le 7 ]; then
	echo 服务未完全运行
else
	echo 服务完全运行
fi

SolrStatus=`ps -ef  | grep $1 | grep solr | grep -v "grep" | wc -l`
if [ $SolrStatus -eq 0 ]; then
	echo -e 'Solr \t\t 未运行'
else
	echo -e 'Solr \t\t 正常运行'
	echo -e 'Solr端口: '`ps -ef  | grep $1 | grep solr | grep -v "grep" | grep -o '\<port=[0-9][0-9][0-9][0-9]' | cut -c 6-10 | uniq -d`
	SolrPort=`ps -ef  | grep $1 | grep solr | grep -v "grep" | grep -o '\<port=[0-9][0-9][0-9][0-9]' | cut -c 6-10 | uniq -d`
fi
TomcatStatus=`ps -ef  | grep $1 | grep tomcat | grep -v "grep" | wc -l`
if [ $TomcatStatus -eq 0 ]; then
	echo -e 'tomcat \t\t 未运行'
else
	echo -e 'tomcat \t\t 正常运行'
	echo -e 'tomcat端口: '80`ps -ef | grep $1 | grep tomcat | grep -v "grep" | grep -o worker[0-9][0-9] | uniq -d | cut -c 7-8`
fi

LoopStatus=`ps -ef  | grep $1 | grep -v "grep" | grep loopCorpFrame | wc -l`
if [ $LoopStatus -eq 0 ]; then
	echo -e 'loopCorpFrame \t 未运行'
else
	echo -e 'loopCorpFrame \t 正常运行'
fi

LoopStatus=`ps -ef  | grep $1 | grep -v "grep" | grep loopDown | wc -l`
if [ $LoopStatus -eq 0 ]; then
	echo -e 'loopDown \t 未运行'
else
	echo -e 'loopDown \t 正常运行'
fi

LoopStatus=`ps -ef  | grep $1 | grep -v "grep" | grep loopAsr | wc -l`
if [ $LoopStatus -eq 0 ]; then
	echo -e 'loopAsr \t 未运行'
else
	echo -e 'loopAsr \t 正常运行'
fi

LoopStatus=`ps -ef  | grep $1 | grep -v "grep" | grep loopMsg | wc -l`
if [ $LoopStatus -eq 0 ]; then
	echo -e 'loopMsg \t 未运行'
else
	echo -e 'loopMsg \t 正常运行'
fi

LoopStatus=`ps -ef  | grep $1 | grep -v "grep" | grep loopMvc | wc -l`
if [ $LoopStatus -eq 0 ]; then
	echo -e 'loopMvc \t 未运行'
else
	echo -e 'loopMvc \t 正常运行'
fi


	# 获取json返回值。
	curl -s http://127.0.0.1:$((SolrPort))/solr/wechat_basic_msg/select?q=*%3A* > json 

	curl -s 'http://127.0.0.1:'$((SolrPort))'/solr/wechat_basic_msg/select?fq=StartTime%3A%5B2021-06-27T00%3A00%3A00.000Z%20TO%202021-06-27T23%3A59%3A59.999Z%5D&fq=speaker_type%3A2&q=*%3A*' > json_2
	# 截取句子库消息数。
	a=`head -n 7 json | grep numFound`
	b=`echo $a | cut -c 24-30`
	echo 句子库总消息数为：${b%,*}

	a=`head -n 9 json_2 | grep numFound`
	b=`echo $a | cut -c 24-30`
	echo 昨天的消息数为：${b%,*}



fi
