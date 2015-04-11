#!/bin/bash 

for i in `ps -aef|grep socket=|grep -v DataDomain|awk -F '--socket=' '{print $2}'|awk -F "--port=" '{print $1}'|grep /`
do

name=`ps -aef|grep mysql|grep $i|tr " " "\n"|grep pid|awk -F "/" '{print $3}'|sed 's/.pid//g'`
last=`cat /tmp/lastqps.$name|grep -e [0-9]`
before=`cat /tmp/lasttime.$name`
after=`date +%s`
elapsed="$(expr $after - $before)"
time=$elapsed
orig=`mysql -uUSER -pPASSWORD -S $i  -e "show global status like 'Queries'"|grep -e [0-9]|awk '{print $2}'`
diff=`expr $orig - $last`
avg=`expr $diff / $time`
echo "$name QPS=$avg| $name=$avg;;;;"
echo $orig > /tmp/lastqps.$name
end=`date +%s`
echo $end  >/tmp/lasttime.$name
done
exit 0
