--
-- check where we are working
--
select NAME, LOG_MODE, OPEN_MODE, CREATED, RESETLOGS_TIME, PRIOR_RESETLOGS_TIME, CONTROLFILE_CREATED, OPEN_RESETLOGS from v$database;
--
-- state of tablespace before any action
--
select TABLESPACE_NAME, BYTES/1024/1024 as freeMB from dba_free_space where tablespace_name='SYSTEM';
--
-- audit auditing for the target DB (2 steps)
--
-- All DDL statement audit
audit ALL BY ACCESS;
-- DML statement audit
audit ALTER TABLE BY ACCESS;
audit DELETE TABLE BY ACCESS;
audit EXECUTE PROCEDURE BY ACCESS;
audit INSERT TABLE BY ACCESS;
audit SELECT TABLE BY ACCESS;
audit UPDATE TABLE BY ACCESS;
--
-- Initial report giving nb of rows and free space
--
@/usr/local/oracle/audit-result.sql
