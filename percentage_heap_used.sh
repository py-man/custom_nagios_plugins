#!/bin/bash 

cd /etc/nagios/plugins
TOTAL_MEM=`free -g|grep Mem|awk '{print $2}'`

GET_TOTAL_USED=`for i in \`cat /data/workdayci/prui17*/tomcat/conf/catalina.properties|grep jmx|cut -d "=" -f2\`; do /etc/nagios/plugins/check_jmx -U service:jmx:rmi:///jndi/rmi://127.0.0.1:$i/jmxrmi -O java.lang:type=Memory -A HeapMemoryUsage -K used|cut -d "=" -f2 |awk '{print $1}'; done > /tmp/2used.txt`

TOTAL_USED=`awk '{s+=$0} END {print s}' /tmp/2used.txt`

TOTAL_USED_GB=`perl -e 'map {print "$ARGV[0] $_\n" and $ARGV[0]/=1024} qw(bytes Kb Mb Gb);' $TOTAL_USED |grep Gb|cut -d "." -f1`

TOTAL_USED_MINUS10=`./calc.pl $TOTAL_MEM 100 10`
TOTALP=`./calc2.pl $TOTAL_MEM  $TOTAL_USED_MINUS10`
TOTALP=`echo $TOTALP|cut -d "." -f1`

if  (("$TOTAL_USED_GB" >= "$TOTALP"))
	then
		echo "CRITICAL: Current Heap Usage ($TOTAL_USED_GB) is over 90% of System Ram ($TOTAL_MEM)"
		exit 3
else
	echo "OK|Total_System_Ram=$TOTAL_MEM|Total_Heap_Used=$TOTAL_USED_GB"
	exit 0
	
fi
