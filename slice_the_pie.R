library(ShortRead)
library(seqinr)

# lines = length(readLines("/mnt/mydata/data/2A1_CGATGT_L001_R1_001.fastq"))
# number_of_reads =  cat(lines/4)
# print(lines/4)


library(ShortRead)

seperate_fastq <- function(file, num_files) {
  
  # Read FASTQ paths
  paths <- readLines(file)
  
  r1_file <- grep("_R1_", paths, value = TRUE)
  r2_file <- grep("_R2_", paths, value = TRUE)
  
  if (length(r1_file) != 1 || length(r2_file) != 1) {
    stop("Expected exactly one R1 and one R2 file")
  }
  
  # -------- Count reads from R1 only --------
  con <- file(r1_file, "r")
  lines <- 0
  
  repeat {
    z <- readLines(con, n = 100000)
    if (length(z) == 0) break
    lines <- lines + length(z)
  }
  close(con)
  
  if (lines %% 4 != 0) stop("Invalid FASTQ format")
  
  reads <- lines / 4
  reads_per_sample <- as.integer(reads / num_files)
  
  cat("Total reads:", reads, "\n")
  cat("Reads per split file:", reads_per_sample, "\n\n")
  
  # -------- Prepare output --------
  output_dir <- "~/chunk"
  dir.create(output_dir, showWarnings = FALSE)
  
  suffix <- "AGRF"
  sample_ids <- sprintf("XY%03d-%s", seq_len(num_files), suffix)
  
  # -------- Streaming --------
  stream1 <- FastqStreamer(r1_file, n = reads_per_sample)
  stream2 <- FastqStreamer(r2_file, n = reads_per_sample)
  
  for (sample in sample_ids) {
    
    fq1 <- yield(stream1)
    fq2 <- yield(stream2)
    
    if (length(fq1) == 0) break
    
    writeFastq(fq1, file.path(output_dir, paste0(sample, "_R1.fastq")))
    writeFastq(fq2, file.path(output_dir, paste0(sample, "_R2.fastq")))
    
    cat("Written", sample, "with", length(fq1), "reads\n")
  }
  
  close(stream1)
  close(stream2)
}


seperate_fastq("mk_vcf/hello.txt",   10)







