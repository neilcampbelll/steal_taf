## Run analysis, write model results
##
## Before: data/data.RData, boot/data/sam_config/model.cfg
## After:  model/fit.RData, model/retro_fit.RData
##
## STOCK-SPECIFIC TAILORING is most likely needed in:
##   - the number of retro peels
##   - any conf overrides applied after loadConf()

library(icesTAF)
library(stockassessment)

mkdir("model")

## ---- Load data ------------------------------------------------------------

load("data/data.RData", verbose = TRUE)

## ---- Configure ------------------------------------------------------------

conf <- loadConf(
  dat,
  taf.data.path("sam_config", "model.cfg"),
  patch = TRUE
)

# Add any stock-specific conf overrides here, e.g.:
#   conf$fbarRange <- c(2, 6)
#   conf$corFlag   <- 1

par <- defpar(dat, conf)

## ---- Fit ------------------------------------------------------------------

fit <- sam.fit(dat, conf, par)

## ---- Retrospective --------------------------------------------------------

retro_fit <- retro(fit, year = 5)

## ---- Save -----------------------------------------------------------------

save(fit,       file = "model/fit.RData")
save(retro_fit, file = "model/retro_fit.RData")
