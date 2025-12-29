#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=40
#SBATCH --time=0-04:00
#SBATCH --job-name efficient_DV_UG_compare
#SBATCH --output=/home/hnatovs1/scratch/Ultima_deepvariant/output_compare_outfiles/GIAB_comparison_out/GIAB_benchmark.log
#SBATCH --mail-type=FAIL


module load bcftools/1.22
module load apptainer/1.3.5

cd /home/hnatovs1/scratch/

# Bash arrays use parentheses, not brackets
SAMPLES=("414004-L7390-Z0117-CTGCCGAGCAGCATGAT" "414004-L7392-Z0032-CTCTGTATTGCAGAT")
# "414004-L7384-Z0008-CACATCCTGCATGTGAT" "414004-L7386-Z0114-CAACATACATCAGAT" "414004-L7388-Z0016-CATCCTGTGCGCATGAT"
export HG19=/home/hnatovs1/scratch/test_data/Homo_sapiens_assembly38.fasta

# Loop through array with ${SAMPLES[@]}
for i in "${SAMPLES[@]}"; do
    echo "Processing sample: ${i}"
    
    # Get the number of variants in both VCFs:
    echo "Their variants:"
    bcftools view -H /home/hnatovs1/scratch/Ultima_deepvariant/test_data/ultima-GIAB/DeepVariant_vcfs/${i}.annotated.filt.vcf.gz | wc -l
    echo "Your variants:"  
    bcftools view -H /home/hnatovs1/scratch/Ultima_deepvariant/postprocess_output/postprocess_output_${i}.vcf.gz | wc -l

    # Benchmark with hap.py
    apptainer run -B $SCRATCH/Ultima_deepvariant/output_compare_outfiles/GIAB_comparison_out -W $SCRATCH/Ultima_deepvariant/output_compare_outfiles/GIAB_comparison_out /scratch/hnatovs1/Ultima_deepvariant/docker_images_eDV/hap.py.sif \
        /opt/hap.py/bin/hap.py \
        /home/hnatovs1/scratch/Ultima_deepvariant/test_data/ultima-GIAB/DeepVariant_vcfs/${i}.annotated.filt.vcf.gz \
        /home/hnatovs1/scratch/Ultima_deepvariant/postprocess_output/postprocess_output_${i}.vcf.gz \
        -r /home/hnatovs1/scratch/Ultima_deepvariant/test_data/Homo_sapiens_assembly38.fasta \
        -o $SCRATCH/Ultima_deepvariant/output_compare_outfiles/GIAB_comparison_out/GIAB_benchmark_${i}
        
    echo "Completed sample: ${i}"
    echo "---"
done