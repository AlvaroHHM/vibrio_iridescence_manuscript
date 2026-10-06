#!/usr/bin/env Rscript
# ============================================================
# 08_go_enrichment_figure.R
# Figure S1: GO enrichment across strains (faceted barplot)
# Uses the same wine-red palette as the other figures.
# ============================================================

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(ggplot2)
  library(cowplot)
})

# ------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------
go_file <- "../data/go_enrichment_full.csv"
if (!file.exists(go_file)) stop("File not found: ", go_file)

go <- read_csv(go_file, show_col_types = FALSE)
cat("Rows read:", nrow(go), "\n")

# ------------------------------------------------------------
# 2. Clean and prepare
# ------------------------------------------------------------
go_clean <- go %>%
  mutate(
    cepa = as.character(cepa),
    GO = as.character(GO),
    p_value = as.numeric(p_value)
  ) %>%
  filter(!is.na(p_value), !is.na(GO), !is.na(cepa)) %>%
  mutate(logp = -log10(p_value))

# Top 3 GO terms per strain
top_per_strain <- go_clean %>%
  group_by(cepa) %>%
  arrange(p_value) %>%
  slice_head(n = 3) %>%
  ungroup() %>%
  mutate(GO = factor(GO, levels = unique(GO[order(p_value)])))

# ------------------------------------------------------------
# 3. Plot with wine-red palette
# ------------------------------------------------------------
p <- ggplot(top_per_strain, aes(x = GO, y = logp, fill = logp)) +
  geom_col(width = 0.7, color = "black", linewidth = 0.3) +
  coord_flip() +
  facet_wrap(~ cepa, scales = "free_y", ncol = 2) +
  scale_fill_gradient(low = "#fcae91", high = "#67001f") +
  labs(
    x = NULL,
    y = expression(-log[10](p[unadjusted]))#,
   # title = "Top 3 GO terms per strain",
   # subtitle = "None of the terms survived FDR correction (p_adj = 1.0)"
  ) +
  theme_cowplot(font_size = 11) +
  theme(
    legend.position = "none",
    strip.background = element_rect(fill = "white", color = NA),
    strip.text = element_text(face = "bold", size = 10),
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, size = 9),
    axis.text.y = element_text(size = 8)
  )

# ------------------------------------------------------------
# 4. Save
# ------------------------------------------------------------
ggsave("FigureS1_GO_enrichment.pdf", p, width = 10, height = 8, bg = "white")
message("✅ FigureS1_GO_enrichment.pdf generated with wine-red palette")
