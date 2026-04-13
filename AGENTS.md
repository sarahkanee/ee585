# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

R-based ecological forecasting pipeline (EE 585) that downloads aquatic targets from NEON, calibrates a linear regression model (air temp → water temp), and generates ensemble forecasts for the EFI NEON Forecasting Challenge.

### Running the pipeline

```bash
cd /workspace && Rscript main.R
```

The full pipeline requires internet access to download data from `data.ecoforecast.org` (targets) and NOAA GEFS (weather forecasts via Apache Arrow/S3). If these external servers are unreachable, the download steps will fail — this is expected.

### Known issues

- `02_calibrate_forecast.R` starts with `{r}` (R Markdown chunk syntax), which causes `source()` to fail with `object 'r' not found`. The `calibrate_forecast()` function defined there works correctly — the issue is only the stray `{r}` line.
- `02_calibrate_forecast_Eric.R` has the same issue wrapped in `` ```{r} ... ``` `` fences.

### Required R packages

All installed to `/usr/local/lib/R/site-library`:

| Package | Source | Notes |
|---------|--------|-------|
| `tidyverse` | CRAN | Includes dplyr, ggplot2, readr, tidyr, etc. |
| `lubridate` | CRAN | Date handling (included in tidyverse but also loaded explicitly) |
| `rMR` | CRAN | Version 1.1.0 specifically — provides `Eq.Ox.conc()` for dissolved oxygen |
| `neon4cast` | GitHub (`eco4cast/neon4cast`) | NOAA data access and forecast submission |
| `arrow` | CRAN | Required by neon4cast for S3/Parquet data access |
| `devtools` / `remotes` | CRAN | For installing GitHub packages |

### No tests or linter

This repository has no automated tests, no linter configuration, and no build system. It is a collection of R scripts run via `Rscript main.R`.
