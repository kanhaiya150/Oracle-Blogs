
drop table lock_holders;

create table LOCK_HOLDERS   /* temporary table */
(
  waiting_session   number,
  holding_session   number,
  lock_type         varchar2(26),
  mode_held         varchar2(14),
  mode_requested    varchar2(14),
  lock_id1          varchar2(22),
  lock_id2          varchar2(22)
);

drop   table dba_locks_temp;
create table dba_locks_temp as select * from dba_locks;

insert into lock_holders 
select w.session_id,
        h.session_id,
        w.lock_type,
        h.mode_held,
        w.mode_requested,
        w.lock_id1,
        w.lock_id2
  from dba_locks_temp w, dba_locks_temp h
where h.mode_held      !=  'None'
  and  h.mode_held      !=  'Null'
  and  w.mode_requested !=  'None'
  and  w.lock_type       =  h.lock_type
  and  w.lock_id1        =  h.lock_id1
  and  w.lock_id2        =  h.lock_id2;

commit;
drop table dba_locks_temp;

insert into lock_holders 
  select holding_session, null, 'None', null, null, null, null
    from lock_holders 
 minus
  select waiting_session, null, 'None', null, null, null, null
    from lock_holders;
commit;

drop table sortie;
create table sortie
(
 waiting_session   number,
  holding_session   number,
  lock_id1          varchar2(22),
  lock_id2          varchar2(22),
  lock_type         varchar2(26),
  mode_held         varchar2(14),
  mode_requested    varchar2(14),
  username	    varchar2(30),
  osuser            varchar2(15),
  process           varchar2(9),
  machine           varchar2(64),
  object_name       varchar2(30),
  object_id         number,
  object_type       varchar2(12)
);

insert into sortie 
select  L.waiting_session,
        L.holding_session,
	L.lock_id1,
	L.lock_id2,
	L.lock_type,
	L.mode_held,
	L.mode_requested,
	S.username,
	S.osuser,
	S.process,
	S.machine,
	'',
	'',
	''
 from lock_holders L, V$session S
where L.waiting_session = S.SID
;
commit;
set charwidth 14;
select * from sortie;
/* Print out the result in a tree structured fashion */
select  lpad(' ',3*(level-1)) || waiting_session waiting_session,
	lock_type,
	mode_requested,
	mode_held,
	process,
	osuser,
	machine,
	username,
	object_name,
	object_type
 from sortie
connect by  prior waiting_session = holding_session
  start with holding_session is null;

drop table lock_holders;
drop table sortie;
