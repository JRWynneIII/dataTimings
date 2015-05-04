#!/bin/bash
COUNTER=0
STRIPENUM=$1
for f in *.dat
do
  echo $f
  lfs setstripe -c $STRIPENUM $f.2
  cp $f $f.2
  rm $f
  mv $f.2 $f
done
