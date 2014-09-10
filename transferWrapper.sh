#!/bin/bash

export TIMEFORMAT='%3R'
TIMEFILE="time.log"
JOBNUM=""
rm -f *.log
touch time.log
echo "Running small file tests:"
echo "HSI on Titan Login Node"
echo "hsi putting a 1GB file onto HPSS: " >> $TIMEFILE
{ time $(hsi put smallFile.dat 2> /dev/null) ; } >> $TIMEFILE 2>&1
echo "HTAR on Titan Login Node"
echo "HTAR putting 1GB tarred file on HPSS from login: " >> $TIMEFILE
{ time htar -cvf small.tar smallFile.dat >> /dev/null ; } >> $TIMEFILE 2>&1

#Run Large file tests on Login

echo "Logging into DTN: "
ssh dtn "bash -s" << 'ENDSSH'
cd $HOME/dataTiming
./remoteTime.sh
ENDSSH

echo "Running small file batch tests from titan login node"
JOBNUM=$(qsub -q dtn hpss.pbs)
until [[ -f "dataTransferTimings.o$JOBNUM" ]] ;
  do
    sleep 2s
  done
#Run Large file tests on DTN

#Run Small file tests on dtn batch via qsub

#Run Large file tests on dtn batch via qsub
