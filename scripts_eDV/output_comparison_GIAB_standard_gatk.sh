#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=120G
#SBATCH --time=0-08:00
#SBATCH --job-name hap_py_GIAB
#SBATCH --output=/home/hnatovs1/scratch/Ultima_deepvariant/output_compare_outfiles/GIAB_comparison_out/V1.9WDLfilt_to_standardGIAB/comparison.log
#SBATCH --mail-type=FAIL


module load bcftools/1.22
module load apptainer/1.3.5

cd /home/hnatovs1/scratch/

# path to the Query VCF
# Query_path='/home/hnatovs1/scratch/Ultima_deepvariant/postprocess_output'
Query_path='/home/hnatovs1/scratch/Ultima_deepvariant/postprocess_output/no_refcalls'
# path to the Truth VCF
Truth_path='/home/hnatovs1/scratch/Ultima_deepvariant/test_data/standard-GIAB'
# path to output
Output_path='/home/hnatovs1/scratch/Ultima_deepvariant/output_compare_outfiles/GIAB_comparison_out/V1.9WDLfilt_to_standardGIAB'
mkdir -p "$Output_path"

# Bash arrays use parentheses, not brackets
SAMPLES=("414004-L7384-Z0008-CACATCCTGCATGTGAT" "414004-L7386-Z0114-CAACATACATCAGAT" "414004-L7388-Z0016-CATCCTGTGCGCATGAT" "414004-L7390-Z0117-CTGCCGAGCAGCATGAT" "414004-L7392-Z0032-CTCTGTATTGCAGAT")
truth_SAMPLES=("HG001" "HG002" "HG003" "HG004" "HG005")

export PATH=/home/hnatovs1/scratch/Ultima_deepvariant/tools/rtg-tools-3.13:$PATH
export HGREF=/home/hnatovs1/scratch/Ultima_deepvariant/test_data/Homo_sapiens_assembly38.fasta

# Loop through array with ${SAMPLES[@]}
for idx in "${!SAMPLES[@]}"; do
    SAMPLE=${SAMPLES[$idx]}
    TRUTH=${truth_SAMPLES[$idx]}
    echo "Processing sample: ${TRUTH} aka ${SAMPLE}"
    
    # Get the number of variants in both VCFs:
    echo "Their variants:"
    bcftools view -H $Truth_path/${TRUTH}_GRCh38_1_22_v4.2.1_benchmark.vcf.gz | wc -l
    echo "Your variants:"  
    bcftools view -H $Query_path/${SAMPLE}.nonref.vcf.gz | wc -l

    # Benchmark with hap.py
    # set memory:
    export RTG_MEM=100g
    
    #set the regions file:
    REGIONS_FILE=$(ls $Truth_path/${TRUTH}_GRCh38_1_22_v4.2.1*bed)
    # positional arguments order : truth then query
    apptainer run -B $SCRATCH/Ultima_deepvariant/output_compare_outfiles/GIAB_comparison_out -W $SCRATCH/Ultima_deepvariant/output_compare_outfiles/GIAB_comparison_out /scratch/hnatovs1/Ultima_deepvariant/docker_images_eDV/hap.py.sif \
        /opt/hap.py/bin/hap.py \
        $Truth_path/${TRUTH}_GRCh38_1_22_v4.2.1_benchmark.vcf.gz \
        $Query_path/${SAMPLE}.nonref.vcf.gz \
        --restrict-regions $REGIONS_FILE \
        -o $Output_path/GIAB_benchmark_${SAMPLE} \
        -r $HGREF \
        --engine=vcfeval \
        --engine-vcfeval-template /home/hnatovs1/scratch/Ultima_deepvariant/test_data/GRCh38.sdf \
        --threads $SLURM_CPUS_PER_TASK

    echo "Completed sample: ${TRUTH}"
    echo "---"
done