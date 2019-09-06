select sum(value),name from v$sesstat,v$statname
where name like 'session %' and v$sesstat.statistic#=v$statname.statistic#
group by name
/
