-- initial situation
select lob.owner,bytes/1024/1024 as usedMB, pct_increase,max_extents, next_extent/1024 as nextKb ,lob.table_name||'.'||lob.column_name as table_column,segment_type||' '||lob.segment_name||' on tablespace '||seg.tablespace_name from dba_lobs lob, dba_segments seg where lob.table_name = 'WWDOC_DOCUMENT$' and lob.owner=seg.owner and lob.segment_name=seg.segment_name ;
-- DDL action
alter table portal30.wwdoc_document$  modify LOB (BLOB_CONTENT)  (storage (next 1M ));
alter table portal30.wwdoc_document$  modify LOB (BLOB_CONTENT)  (storage (maxextents 50000));
-- result
select lob.owner,bytes/1024/1024 as usedMB, pct_increase,max_extents, next_extent/1024 as nextKb ,lob.table_name||'.'||lob.column_name as table_column,segment_type||' '||lob.segment_name||' on tablespace '||seg.tablespace_name from dba_lobs lob, dba_segments seg where lob.table_name = 'WWDOC_DOCUMENT$' and lob.owner=seg.owner and lob.segment_name=seg.segment_name ;
