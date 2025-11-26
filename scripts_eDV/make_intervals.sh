#!/bin/bash

while getopts ":i:o:" flag; do
 case $flag in
  o) # output directory flag (name of directory with bedfiles)
  outdir=$OPTARG
  ;;
  i) 
  interval_list=$OPTARG
  ;;
 esac
done

cd $SCRATCH
module load StdEnv/2023
module load java/21.0.1
#module load NiaEnv
mkdir -p $SCRATCH/Ultima_deepvariant/intermediate_data_dir/interval_list_out
java -jar $SCRATCH/Ultima_deepvariant/tools/picard/picard.jar IntervalListTools \
  SCATTER_COUNT=40 \
  SUBDIVISION_MODE=BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW \
  UNIQUE=true \
  SORT=true \
  BREAK_BANDS_AT_MULTIPLES_OF=100000 \
  INPUT=$interval_list \
  OUTPUT=interval_list_out

mkdir -p "$outdir"

for dir in interval_list_out/*/ ; do 
  dirname=$(basename "$dir")
  cat ${dir}scattered.interval_list | grep -v @ | awk 'BEGIN{OFS="\t"}{print $1,$2-1,$3}' > "$outdir/${dirname}.bed"
done





