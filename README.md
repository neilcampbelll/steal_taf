# NEA saithe assessment — TAF version

TAF (Transparent Assessment Framework) version of the Northeast Arctic
saithe (*Pollachius virens*) assessment, originally run on
[stockassessment.org](https://stockassessment.org/datadisk/stockassessment/userdirs/user3/NEA_saithe_2026_v7/)
as run `NEA_saithe_2026_v7`.

## Reproducing the analysis

The simplest way is to use the wrappers in `run.R`:

```r
source("run.R")

# Steal an assessment from stockassessment.org and run the full pipeline
steal_taf("user3", "NEA_saithe_2026_v7", run = TRUE)
```

`steal_taf()` sets two environment variables (`SA_ORG_USER`, `SA_ORG_RUN`) that
the boot scripts read to construct the download URL, then calls `taf.boot()`
to fetch input data and configuration. With `run = TRUE` it also runs the
analysis pipeline afterwards.

For more control:

```r
source("run.R")

steal_taf("user3", "NEA_saithe_2026_v7")    # download only, into boot/

run_taf()                                    # run analysis (full pipeline)
run_taf(clean = TRUE)                        # wipe data/model/output/report and rerun
run_taf(boot  = TRUE)                        # force re-fetch from stockassessment.org
run_taf(steps = c("output", "report"))       # only re-run later stages
```

If `steal_taf()` isn't called, the boot scripts fall back to the NEA saithe
2026 v7 run baked in as defaults, so the project still works standalone.

The pipeline executes, in order:

1. **`data.R`** — read raw `.dat` files from `boot/data/`, write flat CSVs and a `data.RData` object into `data/`.
2. **`model.R`** — fit SAM and run a 5-year retrospective; save fits to `model/`.
3. **`output.R`** — extract summary, parameter, N-at-age, F-at-age and Mohn's rho tables to `output/`.
4. **`report.R`** — orchestrates `report_plots.R` and `report_tables.R` to produce diagnostic plots and formatted tables in `report/`.

## Folder structure

```
.
├── boot/
│   ├── DATA.bib          # data provenance entries
│   ├── SOFTWARE.bib      # software provenance entries
│   ├── sam_data.R        # fetches input .dat files
│   └── sam_config.R      # fetches model.cfg
├── data.R
├── model.R
├── output.R
├── report.R
├── report_plots.R
├── report_tables.R
├── run.R                 # top-level workflow wrapper
└── README.md
```

After `taf.boot()` runs, `boot/data/sam_data/` and `boot/data/sam_config/`
are populated with the fetched files. After `sourceAll()`, the `data/`,
`model/`, `output/` and `report/` folders contain the analysis products.

## Notes

- `coast_survey_cv.dat` is fetched from stockassessment.org for provenance
  but is **not** currently used in the model fit. If/when external survey
  CVs are wired into `setup.sam.data()`, update `data.R` accordingly.
- The retrospective is set to 5 peels in `model.R`.
