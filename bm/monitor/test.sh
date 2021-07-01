if [ ! -n "$1" ]; then
echo "请输入要查询的客户id"
else
a=`ps -ef  | grep $1 | grep loopMvc | wc -l`
if [ $a -eq 0 ]; then
        echo 服务未完全运行
else
        echo 服务完全运行
fi
fi


http://180.106.83.105:8975/solr/wechat_basic_msg/select?q=StartTime%3A%5B2021-06-27T00%3A00%3A00.000Z%20TO%202021-06-27T23%3A59%3A59.999Z%5D&rows=0
