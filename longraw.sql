set lines 132
set pages 24
select owner,table_name,column_name from dba_tab_columns where data_type like 'LONG RAW%'
and owner not like 'SYS'
and owner not like 'SYSTEM'
/
