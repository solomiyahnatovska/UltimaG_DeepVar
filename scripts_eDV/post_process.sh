#!/bin/bash
while getopts ":i:" flag; do
 case $flag in
  i) 
  CALL_VAR_OUTPUT=$OPTARG
  ;;
 esac
done


##post_process requires 8 GB of memory and runs on a single thread.
cd $SCRATCH

module load apptainer/1.2.4
mkdir -p postprocess_output

echo "$CALL_VAR_OUTPUT"
CALL_VAR_OUTPUT_list=$(echo "$CALL_VAR_OUTPUT" | tr ' ' ',')
echo "$CALL_VAR_OUTPUT_list"

apptainer run  --nv -e -B $SCRATCH -W $SCRATCH/Ultima_deepvariant/postprocess_output $SCRATCH/Ultima_deepvariant/docker_images_eDV/deepvariant_make_examples.sif ug_postproc \
  --infile "$CALL_VAR_OUTPUT_list" \
  --ref /home/hnatovs1/scratch/Ultima_deepvariant/test_data/Homo_sapiens_assembly38.fasta \
  --outfile /home/hnatovs1/scratch/Ultima_deepvariant/postprocess_output/postprocess_output.vcf.gz \
  --consider_strand_bias \
  --flow_order TGCA \
  --qual_filter 1 