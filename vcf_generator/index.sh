read -p "Write you output directory for your indexing files:" index
mkdir $index


read -p "Write the path to your genome fna file:" REF
read -p "Write the path to your file to run gatk:" GATK


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
