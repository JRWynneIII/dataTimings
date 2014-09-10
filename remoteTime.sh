#!/bin/bash
export TIMEFORMAT='%3R'
TIMEFILE="time.log"
cd $HOME/dataTiming
export PATH=/sw/cave/tmux/1.7/centos5.8_gnu4.1.2/bin:/sw/cave/zsh/5.0.0/centos5.8_gnu4.1.2/bin:/usr/lib64/qt-3.3/bin:/usr/lib64/openmpi/bin:/sw/redhat6/lustredu/1.4/rhel6.5_gnu4.7.1/install/bin:/sw/home/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/public/bin
pwd
echo "Running small file tests on DTN"
echo "HSI on DTN:"
echo "HSI on DTN 1GB file: " >> $TIMEFILE
{ time $(hsi put smallFile.dat 2> /dev/null) ; } >>  $TIMEFILE 2>&1
echo "HTAR on DTN Node"
echo "HTAR putting 1GB tarred file on HPSS from DTN: " >> $TIMEFILE
{ time htar -cvf small.tar smallFile.dat >> /dev/null ; } >> $TIMEFILE 2>&1

#Run Large file tests on DTN

