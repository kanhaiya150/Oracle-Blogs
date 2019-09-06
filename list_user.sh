#!/usr/bin/ksh
#
# list user not connected since a date found in listener.log
#
if [ $# -lt 1 ]
then
        echo "Usage : $0 <instance name>"
        exit 1
fi
if grep -q "^$1:" /etc/ORATAB
then
        :
else
       echo "Instance <$1> not found "
       exit 1
fi

export SID=$1

export  USER=`grep "^$SID:" /etc/ORATAB|cut -d: -f4`
export  OHOME=`grep "^$SID:" /etc/ORATAB|cut -d: -f2`
LISTENLOG=$OHOME/network/log/listener.log

su - $USER -c "
sqlplus -s internal > /tmp/users << EOF
set pages 0
set heading off
select 'day='||to_char(add_months(sysdate, -3),'DD-MON-YYYY')||';' from dual;
select 'USER='||username from dba_users 
where username not in ('SYS', 'SYSTEM', 'OUTLN', 'DBSNMP')
minus select role from dba_roles;
EOF
"

date
LINE=$(grep day= /tmp/users )
echo $LINE
eval $LINE 
echo date de clean $day

grep USER=oramid $LISTENLOG |awk '{print $1}' |head -1 >/tmp/first
FIRST=$(cat /tmp/first)

grep USER= /tmp/users |while read LINE
do
grep $LINE $LISTENLOG |awk '{print $1}' |sort -u |tail -1 >/tmp/last
LAST=$(cat /tmp/last)
X=$(echo $LAST |wc -c)
	if [ $X -gt 1 ]
	then
		echo $LINE connected $LAST
	else
		echo $LINE not connected from $FIRST
	fi
	read x
done
