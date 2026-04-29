# steal_taf

A template for converting a SAM stock assessment hosted on
[stockassessment.org](https://stockassessment.org) into the ICES
[Transparent Assessment Framework](https://taf.ices.dk) (TAF) format.

## What this gives you

Run two commands and you get a fully reproducible TAF assessment:

```r
source("run.R")
steal_taf("user3", "WBCod_2027_final", run = TRUE)
```

That will:

1. Download all SAM input files (`cn.dat`, `cw.dat`, ..., `survey.dat`) and
   the model configuration from the specified stockassessment.org run
   into `boot/data/`.
2. Run `data.R` -> read those files, write tidy CSVs and a `data.RData`
   into `data/`.
3. Run `model.R` -> fit SAM and a 5-year retrospective; save to `model/`.
4. Run `output.R` -> extract summary, parameter, N-at-age, F-at-age and
   Mohn's rho tables to `output/`.
5. Run `report.R` -> orchestrate `report_plots.R` and `report_tables.R`
   to produce diagnostic plots and formatted tables in `report/`.

## Prerequisites

```r
install.packages("icesTAF")
install.packages("stockassessment",
                 repos = c(CRAN = "https://cloud.r-project.org/",
                           SAM  = "https://fishfollower.r-universe.dev"))
```

## Usage

```r
source("run.R")

# One-shot: steal AND run
steal_taf("user3", "WBCod_2027_final", run = TRUE)

# Or in two steps
steal_taf("user3", "WBCod_2027_final")    # just download
run_taf()                                  # then run analysis

# After files are already downloaded
run_taf()                                  # re-run analysis only
run_taf(clean = TRUE)                      # wipe outputs and rerun
run_taf(steps = c("output.R", "report.R")) # only re-run later stages
run_taf(boot = TRUE)                       # force re-fetch
```

## Project structure

```
.
|-- boot/
|   |-- DATA.bib              data provenance entries
|   |-- SOFTWARE.bib          software provenance entries
|   |-- sam_data.R            fetches SAM input files
|   `-- sam_config.R          fetches model.cfg
|-- data.R                    preprocess data, write TAF CSVs
|-- model.R                   fit SAM, run retro
|-- output.R                  extract result tables
|-- report.R                  orchestrates the report scripts
|-- report_plots.R            standard SAM plots
|-- report_tables.R           summary tables
|-- run.R                     steal_taf() and run_taf() wrappers
|-- .gitignore
|-- LICENSE
`-- README.md
```

After `taf.boot()` runs, `boot/data/sam_data/` and `boot/data/sam_config/`
are populated with the fetched files. After `run_taf()`, the `data/`,
`model/`, `output/` and `report/` folders contain the analysis products.
None of these are committed to the repo - they're regenerated from the
scripts.

## Adapting for a specific stock

Most of the framework is stock-agnostic. The places likely to need
stock-specific tailoring are commented in each script. Briefly:

- **`boot/sam_data.R`** -- if your stock uses extra input files beyond the
  standard 11 SAM `.dat` files (e.g. external survey CV files), add them
  to the `files` vector.
- **`data.R`** -- if you need a plus group, year truncation, survey
  averaging, or other preprocessing, add it before `setup.sam.data()`.
  Also rename the `survey_1`, `survey_2` outputs to something meaningful.
- **`model.R`** -- adjust the number of retro peels, add any `conf`
  overrides after `loadConf()`.
- **`output.R`** -- add any stock-specific outputs (forecast, reference
  points, advice options).
- **`report_plots.R` / `report_tables.R`** -- add any plots and tables
  that the WG report expects.

## Pinning the SAM version for final assessments

For a finalised assessment, pin the `stockassessment` package version
in `boot/SOFTWARE.bib` to a specific commit SHA or release tag rather
than `master`. After installing your working version, get the SHA with:

```r
packageDescription("stockassessment")$RemoteSha
```

and replace `master` in the `source` field accordingly.
