#!/bin/bash

export TIMEFORMAT='%3R'
DATE=$(date +%s)
SUFFIX="login.log"
TIMEFILE="time/$DATE$SUFFIX"
touch "$TIMEFILE"
SMALLFILE="smallFile.dat"
MEDFILE="midFile.dat"
BIGFILE="biggerfile.dat"
AVGHSI=0
AVGHTAR=0
declare -a files=($SMALLFILE $MEDFILE $BIGFILE)
COUNTER=0
INTCOUNTER=0
rm -f *.log
touch time.log
echo "$TIMEFILE"

function clean {
  hsi rm smallFile.dat 2> /dev/null
  hsi rm midFile.dat 2> /dev/null
  hsi rm biggerFile.dat 2> /dev/null
  hsi rm file.tar 2> /dev/null
  hsi rm 1TB.dat 2> /dev/null
  hsi rm file.tar.idx 2> /dev/null
}


function calcHSI {
  I=$(hsi put ${files[$1]} 2>&1)
  KBS=$(echo "$I" | grep -Po "(?<=bytes, ).*(?= KBS)")
  BYTES=$(echo "$I" | grep -Po "(?<=/midFile.dat' \( ).*(?= bytes)")
  KBYTES=$(echo "$BYTES" / 1000 | bc -l)
  HSITIME=$(echo "$KBYTES" / echo "$KBS" | bc -l)
  echo "$HSITIME"
}

echo "Running  tests:"
while [ "$COUNTER" -lt 3 ] ; do
  while [ "$INTCOUNTER" -lt 3 ] ; do
    clean
    echo "HSI ${files[$COUNTER]} on Titan Login Node"
    I=$(calcHSI $COUNTER)
    echo "Test $INTCOUNTER for ${files[$COUNTER]} With HSI" >> "$TIMEFILE"
    echo "$I" >> "$TIMEFILE"
    hsi rm ${files[$COUNTER]} 2> /dev/null
    AVGHSI=$(echo $AVGHSI + "$I" | bc)
    clean
    echo "HTAR ${files[$COUNTER]} on Titan Login Node"
    I=$( htar -cvf file.tar ${files[$COUNTER]} | grep -Po "(?<=time: ).*(?= seconds)" )
    echo "Test $INTCOUNTER for ${files[$COUNTER]} With HTAR" >> "$TIMEFILE"
    echo "$I" >> "$TIMEFILE"
    AVGHTAR=$(echo "$AVGHTAR" + "$I" | bc)
    #Average the time for this cycle
    INTCOUNTER=$(echo "$INTCOUNTER" + 1 | bc)
  done
  
  AVGHSI=$(echo "$AVGHSI" / 3 | bc -l)
  AVGHTAR=$(echo "$AVGHTAR" / 3 |bc -l)
  echo "Average HSI time for ${files[$COUNTER]} after 3 iterations:" >> "$TIMEFILE"
  echo "$AVGHSI" >> "$TIMEFILE"
  echo "Average HSI for ${files[$COUNTER]}"
  echo "$AVGHSI"
  echo "Average HTAR time for ${files[$COUNTER]} after 3 iterations:" >> "$TIMEFILE"
  echo "$AVGHTAR" >> "$TIMEFILE"
  echo "Average HTAR for ${files[$COUNTER]}"
  echo "$AVGHTAR"
  AVGHSI=0
  AVGHTAR=0
  INTCOUNTER=0
  I=0
  COUNTER=$(echo "$COUNTER" + 1 | bc)
done
clean
echo "HSI of 1TB.dat on Titan Login Node"
I=$(calcHSI 1.TB.dat)
echo "Test 1 for 1TB.dat with HSI" >> "$TIMEFILE"
echo "$I" >> "$TIMEFILE"
echo "$I"
I=$( htar -cvf file.tar 1TB.dat | grep -Po "(?<=time: ).*(?= seconds)" )
echo "Test 1 for 1TB.dat with HTAR" >> "$TIMEFILE"
echo "$I" >> "$TIMEFILE"
echo "$I"

clean

echo "Logging into DTN: "
ssh dtn "bash -s" << 'ENDSSH'
cd /lustre/atlas/scratch/wyn/stf007/dataTiming
./remoteTime.sh
ENDSSH

clean 

echo "Running small file batch tests from titan login node"
JOBNUM=$(qsub -q dtn hpss.pbs)
until [[ -f "dataTransferTimings.o$JOBNUM" ]] ;
  do
    sleep 2s
  done
echo "BATCH DATA" >> "$TIMEFILE"
cat "dataTransferTimings.o$JOBNUM" >> "$TIMEFILE"
