#!/bin/bash 
##Check for length of JAVA GC

cd /etc/nagios/plugins/
for i in `ps -aef|grep java|tr ":" "\n"|grep data|tr "=" "\n"|grep catalina|awk '{print $1}'|grep cata`
  do
    HOST=`echo -n $i|awk -F "/" '{print $4}'`
    PORT=`cat $i|grep jmx|cut -d "=" -f2`
    JMX=`/etc/nagios/plugins/check_jmx -U service:jmx:rmi:///jndi/rmi://127.0.0.1:$PORT/jmxrmi -O 'java.lang:type=GarbageCollector,name=PS MarkSweep' -A CollectionTime -K duration`
   JMX2=`echo $JMX |awk -F "=" '{print $2}'|awk '{print $1}' >/tmp/$HOST.now`
   JMX3=`echo $JMX |awk -F "=" '{print $2}'|awk '{print $1}'`
   OLD=`cat /tmp/$HOST.old|awk '{print $1}'`
   OLD2=`echo $OLD`
   DIFF=`./calc2.pl $JMX3 $OLD`

   if (("$DIFF" >= "20000"))
     then
       echo $JMX |awk -F "=" '{print $2}' >/tmp/$HOST.old
       echo "Critical:$DIFF(ms) GC on $HOST|"$HOST"_OLD_GC_TIME=$OLD;;;;"$HOST"_CURRENT=$JMX3;;;;"$HOST"_Difference=$DIFF;;;;"
       exit 1
     else
       echo "OK -($DIFF)ms|"$HOST"_OLD_GC_TIME=$OLD;;;;"$HOST"_CURRENT=$JMX3;;;;"$HOST"_Difference=$DIFF;;;;"
  fi
done
exit 0



