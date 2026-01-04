#!/bin/bash
set -euo pipefail

############################
# CONFIGURATION
############################
THREADS=8

FASTQ_DIR="/home/osama-gamal/chunks"
PROJECT_DIR="/mnt/mydata/project"
REF="${PROJECT_DIR}/GCF_000001405.40_GRCh38.p14_genomic.fna"
GATK="/home/osama-gamal/gatk-4.5.0.0/gatk-package-4.5.0.0-local.jar"

BAM_DIR="${PROJECT_DIR}/bam"
VCF_DIR="${PROJECT_DIR}/vcf"

mkdir -p "${BAM_DIR}" "${VCF_DIR}"

############################
# REFERENCE PREPARATION
############################
# FASTA index
if [ ! -f "${REF}.fai" ]; then
    samtools faidx "${REF}"
fi

# Sequence dictionary (required by GATK)
DICT="${REF%.fna}.dict"
if [ ! -f "${DICT}" ]; then
    java -jar "${GATK}" CreateSequenceDictionary \
        -R "${REF}" \
        -O "${DICT}"
fi

############################
# MAIN LOOP
############################
for R1 in ${FASTQ_DIR}/*_R1.fastq; do
    sample=$(basename "${R1}" _R1.fastq)
    R2="${FASTQ_DIR}/${sample}_R2.fastq"

    echo "=============================="
    echo "Processing sample: ${sample}"
    echo "=============================="

    ############################
    # 1. ALIGNMENT
    ############################
    bwa mem -t ${THREADS} "${REF}" "${R1}" "${R2}" \
        | samtools view -b - \
        > "${BAM_DIR}/${sample}.bam"

    ############################
    # 2. SORT BAM
    ############################
    samtools sort -@ ${THREADS} \
        -o "${BAM_DIR}/${sample}.sorted.bam" \
        "${BAM_DIR}/${sample}.bam"

    ############################
    # 3. ADD READ GROUPS (MANDATORY)
    ############################
    java -jar "${GATK}" AddOrReplaceReadGroups \
        -I "${BAM_DIR}/${sample}.sorted.bam" \
        -O "${BAM_DIR}/${sample}.rg.bam" \
        -RGID "${sample}" \
        -RGLB "lib1" \
        -RGPL "ILLUMINA" \
        -RGPU "unit1" \
        -RGSM "${sample}"

    ############################
    # 4. MARK DUPLICATES
    ############################
    java -jar "${GATK}" MarkDuplicates \
        -I "${BAM_DIR}/${sample}.rg.bam" \
        -O "${BAM_DIR}/${sample}.markdup.bam" \
        -M "${BAM_DIR}/${sample}.markdup.metrics.txt"

    samtools index "${BAM_DIR}/${sample}.markdup.bam"

    ############################
    # 5. VARIANT CALLING
    ############################
    java -jar "${GATK}" HaplotypeCaller \
        -R "${REF}" \
        -I "${BAM_DIR}/${sample}.markdup.bam" \
        -O "${VCF_DIR}/${sample}.vcf.gz"

    echo "Finished sample: ${sample}"
done

echo "ALL SAMPLES COMPLETED SUCCESSFULLY"
