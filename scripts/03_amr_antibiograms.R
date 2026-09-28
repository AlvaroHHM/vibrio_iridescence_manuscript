#!/usr/bin/env Rscript
# ============================================================
# panel_amr_antibiogramas_invertido.R
# Panel A: Antibiogramas (barras facetadas)
# Panel B: Heatmap AMRFinderPlus
# ============================================================

library(readr)
suppressPackageStartupMessages({
  library(pheatmap)
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(tibble)
  library(ggsci)
  library(cowplot)
  library(png)
  library(RColorBrewer)
  library(grid)
})

# setwd() eliminado; usar here::here() o ruta relativa

# ============================================================
# PARTE 1: Heatmap AMRFinderPlus (se generará para Panel B)
# ============================================================

amr <- read.csv("../data/amrfinder_genes.csv", stringsAsFactors = FALSE)
classes <- read.csv("../data/amrfinder_classes.csv", stringsAsFactors = FALSE)

amr <- left_join(amr, classes, by = "Gene") %>%
  mutate(Class = ifelse(is.na(Class), "Other", Class))

amr <- amr %>%
  filter(Strain != "CSA25-control") %>%
  mutate(Identity = as.numeric(Identity)) %>%
  drop_na(Identity)

amr_clean <- amr %>%
  group_by(Strain, Gene, Class) %>%
  summarise(Identity = mean(Identity), .groups = "drop")

amr_wide <- amr_clean %>%
  select(Gene, Strain, Identity) %>%
  pivot_wider(names_from = Strain, values_from = Identity,
              values_fill = 0, values_fn = mean) %>%
  column_to_rownames("Gene") %>%
  as.matrix()

row_order <- amr_clean %>%
  distinct(Gene, Class) %>%
  arrange(Class, Gene) %>%
  pull(Gene)

amr_wide <- amr_wide[row_order, , drop = FALSE]

annotation_row <- amr_clean %>%
  distinct(Gene, Class) %>%
  column_to_rownames("Gene") %>%
  .[row_order, , drop = FALSE]

clases_unicas <- unique(annotation_row$Class)
n_clases <- length(clases_unicas)

if (n_clases <= 12) {
  paleta <- brewer.pal(n = n_clases, name = "Set3")
} else {
  pal1 <- brewer.pal(12, "Set3")
  pal2 <- brewer.pal(8, "Dark2")
  pal3 <- brewer.pal(12, "Paired")
  paleta <- c(pal1, pal2, pal3)[1:n_clases]
}
names(paleta) <- clases_unicas
ann_colors <- list(Class = paleta)

my_palette <- c("0" = "white",
                colorRampPalette(c("#f7f7f7", "#fcae91", "#fb6a4a", "#de2d26", "#67001f"))(100))
breaks <- c(0, seq(0.01, 100, length.out = 100))

# Generar heatmap temporal
pheatmap(
  amr_wide,
  color = my_palette,
  breaks = breaks,
  cluster_rows = FALSE,
  cluster_cols = TRUE,
  annotation_row = annotation_row,
  annotation_colors = ann_colors,
  display_numbers = FALSE,
  border_color = "white",
  main = "",
  fontsize_row = 11,
  fontsize_col = 11,
  angle_col = 45,
  cellwidth = 20,
  cellheight = 15,
  legend = TRUE,
  annotation_legend = TRUE,
  annotation_legend_side = "left",
  filename = "heatmap_amr_temp.png",
  width = 7,
  height = 9,
  dpi = 300,
  silent = TRUE
)

# Leer como rasterGrob para Panel B
img <- png::readPNG("heatmap_amr_temp.png")
p_heatmap <- cowplot::ggdraw() + cowplot::draw_grob(grid::rasterGrob(img, interpolate = TRUE))

# ============================================================
# PARTE 2: Antibiogramas (Panel A)
# ============================================================

datos <- read_csv("../data/antibiograms.csv", show_col_types = FALSE)

strain_colors_aaas <- c(
  "1_MXM"       = "#3B4992",
  "3_MXM"       = "#008280",
  "6_VM"        = "#A20056",
  "11_VM"       = "#008B45",
  "15_CESAIBC"  = "#EE0000",
  "8_VM"        = "#BB0021",
  "13_VM"       = "#5F559B",
  "9_VM"        = "#808180",
  "10_VM"       = "#1B1919"
)

strain_levels <- c("1_MXM","3_MXM","6_VM","8_VM","9_VM","10_VM","11_VM","13_VM","15_CESAIBC")

datos$Strain <- factor(datos$Strain, levels = strain_levels)

datos_long <- datos %>%
  pivot_longer(cols = c(Florfenicol, Enrofloxacin, Oxytetracycline),
               names_to = "Antibiotic",
               values_to = "Zone_mm") %>%
  mutate(Antibiotic = factor(Antibiotic,
                             levels = c("Florfenicol", "Enrofloxacin", "Oxytetracycline")))


p_antibiogramas <- ggplot(datos_long, aes(x = Strain, y = Zone_mm, fill = Strain)) +
  geom_col(width = 0.7, color = "black", linewidth = 0.3, alpha = 0.7) +
  facet_wrap(~ Antibiotic, ncol = 1, scales = "free_y", strip.position = "top") +
  scale_fill_manual(values = strain_colors_aaas) +
  labs(x = NULL, y = "Inhibition zone (mm)") +
  theme_cowplot(font_size = 14) +
  theme(
    legend.position = "none",
    axis.title.y = element_text(size = 20),   # 👈 tamaño de "Inhibition zone (mm)"
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14, face = "bold"),
    axis.text.y = element_text(size = 15),
    strip.background = element_blank(),
    strip.text = element_text(face = "bold", size = 18, colour = "black")
  ) +
  scale_y_continuous(limits = c(0, 25), breaks = seq(0, 25, by = 5),
                     expand = expansion(mult = c(0, 0.05)))

# ============================================================
# Combinar paneles: A (barras) a la izquierda, B (heatmap) a la derecha
# ============================================================

panel_final <- plot_grid(
  p_antibiogramas, p_heatmap,
  labels = c("A", "B"),
  label_size = 20, 
  ncol = 2,
  rel_widths = c(1, 1.5),   # A más angosto, B más ancho
  align = "v",
  axis = "lr"
)

# Guardar con dimensiones generosas
ggsave("panel_amr_antibiogramas_invertido.png", panel_final,
       width = 20, height = 14, dpi = 300)
ggsave("panel_amr_antibiogramas_invertido.pdf", panel_final,
       width = 20, height = 14)
       
# SVG (requiere svglite)
ggsave("panel_amr_antibiogramas_invertido.svg", panel_final,
       width = 20, height = 14)

cat("✅ Panel invertido guardado: panel_amr_antibiogramas_invertido.png / .pdf\n")
