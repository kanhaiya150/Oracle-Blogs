select
  avg(v.value) shared_pool_size,
  greatest(avg(s.ksmsslen) - sum(p.ksmchsiz), 0) spare_free,
  to_char(
  100 * greatest(avg(s.ksmsslen) - sum(p.ksmchsiz), 0) / avg(v.value),
  '99999'
  ) || '%' wastage
  from
  sys.x$ksmss s,
  sys.x$ksmsp p,
  sys.v_$parameter v
  where
  s.inst_id = userenv('Instance') and
  p.inst_id = userenv('Instance') and
  p.ksmchcom = 'free memory' and
  s.ksmssnam = 'free memory' and
  v.name = 'shared_pool_size'
/
