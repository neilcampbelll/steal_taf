## Fetch SAM model configuration from stockassessment.org
##
## Called automatically by taf.boot() because DATA.bib has:
##   @Misc{sam_config, ..., source = {script}}

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
