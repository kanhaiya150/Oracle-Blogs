/* list blocking locks */

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
select * from lock_holders;
