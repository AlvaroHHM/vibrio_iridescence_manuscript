#!/usr/bin/env Rscript
# ============================================================
# 04_kegg_heatmap.R
# KEGG pathway heatmap for selected functional blocks
# Uses only map identifiers (M) to avoid duplication with ko (K)
# ============================================================

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(pheatmap)
  library(tibble)
})

# ------------------------------------------------------------
# 1. Functional groups (only map identifiers)
# ------------------------------------------------------------
groups_interest <- list(
  "Cellular processes (virulence, secretion, biofilm)" = c(
    "map02010", "map02020", "map02024", "map02025", "map02026",
    "map02040", "map02060", "map03010", "map03070", "map03440", "map04973"),
  "Pathogenicity and host-bacteria interactions" = c(
    "map05111", "map05132", "map05134", "map04621", "map04626", "map01503")
)

group_colors <- c(
  "Cellular processes (virulence, secretion, biofilm)" = "#d62728",
  "Pathogenicity and host-bacteria interactions" = "#9467bd"
)

# Assign group to each code
all_codes <- unlist(groups_interest, use.names = FALSE)
group_assigned <- rep(names(groups_interest), times = sapply(groups_interest, length))
names(group_assigned) <- all_codes

# ------------------------------------------------------------
# 2. Load KEGG pathway count matrix
# ------------------------------------------------------------
kegg_file <- "../data/kegg_pathway_counts.csv"
if (!file.exists(kegg_file)) {
  stop("File not found: ", kegg_file,
       ". Please ensure kegg_pathway_counts.csv is in data/.")
}

kegg_data <- read_delim(kegg_file, delim = ",", col_names = TRUE, show_col_types = FALSE) %>%
  column_to_rownames(var = names(.)[1])

# ------------------------------------------------------------
# 3. Filter selected pathways (only map)
# ------------------------------------------------------------
pathways_present <- intersect(all_codes, rownames(kegg_data))
if (length(pathways_present) == 0) {
  stop("None of the selected map pathways are in the CSV.")
}

mat <- kegg_data[pathways_present, , drop = FALSE]

# Sort by group and code
row_group <- group_assigned[rownames(mat)]
mat <- mat[order(row_group, rownames(mat)), , drop = FALSE]
row_group <- group_assigned[rownames(mat)]

# ------------------------------------------------------------
# 4. Row annotation
# ------------------------------------------------------------
annotation_row <- data.frame(Group = row_group, row.names = rownames(mat))
ann_colors <- list(Group = group_colors)

# ------------------------------------------------------------
# 5. Short labels for Y-axis (M02010, M02020, ...)
# ------------------------------------------------------------
short_labels <- sub("^map", "M", rownames(mat))

# ------------------------------------------------------------
# 6. Generate heatmap (PDF)
# ------------------------------------------------------------
pheatmap(mat,
         color = colorRampPalette(c("white", "#67001f"))(100),
         cluster_rows = FALSE,
         cluster_cols = TRUE,
         annotation_row = annotation_row,
         annotation_colors = ann_colors,
         labels_row = short_labels,
         main = "KEGG pathways relevant to pathogenic proteins",
         filename = "FigureS2_KEGG_heatmap.pdf",
         width = 10,
         height = 7,
         fontsize_row = 8,
         fontsize_col = 8,
         angle_col = 45,
         cellwidth = 12,
         cellheight = 10)

message("✅ FigureS2_KEGG_heatmap.pdf generated (only map identifiers)")
