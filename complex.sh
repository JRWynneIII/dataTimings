#!/bin/bash

export TIMEFORMAT='%10R'
DATE=$(date +%s)
SUFFIX="login.log"
TIMEFILE="/lustre/atlas/scratch/wyn/stf007/dataTiming/time/$DATE$SUFFIX"
touch $TIMEFILE
SMALLFILE="1f"
MEDFILE="2f"
BIGFILE="3f"
AVGHSI=0
AVGHTAR=0
declare -a files=($SMALLFILE $MEDFILE $BIGFILE)
COUNTER=0
INTCOUNTER=0
SUBNUM=1
rm -f *.log
touch /lustre/atlas/scratch/wyn/stf007/dataTimingi/time.log
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
  I=$(hsi put -R $1 2>&1)
  KBS=$(echo $I | grep -Po "(?<=bytes, ).*(?= KBS)")
  BYTES=$(echo $I | grep -Po "(?<=/$1' \( ).*(?= bytes)")
  KBYTES=$(echo $BYTES / 1000 | bc -l)
  HSITIME=$(echo $KBYTES / $(echo $KBS) | bc -l)
  echo $HSITIME
}

cd makedir
echo "Running  tests:"
while [ $COUNTER -lt 3 ] ; do
  cd ${files[$COUNTER]}
  while [ $INTCOUNTER -lt 10 ] ; do
    I=$(calcHSI "${files[$COUNTER]}$INTCOUNTER") 
    echo "Test $INTCOUNTER for ${files[$COUNTER]} With HSI" >> $TIMEFILE
    echo $I >> $TIMEFILE
    echo $I
    AVGHSI=$(echo $AVGHSI + $I | bc)
    I=$( htar -cvf file.tar "${files[$COUNTER]}$INTCOUNTER" | grep -Po "(?<=time: ).*(?= seconds \()" )
    echo "HTAR ${htarfiles[$COUNTER]} on Titan Login Node"
    echo "Test $INTCOUNTER for ${htarfiles[$COUNTER]} With HTAR" >> $TIMEFILE
    echo $I >> $TIMEFILE
    AVGHTAR=$(echo $AVGHTAR + $I | bc)
    #Average the time for this cycle
    INTCOUNTER=$(echo $INTCOUNTER + 1 | bc)
    cd ..
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
