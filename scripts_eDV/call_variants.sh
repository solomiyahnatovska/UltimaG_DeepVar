#!/bin/bash

while getopts ":c:" flag; do
 case $flag in
  c) 
  CONFIG=$OPTARG
  ;;
 esac
done

cd $SCRATCH

module load StdEnv/2023
module load apptainer/1.3.5

mkdir -p call_variants_output

apptainer run --nv -e -B $SCRATCH -W $SCRATCH Ultima_deepvariant/docker_images_eDV/deepvariant_call_variants.sif call_variants --param $CONFIG
