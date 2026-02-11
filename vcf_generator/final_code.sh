#!/bin/bash
set -euo pipefail

############################
# CONFIGURATION
############################

read -p "Write the number of threads you want to use:" THREADS


read -p "Write the path to your fastq files:" FASTQ_DIR

read -p "Write the path to your project workspace:" PROJECT_DIR

read -p "Write the reference genome file name:" Ref_genome

read -p "Write the path of your snpEff.jar file:" Snpeff

read -p "Write the path of your DB:" DB

REF=${Ref_genome}

read -p "Write the path to your file to run gatk:" GATK


BAM_DIR="${PROJECT_DIR}/bam"

VCF_DIR="${PROJECT_DIR}/vcf"

mkdir -p "${BAM_DIR}" "${VCF_DIR}"


############################
# MAIN LOOP
############################
for R1 in "${FASTQ_DIR}"/*_R1.fastq; do
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

############################
#Annotation of the files
############################
ann="${VCF_DIR}"/ann_vcf


mkdir -p "$ann"

for vcf in "${VCF_DIR}"/*.vcf.gz;
do
sample=$(basename "$vcf" .vcf.gz)
echo "Annotationg $sample"
java -Xmx4g -jar $Snpeff \
-v "$DB" \
"$vcf" \

>  $ann/${sample}.ann.vcf

echo "Finished annotation"


done


echo "ALL SAMPLES COMPLETED SUCCESSFULLY"

