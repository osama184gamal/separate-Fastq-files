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
