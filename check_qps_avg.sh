#!/bin/bash 

for i in `ps -aef|grep socket=|grep -v DataDomain|grep -v safe|awk -F '--socket=' '{print $2}'|awk -F "--port=" '{print $1}'|grep /`
do

name=`ps -aef|grep mysql|grep $i|tr " " "\n"|grep pid|awk -F "/" '{print $3}'|sed 's/.pid//g'`
slow_query_result=` mysqladmin status -uNAME -pPASSWORD|awk '{print $22}'`
echo -n "$name QPS avg=$slow_query_result| $name=$slow_query_result;;;;"
done
exit 0



