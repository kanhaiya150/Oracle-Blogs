/* list blocking locks */
drop table lock_holders1;

create table LOCK_HOLDERS1   /* temporary table */
(
  waiting_session   number,
  holding_session   number,
  lock_type         varchar2(26),
  mode_held         varchar2(14),
  mode_requested    varchar2(14),
  lock_id1          varchar2(22),
  lock_id2          varchar2(22)
) nologging;

drop   table dba_locks_temp1;
create table dba_locks_temp1  nologging as select * from dba_locks;

insert into lock_holders1 
select w.session_id,
        h.session_id,
        w.lock_type,
        h.mode_held,
        w.mode_requested,
        w.lock_id1,
        w.lock_id2
  from dba_locks_temp1 w, dba_locks_temp1 h
where h.mode_held      !=  'None'
  and  h.mode_held      !=  'Null'
  and  w.mode_requested !=  'None'
  and  w.lock_type       =  h.lock_type
  and  w.lock_id1        =  h.lock_id1
  and  w.lock_id2        =  h.lock_id2;

commit;
drop table dba_locks_temp1;

insert into lock_holders1 
  select holding_session, null, 'None', null, null, null, null
    from lock_holders1 
 minus
  select waiting_session, null, 'None', null, null, null, null
    from lock_holders1;
commit;

drop table sortie1;
create table sortie1
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
  object_id         number
) nologging ;

insert into sortie1
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
	N.name,
	O.object_id
 from lock_holders1 L, V$session S, V$locked_object O, obj$ N
where L.waiting_session = S.SID
and S.SID=O.session_id
and O.object_id=N.obj#
;
commit;

set charwidth 14;
/* Print out the result in a tree structured fashion */
select  lpad(' ',3*(level-1)) || waiting_session waiting_session,
	lock_type,
	mode_requested,
	mode_held,
	process,
	osuser,
	machine,
	username,
	object_name
 from sortie1
connect by  prior waiting_session = holding_session
  start with holding_session is null;

drop table lock_holders1;
drop table sortie1;
