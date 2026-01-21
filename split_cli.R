suppressMessages({source("slice_the_pie.R")})


option_list <- list(
  make_option(c("-n", "--number"), type="integer", default=1),
  make_option(c("-p", "--path"), type="character", help="File containing FASTQ paths")
)

opts <- parse_args(OptionParser(option_list = option_list))

# This ensures the user **must provide the path**
if (is.null(opts$path)) {
  stop("ERROR: --path is required", call. = FALSE)
}

seperate_fastq(opts$path, opts$number)

