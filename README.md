custom_nagios_plugins
=====================

<<<<<<< HEAD
Simple Useful Nagios Plugins created over time

GC checks
QPS checks


Lots of examples on various sites, tese are run using only bash and a smidge of perl, for environments where modules, and external libs and tools can not be installed, ie: not even bc can be used.

=======
Useful Nagios Plugins created over time

check_gc_oms.sh  --> uses check_jmx from nagios exchange and checks for increasing GC (note: if in FGC jmx may not respond untill condition clears - thus giving a connection refused and error in nagios)

gc_check.py --> Check gc.log for increasing GC and reports to nagios 
>>>>>>> 5840d6139d12df4284ddda1dc3437a90bc77b236
