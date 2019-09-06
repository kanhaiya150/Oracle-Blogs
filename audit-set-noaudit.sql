--
-- check where we are working
--
select NAME, LOG_MODE, OPEN_MODE, CREATED, RESETLOGS_TIME, PRIOR_RESETLOGS_TIME, CONTROLFILE_CREATED, OPEN_RESETLOGS from v$database;
--
-- state of tablespace before any action
--
select TABLESPACE_NAME, BYTES/1024/1024 as freeMB from dba_free_space where tablespace_name='SYSTEM';
--
-- noaudit auditing for the target DB (2 steps)
--
-- All DDL statement audit
noaudit ALL ;
-- DML statement audit
noaudit ALTER TABLE ;
noaudit DELETE TABLE ;
noaudit EXECUTE PROCEDURE ;
noaudit INSERT TABLE ;
noaudit SELECT TABLE ;
noaudit UPDATE TABLE ;
--
-- Initial report giving nb of rows and free space
--
@/usr/local/oracle/audit-result.sql
