#!/bin/bash
#SBATCH --job-name=snakemake_controller
#SBATCH --output=snakemake_controller_%j.out
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
mkdir slurmlogs


# module load StdEnv/2023 python/3.11

# # Create virtual environment
# virtualenv ~/snakemake_env

# # Activate it
# source ~/snakemake_env/bin/activate

# # Install from wheel
# pip install --no-index snakemake

# # Verify
# snakemake --version
# #8.20.6
#
#[hnatovs1@narval2 Ultima_deepvariant]$ snakemake --version
#[mii] Please select a module to run snakemake:
#       MODULE                 PARENT(S)
#    1  metagenome-atlas/2.5.0 StdEnv/2020 intel/2020.1.217
#    2  metagenome-atlas/2.4.3 StdEnv/2020 intel/2020.1.217

module load StdEnv/2020  
module load intel/2020.1.217
module load metagenome-atlas/2.5.0

  snakemake \
  --cluster "sbatch -J {cluster.job_name} -o {cluster.output} -N {cluster.nodes} -n {cluster.ntasks} -t {cluster.time_min} --mem={cluster.mem_mb} --gpus={cluster.gpus}" \
  --cluster-config /home/hnatovs1/scratch/Ultima_deepvariant/cluster.yaml \
  --jobs 40 \
  --latency-wait 60