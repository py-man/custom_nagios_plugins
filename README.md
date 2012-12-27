custom_nagios_plugins
=====================

Useful Nagios Plugins created over time

check_gc_oms.sh  --> uses check_jmx from nagios exchange and checks for increasing GC (note: if in FGC jmx may not respond untill condition clears - thus giving a connection refused and error in nagios)

gc_check.py --> Check gc.log for increasing GC and reports to nagios 
