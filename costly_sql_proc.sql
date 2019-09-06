set echo on;
spool /tmp/db_481_dba00.sql.log

CREATE OR REPLACE PROCEDURE costly_sql_proc (
  v_num_rec     IN NUMBER DEFAULT 100) 
IS 
  v_file_name	   VARCHAR2(40)       ;
  v_file_handle    utl_file.file_type ;
  v_tmp_text 	   VARCHAR2(64)       ; 
  v_user_name      varchar2(30)       ;

/* Cursor to select the hash_value and cost  */
  CURSOR cost_cursor IS 
         SELECT address,
		hash_value,
                (500*disk_reads+buffer_gets +executions*sorts) b,
	        executions,
		sorts,
		disk_reads,
		buffer_gets,
		parsing_user_id,
		first_load_time
	 FROM   v$sqlarea 
	 ORDER  BY 3 DESC;

/* Cursor to select full text of sqlstatements */
  CURSOR text_cursor(v_tmp_address IN VARCHAR2 ) IS 
         SELECT sql_text 
         FROM   v$sqltext 
         WHERE  address = v_tmp_address
         ORDER  BY piece;

/* Cursor to get the hash values from collectes hash_values */
  CURSOR hash_value_cursor (v_tmp_hash_value IN NUMBER) IS
         SELECT hash_value,cost 
         FROM   hash_values 
         WHERE  hash_value = v_tmp_hash_value ;

  v_tmp_rec 	cost_cursor%ROWTYPE; 
  v_tmp_rec_c3 	hash_value_cursor%ROWTYPE;  
BEGIN
  v_file_name := 'costlysql'||to_char(sysdate,'dd_mm')||'.lst';
  v_file_handle := utl_file.fopen('/tmp',v_file_name,'w');
  utl_file.putf(v_file_handle,'%s\n','+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++') ;
  utl_file.putf(v_file_handle,'%s\n','+ RESOURCE CONSUMING TOP STATEMENTS        DATED : '||SYSDATE||' +')        ;
  utl_file.putf(v_file_handle,'%s\n','+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++') ;
  OPEN cost_cursor;
  FOR i IN 1..v_num_rec 
  LOOP
        FETCH cost_cursor INTO v_tmp_rec;
	OPEN hash_value_cursor(v_tmp_rec.hash_value);
	     FETCH hash_value_cursor INTO v_tmp_rec_c3;
	     IF hash_value_cursor%NOTFOUND THEN
                SELECT username 
		INTO   v_user_name
	        FROM   dba_users
                WHERE  user_id = v_tmp_rec.parsing_user_id ;
		utl_file.putf(v_file_handle,'\n%s\n','________________________________________________________________'); 
		utl_file.putf(v_file_handle,'%s','S.No.     : '||cost_cursor%rowcount);
		utl_file.putf(v_file_handle,'%s','    Hash Value : '||v_tmp_rec.hash_value );
		utl_file.putf(v_file_handle,'%s\n','    Cost : '||v_tmp_rec.b );
		utl_file.putf(v_file_handle,'%s','Exec      : '||v_tmp_rec.executions );
		utl_file.putf(v_file_handle,'%s','   Sorts : '||v_tmp_rec.sorts );
		utl_file.putf(v_file_handle,'%s','   Disk Rds : '||v_tmp_rec.disk_reads );
		utl_file.putf(v_file_handle,'%s\n','   Buffer Gets :'||v_tmp_rec.buffer_gets );
		utl_file.putf(v_file_handle,'%s','User name :  '||v_user_name );
		utl_file.putf(v_file_handle,'%s\n\n\n','   First Exec. Time : '||v_tmp_rec.first_load_time);
		INSERT INTO hash_values values (
		       v_tmp_rec.hash_value    ,
		       v_tmp_rec.b             ,
		       v_tmp_rec.disk_reads    ,
		       v_tmp_rec.executions    ,
		       sysdate                 ,
		       v_user_name             ) ;
		OPEN text_cursor(v_tmp_rec.address);
		LOOP
		     FETCH text_cursor INTO v_tmp_text;
		     EXIT WHEN text_cursor%NOTFOUND;
		     utl_file.putf(v_file_handle,'%s\n',v_tmp_text);
		END LOOP;
		CLOSE text_cursor; 
		ELSE 
		     IF v_tmp_rec_c3.cost<v_tmp_rec.b THEN
			UPDATE hash_values SET 
			       cost         = v_tmp_rec.b          ,
			       executions   = v_tmp_rec.executions ,
			       phycal_reads = v_tmp_rec.disk_reads , 
			       dated        = sysdate 
			WHERE hash_value    = v_tmp_rec.hash_value ;
		     END IF;
		END IF; 
	CLOSE hash_value_cursor;
  END LOOP;
  CLOSE cost_cursor;
  COMMIT;
  utl_file.fclose(v_file_handle);
END;
/

exec costly_sql_proc ;
spool off
quit

