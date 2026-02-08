# -------- Find script directory safely --------
args <- commandArgs(trailingOnly = FALSE)
script_path <- sub("^--file=", "", args[grep("--file=", args)])
script_dir <- dirname(normalizePath(script_path))

# -------- Source worker code --------
suppressMessages(
  source(file.path(script_dir, "slice_the_pie.R"))
)



option_list <- list(
  make_option(c("-p", "--path"), type="character", help="File containing FASTQ paths"),
  make_option(c("-n", "--number"), type="integer", default=1, help="Number of files you want to generate"),
  make_option(c("-d" , "--dir") , type = "character" , help = "Where you want your files"),
  make_option(c("-s","--suffix"),type = "character" , help = "The suffix or part of your patient name")
)

opts <- parse_args(OptionParser(option_list = option_list))



seperate_fastq(opts$path, opts$number , opts$dir , opts$suffix)

