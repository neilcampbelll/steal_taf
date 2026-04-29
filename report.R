## Prepare plots and tables for report
##
## Before: model/fit.RData, output/*.csv
## After:  png plots and formatted csv tables in report/

library(icesTAF)

mkdir("report")

sourceTAF("report_plots.R")
sourceTAF("report_tables.R")
