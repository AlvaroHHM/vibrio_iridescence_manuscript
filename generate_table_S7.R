#!/usr/bin/env Rscript
# ============================================================
# generate_table_S7.R
# Genera la Tabla S7: una fila por región con MiBIG agrupados
# ============================================================

suppressPackageStartupMessages({
  library(jsonlite)
  library(dplyr)
  library(purrr)
  library(readr)
  library(stringr)
  library(tidyr)
})

# ------------------------------------------------------------
# 1. Rutas
# ------------------------------------------------------------
antismash_dir <- "/home/alvaro/Desktop/Doctorado/Articulos en proceso/Bacterias_fernando/20230716_processed/annotations/antismash_extracted"
strain_map <- c("4_SR" = "AT_BV")

# ------------------------------------------------------------
# 2. Extraer regiones de los JSON
# ------------------------------------------------------------
extract_regions_from_json <- function(json_file) {
  strain_raw <- basename(dirname(json_file))
  strain <- ifelse(strain_raw %in% names(strain_map),
                   strain_map[strain_raw], strain_raw)
  data <- fromJSON(json_file, simplifyVector = FALSE)
  records <- data$records
  if (is.null(records) || length(records) == 0) return(NULL)

  rows <- list()
  for (rec in records) {
    contig_id <- if (!is.null(rec$id)) rec$id else "NA"
    areas <- rec$areas
    if (is.null(areas) || length(areas) == 0) next
    for (i in seq_along(areas)) {
      area <- areas[[i]]
      products <- area$products
      protocluster <- if (!is.null(products) && length(products) > 0) {
        paste(unlist(products), collapse = "; ")
      } else "NA"

      rows[[length(rows) + 1]] <- data.frame(
        Isolate = strain,
        Contig = as.character(contig_id),
        Region = as.character(i),
        Start = as.character(area$start),
        End = as.character(area$end),
        Protocluster_type = protocluster,
        stringsAsFactors = FALSE
      )
    }
  }
  if (length(rows) == 0) return(NULL)
  bind_rows(rows)
}

json_files <- list.files(antismash_dir, pattern = "\\.json$",
                         recursive = TRUE, full.names = TRUE)
all_regions <- map_dfr(json_files, extract_regions_from_json)

# ------------------------------------------------------------
# 3. Extraer MiBIG de los archivos .txt
# ------------------------------------------------------------
extract_mibig_from_txt <- function(txt_file) {
  lines <- readLines(txt_file, warn = FALSE)
  start_idx <- grep("^Significant hits:", lines)
  if (length(start_idx) == 0) return(NULL)
  start_idx <- start_idx[1] + 1
  end_idx <- grep("^Details:", lines)
  if (length(end_idx) == 0) end_idx <- length(lines) + 1
  end_idx <- end_idx[1] - 1
  if (start_idx > end_idx) return(NULL)
  hit_lines <- lines[start_idx:end_idx]
  hit_lines <- hit_lines[grepl("^[0-9]+\\.", hit_lines)]
  if (length(hit_lines) == 0) return(NULL)
  hits <- str_match(hit_lines, "^[0-9]+\\.\\s+(BGC[0-9]+\\.[0-9]+)\\s+(.*)$")
  hits <- hits[!is.na(hits[, 1]), , drop = FALSE]
  if (nrow(hits) == 0) return(NULL)
  data.frame(
    MiBIG_accession = hits[, 2],
    MiBIG_match = hits[, 3],
    stringsAsFactors = FALSE
  )
}

kb_dirs <- list.dirs(antismash_dir, recursive = TRUE, full.names = TRUE)
kb_dirs <- kb_dirs[grepl("knownclusterblast$", kb_dirs)]

mibig_list <- list()
for (kb_dir in kb_dirs) {
  strain_raw <- basename(dirname(kb_dir))
  strain <- ifelse(strain_raw %in% names(strain_map),
                   strain_map[strain_raw], strain_raw)
  txt_files <- list.files(kb_dir, pattern = "\\.txt$", full.names = TRUE)
  for (txt in txt_files) {
    fname <- basename(txt)
    m <- str_match(fname, "^(contig_[0-9]+)_c([0-9]+)\\.txt$")
    if (is.na(m[1, 1])) next
    contig <- m[1, 2]
    region <- m[1, 3]
    mibig_df <- extract_mibig_from_txt(txt)
    if (is.null(mibig_df) || nrow(mibig_df) == 0) next
    mibig_df$Isolate <- strain
    mibig_df$Contig <- contig
    mibig_df$Region <- region
    mibig_list[[length(mibig_list) + 1]] <- mibig_df
  }
}

if (length(mibig_list) == 0) {
  all_mibig <- data.frame(Isolate = character(), Contig = character(),
                          Region = character(), MiBIG_accession = character(),
                          MiBIG_match = character())
} else {
  all_mibig <- bind_rows(mibig_list)
}

# ------------------------------------------------------------
# 4. Agrupar MiBIG por región (una fila por región)
# ------------------------------------------------------------
mibig_grouped <- all_mibig %>%
  group_by(Isolate, Contig, Region) %>%
  summarise(
    MiBIG_accession = paste(unique(MiBIG_accession), collapse = "; "),
    MiBIG_match = paste(unique(MiBIG_match), collapse = "; "),
    .groups = "drop"
  )

# Unir con las regiones
all_regions <- all_regions %>%
  left_join(mibig_grouped, by = c("Isolate", "Contig", "Region")) %>%
  mutate(
    MiBIG_accession = ifelse(is.na(MiBIG_accession), "NA", MiBIG_accession),
    MiBIG_match = ifelse(is.na(MiBIG_match), "NA", MiBIG_match)
  )

# ------------------------------------------------------------
# 5. Guardar Tabla S7
# ------------------------------------------------------------
output_dir <- "supplementary_tables"
if (!dir.exists(output_dir)) dir.create(output_dir)
output_file <- file.path(output_dir, "Table_S7_antiSMASH_regions.csv")
write_csv(all_regions, output_file)

cat("\n✅ Tabla S7 generada:", output_file, "\n")
cat("Total de regiones (una fila por región):", nrow(all_regions), "\n\n")
cat("Resumen por cepa:\n")
print(all_regions %>% count(Isolate))
