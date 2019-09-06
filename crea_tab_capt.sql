drop table captured_session_waits;
create table captured_session_waits (timestamp date,
sid number,
process number,
ppid varchar2(9),
osuser varchar2(15),
username varchar2(30),
wait_time number,
seconds_in_wait number,
state varchar2(19),
sql_text varchar2(64),
piece number)
/
