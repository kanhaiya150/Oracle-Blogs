select sid,event,p2,seconds_in_wait from v$session_wait where event like 'latch free%'
/* 
    ** Display System-wide latch statistics. 
*/ 

    column name format A32 truncate heading "LATCH NAME" 
    column pid heading "HOLDER PID" 
    select c.name,a.addr,a.gets,a.misses,a.sleeps, 
    a.immediate_gets,a.immediate_misses,b.pid 
    from v$latch a, v$latchholder b, v$latchname c 
    where a.addr = b.laddr(+) 
    and a.latch# = c.latch# 
    order by a.latch#; 
/* 
    ** Given a latch address, find out the latch name.
*/ 

    column name format a64 heading 'Name' 
    select name from v$latchname a, v$latch b 
    where b.addr = '&addr' 
    and b.latch#=a.latch#; 
      

/* 
    ** Display latch statistics by latch name. 
*/ 
    column name format a32 heading 'LATCH NAME' 
    column pid heading 'HOLDER PID' 
    select c.name,a.addr,a.gets,a.misses,a.sleeps, 
    a.immediate_gets,a.immediate_misses,b.pid 
    from v$latch a, v$latchholder b, v$latchname c 
    where a.addr   = b.laddr(+) and a.latch# = c.latch# 
    and c.name like '&latch_name%' order by a.latch#; 
/
