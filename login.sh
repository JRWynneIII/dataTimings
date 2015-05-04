#!/bin/bash

export TIMEFORMAT='%10R'
DATE=$(date +%s)
SUFFIX="login.log"
TIMEFILE="time/$DATE$SUFFIX"
touch $TIMEFILE
XSMALL="xsmall"
SMALL="small"
MEDIUM="medium"
LARGE="large"
XLARGE="xlarge"
XXLARGE="xxlarge"
AVGHSI=0
AVGHTAR=0

declare -a files=($XSMALL $SMALL $MEDIUM $LARGE $XLARGE $XXLARGE)
declare -a htarfiles=("htar/xsmall" "htar/small" "htar/medium" "htar/large" "htar/xlarge" "htar/xxlarge")

COUNTER=0
INTCOUNTER=0
rm -f *.log
touch time.log
echo $TIMEFILE

function calcHSI {
  I=$(hsi put ${files[$1]} 2>&1)
  KBS=$(echo $I | grep -Po "(?<=bytes, ).*(?= KBS)")
  BYTES=$(echo $I | grep -Po "(?<=/${files[$1]}' \( ).*(?= bytes)")
  KBYTES=$(echo $BYTES / 1000 | bc -l)
  HSITIME=$(echo $KBYTES / $(echo $KBS) | bc -l)
  echo $HSITIME
}

if [ "$#" -eq 0 ]; then
  declare -a HSI=("${files[@]}")
  declare -a HTAR=("${htarfiles[@]}")
else
  HSI=( "$@" )
  HTAR=( "${@/#/htar/}" )
fi

echo ${#HTAR[@]}

echo "Running  tests:"
while [ $COUNTER -lt ${#HSI[@]} ] ; do
    while [ $INTCOUNTER -lt 10 ] ; do
      echo "HSI ${HSI[$COUNTER]} on Titan Login Node"
      I=$(calcHSI $COUNTER)
      echo "Test $INTCOUNTER for ${HSI[$COUNTER]} With HSI" >> $TIMEFILE
      echo $I >> $TIMEFILE
      hsi rm ${HSI[$COUNTER]} 2> /dev/null
      AVGHSI=$(echo $AVGHSI + $I | bc)
      echo "HTAR ${HTAR[$COUNTER]} on Titan Login Node"
      I=$( htar -cvf file.tar ${HTAR[$COUNTER]} | grep -Po "(?<=time: ).*(?= seconds \()" )
      echo "Test $INTCOUNTER for ${HTAR[$COUNTER]} With HTAR" >> $TIMEFILE
      echo $I >> $TIMEFILE
      AVGHTAR=$(echo $AVGHTAR + $I | bc)
      #Average the time for this cycle
      INTCOUNTER=$(echo $INTCOUNTER + 1 | bc)
    done
  AVGHSI=$(echo $AVGHSI / 10 | bc -l)
  AVGHTAR=$(echo $AVGHTAR / 10 |bc -l)
  echo "Average HSI time for ${HSI[$COUNTER]} after 10 iterations:" >> $TIMEFILE
  echo $AVGHSI >> $TIMEFILE
  echo "Average HSI for ${HSI[$COUNTER]}"
  echo $AVGHSI
  echo "Average HTAR time for ${HTAR[$COUNTER]} after 10 iterations:" >> $TIMEFILE
  echo $AVGHTAR >> $TIMEFILE
  echo "Average HTAR for ${HTAR[$COUNTER]}"
  echo $AVGHTAR
  AVGHSI=0
  AVGHTAR=0
  INTCOUNTER=0
  I=0
  COUNTER=$(echo $COUNTER + 1 | bc)
done
