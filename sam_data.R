## Fetch SAM input data files from stockassessment.org
##
## Called automatically by taf.boot() because DATA.bib has:
##   @Misc{sam_data, ..., source = {script}}
##
## URL is built from environment variables set by steal_taf() in run.R.
## Defaults are baked in so the project works standalone too.

library(icesTAF)

## ---- Resolve target run ----------------------------------------------------

user_dir <- Sys.getenv("SA_ORG_USER", unset = "user3")
run_name <- Sys.getenv("SA_ORG_RUN",  unset = "NEA_saithe_2026_v7")

run_url <- sprintf(
  "https://stockassessment.org/datadisk/stockassessment/userdirs/%s/%s/data/",
  user_dir, run_name
)

## ---- Files to fetch --------------------------------------------------------

files <- c(
  "cn.dat",
  "cw.dat",
  "dw.dat",
  "lf.dat",
  "lw.dat",
  "mo.dat",
  "nm.dat",
  "pf.dat",
  "pm.dat",
  "sw.dat",
  "survey.dat",
  "coast_survey_cv.dat"   # provenance only; not currently used in the fit
)

## ---- Resolve destination and fetch -----------------------------------------

dest <- taf.data.path("sam_data")
mkdir(dest)

for (f in files) {
  download(paste0(run_url, f), dir = dest)
}
