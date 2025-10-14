#!/bin/bash

#SBATCH --gpus=a100_4g.20gb:1
#SBATCH --time=1:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=2
#SBATCH --job-name efficient_DV_ultimaG_call_variants
#SBATCH --output=efficient_DV_ultimaG_call_variants.txt
#SBATCH --mail-type=FAIL

cd $SCRATCH

module load apptainer/1.3.5

mkdir -p call_variants_output

apptainer run --nv -e -B $SCRATCH -W $SCRATCH/call_variants_output $SCRATCH/docker_images_eDV/deepvariant_call_variants.sif call_variants --param /home/hnatovs1/scratch/scripts_eDV/call_variants.ini
