#!/usr/bin/env Rscript
# ============================================================
# genome_metrics_plots.R
# Gráficos de calidad genómica para el manuscrito
# Usa ggsci (pal_aaas) y cowplot (theme_cowplot)
# ============================================================

library(readr)
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(ggsci)      # pal_aaas
  library(cowplot)    # theme_cowplot
  library(scales)     # para formatear ejes
})

# ------------------------------------------------------------
# Datos de la Tabla S4 (inglés)
# ------------------------------------------------------------
genomes <- read_csv("../data/genome_metrics.csv", show_col_types = FALSE)

# Ordenar por tamaño del genoma (descendente)
genomes <- genomes %>%
  mutate(Code = reorder(Code, Genome_size))

# ------------------------------------------------------------
# Gráfico 1: Barras horizontales – Genome size
# ------------------------------------------------------------
p1 <- ggplot(genomes, aes(x = Code, y = Genome_size/1e6,
                          fill = Code)) +
  geom_col(width = 0.7, color = "black", linewidth = 0.3) +
  coord_flip() +
  scale_fill_aaas() +
  labs(x = NULL, y = "Genome size (Mbp)",
       title = "Genome size of sequenced isolates") +
  theme_cowplot(font_size = 12) +
  theme(legend.position = "none",
        axis.text.y = element_text(size = 10, face = "bold"),
        axis.text.x = element_text(size = 10),
        plot.title = element_text(face = "bold", hjust = 0.5)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05)))

# Guardar
ggsave("genome_size_horizontal.svg", p1, width = 8, height = 5, bg = "white")

# ------------------------------------------------------------
# Gráfico 2: Barras verticales – GC, Completeness, Coding density
# ------------------------------------------------------------
# Pasar a formato largo
metrics_long <- genomes %>%
  select(Code, GC, Completeness, Coding_density) %>%
  pivot_longer(cols = c("GC", "Completeness", "Coding_density"),
               names_to = "Metric", values_to = "Value")

# Etiquetas elegantes
metrics_long$Metric <- factor(metrics_long$Metric,
                              levels = c("GC", "Completeness", "Coding_density"),
                              labels = c("GC (%)", "Completeness (%)", "Coding density (%)"))

p2 <- ggplot(metrics_long, aes(x = Code, y = Value, fill = Metric)) +
  geom_col(position = position_dodge(width = 0.8),
           width = 0.7, color = "black", linewidth = 0.3) +
  scale_fill_aaas() +
  labs(x = NULL, y = "Percentage (%)",
       title = "Genome quality metrics") +
  theme_cowplot(font_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 9, face = "bold"),
        axis.text.y = element_text(size = 10),
        legend.position = "bottom",
        legend.title = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5)) +
  scale_y_continuous(limits = c(0, 110), breaks = seq(0, 100, by = 20),
                     expand = expansion(mult = c(0, 0.05))) +
  guides(fill = guide_legend(nrow = 1))

# Guardar
ggsave("genome_metrics_vertical.svg", p2, width = 10, height = 5.5, bg = "white")

cat("✅ Gráficos generados:\n")
cat("  - genome_size_horizontal.png/pdf\n")
cat("  - genome_metrics_vertical.png/pdf\n")
