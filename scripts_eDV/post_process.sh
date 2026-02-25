#!/bin/bash
while getopts ":i:o:" flag; do
 case $flag in
  i) 
  CALL_VAR_OUTPUT=$OPTARG
  ;;
  o)
  POST_PROCESS_OUTPUT=$OPTARG
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

## filters file for the Walkthrough-recommended cutoffs (also change the output location in the Snakefile)

# apptainer run  --nv -e -B $SCRATCH -W $SCRATCH/Ultima_deepvariant/postprocess_output $SCRATCH/Ultima_deepvariant/docker_images_eDV/deepvariant_make_examples.sif ug_postproc \
#   --infile "$CALL_VAR_OUTPUT_list" \
#   --ref /home/hnatovs1/scratch/Ultima_deepvariant/test_data/Homo_sapiens_assembly38.fasta \
#   --outfile "$POST_PROCESS_OUTPUT" \
#   --consider_strand_bias \
#   --flow_order TGCA \
#   --annotate \
#   --bed_annotation_files /home/hnatovs1/scratch/Ultima_deepvariant/test_data/filtering_annotations/exome_simple_sorted.bed \
#   --qual_filter 1 \
#   --filter \
#   --filters_file /home/hnatovs1/scratch/Ultima_deepvariant/test_data/filtering_annotations/filters_walkthrough_cutoffs.txt \
#   --dbsnp /home/hnatovs1/scratch/Ultima_deepvariant/test_data/filtering_annotations/Homo_sapiens_assembly38.dbsnp138.vcf


## filters file for the WDL-recommended cutoffs (also change the output location in the Snakefile)
apptainer run  --nv -e -B $SCRATCH -W $SCRATCH/Ultima_deepvariant/postprocess_output $SCRATCH/Ultima_deepvariant/docker_images_eDV/deepvariant_make_examples.sif ug_postproc \
  --infile "$CALL_VAR_OUTPUT_list" \
  --ref /home/hnatovs1/scratch/Ultima_deepvariant/test_data/Homo_sapiens_assembly38.fasta \
  --outfile "$POST_PROCESS_OUTPUT" \
  --consider_strand_bias \
  --flow_order TGCA \
  --annotate \
  --bed_annotation_files /home/hnatovs1/scratch/Ultima_deepvariant/test_data/filtering_annotations/exome_simple_sorted.bed \
  --qual_filter 1 \
  --filter \
  --filters_file /home/hnatovs1/scratch/Ultima_deepvariant/test_data/filtering_annotations/filters_wdl_cutoffs.txt \
  --dbsnp /home/hnatovs1/scratch/Ultima_deepvariant/test_data/filtering_annotations/Homo_sapiens_assembly38.dbsnp138.vcf


