## Extract results of interest, write TAF output tables
##
## Before: model/fit.RData, model/retro_fit.RData
## After:  csv tables of assessment output in output/
##
## STOCK-SPECIFIC TAILORING is most likely needed in:
##   - additional outputs (e.g. catch options, reference points, forecast tables)

library(icesTAF)
library(stockassessment)

mkdir("output")

## ---- Load -----------------------------------------------------------------

load("model/fit.RData",       verbose = TRUE)
load("model/retro_fit.RData", verbose = TRUE)

## ---- Parameter table ------------------------------------------------------

partab <- partable(fit)

## ---- F at age -------------------------------------------------------------

fatage <- as.data.frame(faytable(fit))

## ---- N at age -------------------------------------------------------------

natage <- as.data.frame(ntable(fit))

## ---- Catch table ----------------------------------------------------------

catab <- as.data.frame(catchtable(fit))
colnames(catab) <- c("Catch", "Catch_Low", "Catch_High")

## ---- TSB ------------------------------------------------------------------

tsb <- as.data.frame(tsbtable(fit))
colnames(tsb) <- c("TSB", "TSB_Low", "TSB_High")

## ---- Summary table --------------------------------------------------------

summ <- as.data.frame(summary(fit))
colnames(summ) <- c("Recruitment", "Rec_Low", "Rec_High",
                    "SSB", "SSB_Low", "SSB_High",
                    "Fbar", "Fbar_Low", "Fbar_High")

tab_summary <- cbind(summ, tsb, catab)

## ---- Mohn's rho -----------------------------------------------------------

mohns_rho <- as.data.frame(t(mohn(retro_fit)))

## ---- Write ----------------------------------------------------------------

write.taf(
  c("partab", "tab_summary", "natage", "fatage", "mohns_rho"),
  dir = "output"
)
