suppressMessages({source("slice_the_pie.R")})


option_list <- list(
  make_option(c("-n", "--number"), type="integer", default=1),
  make_option(c("-p", "--path"), type="character", help="File containing FASTQ paths"),
  make_option(c("-d" , "--dir") , type = "character" , help = "Where you want your files"),
  make_option(c("-s","--suffix"),type = "character" , help = "The suffix or part of your patient name")
)

opts <- parse_args(OptionParser(option_list = option_list))



seperate_fastq(opts$path, opts$number , opts$dir , opts$suffix)

