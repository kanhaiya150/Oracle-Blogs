select sid Holder ,KGLPNUSE Sesion , KGLPNMOD Held, KGLPNREQ Req
from sys.kglpn x, v$session s
where x.KGLPNHDL in (select p1raw from v$session_wait where wait_time=0
and event like 'library cache pin%' ) and s.saddr=x.kglpnuse

/
