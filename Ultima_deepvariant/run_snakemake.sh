#!/bin/bash
#SBATCH --job-name=snakemake_controller
#SBATCH --output=snakemake_controller_%j.out
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G


module load StdEnv/2023

  snakemake \
  --cluster "sbatch -J {cluster.job_name} -o {cluster.output} -N {cluster.nodes} -n {cluster.ntasks} -t {cluster.time_min} --mem={cluster.mem_mb} --gpus={cluster.gpus}" \
  --cluster-config /home/hnatovs1/scratch/Ultima_deepvariant/cluster.yaml \
  --jobs 2 \
  --latency-wait 60