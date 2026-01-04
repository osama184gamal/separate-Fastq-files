# About this repo

## Disclaimer:
The data we are using in this project is synthetic and just created for specific usage.


## READMANE workflow team WGS project:
In the wgs pipline we need read files in fastq format and ref sequence genome in fasta format.
But we want to sythisise the fastq files, so we download the read files from the genome in bottle.
Then we need to split the files depends on the reads size.

## Seperate fastq files using R program:
The code consists of one function with 4 arguments.
- r1_file is the first read file 
- r2_file is the second read file
- read_per_sample ==> is number of reads you want each file to contain
- sample_file ==> file that contains synthisise sample ids 

### Output: 
- Two files (R1 - R2) named by the sample ids in sample_file 
- Each file has the number of reads you have decided in read_per_sample argument

##Create VCF files:
I wrote a bash script file consistes of  3 main sections every section has a job to do 

### Configuration:
In order to reuse the code you need to adjust this section with the right paths of files in your personal computer. 

### Reference preparation: 
In this step we create index file we need for the aligner in other step.

### The main loop 
In this section we have 3 tools
- bwa the aligner 
- samtools to sort the data of the bam files
- GATK to get the (adding read groups , mark duplicates , variant calling) 
