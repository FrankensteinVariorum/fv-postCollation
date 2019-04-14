#!/bin/bash
# 2019-04-14 ebb: A shell script to separate msColl constructed edition files from other output edition files in the Frankenstein Variorum. 

# First, delete previous directories made by running this script. Then, copy all of P5-output into P5-print.
rm -R P5-print  
rm -R P5-MS
cp -R P5-output P5-print

# Then, find and move msColl files out into their own directory, named P5-MS, and remove P5 prefix from MS edition filenames.

STRING="fMS"
mkdir P5-MS
for i in P5-print/P5-$STRING*.xml
do   
  mv $i P5-MS/${i##*/P5-}
done

# Remove P5 prefix from files in P5-print directory
for i in P5-print/*.xml
do
  mv $i P5-print/${i##*/P5-}
done 

# Copy separate directories to fv-data repo
cp -R P5-print/*.xml ../../fv-data/variorum-chunks
cp -R P5-MS/*.xml ../../fv-data/reseqMS-chunks