---------------------------------------------------------
-- Result of auditing
-- 1) MB of tablespace used by audit table
-- 2) Space left for auditing
-- 3) Number of audited actions per day and hour
-- 4) (optional, remove '--' to run) Detailed count of actions per action type, object, return code
-- 5) Number of audited actions per user
-- 6) Grand total
---------------------------------------------------------
-- evaluate audit disk usage
---------------------------------------------------------
select 'UsedMB ' as tag, bytes/1024/1024 as usedMB,segment_type,segment_name,tablespace_name as tablespace from dba_segments where segment_name in ('AUD$','I_AUD1');

---------------------------------------------------------
-- tablespace free space report
---------------------------------------------------------
select TABLESPACE_NAME, sum(BYTES)/1024/1024 as sizeMB, AUTOEXTENSIBLE, sum(MAXBYTES)/1024/1024 as maxMB, INCREMENT_BY/1024/1024 as incrementMB, sum(USER_BYTES)/1024/1024 as userMB
from dba_data_files where tablespace_name='SYSTEM' group by TABLESPACE_NAME, AUTOEXTENSIBLE, INCREMENT_BY ;
select TABLESPACE_NAME, BYTES/1024/1024 as freeMB from dba_free_space where tablespace_name='SYSTEM';

---------------------------------------------------------
-- time repartition of audited actions 
---------------------------------------------------------
select count(*) as NbActions, to_char(TIMESTAMP,'DD-MON HH24') as hourRange from dba_audit_trail group by to_char(TIMESTAMP,'DD-MON HH24');

---------------------------------------------------------
-- Detail by action,object (deactivated /too many lines, uncomment to re-activate)
---------------------------------------------------------
--select count(*) as NbActions, substr(ACTION_NAME||'  '||OWNER||'.'||OBJ_NAME,1,57), RETURNCODE, to_char(min(TIMESTAMP),'DD-MON HH24:MI:SS') as minDT, to_char(max(TIMESTAMP),'DD-MON HH24:MI:SS') as maxDT from dba_audit_trail group by ACTION_NAME||'  '||OWNER||'.'||OBJ_NAME, RETURNCODE ;

---------------------------------------------------------
-- Detail by user,action 
-- (select <=> SES_ACTIONS = '---------S------' ; AL,AUD,COMM,DEL,GR,IND,INS,LOCK,REN,SEL,UPD,REF,EXE,null,null,null)
---------------------------------------------------------
select count(*) as NbActions, substr(USERNAME||' does '||ACTION_NAME||' '||SES_ACTIONS,1,57), to_char(min(TIMESTAMP),'DD-MON HH24:MI:SS') as minDT, to_char(max(TIMESTAMP),'DD-MON HH24:MI:SS') as maxDT from dba_audit_trail group by USERNAME||' does '||ACTION_NAME||' '||SES_ACTIONS ;

---------------------------------------------------------
-- Number of actions per user
---------------------------------------------------------
select count(*) as NbActions, OS_USERNAME||' as '||USERNAME, USERHOST, to_char(min(TIMESTAMP),'DD-MON HH24:MI:SS') as minDT, to_char(max(TIMESTAMP),'DD-MON HH24:MI:SS') as maxDT from dba_audit_trail group by OS_USERNAME||' as '||USERNAME, USERHOST;

---------------------------------------------------------
-- grand total
---------------------------------------------------------
select 'AuditTrailCnt ' as tag, count(*) as dba_audit_trail_cnt from dba_audit_trail;
