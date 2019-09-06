CREATE OR REPLACE PROCEDURE get_dblink_session_wait
  (Iduration IN NUMBER, interval IN number) as 
  duration NUMBER; 
  BEGIN 
  duration := Iduration; 
  WHILE duration > 0 
  LOOP 
  INSERT INTO captured_session_waits (timestamp,sid,process,ppid,osuser,username,
  wait_time,seconds_in_wait,state,sql_text,piece) 
  SELECT SYSDATE,W.sid,P.spid,S.process,S.osuser,S.username,
  W.wait_time,W.seconds_in_wait,W.state,T.sql_text,t.piece
  FROM v$session_wait W,v$process P,v$session S,v$sqltext T
  WHERE W.event like 'SQL*Net message from dblink'
  AND P.addr = S.paddr
  AND S.Sid = W.sid
  AND W.seconds_in_wait > 1
  AND S.sql_hash_value = T.hash_value
  AND S.SQL_address    = T.address;
  COMMIT; 
  dbms_lock.sleep(interval); 
  duration := duration - interval; 
  END LOOP; 
  END; 
/
