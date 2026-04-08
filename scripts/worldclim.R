#!/usr/bin/env Rscript
##' Extract WorldClim (BioClim) variables at NEON aquatic field sites.
##' Run from repo root: Rscript scripts/worldclim.R
##' Requires: geodata, terra

script_dir <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  f <- sub("^--file=", "", args[grep("^--file=", args)])
  if (length(f)) dirname(normalizePath(f[1])) else getwd()
}

main <- function() {
  if (!requireNamespace("geodata", quietly = TRUE) ||
      !requireNamespace("terra", quietly = TRUE)) {
    stop(
      "Install dependencies: install.packages(c(\"geodata\", \"terra\"))",
      call. = FALSE
    )
  }

  meta_url <- "https://raw.githubusercontent.com/eco4cast/neon4cast-targets/main/NEON_Field_Site_Metadata_20220412.csv"
  site_data <- utils::read.csv(meta_url, stringsAsFactors = FALSE)
  aquatic <- site_data[as.integer(site_data$aquatics) == 1L, , drop = FALSE]

  if (!nrow(aquatic)) {
    stop("No aquatic sites found in metadata.", call. = FALSE)
  }

  lon <- aquatic$field_longitude
  lat <- aquatic$field_latitude
  if (any(is.na(lon)) || any(is.na(lat))) {
    stop("Missing latitude/longitude for some sites.", call. = FALSE)
  }

  pts <- terra::vect(
    data.frame(lon = lon, lat = lat),
    geom = c("lon", "lat"),
    crs = "EPSG:4326"
  )

  wc_path <- file.path(script_dir(), "worldclim_cache")
  dir.create(wc_path, showWarnings = FALSE, recursive = TRUE)

  wc <- geodata::worldclim_global(var = "bio", res = 10, path = wc_path)
  ext <- terra::extract(wc, pts, ID = FALSE)

  out <- data.frame(
    field_site_id = aquatic$field_site_id,
    field_site_name = aquatic$field_site_name,
    ext,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  out_path <- file.path(script_dir(), "worldclim_neon_aquatic_sites.csv")
  utils::write.csv(out, out_path, row.names = FALSE)
  message("Wrote ", nrow(out), " rows to ", out_path)
  invisible(out)
}

main()
