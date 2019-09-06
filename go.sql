PROMPT Status of the database
SELECT status FROM v$instance;
PROMPT Status of datafiles
SELECT DISTINCT status FROM v$datafile;
PROMPT Status of tempfiles
SELECT DISTINCT status FROM v$tempfile;
PROMPT Status of tablespaces
SELECT DISTINCT status FROM dba_tablespaces;
PROMPT List of files to recover
SELECT * FROM v$recover_file;
--PROMPT File name which need a recover
--SELECT file_name FROM dba_data_files WHERE file_id IN (21,33);
PROMPT List of logfiles and their status
SELECT group#, status, substr(member,1,60) FROM v$logfile;
PROMPT Any files in begin backup ?
SELECT DISTINCT status FROM v$backup;

