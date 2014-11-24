#!/bin/bash
export TIMEFORMAT='%10R'
DATE=$(date +%s)
SMALLFILE="smallFile.dat"
MEDFILE="midFile.dat"
BIGFILE="biggerfile.dat"
HTARBIG="htardir"
#SMALLFILE="/lustre/atlas/scratch/wyn/stf007/dataTiming/smallFile.dat"
#MEDFILE="/lustre/atlas/scratch/wyn/stf007/dataTiming/midFile.dat"
#BIGFILE="/lustre/atlas/scratch/wyn/stf007/dataTiming/biggerfile.dat"
SUFFIX="dtn.log"
TIMEFILE="/lustre/atlas/scratch/wyn/stf007/dataTiming/time/$DATE$SUFFIX"
touch "$TIMEFILE"
AVGHSI=0
AVGHTAR=0
I=0
#TBFILE="/lustre/atlas/scratch/wyn/stf007/dataTiming/1TB.dat"
TBFILE="1TB.dat"
declare -a files=($SMALLFILE $MEDFILE $BIGFILE $TBFILE)
declare -a htarfiles=($SMALLFILE $MEDFILE $HTARBIG $TBFILE)
COUNTER=0
INTCOUNTER=0
cd "$MEMBERWORK"/stf007/dataTiming
export PATH=/sw/cave/tmux/1.7/centos5.8_gnu4.1.2/bin:/sw/cave/zsh/5.0.0/centos5.8_gnu4.1.2/bin:/usr/lib64/qt-10.3/bin:/usr/lib64/openmpi/bin:/sw/redhat6/lustredu/1.4/rhel6.5_gnu4.7.1/install/bin:/sw/home/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/public/bin

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

echo "Running file tests on DTN"
while [ $COUNTER -lt 10 ] ; do
  while [ $INTCOUNTER -lt 10 ] ; do
    clean
    echo "HSI ${files[$COUNTER]} on DTN"
    I=$(calcHSI $COUNTER)
    echo "Test $INTCOUNTER for ${files[$COUNTER]} With HSI on DTN" >> $TIMEFILE
    echo $I >> $TIMEFILE
    AVGHSI=$(echo $AVGHSI + $I | bc)
    clean
    echo "HTAR ${htarfiles[$COUNTER]} on DTN"
    I=$(htar -cvf file.tar ${htarfiles[$COUNTER]} | grep -Po "(?<=Transfer time:).*(?=seconds \()")
    echo "Test $INTCOUNTER for ${htarfiles[$COUNTER]} With HTAR on DTN" >> $TIMEFILE
    echo $I >> $TIMEFILE
    AVGHTAR=$(echo $AVGHTAR + $I | bc)
    #Average the time for this cycle
    INTCOUNTER=$(echo $INTCOUNTER + 1 | bc)
  done

  AVGHSI=$(echo $AVGHSI / 10 | bc -l)
  AVGHTAR=$(echo $AVGHTAR / 10 |bc -l)
  echo "Average HSI time from DTN for ${files[$COUNTER]} after 10 iterations:" >> $TIMEFILE
  echo $AVGHSI >> $TIMEFILE
  echo "Average HSI for ${files[$COUNTER]} from DTN"
  echo $AVGHSI
  echo "Average HTAR time from DTN for ${htarfiles[$COUNTER]} after 10 iterations:" >> $TIMEFILE
  echo $AVGHTAR >> $TIMEFILE
  echo "Average HTAR for ${htarfiles[$COUNTER]} from DTN"
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
done
