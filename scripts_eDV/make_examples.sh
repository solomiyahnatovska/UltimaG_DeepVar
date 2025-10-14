#!/bin/bash

while getopts ":i:c:d:o:" flag; do
 case $flag in
  i) # bed directory flag
  beddir=$OPTARG
  ;;
  c)
  cram_file=$OPTARG
  ;;
  d)
  cram_index=$OPTARG
  ;;
  o)
  examplesdir=$OPTARG
  ;;
 esac
done

cd $SCRATCH
module load StdEnv/2023
module load apptainer/1.3.5

mkdir -p $examplesdir
cd $beddir

for bedfile in temp_000{1..3}_of_40.bed ; do
	{
		echo "Processing $bedfile..."
		apptainer run -e -B $SCRATCH -W $SCRATCH $SCRATCH/docker_images_eDV/deepvariant_make_examples.sif tool \
		  --input $cram_file \
		  --cram-index $cram_index \
		  --bed $bedfile \
		  --output $examplesdir/$bedfile.out \
		  --reference /home/hnatovs1/scratch/test_data/Homo_sapiens_assembly38.fasta \
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
		echo "Completed $bedfile"
	}
done




