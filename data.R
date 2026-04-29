## Preprocess data, write TAF data tables
##
## Before: input .dat files in boot/data/sam_data
## After:  flat .csv tables and data.RData in data/
##
## STOCK-SPECIFIC TAILORING is most likely needed in:
##   - any preprocessing block (plus group, year truncation, survey averaging)
##   - the survey naming block (replace generic survey_1, survey_2 with proper names)

library(icesTAF)
library(stockassessment)

mkdir("data")

## ---- 1. Read underlying data from boot/data --------------------------------

read.ices.taf <- function(...) {
  read.ices(taf.data.path("sam_data", ...))
}

# Catch
catage <- read.ices.taf("cn.dat")

# Weights at age
wcatch    <- read.ices.taf("cw.dat")
wdiscards <- read.ices.taf("dw.dat")
wlandings <- read.ices.taf("lw.dat")
wstock    <- read.ices.taf("sw.dat")

# Biology
natmort  <- read.ices.taf("nm.dat")
maturity <- read.ices.taf("mo.dat")

# Proportion of F / M before spawning
propf <- read.ices.taf("pf.dat")
propm <- read.ices.taf("pm.dat")

# Landing fraction
landfrac <- read.ices.taf("lf.dat")

# Surveys
surveys <- read.ices.taf("survey.dat")


## ---- 2. Preprocess --------------------------------------------------------
##
## Add any stock-specific preprocessing here:
##   - ages aggregated into a plus group
##   - years truncated
##   - survey indices smoothed or combined

# Split catch into landings and discards at age
latage <- catage * landfrac
datage <- catage * (1 - landfrac)

# Pull each survey out separately for writing as flat CSV
for (i in seq_along(surveys)) {
  assign(paste0("survey_", i), surveys[[i]])
}


## ---- 3. Write TAF tables --------------------------------------------------

taf_objects <- c(
  "catage", "latage", "datage",
  "wstock", "wcatch", "wdiscards", "wlandings",
  "natmort", "maturity", "propf", "propm", "landfrac",
  paste0("survey_", seq_along(surveys))
)

write.taf(taf_objects, dir = "data")


## ---- 4. Build SAM data object ---------------------------------------------

dat <- setup.sam.data(
  surveys           = surveys,
  residual.fleet    = catage,
  prop.mature       = maturity,
  stock.mean.weight = wstock,
  catch.mean.weight = wcatch,
  dis.mean.weight   = wdiscards,
  land.mean.weight  = wlandings,
  prop.f            = propf,
  prop.m            = propm,
  natural.mortality = natmort,
  land.frac         = landfrac
)

save(dat, file = "data/data.RData")
