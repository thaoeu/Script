#!/usr/bin/env bash

# 进程检查。
function CheckProcess() {
	Status=`ps -ef | grep $1 | grep -v "grep" | wc -l`
	if [ $Status -eq 0 ]; then
		echo -e ''$2' \t\t \033[31m 未运行 \033[0m'
	else
		echo -e ''$2' \t\t \033[32m 已运行 \033[0m'
	fi
}
# 端口检查。
function CheckPort() {
	Status=`netstat -nlt | grep $1 | wc -l`
	if [ $Status -eq 0 ]; then
		echo -e ''$2' \t \033[31m 异常 \033[0m'
	else
		echo -e ''$2' \t \033[32m 正常 \033[0m'
	fi
}
# Sdk 进程检查。
function CheckSdk() {
	Status=`ps -ef | grep $1 | grep -v "grep" | grep $2 | wc -l`
	if [ $Status -eq 0 ]; then
		echo -e ''$2' \t \033[31m 未运行 \033[0m'
	else
		echo -e ''$2' \t \033[32m 已运行 \033[0m'
	fi
}


# 判断 Solr 进程及端口。
CheckProcess $SolrDir Solr
CheckPort $SolrPort Solr端口

# 判断是否为企业版，确定要检查的进程数。
if [ "$Tomcat" = "EE" ]; then
	# 检查 Tomcat 进程及端口。
	CheckProcess $TomcatDir Tomcat
	CheckPort $TomcatPort Tomcat端口

	# 检查 Tomcat2 进程及端口。
	CheckProcess $MvcDir Mvc
	CheckPort $MvcPort Mvc端口
else
	# 检查 Tomcat 进程及端口。
	CheckProcess $TomcatDir Tomcat
	CheckPort $TomcatPort Tomcat端口

fi

# 获取需要检查的Sdk数量

if [ $SdkNum -eq 5 ]; then
	# 依次检查五个 Skd 进程。
	CheckSdk $Sdk loopCorpFrame 
	CheckSdk $Sdk loopDown 
	CheckSdk $Sdk loopAsr 
	CheckSdk $Sdk loopMsg 
	CheckSdk $Sdk loopMvc 
else 
	echo "4"
fi

# 获取前一天日期。
Date=`date -d "-1 Day" +%Y-%m-%d`
# 获取 Solr 端口。
Port=`ps -ef  | grep $Corp | grep solr | grep -v "grep" | grep -o '\<port=[0-9][0-9][0-9][0-9]' | cut -c 6-10 | uniq -d`


# 获取json返回值，储存到文件等待处理。
curl -s 'http://127.0.0.1:'$Port'/solr/wechat_basic_msg/select?q=StartTime%3A%5B'$Date'T00%3A00%3A00.000Z%20TO%20'$Date'T23%3A59%3A59.999Z%5D&rows=0' > json
#	截取出消息数。
a=`head -n 8 json | grep numFound`
b=`echo $a | cut -c 24-30`
echo 昨日消息数：${b%,*}
