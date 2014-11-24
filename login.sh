#!/bin/bash

export TIMEFORMAT='%10R'
DATE=$(date +%s)
SUFFIX="login.log"
TIMEFILE="time/$DATE$SUFFIX"
touch $TIMEFILE
SMALLFILE="smallFile.dat"
MEDFILE="midFile.dat"
BIGFILE="biggerfile.dat"
HTARBIG="htardir"
TBFILE="1TB.dat"
AVGHSI=0
AVGHTAR=0
declare -a files=($SMALLFILE $MEDFILE $BIGFILE $TBFILE)
declare -a htarfiles=($SMALLFILE $MEDFILE $HTARBIG $TBFILE)
COUNTER=0
INTCOUNTER=0
rm -f *.log
touch time.log
echo $TIMEFILE

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
  KBS=$(echo $I | grep -Po "(?<=bytes, ).*(?= KBS)")
  BYTES=$(echo $I | grep -Po "(?<=/${files[$1]}' \( ).*(?= bytes)")
  KBYTES=$(echo $BYTES / 1000 | bc -l)
  HSITIME=$(echo $KBYTES / $(echo $KBS) | bc -l)
  echo $HSITIME
}

echo "Running  tests:"
while [ $COUNTER -lt 10 ] ; do
  while [ $INTCOUNTER -lt 10 ] ; do
    clean
    echo "HSI ${files[$COUNTER]} on Titan Login Node"
    I=$(calcHSI $COUNTER)
    echo "Test $INTCOUNTER for ${files[$COUNTER]} With HSI" >> $TIMEFILE
    echo $I >> $TIMEFILE
    hsi rm ${files[$COUNTER]} 2> /dev/null
    AVGHSI=$(echo $AVGHSI + $I | bc)
    clean
    echo "HTAR ${htarfiles[$COUNTER]} on Titan Login Node"
    I=$( htar -cvf file.tar ${htarfiles[$COUNTER]} | grep -Po "(?<=time: ).*(?= seconds)" )
    echo "Test $INTCOUNTER for ${htarfiles[$COUNTER]} With HTAR" >> $TIMEFILE
    echo $I >> $TIMEFILE
    AVGHTAR=$(echo $AVGHTAR + $I | bc)
    #Average the time for this cycle
    INTCOUNTER=$(echo $INTCOUNTER + 1 | bc)
  done
  
  AVGHSI=$(echo $AVGHSI / 10 | bc -l)
  AVGHTAR=$(echo $AVGHTAR / 10 |bc -l)
  echo "Average HSI time for ${files[$COUNTER]} after 10 iterations:" >> $TIMEFILE
  echo $AVGHSI >> $TIMEFILE
  echo "Average HSI for ${files[$COUNTER]}"
  echo $AVGHSI
  echo "Average HTAR time for ${htarfiles[$COUNTER]} after 10 iterations:" >> $TIMEFILE
  echo $AVGHTAR >> $TIMEFILE
  echo "Average HTAR for ${htarfiles[$COUNTER]}"
  echo $AVGHTAR
  AVGHSI=0
  AVGHTAR=0
  INTCOUNTER=0
  I=0
  COUNTER=$(echo $COUNTER + 1 | bc)
done
clean
for COUNTER in {0..9}; do
  echo "HSI test $COUNTER of 1TB.dat on Titan Login Node"
  I=$(calcHSI 3)
  echo "Test $COUNTER for 1TB.dat with HSI" >> $TIMEFILE
  echo $I >> $TIMEFILE
  echo $I
  clean
done
