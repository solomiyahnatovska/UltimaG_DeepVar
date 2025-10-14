#!/bin/bash


#SBATCH --time=1:00:00
#SBATCH --mem=100G
#SBATCH --cpus-per-task=1
#SBATCH --job-name efficient_DV_ultimaG_call_variants
#SBATCH --output=efficient_DV_ultimaG_call_variants.txt
#SBATCH --mail-type=FAIL

##post_process requires 8 GB of memory and runs on a single thread.
cd $SCRATCH

module load apptainer/1.3.5

mkdir -p postprocess_output

apptainer run --cleanenv -e -B $SCRATCH -W $SCRATCH/postprocess_output $SCRATCH/docker_images_eDV/deepvariant_make_examples.sif ug_postproc \
  --infile /home/hnatovs1/scratch/call_variants_output/call_variants.1.gz \
  --ref /home/hnatovs1/scratch/test_data/Homo_sapiens_assembly38.fasta \
  --outfile /home/hnatovs1/scratch/postprocess_output/postprocess_output.vcf.gz \
  --consider_strand_bias \
  --flow_order TGCA \
  --qual_filter 1 
#  --annotate \
#  --bed_annotation_files exome.twist.bed,ug_hcr.bed,... \
#  --filter \
#  --filters_file filters.txt \
#  --dbsnp Homo_sapiens_assembly38.dbsnp138.vcf
