#!/usr/bin/ksh
#
# The script is intended to get only the timestamp and the elasp time of a session 
# 
# Usage :  auditsession <SID> <DAY>
#

OSTYPE=$(uname -s)
case $OSTYPE in
"AIX" ) alias bdf="/usr/bin/df -Ik"
        alias ll="/usr/bin/ls -l" ;;
"SunOS") alias bdf="/usr/bin/df -k"
         alias ll="/usr/bin/ls -l"
         alias grep="/usr/xpg4/bin/grep" ;;
esac


if [ "$LOGNAME" != "root" ]
then
	if [ -z "$LOGNAME" ]
	then
		:
	else
        	echo "you must launch this script as root"
        	exit 1
	fi
fi

if [ `bdf /tmp|grep tmp|awk '{print $5}'|tr -d %` -ge 98 ]
then
	echo "File system /tmp is full, before running this job "
	echo "please clear all unecessary files in /tmp"
	exit 1
fi

if [ $# -ne 2 ]
then
        echo "Usage : $0 <instance name> <how many days>"
        echo "List of existing instances : \n`grep -v -e "^#" -e "^$" /etc/ORATAB|cut -f1 -d:`"
        exit 1
else
        if grep -q "^$1:" /etc/ORATAB
        then
                echo "\nInstance $1 exists in /etc/ORATAB\n"
        else
                echo "Instance <$1> does not exist Please check"
                echo "List of existing instances : \n`grep -v -e "^#" -e "^$" /etc/ORATAB|cut -f1 -d:`"
                exit 1
        fi
fi

set -x;
export SID=$1
export DAY=$2
export USER=`grep "^$SID:" /etc/ORATAB|cut -d: -f4`
export  OHOME=`grep "^$SID:" /etc/ORATAB|cut -d: -f2`

##if [ -x $OHOME/bin/svrmgrl ]
##then
#        VAR3=svrmgrl
##        VAR3="sqlplus -s \"/nolog \" "
##        export VAR4="connect internal"
##else
        VAR3="sqlplus -s  \"/ as sysdba \" "
        export VAR4="set wrap off"
        export VAR5="set lines 500"
##fi
## csh or ksh
if grep "^$USER:" /etc/passwd|grep -q csh$
then
        export VAR="setenv ORACLE_SID ${SID};setenv ORACLE_HOME ${OHOME}"
        export VAR2="$OHOME/bin/$VAR3 <<EOF >&/dev/null"
else
        export VAR="ORACLE_SID=${SID};ORACLE_HOME=${OHOME};export ORACLE_SID ORACLE_HOME"
        export VAR2="$OHOME/bin/$VAR3 <<EOF 1>/dev/null 2>&1"
fi

## where TIMESTAMP > (SYSDATE - $DAY); 

su - $USER -c "
$VAR
$VAR2
$VAR4
$VAR5
spool /tmp/${SID}_session.trc
column USERNAME on format a15
column OS_USERNAME on format a15
select USERNAME,OS_USERNAME,to_char(TIMESTAMP,'DD-MM:HH24:MI:SS')as CONNECT_TIME,
to_char(LOGOFF_TIME,'DD-MM:HH24:MI:SS') as LOGOFF_TIME, 
((LOGOFF_TIME-TIMESTAMP)*3600*24)
as ELAPS_TIME from dba_audit_session
where to_char(TIMESTAMP,'DD') > to_char(SYSDATE,'DD') - ($DAY+1);
spool off
exit
EOF
"
echo "\n"
cat /tmp/${SID}_session.trc
echo " "
echo See the /tmp/${SID}_session.trc file for more details.
