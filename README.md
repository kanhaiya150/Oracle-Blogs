# Oracle-Blogs
Oracle OS Watcher - Start and generate html report
Hi Guys,

OS Watcher is excellent utility for system performance investigation.

OSWatcher invokes these distinct operating system utilities, each as a distinct background process, as data collectors. These utilities will be supported, or their equivalents, as available for each supported target platform.
ps
top
ifconfig
mpstat
iostat
netstat
traceroute
vmstat
meminfo (Linux Only)
slabinfo (Linux Only)

OSWatcher is java program and requires as a minimum java version 1.4.2 or higher. This can run on on any Unix/Windows. An X Windows environment is required because oswbba uses Oracle Chart builder which requires it.

Make sure java path is set

$which java
$<java path>/java

Following will take system snapshot in every 30 seconds and will log last 24 hours data to OS Watcher archive log files.

$cd <OS watcher dir>
$nohup ./startOSWbb.sh 30 24 gzip <OS Watcher file location> &

Without compress

$nohup ./startOSWbb.sh 30 48 NONE /oracle/PB0/oraarch/oswbb/archive &

Stop OS Watcher

./stopOSWbb.sh

This must be executed from X manager session and will generate html report. You can set required memory size for java program, this size depends on how much data you are analysing. I use 1000M for one day data, sometime 3000M as well for 3 days.

$<java path>java -jar -Xmx3000M oswbba.jar -i <OS Watcher Archive dir> -B Mar 10 06:00:00 2017 -E Mar 12 08:00:00 2017 -P

-B   --> Begin time of job analysis
-E  --> End time of analysis

More information

Download oswbb732.tar from MOS - 301137.1
OS Watcher User's Guide (Doc ID 1531223.1)

http://bit.ly/2ppOOyu

