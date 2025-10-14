#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=40
#SBATCH --time=0-01:00
#SBATCH --job-name efficient_DV_ultimaG_make_examples
#SBATCH --output=efficient_DV_ultimaG_make_examples.txt
#SBATCH --mail-type=FAIL

cd $SCRATCH

module load apptainer/1.3.5
#module load java/1.8.0_201
#module load NiaEnv
#rm -rf out bedfiles  # Clean up first
#mkdir interval_list_out &&\
#java -jar $SCRATCH/tools/picard/picard.jar IntervalListTools \
#  SCATTER_COUNT=40 \
#  SUBDIVISION_MODE=BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW \
#  UNIQUE=true \
#  SORT=true \
#  BREAK_BANDS_AT_MULTIPLES_OF=100000 \
#  INPUT=$SCRATCH/test_data/wgs_calling_regions.hg38.interval_list \
#  OUTPUT=interval_list_out
#
#mkdir bedfiles
#
#cd interval_list_out
#for file in * ; do 
#	cd $file
#	cat *.interval_list | grep -v @ | awk 'BEGIN{OFS="\t"}{print $1,$2-1,$3}' > ../../bedfiles/${file}.bed
#	cd ..
#done
#
cd $SCRATCH/bedfiles

for bedfile in temp_000{1..3}_of_40.bed ; do
	{
		echo "Processing $bedfile..."
		apptainer run -e -B $SCRATCH -W $SCRATCH $SCRATCH/docker_images_eDV/deepvariant_make_examples.sif tool \
		  --input /home/hnatovs1/scratch/test_data/sample.chr1.5M.cram \
		  --cram-index /home/hnatovs1/scratch/test_data/sample.chr1.5M.cram.crai \
		  --bed $bedfile \
		  --output $bedfile.out \
		  --reference /home/hnatovs1/scratch/test_data/Homo_sapiens_assembly38.fasta \
		  --min-base-quality 5 \
		  --min-mapq 5 \
		  --cgp-min-count-snps 2 \
		  --cgp-min-count-hmer-indels 2 \
		  --cgp-min-count-non-hmer-indels 2 \
		  --cgp-min-fraction-snps 0.12 \
		  --cgp-min-fraction-hmer-indels 0.12 \
		  --cgp-min-fraction-non-hmer-indels 0.06 \
		  --cgp-min-mapping-quality 5 \
		  --max-reads-per-region 1500 \
		  --assembly-min-base-quality 0 \
		  --optimal-coverages 50 \
		  --add-ins-size-channel
		echo "Completed $bedfile"
	}
done




