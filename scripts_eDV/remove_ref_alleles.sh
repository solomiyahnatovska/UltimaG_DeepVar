#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=0-04:00
#SBATCH --job-name remove_ref_alleles
#SBATCH --output=/home/hnatovs1/scratch/Ultima_deepvariant/output_compare_outfiles/GIAB_comparison_out/V1.9WDLfilt_to_standardGIAB/removeref.log
#SBATCH --mail-type=FAIL
#SBATCH --mem=70G
module load bcftools/1.22

VCF_PATH='/home/hnatovs1/scratch/Ultima_deepvariant/postprocess_output'
mkdir -p $VCF_PATH/no_refcalls
# Bash array of the samples
# SAMPLES=("414004-L7384-Z0008-CACATCCTGCATGTGAT" "414004-L7386-Z0114-CAACATACATCAGAT" "414004-L7388-Z0016-CATCCTGTGCGCATGAT" "414004-L7390-Z0117-CTGCCGAGCAGCATGAT" "414004-L7392-Z0032-CTCTGTATTGCAGAT")
SAMPLES=("414004-L7384-Z0008-CACATCCTGCATGTGAT" "414004-L7388-Z0016-CATCCTGTGCGCATGAT")

# Loop through array with ${SAMPLES[@]}
for i in "${SAMPLES[@]}"; do
    echo "Processing sample: ${i}"
    bcftools view -i 'GT!="0/0" && GT!="0|0"' -v snps,indels $VCF_PATH/postprocess_output_${i}_model_1.9.vcf.gz | bcftools sort $VCF_PATH/no_refcalls/${i}.nonref.unsorted.vcf.gz -Oz -o $VCF_PATH/no_refcalls/${i}.nonref.vcf.gz

    # Index the sorted file
    bcftools index -t -f $VCF_PATH/no_refcalls/${i}.nonref.vcf.gz

done