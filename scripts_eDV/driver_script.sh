#!/bin/bash
#SBATCH --time=0-12:00
#SBATCH --job-name efficient_DV_UG_driverScript
#SBATCH --output=efficient_DV_UG_driverScript.out
#SBATCH --mail-type=FAIL
#
#
# submit_pipeline.sh

echo "Submitting DeepVariant pipeline: Examples -> Variants -> Postprocess"

# Submit make_examples and capture job ID
JOB1=$(sbatch --parsable efficientDV.make_examples.sh)
echo "Submitted make_examples: Job ID $JOB1"

# Submit call_variants to run after make_examples completes
JOB2=$(sbatch --parsable --dependency=afterok:$JOB1 efficientDV.call_variants.sh)
echo "Submitted call_variants: Job ID $JOB2 (depends on $JOB1)"

# Submit post_processing to run after call_variants completes  
JOB3=$(sbatch --parsable --dependency=afterok:$JOB2 efficientDV.post_processing.sh)
echo "Submitted post_processing: Job ID $JOB3 (depends on $JOB2)"
