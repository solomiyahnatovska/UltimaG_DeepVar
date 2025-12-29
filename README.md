Efficient DeepVariant (eDV) Snakemake Workflow  
### Variant Calling on Ultima Genomics CRAM Files (hg38)

This repository contains a Snakemake workflow for running **Efficient DeepVariant (eDV)** on Ultima Genomics CRAM files.  
The pipeline performs:

1. Genome interval sharding  
2. Example generation  
3. Configuration file creation  
4. Variant calling  
5. Post-processing to produce final per-sample VCF files  

The workflow supports multiple samples and 40-way sharding for efficient parallelization.

# DeepVariant Pipeline Flowchart

## Pipeline Overview
```
Reference Intervals (hg38)
         ↓
    RULE:make_intervals
         ↓
    40 BED files (shards)
         ↓
    [For each SAMPLE - Parallel across 40 shards]
         │
         ├──→ RULE:make_examples_single (shard 0001)
         ├──→ RULE:make_examples_single (shard 0002)
         ├──→ RULE:make_examples_single (shard 0003)
         │    ...
         └──→ RULE:make_examples_single (shard 0040)
                     ↓
            40 TFRecord files per sample
                     ↓
              RULE:generate_config [For each SAMPLE - each listing the 40 shards]
                     ↓
             call_variants.ini
                     ↓
               call_variants
                     ↓
         40 compressed output files
                     ↓
              post_process
                     ↓
            Final VCF.GZ file
```

## Detailed Step Breakdown

### Step 1: make_intervals
- **Input:** `wgs_calling_regions.hg38.interval_list`
- **Output:** 40 BED files (`temp_0001_of_40.bed` ... `temp_0040_of_40.bed`)
- **Purpose:** Split genome into 40 shards for parallel processing
- **Run once:** Not sample-specific

### Step 2: make_examples_single (×40 per sample)
- **Input:** 
  - 1 BED file (one shard)
  - Sample CRAM + index
- **Output:** 1 TFRecord file per shard
- **Purpose:** Extract variant examples from aligned reads
- **Parallelization:** 40 shards × 5 samples = 200 parallel jobs

### Step 3: generate_config
- **Input:** All 40 TFRecord files for a sample
- **Output:** `call_variants.ini` configuration file
- **Purpose:** Create config pointing to all TFRecords and model settings
- **Per sample:** One config per sample

### Step 4: call_variants
- **Input:** 
  - call_variants.ini config
  - 40 TFRecord files (via config)
- **Output:** 40 compressed variant call files
- **Purpose:** Run neural network model to classify variants
- **GPU accelerated:** Uses ONNX model with TensorRT

### Step 5: post_process
- **Input:** 40 compressed variant files
- **Output:** Single merged VCF.GZ file
- **Purpose:** Merge and format final variant calls
- **Per sample:** One final VCF per sample

## Sample Processing

**5 Samples in parallel:**
1. `414004-L7384-Z0008-CACATCCTGCATGTGAT`
2. `414004-L7386-Z0114-CAACATACATCAGAT`
3. `414004-L7388-Z0016-CATCCTGTGCGCATGAT`
4. `414004-L7390-Z0117-CTGCCGAGCAGCATGAT`
5. `414004-L7392-Z0032-CTCTGTATTGCAGAT`

Each sample follows the same pipeline independently.

## Final Output

** One VCF file per sample:** 
Directory: '/home/hnatovs1/scratch/Ultima_deepvariant/postprocess_output'
- `postprocess_output_414004-L7384-Z0008-CACATCCTGCATGTGAT.vcf.gz`
- `postprocess_output_414004-L7386-Z0114-CAACATACATCAGAT.vcf.gz`
- `postprocess_output_414004-L7388-Z0016-CATCCTGTGCGCATGAT.vcf.gz`
- `postprocess_output_414004-L7390-Z0117-CTGCCGAGCAGCATGAT.vcf.gz`
- `postprocess_output_414004-L7392-Z0032-CTCTGTATTGCAGAT.vcf.gz`