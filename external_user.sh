#!/bin/sh
#
# This script is intended to cach external sessions doing BO, MSACESS, GQL
# and kill them for performance reasons.
#
#
trap 'STATUS=$?;set +x;echo;echo error $STATUS at line nb $LINENO executing :  `sed -n "${LINENO}p" $0`;echo;exit $STATUS' ERR
if [ "$LOGNAME" != "oracle" ]
then
        if [ -z "$LOGNAME" ]
        then
                :
        else
                echo "you must launch this script as oracle"
                exit 1
        fi
fi

if [ `bdf /tmp|grep tmp|awk '{print $5}'|tr -d %` -ge 98 ]
then
        echo "File system /tmp is full, before running this job "
        echo "please clear all unecessary files in /tmp"
        exit 1
fi
export SESSION=v'$'session

sqlplus internal <<EOF

set termout off
set heading off
set feedback off

spool /tmp/external_user.log

select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program in ('rwrun60.exe','BUSOBJ.EXE','DBACCESS.EXE','PLUS80W.EXE','SQL Plus 8.0','AutoGRN.exe','VAW.EXE',,'PLUS33.exe', 'SQLPLUSW.EXE','sqlplus@del09mis(TNS V1-V3)' and STATUS not in ('KILLED');
/
select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program like '%access%' and STATUS not in ('KILLED');
/
select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program like '%ACCESS%' and STATUS not in ('KILLED');
/
select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program like '%TOAD.lnk%' and STATUS not in ('KILLED');
/
select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program like '%TOAD.EXE%' and STATUS not in ('KILLED');
/
select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program like '%PLUS33%' and STATUS not in ('KILLED');
/
select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program like '%SQLPLUSW.EXE%' and STATUS not in ('KILLED');
/
select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program like '%SQL Plus 8.0%' and STATUS not in ('KILLED');
/
select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program like '%SQL Plus 8.0%' and STATUS not in ('KILLED');
/
select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program like '%BUSOBJ.EXE%' and STATUS not in ('KILLED');
/
-- select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program like '%sqlplus@gnx145(TNS V1-V3)%' and STATUS not in ('KILLED');
-- /
select 'alter system kill session '''||SID||','||SERIAL#||''';' from $SESSION where program like '%rwrun60.exe%' and STATUS not in ('KILLED');
/

spool off
!cat /tmp/external_user.log | grep -v "SQL>" | sed 's/  //g' > /tmp/external_user_kill.sql
   spool /tmp/external_user_kill.log
   @/tmp/external_user_kill.sql
   spool off
EOF
rm -f /tmp/external_user*
