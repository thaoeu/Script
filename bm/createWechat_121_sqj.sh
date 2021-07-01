#!/bin/bash

# lhy 2020-07-16 在180上创建新用户

[ $# != 1 ] && echo "$0 conf/lk.conf " && exit 1
[ ! -e $1 ] && echo "$1 is not exists" && exit 2

source $1

# 获得此脚本所在的路径
shellPath=$(cd `dirname $0`; pwd);
cd ${shellPath};



# [1] 先检测各端口、库等
echo -e "\n************* test conf ***************"
hasError=no
# [1.1] 检测mysql库还没人使用
#res=`mysql -ubluemine-dev -pQazxsw123 -e "use ${Corp};"`;
res=`mysql -ubluemine-dev -pQazxsw123 -e "SELECT * FROM information_schema.SCHEMATA where SCHEMA_NAME='wechat_${Corp}';"`;
[ "${res}x" != "x" ] && echo "error!!! databse wechat_${Corp} has already exits" && echo ${res} && hasError=yes;

if [ "${SdkV}x" == "EEx" ]; then
    # 到这里说明是企业版
    res=`mysql -ubluemine-dev -pQazxsw123 -e "SELECT * FROM information_schema.SCHEMATA where SCHEMA_NAME='mvc_${Corp}';"`;
    [ "${res}x" != "x" ] && echo "error!!! databse mvc_${Corp} has already exits" && echo ${res} && hasError=yes;
fi


# [1.2] 检测solr端口是否被占用
res=`netstat -lan | grep ${SolrPort}`;
[ "${res}x" != "x" ] && echo "error!!! solr port ${SolrPort} has been used" && hasError=yes;

# [1.3] 检测tomcat端口 worker34 xwyb      18038 9113  8476
tomcatPortFile=/ai/workspace/LKASR/tomcat/port.conf;
res=`cat ${tomcatPortFile} | grep "worker${CorpSeq} "`;
[ "${res}x" != "x" ] && echo "error!!! tomcat  ${CorpSeq} has been used" && hasError=yes;
res=`cat ${tomcatPortFile} | grep " ${Corp} "`;
[ "${res}x" != "x" ] && echo "error!!! tomcat Corp ${Corp} has been used" && hasError=yes;
res=`cat ${tomcatPortFile} | grep " ${TomcatPort1} "`;
[ "${res}x" != "x" ] && echo "error!!! tomcat port ${TomcatPort1} has been used" && hasError=yes;
res=`cat ${tomcatPortFile} | grep " ${TomcatPort2} "`;
[ "${res}x" != "x" ] && echo "error!!! tomcat port ${TomcatPort2} has been used" && hasError=yes;
res=`cat ${tomcatPortFile} | grep " ${TomcatPort3}"`;
[ "${res}x" != "x" ] && echo "error!!! tomcat port ${TomcatPort3} has been used" && hasError=yes;

if [ "${SdkV}x" == "EEx" ]; then
    # 到这里说明是企业版
    res=`cat ${tomcatPortFile} | grep "worker${CorpSeq2} "`;
    [ "${res}x" != "x" ] && echo "error!!! tomcat  ${CorpSeq2} has been used" && hasError=yes;
    #res=`cat ${tomcatPortFile} | grep " ${Corp} "`;
    #[ "${res}x" != "x" ] && echo "error!!! tomcat Corp ${Corp} has been used" && hasError=yes;
    res=`cat ${tomcatPortFile} | grep " ${TomcatPort11} "`;
    [ "${res}x" != "x" ] && echo "error!!! tomcat port ${TomcatPort11} has been used" && hasError=yes;
    res=`cat ${tomcatPortFile} | grep " ${TomcatPort22} "`;
    [ "${res}x" != "x" ] && echo "error!!! tomcat port ${TomcatPort22} has been used" && hasError=yes;
    res=`cat ${tomcatPortFile} | grep " ${TomcatPort33}"`;
    [ "${res}x" != "x" ] && echo "error!!! tomcat port ${TomcatPort33} has been used" && hasError=yes;
fi


# [1.4] 检测ngnix端口
res=`cat /usr/local/nginx/conf/nginx.conf |grep ${TomcatPort2}`;
[ "${res}x" != "x" ] && echo "error!!! nginx has contained ${TomcatPort2} res: ${res}" && hasError=yes;


# [1.5] 提示是否还要进行
if [ ${hasError}x == "yesx" ]; then
	echo -n "there is a error when checking port, Is it still installed? no will exit. (yes(y)|no(n)): ";
	read need
	case $need in
		yes|y)
            echo "you choose ignore the errors, continue..." && sleep 2s
            ;;
        no|n)
            echo "exit...";
            exit 3
            ;;
        *)
            echo "you choose nothing, exit...";
            exit 3
            ;;
    esac
else
	echo "creating..." && sleep 1s
fi




# [2] 配置mysql
echo -e "\n************* create mysql ***************"
# [2.2] 新建mysql库
mysql -ubluemine-dev -pQazxsw123 -e "CREATE DATABASE IF NOT EXISTS wechat_${Corp} DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;flush privileges;";

# [2.3] 插入表结构
mysql -ubluemine-dev -pQazxsw123 -Dwechat_${Corp} < ${Wechat_sql};

# [2.4] 企业版建电话库
if [ "${SdkV}x" == "EEx" ]; then
    # 到这里说明是企业版
    mysql -ubluemine-dev -pQazxsw123 -e "CREATE DATABASE IF NOT EXISTS mvc_${Corp} DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;flush privileges;";
    cp ${Mvc_sql} ${Mvc_sql}_${Corp};
    sed -i 's/yuyinzhijianshitu/'wechat_${Corp}'/g' ${Mvc_sql}_${Corp};
    mysql -ubluemine-dev -pQazxsw123 -Dmvc_${Corp} < ${Mvc_sql}_${Corp};
fi


# [3] 创建solr
echo -e "\n************* create solr ***************"
# [3.1] cp新solr并启动
cd /ai/workspace/LKASR/solr;
cp -rf /ai/workspace/LKASR/solr/solr_9003_hascore/ solr_${SolrPort}_${Corp};
cd solr_${SolrPort}_${Corp}/bin;
sed -i 's/SOLR_PORT=9003/SOLR_PORT='${SolrPort}'/g' solr.in.sh;
./solr restart


# [4] 生成tomcat
echo -e "\n************* create tomcat ***************"
cd /ai/workspace/LKASR/tomcat;
echo "worker${CorpSeq} ${TomcatPort1} ${TomcatPort2} ${TomcatPort3} ${Corp}_wechat" >> port.conf;
tomcatName=worker${CorpSeq}_${Corp}_wechat;
#scp -r lhy@192.168.1.143:/ai/workspace/LKASR/tomcat/apache-tomcat-8.5.53 ./${tomcatName};
cp -r pkg/apache-tomcat-8.5.53 ${tomcatName};
#scp -r lhy@192.168.1.143:/ai/workspace/LKASR/tomcat/ROOT_wechat ./${tomcatName}/webapps/ROOT;
cp -r pkg/ROOT_wechat ${tomcatName}/webapps/ROOT;
rm -rf ${tomcatName}/webapps/ROOT/WEB-INF/classes/config;
#scp -r lhy@192.168.1.143:/ai/workspace/LKASR/tomcat/config_wechat ./${tomcatName}/webapps/ROOT/WEB-INF/classes/config;
cp -r pkg/config_wechat ${tomcatName}/webapps/ROOT/WEB-INF/classes/config;

# 改端口
sed -i 's/TomcatPort1/'${TomcatPort1}'/g' ${tomcatName}/conf/server.xml
sed -i 's/TomcatPort2/'${TomcatPort2}'/g' ${tomcatName}/conf/server.xml
sed -i 's/TomcatPort3/'${TomcatPort3}'/g' ${tomcatName}/conf/server.xml

sed -i 's/Corpx/wechat_'${Corp}'/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/jdbc.properties
sed -i 's/SolrPort/'${SolrPort}'/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/solr.properties
sed -i 's/TomcatPort2/1'${TomcatPort2}'/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/solr.properties
sed -i 's/localIp/121.229.54.24/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/solr.properties
#sed -i 's/Corpx/wechat_'${Corp}'/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/jdbc.properties

sed -i 's/Corpx/'${Corp}'/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/fileUrl.properties
mkdir /ai/workspace/ftphome/wechat/material/${Corp};
sed -i 's/CorpIdx/'${CorpId}'/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/qywx.properties
sed -i 's/Corpx/'${Corp}'/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/qywx.properties

cd ${tomcatName}/bin;
./startup.sh
res=`ps -ef | grep "${tomcatName}"` && sleep 3s;
[ "${res}x" == "x" ] && echo "error!!! ${tomcatName} is not alive!";

# [4.2] 企业版安装电话质检tomcat
if [ "${SdkV}x" == "EEx" ]; then
    cd /ai/workspace/LKASR/tomcat;
    echo "worker${CorpSeq2} ${TomcatPort11} ${TomcatPort22} ${TomcatPort33} ${Corp}_mvc" >> port.conf;
    tomcatName=worker${CorpSeq2}_${Corp}_mvc;
    #scp -r lhy@192.168.1.143:/ai/workspace/LKASR/tomcat/apache-tomcat-8.5.53 ./${tomcatName};
    cp -r pkg/apache-tomcat-8.5.53 ${tomcatName};
    #scp -r lhy@192.168.1.143:/ai/workspace/LKASR/tomcat/ROOT_wechat_call ./${tomcatName}/webapps/ROOT;
    cp -r pkg/ROOT_wechat_call ${tomcatName}/webapps/ROOT;
    rm -rf ${tomcatName}/webapps/ROOT/WEB-INF/classes/config;
    #scp -r lhy@192.168.1.143:/ai/workspace/LKASR/tomcat/config_wechat_call ./${tomcatName}/webapps/ROOT/WEB-INF/classes/config;
    cp -r pkg/config_wechat_call ${tomcatName}/webapps/ROOT/WEB-INF/classes/config;

    # 改端口
    sed -i 's/TomcatPort1/'${TomcatPort11}'/g' ${tomcatName}/conf/server.xml
    sed -i 's/TomcatPort2/'${TomcatPort22}'/g' ${tomcatName}/conf/server.xml
    sed -i 's/TomcatPort3/'${TomcatPort33}'/g' ${tomcatName}/conf/server.xml

    sed -i 's/Corpx/mvc_'${Corp}'/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/jdbc.properties
    sed -i 's/SolrPort/'${SolrPort}'/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/solr.properties
    sed -i 's/SolrPort/'${SolrPort}'/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/solr.properties
    # 注意下面的是 TomcatPort2，不是22，要用wechat的端口
    sed -i 's/TomcatPort2/1'${TomcatPort2}'/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/solr.properties
    sed -i 's/localIp/121.229.54.24/g' ${tomcatName}/webapps/ROOT/WEB-INF/classes/config/solr.properties

    cd ${tomcatName}/bin && ./startup.sh;
    res=`ps -ef | grep "${tomcatName}"` && sleep 3s;
    [ "${res}x" == "x" ] && echo "error!!! ${tomcatName} is not alive!";
fi



# [5] nginx
echo -e "\n************* create nginx ***************"
# 注意121的nginx要手动改
cd /ai/workspace/wechat_creator/nginx;
cp /usr/local/nginx/conf/nginx.conf nginx.conf_bak;
cp nginx_http.txt nginx.${Corp};
sed -i 's/TomcatPort22/'${TomcatPort22}'/g' nginx.${Corp}; # 注意需要先改22
sed -i 's/TomcatPort2/'${TomcatPort2}'/g' nginx.${Corp};
sed -i 's/Corpx/'${Corp}'/g' nginx.${Corp};
sed -i 's/WechatCallBackPortx/'${WechatCallBackPort}'/g' nginx.${Corp};

sed -i '/^# over lhy/,/^}$/s/.*//g' /usr/local/nginx/conf/nginx.conf;
cat nginx.${Corp} >> /usr/local/nginx/conf/nginx.conf;
#sudo /usr/local/nginx/sbin/nginx -s reload
res=`netstat -lan | grep "1${TomcatPort2}"`;
[ "${res}x" == "x" ] && echo "port 1${TomcatPort2} not alive, please check" && sleep 5s


# [6] sdk、ftpdown
echo -e "\n************* create sdk ***************"
# 蓝旷license限制
cd /ai/workspace/LKASR/javaApp/SolrJ;
processDate=`/bin/date +%Y%m%d`;
java -jar -Xmx64m SolrM.jar encrypt "${Corp}${processDate}${LkLicenseNum}" > encrytData.txt 2>&1
encrytData=`cat encrytData.txt`;
echo "(${Corp}${processDate}${LkLicenseNum})=${encrytData}";

mkdir /ai/workspace/ftphome/wechat/download/${Corp};
cd /ai/workspace/LKASR/javaApp/wechat;
wechatDir=wechat_bluemine_${CorpSeq}_${Corp};
cp -rf  wechat_bluemine ${wechatDir};
cd ${wechatDir};

sed -i 's/Corpx/'${Corp}'/g' config/druid.properties

sed -i 's/SolrPort/'${SolrPort}'/g' config/wechat_lk.properties
sed -i 's/TomcatPort22/'${TomcatPort22}'/g' config/wechat_lk.properties
sed -i 's/TomcatPort2/'${TomcatPort2}'/g' config/wechat_lk.properties
sed -i 's/Corpx/'${Corp}'/g' config/wechat_lk.properties

sed -i 's/CorpIdx/'${CorpId}'/g' config/wechat_lk.properties
sed -i 's/CorpSecretx/'${CorpSecret}'/g' config/wechat_lk.properties
sed -i 's#AddressBookSecretx#'${AddressBookSecret}'#g' config/wechat_lk.properties
sed -i 's#CustomerSecretx#'${CustomerSecret}'#g' config/wechat_lk.properties
sed -i 's/WechatCallBackPort/'${WechatCallBackPort}'/g' config/wechat_lk.properties
sed -i 's#DeptCodex#'${encrytData}'#g' config/wechat_lk.properties
sed -i 's/SdkVx/'${SdkV}'/g' config/wechat_lk.properties
sed -i 's/ZkIpPortx/'${ZkIpPort}'/g' config/wechat_lk.properties


[ -e ${shellPath}/private_key.pem_${Corp} ] && cp ${shellPath}/private_key.pem_${Corp} config/private_key.pem
mv wechat_bluemine.jar wechat_bluemine_${Corp}.jar
mv WechatCallBackServer.jar WechatCallBackServer_${Corp}.jar
sed -i 's/wechat_bluemine.jar/wechat_bluemine_'${Corp}'.jar/g' *.sh
sed -i 's/WechatCallBackServer.jar/WechatCallBackServer_'${Corp}'.jar/g' *.sh

#  提示是否还要进行
echo -n "start wechat sdk? (yes(y)|no(n)): ";
read need
case $need in
    yes|y)
        echo "you choose start wechat sdk..."
        cd /ai/workspace/LKASR/javaApp/wechat/wechat_bluemine_${Corp}/
        ./start_wechat_bluemine.sh
        ;;
    *)
        echo "do not start wechat sdk...";
        exit 4
        ;;
esac


# [7] 配置crontab
echo -e "runWork ${Corp} & \n sleep 2s \n" >> ${shellPath}/pro_day.sh;
echo -e "runWork ${Corp} & \n sleep 2s \n" >> ${shellPath}/pro_hour.sh;





