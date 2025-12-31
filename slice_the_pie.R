library(ShortRead)
setwd("/home/osama-gamal/")


r1_file <- "/mnt/mydata/data/2A1_CGATGT_L001_R1_001.fastq"
r2_file <- "/mnt/mydata/data/2A1_CGATGT_L001_R2_001.fastq"

reads_per_sample <- 100000

output_dir <- "~/chunks"
dir.create(output_dir, showWarnings = FALSE)

sample_ids <- read.table("/mnt/mydata/project/file.txt", header = FALSE)[,1]

stream1 <- FastqStreamer(r1_file, n = reads_per_sample)
stream2 <- FastqStreamer(r2_file, n = reads_per_sample)

for (sample in sample_ids) {
  
  fq1 <- yield(stream1)
  fq2 <- yield(stream2)
  
  if (length(fq1) == 0) {
    message("No more reads left. Stopping.")
    break
  }
  
  writeFastq(
    fq1,
    file.path(output_dir, paste0(sample, "_R1.fastq"))
  )
  writeFastq(
    fq2,
    file.path(output_dir, paste0(sample, "_R2.fastq"))
  )
  
  cat("Written", sample, "with", length(fq1), "reads\n")
}

close(stream1)
close(stream2)
dir.exists("/mnt/mydata/project/chunks")
