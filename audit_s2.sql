alter system set max_dump_file_size=unlimited;
  
-- Execute Step 1 at SQL prompt
  
-- Repeat after every 3 minutes Step 2 for 5 No. of times again at SQL Prompt
       
   
alter session set events 
'immediate trace name SYSTEMSTATE level 10';
  
  
--  Step 3, 
  
set echo on
spool result.log
select sid Holder ,KGLPNUSE Sesion , KGLPNMOD Held, KGLPNREQ Req
       from sys.kglpn x, v$session s
       where x.KGLPNHDL in (select p1raw from v$session_wait
       where wait_time=0
       and event like 'library cache pin%' )
       and s.saddr=x.kglpnuse
       /
  
  
spool off
