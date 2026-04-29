## Top-level workflow wrappers
##
## Usage:
##   source("run.R")
##
##   # Steal an assessment from stockassessment.org AND run the full pipeline
##   steal_taf("user3", "NEA_saithe_2026_v7", run = TRUE)
##
##   # Or do it in two steps
##   steal_taf("user3", "NEA_saithe_2026_v7")  # just download into boot/
##   run_taf()                                  # then run the analysis
##
##   # If boot/data already populated, just rerun the analysis
##   run_taf()
##   run_taf(clean = TRUE)              # wipe data/model/output/report and rerun
##   run_taf(steps = c("output", "report"))  # only re-run later stages

library(icesTAF)


## ---------------------------------------------------------------------------
## steal_taf() — snatch an assessment from stockassessment.org
## ---------------------------------------------------------------------------
##
## Sets two environment variables that the boot scripts (boot/sam_data.R,
## boot/sam_config.R) read at runtime to construct download URLs.
##
##   user_dir : userdirs subfolder on stockassessment.org, e.g. "user3"
##   run_name : assessment run name, e.g. "NEA_saithe_2026_v7"
##   run      : if TRUE, also call run_taf() after the boot phase
##   ...      : extra args passed to run_taf() when run = TRUE

steal_taf <- function(user_dir,
                      run_name,
                      run = FALSE,
                      ...) {

  msg <- function(x) message(format(Sys.time(), "[%H:%M:%S] "), x)

  Sys.setenv(SA_ORG_USER = user_dir,
             SA_ORG_RUN  = run_name)

  msg(sprintf("steal_taf: stockassessment.org/%s/%s", user_dir, run_name))
  msg("Running taf.boot() ...")
  taf.boot()

  if (isTRUE(run)) run_taf(...)
  invisible(TRUE)
}


## ---------------------------------------------------------------------------
## run_taf() — run the analysis pipeline
## ---------------------------------------------------------------------------

run_taf <- function(clean = FALSE,
                    boot  = FALSE,
                    steps = c("data", "model", "output", "report")) {

  t0 <- Sys.time()
  msg <- function(x) message(format(Sys.time(), "[%H:%M:%S] "), x)

  ## ---- Boot: only if explicitly requested or boot/data missing -------------
  if (boot || !dir.exists("boot/data")) {
    msg("Running taf.boot() ...")
    taf.boot()
  }

  ## ---- Optionally clean prior outputs --------------------------------------
  if (clean) {
    msg("Cleaning data/, model/, output/, report/ ...")
    clean(c("data", "model", "output", "report"))
  }

  ## ---- Run the four stages -------------------------------------------------
  for (s in steps) {
    msg(paste0("sourceTAF('", s, "') ..."))
    sourceTAF(s)
  }

  msg(sprintf("Done in %s.",
              format(round(difftime(Sys.time(), t0, units = "secs"), 1))))
  invisible(TRUE)
}
