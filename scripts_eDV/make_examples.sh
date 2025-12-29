#!/bin/bash

while getopts ":i:c:d:o:" flag; do
 case $flag in
  i) 
  BEDFILE=$OPTARG
  ;;
  c)
  CRAM_FILE=$OPTARG
  ;;
  d)
  CRAM_INDEX=$OPTARG
  ;;
  o)
  OUTPUT=$OPTARG
  ;;
 esac
done

module load StdEnv/2023
module load apptainer/1.3.5

cd $SCRATCH/Ultima_deepvariant

# Create output directory if it doesn't exist
mkdir -p $(dirname $OUTPUT)

OUTPUT_no_suffix="${OUTPUT%.tfrecord.gz}"

REFERENCE=$SCRATCH/Ultima_deepvariant/test_data/Homo_sapiens_assembly38.fasta

echo "Processing $BEDFILE..."

apptainer run -e -B $SCRATCH -W $SCRATCH docker_images_eDV/deepvariant_make_examples.sif tool \
  --input $CRAM_FILE \
  --cram-index $CRAM_INDEX \
  --bed $BEDFILE \
  --output $OUTPUT_no_suffix \
  --reference $REFERENCE \
  --min-base-quality 5 \
  --min-mapq 5 \
  --cgp-min-count-snps 2 \
  --cgp-min-count-hmer-indels 2 \
  --cgp-min-count-non-hmer-indels 2 \
  --cgp-min-fraction-snps 0.12 \
  --cgp-min-fraction-hmer-indels 0.12 \
  --cgp-min-fraction-non-hmer-indels 0.06 \
  --cgp-min-mapping-quality 5 \
  --max-reads-per-region 1500 \
  --assembly-min-base-quality 0 \
  --optimal-coverages 50 \
  --add-ins-size-channel

echo "Completed $BEDFILE"