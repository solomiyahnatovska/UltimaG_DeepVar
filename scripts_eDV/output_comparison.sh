#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=40
#SBATCH --time=0-01:00
#SBATCH --job-name efficient_DV_UG_compare
#SBATCH --output=efficient_DV_UG_compare.txt
#SBATCH --mail-type=FAIL


module load bcftools/1.22
module load apptainer/1.3.5

cd /home/hnatovs1/scratch/

# get the number of variants in my vcf and their vcf:
echo "Their variants:"
bcftools view -H /home/hnatovs1/scratch/test_data/sample.vcf.gz | wc -l
echo "Your variants:"  
bcftools view -H /home/hnatovs1/scratch/postprocess_output/postprocess_output.vcf.gz | wc -l

export HG19=/home/hnatovs1/scratch/test_data/Homo_sapiens_assembly38.fasta

mkdir -p output_compare_outfiles

#Benchmark SNVs -script from Navneet
apptainer run -B $SCRATCH -W $SCRATCH /scratch/hnatovs1/docker_images_eDV/hap.py.sif \
	/opt/hap.py/bin/hap.py  /home/hnatovs1/scratch/postprocess_output/postprocess_output.vcf.gz /home/hnatovs1/scratch/test_data/sample.vcf.gz \
		-r /home/hnatovs1/scratch/test_data/Homo_sapiens_assembly38.fasta \
		-o output_compare_outfiles/benchmark_

