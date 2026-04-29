## Formatted summary tables for the report
##
## Before: data/*.csv, output/*.csv
## After:  formatted csv tables in report/
##
## STOCK-SPECIFIC TAILORING: add any stock-specific WG report tables here
## (catch by area, advice tables, forecast tables, etc.).

library(icesTAF)

mkdir("report")

## ---- Catch at age with row/column totals ----------------------------------

catage <- read.taf("data/catage.csv")
catage <- cbind(catage, Total = rowSums(catage))
catage <- rbind(catage, Mean  = colMeans(catage))
write.taf(catage, "report/catage.csv")

## ---- Summary table --------------------------------------------------------

tab_summary <- read.taf("output/tab_summary.csv")
write.taf(tab_summary, "report/tab_summary.csv")
