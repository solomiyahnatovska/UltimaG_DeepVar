#!/bin/bash

while getopts ":i:o:" flag; do
 case $flag in
  o) # output directory flag (name of directory with bedfiles)
  beddir=$OPTARG
  ;;
  i) # interval list flag
  interval_list=$OPTARG
  ;;
 esac
done

cd $SCRATCH
module load StdEnv/2023
module load java/21.0.1
#module load NiaEnv
mkdir interval_list_out &&\
java -jar $SCRATCH/tools/picard/picard.jar IntervalListTools \
  SCATTER_COUNT=40 \
  SUBDIVISION_MODE=BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW \
  UNIQUE=true \
  SORT=true \
  BREAK_BANDS_AT_MULTIPLES_OF=100000 \
  INPUT=$interval_list \
  OUTPUT=interval_list_out

mkdir $beddir

cd interval_list_out
for file in * ; do 
	cd $file
	cat *.interval_list | grep -v @ | awk 'BEGIN{OFS="\t"}{print $1,$2-1,$3}' > $beddir/${file}.bed
	cd ..
done





