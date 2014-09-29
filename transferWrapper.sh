#!/bin/bash

export TIMEFORMAT='%3R'
TIMEFILE="time.log"
SMALLFILE="smallFile.dat"
MEDFILE="midFile.dat"
BIGFILE="biggerFile.dat"
AVGHSI=0
AVGHTAR=0
I=0
declare -a files=($SMALLFILE $MEDFILE $BIGFILE)
COUNTER=0
INTCOUNTER=0
rm -f *.log
touch time.log

hsi rm smallFile.dat 2> /dev/null
hsi rm midFile.dat 2> /dev/null
hsi rm biggerFile.dat 2> /dev/null

echo "Running  tests:"
while [ $COUNTER -lt 3 ] ; do
  hsi rm smallFile.dat 2> /dev/null
  hsi rm midFile.dat 2> /dev/null
  hsi rm biggerFile.dat 2> /dev/null
  while [ $INTCOUNTER -lt 3 ] ; do
    echo "HSI ${files[$COUNTER]} on Titan Login Node"
    I=$( { time $(hsi put ${files[$COUNTER]} 2> /dev/null); } 2>&1 )
    AVGHSI=$(echo $AVGHSI + $I | bc)
    echo "HTAR ${files[$COUNTER]} on Titan Login Node"
    I=$( { time htar -cvf small.tar ${files[$COUNTER]} >> /dev/null; } 2>&1 )
    AVGHTAR=$(echo $AVGHTAR + $I | bc)
    #Average the time for this cycle
    INTCOUNTER=$(echo $INTCOUNTER + 1 | bc)
  done
  
  AVGHSI=$(echo $AVGHSI / 3 | bc -l)
  AVGHTAR=$(echo $AVGHTAR / 3 |bc -l)
  echo "Average HSI time for ${files[$COUNTER]} after 3 iterations:" >> $TIMEFILE
  echo $AVGHSI >> $TIMEFILE
  echo "Average HSI for ${files[$COUNTER]}"
  echo $AVGHSI
  echo "Average HTAR time for ${files[$COUNTER]} after 3 iterations:" >> $TIMEFILE
  echo $AVGHTAR >> $TIMEFILE
  echo "Average HTAR for ${files[$COUNTER]}"
  echo $AVGHTAR
  AVGHSI=0
  AVGHTAR=0
  INTCOUNTER=0
  I=0
  COUNTER=$(echo $COUNTER + 1 | bc)
done

hsi rm smallFile.dat 2> /dev/null
hsi rm midFile.dat 2> /dev/null
hsi rm biggerFile.dat 2> /dev/null

echo "Logging into DTN: "
ssh dtn "bash -s" << 'ENDSSH'
cd $HOME/dataTiming
./remoteTime.sh
ENDSSH

hsi rm smallFile.dat 2> /dev/null
hsi rm midFile.dat 2> /dev/null
hsi rm biggerFile.dat 2> /dev/null

echo "Running small file batch tests from titan login node"
JOBNUM=$(qsub -q dtn hpss.pbs)
until [[ -f "dataTransferTimings.o$JOBNUM" ]] ;
  do
    sleep 2s
  done
