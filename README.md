# READMANE workflow team WGS project
In the wgs pipline we need read files in fastq format and ref sequence genome in fasta format.
But we want to sythisise the fastq files, so we download the read files from the genome in bottle.
Then we need to split the files depends on the reads size.

## Seperate fastq files using R program
The code consists of one function with 4 arguments.
- r1_file is the first read file 
- r2_file is the second read file
- read_per_sample ==> is number of reads you want each file to contain
- sample_file ==> file that contains synthisise sample ids 

### Output 
- Two files (R1 - R2) named by the sample ids in sample_file 
- Each file has the number of reads you have decided in read_per_sample argument

