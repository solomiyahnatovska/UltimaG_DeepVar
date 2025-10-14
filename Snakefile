
#configfile: "/home/hnatovs1/scratch/cluster.yaml"

rule all:
    input:
        directory("/home/hnatovs1/scratch/call_variants_output")
rule make_intervals:
    input:
        interval_list='/scratch/hnatovs1/test_data/wgs_calling_regions.hg38.interval_list'
    output:
        beddir=directory("/home/hnatovs1/scratch/bedfiles")
    resources:
        nodes=1,
        ntasks=40,
        time_min=60,
        slurm_extra="--mail-type=FAIL"
    log:
        "logs/efficient_DV_ultimaG_make_intervals.txt"
    shell:
        "/home/hnatovs1/scratch/scripts_eDV/make_intervals.sh -i {input.interval_list} -o {output.beddir}"
rule make_examples:
    input:
        beddir=rules.make_intervals.output.beddir,
        cram_file='/home/hnatovs1/scratch/test_data/sample.chr1.5M.cram',
        cram_index='/home/hnatovs1/scratch/test_data/sample.chr1.5M.cram.crai'
    output:
        examplesdir=directory('/home/hnatovs1/scratch/example_files')
    resources:
        nodes=1,
        ntasks=40,
        time_min=60,
        slurm_extra="--mail-type=FAIL"
    log:
        "logs/efficient_DV_ultimaG_make_examples.txt"
    shell:
        "/home/hnatovs1/scratch/scripts_eDV/make_examples.sh -c {input.cram_file} -d {input.cram_index} -i {input.beddir} -o {output.examplesdir} "
rule generate_config:
    input:
        examplesdir=rules.make_examples.output.examplesdir
    output:
        config="configs/call_variants.ini"
    params:
        outputFileName="/scratch/hnatovs1/call_variants_output/call_variants",
        log_dir="/home/hnatovs1/scratch/call_variants_output"
    shell:
        """
        mkdir -p configs

        TFRECORDS=({input.examplesdir}/*bed.out.tfrecord.gz)  # store array of files
        NUM_FILES=${{#TFRECORDS[@]}}    # count the files
        
        cat > {output.config} <<EOF
[RT classification]
onnxFileName = /scratch/hnatovs1/test_data/ultima-usb4-pe-germline-model-v1.5.ckpt-380000.onnx
useSerializedModel = 1
trtWorkspaceSizeMB = 2000
numInferTreadsPerGpu = 2
useGPUs = 1
gpuid = 0
[debug]
logFileFolder = {params.log_dir}
[general]
tfrecord = 1
compressed = 1
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
        examplesdir=rules.make_examples.output.examplesdir,
        config=rules.generate_config.output.config
    output:
        directory("/home/hnatovs1/scratch/call_variants_output")
    resources:
        mem_mb=10000,           # 10G = 10000 MB
        runtime=60,             # 1:00:00 = 60 minutes
        cpus=2,                 # --cpus-per-task=2
        slurm_extra="--gpus=a100_4g.20gb:1 --mail-type=FAIL"
    log:
        "logs/efficient_DV_ultimaG_call_variants_.txt" 
    shell:
        "/home/hnatovs1/scratch/scripts_eDV/call_variants.sh"

#snakemake --executor slurm --jobs 3
#snakemake --cluster "sbatch -J {cluster.job_name} -o {cluster.output} -N {resources.nodes} -n {resources.ntasks} -t {resources.time_min}" --cluster-config cluster.yaml --jobs 2 --forcerun
