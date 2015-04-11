#!/bin/bash 

##Use nagios exchange cheeck_jmx - which handles all the nagios exit codes
##for each instance of Java (and its JMX port)

for i in `ps -aef|grep java|tr ":" "\n"|grep data|tr "=" "\n"|grep catalina|awk '{print $1}'|grep catalina.prop`
	do
		##check JMX for GC and get Value - Wait X seconds - check Again - Checking GC Duration 
		HOST=`echo -n $i|awk -F "/" '{print $4}'`
		PORT=`cat $i|grep jmx|cut -d "=" -f2`
		current=`/etc/nagios/plugins/check_jmx -U service:jmx:rmi:///jndi/rmi://127.0.0.1:$PORT/jmxrmi -O 'java.lang:type=GarbageCollector,name=PS MarkSweep' -A CollectionCount|awk -F "|" '{print $2}'|cut -d "=" -f2`
		last=`cat /tmp/lastgc1|grep -e [0-9]`

		if  [ "$current" -gt "$last" ]; then
			w=$(($last + 2))
			c=$(($last + 3))
			/etc/nagios/plugins/check_jmx -U service:jmx:rmi:///jndi/rmi://127.0.0.1:$PORT/jmxrmi -O 'java.lang:type=GarbageCollector,name=PS MarkSweep' -A CollectionCount -w $w -c $c
			echo "$current" >/tmp/lastgc1

		else
			/etc/nagios/plugins/check_jmx -U service:jmx:rmi:///jndi/rmi://127.0.0.1:$PORT/jmxrmi -O 'java.lang:type=GarbageCollector,name=PS MarkSweep' -A CollectionCount

		fi


done




