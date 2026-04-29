## Standard SAM diagnostic and summary plots
##
## Before: model/fit.RData, model/retro_fit.RData
## After:  png files in report/
##
## STOCK-SPECIFIC TAILORING: add stock-specific diagnostic plots
## (residuals, leave-one-out, selectivity, etc.) as needed.

library(icesTAF)
library(stockassessment)

mkdir("report")

load("model/fit.RData",       verbose = TRUE)
load("model/retro_fit.RData", verbose = TRUE)

## ---- Standard SAM summary -------------------------------------------------

taf.png("summary", width = 1600, height = 2000)
plot(fit)
dev.off()

## ---- Individual panels ----------------------------------------------------

taf.png("SSB")
ssbplot(fit, addCI = TRUE)
dev.off()

taf.png("Fbar")
fbarplot(fit, xlab = "", partial = FALSE)
dev.off()

taf.png("Rec")
recplot(fit, xlab = "")
dev.off()

taf.png("Catch")
catchplot(fit, xlab = "")
dev.off()

## ---- Retrospective --------------------------------------------------------

taf.png("retrospective", width = 1600, height = 2000)
plot(retro_fit)
dev.off()
