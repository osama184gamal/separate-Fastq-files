library(optparse)
source("mk_vcf/slice_the_pie.R")

number = list(make_option(c("-n", "-number"),
                          type = "integer", 
                          default = 1,
                          help = "Number of files you want"))

parser_n = OptionParser(option_list = number)

