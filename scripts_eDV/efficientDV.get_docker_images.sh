#!/bin/bash 
#SBATCH --nodes=2
#SBATCH --ntasks=80
#SBATCH --time=0-00:30
#SBATCH --job-name efficient_DV_ultimaG
#SBATCH --output=efficient_DV_ultimaG_output.txt
#SBATCH --mail-type=FAIL
 
cd $SLURM_SUBMIT_DIR
 
module load apptainer/1.2.2

# pull docker images for `make_examples` and `call_variants` steps
apptainer pull deepvariant_make_examples.sif docker://ultimagenomics/make_examples:3.1.3
apptainer pull deepvariant_call_variants.sif docker://ultimagenomics/call_variants:2.2.2


