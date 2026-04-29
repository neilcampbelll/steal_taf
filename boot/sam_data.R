## Fetch SAM input data files from stockassessment.org
##
## Called automatically by taf.boot() because DATA.bib has:
##   @Misc{sam_data, ..., source = {script}}
##
## URL is built from environment variables that should be set by
## steal_taf() in run.R before calling taf.boot().

library(icesTAF)

## ---- Resolve target run ----------------------------------------------------

user_dir <- Sys.getenv("SA_ORG_USER")
run_name <- Sys.getenv("SA_ORG_RUN")

if (!nzchar(user_dir) || !nzchar(run_name)) {
  stop("SA_ORG_USER and SA_ORG_RUN env vars not set. ",
       "Call steal_taf(user_dir, run_name) before taf.boot(), or set them by hand.",
       call. = FALSE)
}

run_url <- sprintf(
  "https://stockassessment.org/datadisk/stockassessment/userdirs/%s/%s/data/",
  user_dir, run_name
)

## ---- Files to fetch --------------------------------------------------------
##
## Standard SAM input files. Add stock-specific extras (e.g. external survey
## CV files) here if needed.

files <- c(
  "cn.dat",       # catch numbers at age
  "cw.dat",       # catch weights at age
  "dw.dat",       # discard weights at age
  "lf.dat",       # landing fraction
  "lw.dat",       # landings weights at age
  "mo.dat",       # maturity
  "nm.dat",       # natural mortality
  "pf.dat",       # proportion F before spawning
  "pm.dat",       # proportion M before spawning
  "sw.dat",       # stock weights at age
  "survey.dat"    # survey indices
)

## ---- Resolve destination and fetch -----------------------------------------

dest <- taf.data.path("sam_data")
mkdir(dest)

for (f in files) {
  download(paste0(run_url, f), dir = dest)
}
