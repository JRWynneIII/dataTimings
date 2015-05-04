#!/bin/bash
HELPTEXT="Usage: ./makefiles.sh [size of individual files] [number of files]  [OPTIONAL: source. Defaults to /dev/zero] [OPTIONAL: name]
Ex: ./makefiles.sh 10M 10"
if [[ $1 =~ "help" ]] ; then
  echo $HELPTEXT
  exit
fi
FILESIZE=$1
NUMOFFILES=$2
if [[ $3 =~ "/dev/"* ]] ; then
  SOURCE=${3-/dev/zero}
  NAME=$4
else
  SOURCE=/dev/zero
  NAME=$3
fi

I=0

if [[ ! -z $NAME ]] ; then
  if [[ ${FILESIZE} =~ "G" ]] ; then
    echo "DD'ing $NAME ($FILESIZE)"
    COUNTSIZE=${FILESIZE%%G}
    COUNTSIZE=$(echo "$COUNTSIZE * 1024" | bc)
    echo $COUNTSIZE
    dd if=$SOURCE of=$NAME bs=1M count=$COUNTSIZE
  else
    echo "DD'ing $NAME ($FILESIZE)"
    dd if=$SOURCE of=$NAME bs=$FILESIZE count=1
  fi
else
  while [ $I -lt $NUMOFFILES ] ; do
    if [[ ${FILESIZE} =~ "G" ]] ; then
      echo "DD'ing $I ($FILESIZE)"
      COUNTSIZE=${FILESIZE%%G}
      COUNTSIZE=$(echo "$COUNTSIZE * 1024" | bc)
      echo $COUNTSIZE
      dd if=$SOURCE of=$I bs=1M count=$COUNTSIZE
    else
      echo "DD'ing $I.dat ($FILESIZE)"
      dd if=$SOURCE of=$I bs=$FILESIZE count=1
    fi
    I=$(echo $I + 1 | bc)
  done
fi
