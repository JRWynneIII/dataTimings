#!/bin/bash
export TIMEFORMAT='%3R'
DATE=$(date +%s)
SMALLFILE="/lustre/atlas/scratch/wyn/stf007/dataTiming/smallFile.dat"
MEDFILE="/lustre/atlas/scratch/wyn/stf007/dataTiming/midFile.dat"
BIGFILE="/lustre/atlas/scratch/wyn/stf007/dataTiming/biggerfile.dat"
SUFFIX="dtn.log"
TIMEFILE="/lustre/atlas/scratch/wyn/stf007/dataTiming/time/$DATE$SUFFIX"
touch $TIMEFILE
AVGHSI=0
AVGHTAR=0
I=0
declare -a files=($SMALLFILE $MEDFILE $BIGFILE)
COUNTER=0
INTCOUNTER=0
cd $HOME/dataTiming
export PATH=/sw/cave/tmux/1.7/centos5.8_gnu4.1.2/bin:/sw/cave/zsh/5.0.0/centos5.8_gnu4.1.2/bin:/usr/lib64/qt-3.3/bin:/usr/lib64/openmpi/bin:/sw/redhat6/lustredu/1.4/rhel6.5_gnu4.7.1/install/bin:/sw/home/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/public/bin

function clean {
  hsi rm smallFile.dat 2> /dev/null
  hsi rm midFile.dat 2> /dev/null
  hsi rm biggerFile.dat 2> /dev/null
  hsi rm file.tar 2> /dev/null
  hsi rm 1TB.dat 2> /dev/null
  hsi rm file.tar.idx 2> /dev/null
}

echo "Running file tests on DTN"
while [ $COUNTER -lt 3 ] ; do
  while [ $INTCOUNTER -lt 3 ] ; do
    clean
    echo "HSI ${files[$COUNTER]} on DTN"
    I=$( { time $(hsi put ${files[$COUNTER]} 2> /dev/null); } 2>&1 )
    echo "Test $INTCOUNTER for ${files[$COUNTER]} With HSI on DTN" >> $TIMEFILE
    echo $I >> $TIMEFILE
    AVGHSI=$(echo $AVGHSI + $I | bc)
    clean
    echo "HTAR ${files[$COUNTER]} on DTN"
    I=$( { time htar -cvf file.tar ${files[$COUNTER]} >> /dev/null; } 2>&1 )
    echo "Test $INTCOUNTER for ${files[$COUNTER]} With HTAR on DTN" >> $TIMEFILE
    echo $I >> $TIMEFILE
    AVGHTAR=$(echo $AVGHTAR + $I | bc)
    #Average the time for this cycle
    INTCOUNTER=$(echo $INTCOUNTER + 1 | bc)
  done

  AVGHSI=$(echo $AVGHSI / 3 | bc -l)
  AVGHTAR=$(echo $AVGHTAR / 3 |bc -l)
  echo "Average HSI time from DTN for ${files[$COUNTER]} after 3 iterations:" >> $TIMEFILE
  echo $AVGHSI >> $TIMEFILE
  echo "Average HSI for ${files[$COUNTER]} from DTN"
  echo $AVGHSI
  echo "Average HTAR time from DTN for ${files[$COUNTER]} after 3 iterations:" >> $TIMEFILE
  echo $AVGHTAR >> $TIMEFILE
  echo "Average HTAR for ${files[$COUNTER]} from DTN"
  echo $AVGHTAR
  AVGHSI=0
  AVGHTAR=0
  INTCOUNTER=0
  I=0
  COUNTER=$(echo $COUNTER + 1 | bc)
done
clean
echo "HSI of 1TB.dat on Titan Login Node"
I=$( { time $(hsi put /lustre/atlas/scratch/wyn/stf007/dataTiming/1TB.dat 2> /dev/null); } 2>&1 )
echo "Test 1 for 1TB.dat with HSI" >> $TIMEFILE
echo $I >> $TIMEFILE
echo $I
I=$( { time $(htar -cVf file.tar /lustre/atlas/scratch/wyn/stf007/dataTiming/1TB.dat 2> /dev/null); } 2>&1 )
echo "Test 1 for 1TB.dat with HTAR" >> $TIMEFILE
echo $I >> $TIMEFILE
echo $I
