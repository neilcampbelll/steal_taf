## Fetch SAM model configuration from stockassessment.org
##
## Called automatically by taf.boot() because DATA.bib has:
##   @Misc{sam_config, ..., source = {script}}

library(icesTAF)

## ---- Resolve target run ----------------------------------------------------

user_dir <- Sys.getenv("SA_ORG_USER", unset = "user3")
run_name <- Sys.getenv("SA_ORG_RUN",  unset = "NEA_saithe_2026_v7")

run_url <- sprintf(
  "https://stockassessment.org/datadisk/stockassessment/userdirs/%s/%s/conf/",
  user_dir, run_name
)

files <- c("model.cfg")

## ---- Resolve destination and fetch -----------------------------------------

dest <- taf.data.path("sam_config")
mkdir(dest)

for (f in files) {
  download(paste0(run_url, f), dir = dest)
}
