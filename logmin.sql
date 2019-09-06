execute DBMS_LOGMNR_D.BUILD(DICTIONARY_FILENAME => 'dictionary.ora', DICTIONARY_LOCATION => '/home/oraoem');

execute DBMS_LOGMNR.ADD_LOGFILE(LOGFILENAME => '/oraoem/arch/oem/1_900.dbf', OPTIONS => dbms_logmnr.NEW);

execute DBMS_LOGMNR.ADD_LOGFILE(LOGFILENAME => '/oraoem/arch/oem/1_901.dbf', OPTIONS => dbms_logmnr.ADDFILE);

execute DBMS_LOGMNR.START_LOGMNR(DICTFILENAME => '/home/oraoem/dictionary.ora');
