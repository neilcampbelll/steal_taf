## copy_taf() - copy TAF assessment files to a target directory
##
## Creates a directory named "<year>_<run_name>_assessment" in the same
## parent directory as the current working directory, then copies all
## required TAF files into it.
##
## Usage:
##   source("copy_taf.R")
##   copy_taf("user3", "WBCod_2027_final")

copy_taf <- function(user_dir, run_name) {
  
  msg <- function(x) message(format(Sys.time(), "[%H:%M:%S] "), x)
  
  ## ---- Construct target directory ------------------------------------------
  
  target_name <- sprintf("%s_%s_assessment", format(Sys.Date(), "%Y"), run_name)
  target_dir  <- file.path(dirname(getwd()), target_name)
  
  ## ---- Create target directory structure -----------------------------------
  
  dir.create(target_dir,                    showWarnings = FALSE, recursive = TRUE)
  dir.create(file.path(target_dir, "boot"), showWarnings = FALSE)
  
  ## ---- Copy TAF scripts ----------------------------------------------------
  
  scripts <- c("data.R", "model.R", "output.R",
               "report.R", "report_plots.R", "report_tables.R")
  
  for (s in scripts) {
    if (file.exists(s)) {
      file.copy(s, file.path(target_dir, s), overwrite = TRUE)
      msg(paste("Copied", s))
    } else {
      warning("Script not found, skipping: ", s)
    }
  }
  
  ## ---- Patch model.R for TAF boot path -------------------------------------
  ## The local model.R uses taf.data.path("sam_config", "model.cfg") which
  ## reflects the steal_taf boot structure. In the TAF repo, model.cfg sits
  ## flat in boot/data/, so we patch the copied model.R accordingly.
  
  model_r_path <- file.path(target_dir, "model.R")
  model_r      <- readLines(model_r_path)
  model_r      <- gsub(
    'taf.data.path("sam_config", "model.cfg")',
    'taf.boot.path("data", "model.cfg")',
    model_r, fixed = TRUE
  )
  writeLines(model_r, model_r_path)
  msg("Patched model.R: updated loadConf() path")
  
  ## ---- Copy downloaded data files to boot/initial -------------------------
  
  src_dirs <- c("boot/data/sam_data", "boot/data/sam_config")
  dest     <- file.path(target_dir, "boot/initial/data")
  dir.create(dest, showWarnings = FALSE, recursive = TRUE)
  
  for (src in src_dirs) {
    if (dir.exists(src)) {
      files <- list.files(src, full.names = TRUE)
      file.copy(files, dest, overwrite = TRUE)
      msg(sprintf("Copied %d file(s) from %s to boot/initial/data", length(files), src))
    } else {
      warning("Source directory not found, skipping: ", src)
    }
  }
  
  ## ---- Write DATA.bib ------------------------------------------------------
  ## One @Misc entry per file, with originator citing the stockassessment.org
  ## run the files were downloaded from. title, period etc. should be filled
  ## in manually after copying.
  
  originator <- sprintf("stockassessment.org/%s/%s", user_dir, run_name)
  year       <- format(Sys.Date(), "%Y")
  
  all_files <- c(
    list.files("boot/data/sam_data",   full.names = FALSE),
    list.files("boot/data/sam_config", full.names = FALSE)
  )
  
  bib_entries <- vapply(all_files, function(f) {
    sprintf(
      "@Misc{%s,\n  originator = {%s},\n  year       = {%s},\n  title      = {},\n  period     = {},\n  access     = {Public},\n  source     = {file},\n}",
      f, originator, year
    )
  }, character(1))
  
  writeLines(paste(bib_entries, collapse = "\n\n"),
             file.path(target_dir, "boot", "DATA.bib"))
  msg("Written boot/DATA.bib")
  
  ## ---- Write SOFTWARE.bib --------------------------------------------------
  ## draft.software() writes to boot/SOFTWARE.bib by default; we capture the
  ## output and write it to the target directory instead.
  
  software_bib <- draft.software("stockassessment")
  writeLines(as.character(software_bib),
             file.path(target_dir, "boot", "SOFTWARE.bib"))
  msg("Written boot/SOFTWARE.bib")
  
  ## ---- Write .gitignore ----------------------------------------------------
  ## boot/initial/ is intentionally NOT excluded - those are the input data
  ## files that should be committed to the TAF repository.
  
  gitignore <- paste(
    "boot/data/",
    "boot/library/",
    "boot/software/",
    "data/",
    "model/",
    "output/",
    "report/",
    "*.RData",
    sep = "\n"
  )
  
  writeLines(gitignore, file.path(target_dir, ".gitignore"))
  msg("Written .gitignore")
  
  msg(sprintf("copy_taf: files ready in %s", target_dir))
  invisible(TRUE)
}