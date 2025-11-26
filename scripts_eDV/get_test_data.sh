#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=40
#SBATCH --time=0-02:00
#SBATCH --job-name efficient_DV_ultimaG
#SBATCH --output=efficient_DV_ultimaG_output.txt
#SBATCH --mail-type=FAIL

#cd $HOME/efficient_DV_UltimaGenomics
#mkdir test_data
cd $SCRATCH/test_data

module load apptainer/1.2.2
module load awscli/2.13.19

#
#apptainer exec docker://google/cloud-sdk:latest \
#	gsutil cp \
#		gs://gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.fasta \
#		gs://gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.fasta.fai \
#		gs://gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dict \
#		gs://gcp-public-data--broad-references/hg38/v0/wgs_calling_regions.hg38.interval_list \
#		./
#
## this file is private so I couldnt download it
##aws s3 cp s3://ultimagen-workflow-resources-us-east-1/deepvariant/model/germline/v1.3/model.ckpt-890000.dyn_1500.onnx ./	

#this was the referenced file in the the actual init file under Running call_variants:
#aws s3 cp s3://ultimagen-workflow-resources-us-east-1/deepvariant/model/germline/v1.5/ultima-usb4-pe-germline-model-v1.5.ckpt-380000.onnx ./ --no-sign-request

#apptainer exec docker://google/cloud-sdk:latest \
#    gsutil cp gs://concordanz/deepvariant/model/germline/v1.3/model.ckpt-890000.dyn_1500.onnx ./

#get the cram test files from the test_files folder in the github:

#wget https://github.com/Ultimagen/healthomics-workflows/raw/refs/heads/main/tests/efficient_dv/test_files/sample.chr1.5M.cram

#wget https://github.com/Ultimagen/healthomics-workflows/raw/refs/heads/main/tests/efficient_dv/test_files/sample.chr1.5M.cram.crai
#
# get the output files to compare to 
wget https://github.com/Ultimagen/healthomics-workflows/raw/refs/heads/main/tests/efficient_dv/test_outputs/sample.vcf.gz

wget https://github.com/Ultimagen/healthomics-workflows/raw/refs/heads/main/tests/efficient_dv/test_outputs/sample.vcf.gz.tbi

# The following are 10 cram GIAB data sets and their respective vcr's (using adapted DeepVariant pipeline)
# So it's another good test data set
# https://cdn.sanity.io/files/l7780ks7/production-2024/0a1b6a62a6da3e3fcafb81cad4c8ff2ffe85dd41.pdf
\aws s3 sync s3://ultima-public-data/WGS/agbt_2025_reference_set/GIAB ultima-GIAB/ --no-sign-request
\aws s3 sync s3://ultima-public-data/WGS/agbt_2025_reference_set/GIAB/DeepVariant_vcfs/… --nosign-request