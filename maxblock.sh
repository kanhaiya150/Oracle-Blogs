svrmgrl <<EOF
connect internal
spool /tmp/maxblock.log
select tablespace_name,bytes,maxbytes,(maxbytes-bytes)/1024 as "Left Ko",
         blocks,maxblocks,maxblocks-blocks as "Left blocks"
  from
  (select tablespace_name,sum(bytes) as bytes,sum(maxbytes) as maxbytes,
          sum(blocks) as blocks,sum(maxblocks) as maxblocks
   from dba_data_files
   group by tablespace_name)
;

exit
EOF
