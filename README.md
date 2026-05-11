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

Once you have a working local assessment, use `copy_taf()` to prepare the
files for submission to the ICES TAF repository (see
[Copying to a TAF repository](#copying-to-a-taf-repository) below).

## Prerequisites

You need `icesTAF` (which pulls in `TAF`) and `stockassessment` installed
before cloning this repo. `icesTAF` is required to run `taf.boot()` and
the rest of the framework; `stockassessment` is the assessment model.

```r
# icesTAF and other ICES packages from the canonical ICES r-universe
install.packages("icesTAF",
                 repos = c(CRAN = "https://cloud.r-project.org/",
                           ICES = "https://ices-tools-prod.r-universe.dev"))

# stockassessment from the SAM r-universe
install.packages("stockassessment",
                 repos = c(CRAN = "https://cloud.r-project.org/",
                           SAM  = "https://fishfollower.r-universe.dev"))
```

The ICES r-universe at <https://ices-tools-prod.r-universe.dev> is the
authoritative source for ICES R packages and is kept up to date
continuously. CRAN copies exist but can lag.

`stockassessment` is also pinned in `boot/SOFTWARE.bib` and will be
re-installed at boot time to guarantee version consistency. See
[Pinning the SAM version for final assessments](#pinning-the-sam-version-for-final-assessments)
below for how to update the pin.

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
|   |-- sam_data.R            fetches SAM input files (including extras)
|   `-- sam_config.R          fetches model.cfg
|-- data.R                    preprocess data, write TAF CSVs
|-- model.R                   fit SAM, run retro
|-- output.R                  extract result tables
|-- report.R                  orchestrates the report scripts
|-- report_plots.R            standard SAM plots
|-- report_tables.R           summary tables
|-- run.R                     steal_taf() and run_taf() wrappers
|-- copy_taf.R                copy_taf() for TAF repository preparation
|-- .gitignore
`-- README.md
```

A `LICENSE` file is added when the GitHub repo is created.

After `taf.boot()` runs, `boot/data/sam_data/` and `boot/data/sam_config/`
are populated with the fetched files. After `run_taf()`, the `data/`,
`model/`, `output/` and `report/` folders contain the analysis products.
None of these are committed to the repo - they're regenerated from the
scripts.

## Copying to a TAF repository

Once your local assessment is running and producing results that match
stockassessment.org, use `copy_taf()` to prepare the files for a TAF
repository:

```r
source("copy_taf.R")
copy_taf("user3", "WBCod_2027_final")
```

This will create a directory named `2026_WBCod_2027_final_assessment`
alongside your current working directory, containing:

- All TAF scripts (`data.R`, `model.R`, `output.R`, `report.R`, etc.)
  with paths patched for the TAF boot structure
- `boot/initial/data/` with all downloaded data files
- `boot/DATA.bib` with a per-file entry for each data file, citing the
  stockassessment.org run as the source
- `boot/SOFTWARE.bib` generated from the installed `stockassessment` package
- `run.R` to run the full pipeline via `taf.boot()` and the four TAF stages
- `.gitignore` configured to exclude generated outputs

You can then push the contents of that directory to your blank TAF
repository on GitHub.

### Before you push: verify your assessment

> **Important:** `steal_taf` automates the mechanics of converting an
> assessment to TAF format, but it cannot verify that the science is
> correct. Before pushing to the TAF repository, you must satisfy yourself
> that:

- The results (SSB, Fbar, recruitment, catch) match those on
  stockassessment.org to an acceptable degree of precision.
- You understand any stock-specific preprocessing in the original
  `datascript.R` on stockassessment.org and have replicated it correctly
  in `data.R`.
- The `DATA.bib` entries are complete -- the `title` and `period` fields
  are left blank by `copy_taf()` and should be filled in before submission.

### Stock-specific preprocessing

The most common source of discrepancies between a `steal_taf` run and
stockassessment.org is stock-specific preprocessing in `datascript.R` that
goes beyond reading the standard input files. A typical example is an
external survey CV file used to set observation weights:

```r
mod.cvs <- stockassessment:::read.surveys("coast_survey_cv.dat")
attr(surveys[[2]], "weight") <- 1/log((mod.cvs[[1]])^2+1)
```

`steal_taf` will download any additional `.dat` or `.csv` files it finds in
the stockassessment.org data directory, but it cannot automatically replicate
custom preprocessing code. You should:

1. Check `datascript.R` for your run at:
   `https://stockassessment.org/datadisk/stockassessment/userdirs/{user}/{run}/src/datascript.R`
2. Identify any preprocessing beyond the standard `read.ices()` calls.
3. Add the equivalent code to `data.R` in the marked stock-specific section.
4. Verify that your results match stockassessment.org before pushing.

## Adapting for a specific stock

Most of the framework is stock-agnostic. The places likely to need
stock-specific tailoring are commented in each script. Briefly:

- **`boot/sam_data.R`** -- any extra input files beyond the standard set
  will be downloaded automatically if they have a `.dat` or `.csv`
  extension. If files with other extensions are needed, add them manually.
- **`data.R`** -- add stock-specific preprocessing (plus group, year
  truncation, survey averaging, observation weights, etc.) before
  `setup.sam.data()`. Also rename the `survey_1`, `survey_2` outputs to
  something meaningful.
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
