#configfile: "/home/hnatovs1/scratch/Ultima_deepvariant/cluster.yaml"
from pathlib import Path

# defining the paths:
project_dir = Path('/home/hnatovs1/scratch/Ultima_deepvariant')
intermediate_data_dir = project_dir.joinpath("intermediate_outputs")
data_dir = project_dir.joinpath("test_data")
cram_dir = project_dir.joinpath("test_data/ultima-GIAB/Crams")
scripts_dir = project_dir.joinpath("scripts_eDV")
log_dir = project_dir.joinpath("logs")
config_dir = project_dir.joinpath("configs")

# specify here a list of sample names
SAMPLES = ["414004-L7384-Z0008-CACATCCTGCATGTGAT", "414004-L7386-Z0114-CAACATACATCAGAT", "414004-L7388-Z0016-CATCCTGTGCGCATGAT", "414004-L7390-Z0117-CTGCCGAGCAGCATGAT", "414004-L7392-Z0032-CTCTGTATTGCAGAT"]  

# Define the shard IDs so that the make examples step is run for each one that is missing
SHARDS = [f"{i:04d}" for i in range(1, 41)]

rule all: 
    input:
        expand(f"{project_dir}/postprocess_output/postprocess_output_{{sample}}.vcf.gz", sample=SAMPLES)

rule make_intervals: # This rule runs the make intervals script which only needs to be run once for the reference version (hg38 in this case) -not a sample specific step
    input:
        interval_list=data_dir.joinpath('wgs_calling_regions.hg38.interval_list')
    output:
        interval_beds=expand(str(intermediate_data_dir.joinpath("bedfiles/temp_{i:04d}_of_40.bed")), i=range(1,41))
    params:
        script=scripts_dir.joinpath("make_intervals.sh"),
        outdir=intermediate_data_dir.joinpath("bedfiles")
    log:
        log_dir.joinpath("efficient_DV_ultimaG_make_intervals.txt")
    shell:
        "{params.script} -i {input.interval_list} -o {params.outdir} &> {log}"
rule make_examples_single:
    input:
        interval_bed=str(intermediate_data_dir.joinpath("bedfiles/temp_{shard}_of_40.bed")),
        cram_file=cram_dir.joinpath("{sample}.cram"),
        cram_index=cram_dir.joinpath("{sample}.cram.crai"),
    output:
        example_bed=str(intermediate_data_dir.joinpath("examplesdir/{sample}/temp_{shard}_of_40.bed.out.tfrecord.gz"))
    log:
        str(log_dir.joinpath("{sample}/efficient_DV_ultimaG_make_examples_{shard}.txt"))
    params:
        script=str(scripts_dir.joinpath("make_examples.sh")),
        sample_examplesdir=str(intermediate_data_dir.joinpath("examplesdir/{sample}")),
        sample_log_dir=str(log_dir.joinpath("{sample}"))
    shell:
        """
        mkdir -p {params.sample_examplesdir}
        mkdir -p {params.sample_log_dir}
        {params.script} -c {input.cram_file} -d {input.cram_index} -i {input.interval_bed} -o {output.example_bed} &> {log}
        """
rule generate_config:
    input:
        example_beds=expand(str(intermediate_data_dir.joinpath("examplesdir/{{sample}}/temp_{shard}_of_40.bed.out.tfrecord.gz")), shard=SHARDS)
    output:
        config=config_dir.joinpath("{sample}/call_variants.ini")
    params:
        outputFileName=intermediate_data_dir.joinpath("call_variants_output/{sample}/call_variants"),
        sample_call_log_dir=intermediate_data_dir.joinpath("call_variants_output/{sample}"),
        sample_config_dir=config_dir.joinpath("{sample}")

    shell:
        """
        mkdir -p {params.sample_config_dir}
        mkdir -p {params.sample_call_log_dir}

        TFRECORDS=({input.example_beds})  # store array of files
        NUM_FILES=${{#TFRECORDS[@]}}    # count the files
        
        cat > {output.config} <<EOF
[RT classification]
onnxFileName = /scratch/hnatovs1/Ultima_deepvariant/test_data/ultima-usb4-pe-germline-model-v1.5.ckpt-380000.onnx
useSerializedModel = 1
trtWorkspaceSizeMB = 2000
numInferTreadsPerGpu = 2
useGPUs = 1
gpuid = 0
[debug]
logFileFolder = {params.sample_call_log_dir}
[general]
tfrecord = 1
compsed = 1
outputInOneFile = 0
numUncomprThreads = 8
uncomprBufSizeGB = 1
outputFileName = {params.outputFileName}
numConversionThreads = 2
numExampleFiles = $NUM_FILES
EOF
        
        # Add each file in one loop
        for i in "${{!TFRECORDS[@]}}"; do
            echo "exampleFile$((i+1)) = ${{TFRECORDS[$i]}}" >> {output.config}
        done
        """

rule call_variants:
    input:
        example_beds=expand(str(intermediate_data_dir.joinpath("examplesdir/{{sample}}/temp_{i:04d}_of_40.bed.out.tfrecord.gz")), i=range(1,41)),
        config=rules.generate_config.output.config
    output:
        call_vars_outfile=expand(str(intermediate_data_dir.joinpath("call_variants_output/{{sample}}/call_variants.{i}.gz")), i=range(1,41))
    params:
        script=scripts_dir.joinpath("call_variants.sh"),
        call_variants_dir=str(intermediate_data_dir.joinpath("call_variants_output/{sample}"))
    log:
        log_dir.joinpath("{sample}/efficient_DV_ultimaG_call_variants.txt")
    shell:
       '''
       mkdir -p {params.call_variants_dir}
       {params.script} -c {input.config} &> {log}
       '''


rule post_process:
    input:
        call_vars_outfile=rules.call_variants.output.call_vars_outfile
    output:
        postprocess_output=project_dir.joinpath("postprocess_output/postprocess_output_{sample}.vcf.gz")
    params:
        script=str(scripts_dir.joinpath("post_process.sh"))
    log:
        str(log_dir.joinpath("{sample}/efficient_DV_ultimaG_post_process.txt"))
    shell:
        "{params.script} -i '{input.call_vars_outfile}' &> {log}"

# For Snakemake version 5.9.1