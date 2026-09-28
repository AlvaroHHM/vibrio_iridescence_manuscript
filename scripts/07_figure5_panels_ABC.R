#!/usr/bin/env Rscript
# ============================================================
# figure_panel_ABC_final_v3.R
# Panel A: Genome size
# Panel B: Genome quality metrics
# Panel C: Heatmap BGC types (expandido, sin números)
# ============================================================

library(readr)
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(tibble)
  library(ggsci)
  library(cowplot)
  library(pheatmap)
  library(png)
  library(RColorBrewer)
  library(grid)
  library(svglite)
})

# ------------------------------------------------------------
# 1. Datos genómicos
# ------------------------------------------------------------
genomes <- read_csv("../data/genome_metrics.csv", show_col_types = FALSE)

strain_order <- genomes %>%
  arrange(desc(Genome_size)) %>%
  pull(Code)

genomes$Code <- factor(genomes$Code, levels = strain_order)

# ------------------------------------------------------------
# 2. Cargar datos de BGC y preparar matriz
# ------------------------------------------------------------
bgc <- read.csv("../data/bgc_types_summary.csv", stringsAsFactors = FALSE)


# CSA25-control was not genome-sequenced; excluded from genomic analyses
bgc <- bgc %>% filter(Strain != "CSA25-control")

bgc_long <- bgc %>%
  separate_rows(BGC_Types, sep = ";\\s*") %>%
  separate(BGC_Types, into = c("Type", "Count"), sep = ":", convert = TRUE) %>%
  mutate(Count = as.numeric(Count)) %>%
  drop_na(Type, Count)

bgc_summary <- bgc_long %>%
  group_by(Strain, Type) %>%
  summarise(Count = sum(Count), .groups = "drop") %>%
  mutate(Strain = factor(Strain, levels = strain_order))

bgc_wide <- bgc_summary %>%
  pivot_wider(id_cols = Type, names_from = Strain, values_from = Count,
              values_fill = 0, values_fn = sum) %>%
  column_to_rownames("Type") %>%
  as.matrix()

strain_order <- intersect(strain_order, colnames(bgc_wide))
bgc_wide <- bgc_wide[, strain_order, drop = FALSE]

# Colores por cepa
strain_colors_aaas <- c(
  "1_MXM"      = "#3B4992",
  "3_MXM"      = "#008280",
  "6_VM"       = "#A20056",
  "11_VM"      = "#008B45",
  "15_CESAIBC" = "#EE0000",
  "AT_BV"      = "#631879",
  "8_VM"       = "#BB0021",
  "13_VM"      = "#5F559B",
  "9_VM"       = "#808180",
  "10_VM"      = "#1B1919"
)

# ------------------------------------------------------------
# Panel A: Genome size
# ------------------------------------------------------------
pA <- ggplot(genomes, aes(x = Code, y = Genome_size/1e6, fill = Code)) +
  geom_col(width = 0.7, color = "white", linewidth = 0.3, alpha = 0.7) +
  coord_flip() +
  scale_fill_manual(values = strain_colors_aaas) +
  labs(x = NULL, y = "Genome size (Mbp)") +
  theme_cowplot(font_size = 11) +
  theme(legend.position = "none",
        axis.text.y = element_text(size = 12),
        axis.text.x = element_text(size = 12)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05)))

# ------------------------------------------------------------
# Panel B: Genome quality metrics
# ------------------------------------------------------------
metrics_long <- genomes %>%
  select(Code, GC, Completeness, Coding_density) %>%
  pivot_longer(cols = c("GC", "Completeness", "Coding_density"),
               names_to = "Metric", values_to = "Value") %>%
  mutate(Metric = factor(Metric,
                         levels = c("GC", "Completeness", "Coding_density"),
                         labels = c("GC (%)", "Completeness (%)", "Coding density (%)")))

blue_palette <- c("GC (%)"             = "gray",
                  "Completeness (%)"   = "#9ecae1",
                  "Coding density (%)" = "#3182bd")

pB <- ggplot(metrics_long, aes(x = Code, y = Value, fill = Metric)) +
  geom_col(position = position_dodge2(width = 0.9, padding = 0.1),
           width = 0.7,
           color = "white", linewidth = 0.3) +
  scale_fill_manual(values = blue_palette) +
  labs(x = NULL, y = "Percentage (%)") +
  theme_cowplot(font_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 11),
    axis.text.y = element_text(size = 12),
    axis.title.y = element_text(size = 14),
    legend.position = "top",
    legend.title = element_blank(),
    legend.text = element_text(size = 12),      # 👈 letras de la leyenda más grandes
    legend.key.size = unit(0.5, "cm")           # opcional: cuadros de color más grandes
  ) +
  scale_y_continuous(limits = c(0, 110), breaks = seq(0, 100, by = 20),
                     expand = expansion(mult = c(0, 0.05))) +
  scale_x_discrete(expand = expansion(mult = c(0.03, 0.03))) +
  guides(fill = guide_legend(nrow = 1))

# ------------------------------------------------------------
# Panel C: Heatmap estilo plot_bgc_final.R (sin números, bordes blancos)
# ------------------------------------------------------------
my_palette_bgc <- colorRampPalette(c("white", "#67001f"))(100)

pheatmap(
  bgc_wide,
  color = my_palette_bgc,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  display_numbers = FALSE,
  border_color = "white",
  main = "",
  fontsize_row = 14,
  fontsize_col = 14,
  angle_col = 45,
  cellwidth = 30,
  cellheight = 20,
  legend = TRUE,
  filename = "heatmap_bgc_panel.png",
  width = 8,
  height = 8,
  dpi = 300,
  silent = TRUE
)

heatmap_img <- png::readPNG("heatmap_bgc_panel.png")
pC <- cowplot::ggdraw() + cowplot::draw_image(heatmap_img)

# ------------------------------------------------------------
# Combinar paneles
# ------------------------------------------------------------
top_row <- plot_grid(pA, pB, labels = c("A", "B"), ncol = 2,
                     rel_widths = c(1, 1.3), align = "h", axis = "tb",
                     label_size = 20)

pC_label <- ggdraw() +
  draw_plot(pC, x = 0, y = 0, width = 0.6, height = 1) +   # heatmap ocupa todo el ancho
  draw_plot_label(label = "C", x = 0.02, y = 0.95, size = 20, fontface = "bold")

panel_final <- ggdraw() +
  draw_plot(top_row, x = 0, y = 0.5, width = 1, height = 0.5) +
  draw_plot(pC_label, x = 0, y = 0, width = 1, height = 0.5)

# ------------------------------------------------------------
# Guardar
# ------------------------------------------------------------
ggsave("figure_panel_ABC_final_v3.pdf", panel_final,
       width = 14, height = 13)

cat("✅ Panel final v3 guardado en PNG, PDF y SVG\n")
