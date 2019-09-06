#!/usr/bin/ksh
#
# This script is intended to generate trace.
# It generates RDA trace file and oracle trace file in /oracle/dump/s2
#
#

clear
procppid=`ps -ef | grep MSidTx_001 | grep -v grep |awk '{print $2}'`
procpid=`ps -ef | grep $procppid | grep oracles2 | awk '{print $2}'`
export procppid procpid

echo "Oracle tuxedo session process : $procpid"
echo "Tuxedo service hanging is MSidTs_UPP"

#/usr/local/oracle/infoproc $procpid


cd /oracle/software/admin/RDA
#removing file mandatory !!!!
cd RDA_Output
rm -f RDA*
cd ..

export ORACLE_SID=s2
export ORACLE_HOME=/oracle/software

echo " \n\nBE CAREFULL : YOU WILL BE PROMPT for SYS account PASSWORD "
echo " NEW PASS is "gg""
echo " FOR WWDC INTERNAL USAGE ONLY "
echo " Press <Return> to continue ..."
read
./rda.sh

echo "1. Hanging process number is : $procpid"
echo "2. get sql trace via oradebug as sys user"

   
sqlplus internal<< EOF
oradebug setospid $procpid
oradebug event 10046 trace name context forever, level 8
exit
EOF

echo " Waiting for 30 mns ...\c  "
sleep 1800
echo "Ok"

sqlplus internal<< EOF
oradebug setospid $procpid
oradebug event 10046 trace name context off
exit
EOF

echo "Completed at `date` ... "
echo " Results are located into : /oracle/software/admin/RDA/RDA_Output"
