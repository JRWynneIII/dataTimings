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
cd $HOME/dataTiming
export PATH=/sw/cave/tmux/1.7/centos5.8_gnu4.1.2/bin:/sw/cave/zsh/5.0.0/centos5.8_gnu4.1.2/bin:/usr/lib64/qt-3.3/bin:/usr/lib64/openmpi/bin:/sw/redhat6/lustredu/1.4/rhel6.5_gnu4.7.1/install/bin:/sw/home/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/public/bin
echo "Running small file tests on DTN"
while [ $COUNTER -lt 3 ] ; do
  while [ $INTCOUNTER -lt 3 ] ; do
    echo "HSI ${files[$COUNTER]} on DTN"
    I=$( { time $(hsi put ${files[$COUNTER]} 2> /dev/null); } 2>&1 )
    AVGHSI=$(echo $AVGHSI + $I | bc)
    echo "HTAR ${files[$COUNTER]} on DTN"
    I=$( { time htar -cvf small.tar ${files[$COUNTER]} >> /dev/null; } 2>&1 )
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
