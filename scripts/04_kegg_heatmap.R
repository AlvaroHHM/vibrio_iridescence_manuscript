#!/usr/bin/env Rscript
# heatmap_kegg_seleccion.R
# Heatmap de rutas KEGG seleccionadas (solo bloques de interés)
# con etiquetas cortas en eje Y y anotación de grupo correcta.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(pheatmap)
  library(tibble)
})

# setwd() eliminado; usar here::here() o ruta relativa

# ------------------------------------------------------------
# 1. Grupos de interés y colores
# ------------------------------------------------------------
groups_interes <- list(
  "Cellular processes (virulence, secretion, biofilm)" = c(
    "ko02010","map02010","ko02020","map02020","ko02024","map02024",
    "ko02025","map02025","ko02026","map02026","ko02040","map02040",
    "ko02060","map02060","ko03010","map03010","ko03070","map03070",
    "ko03440","map03440","ko04973","map04973"),
  "Pathogenicity and host-bacteria interactions" = c(
    "ko05111","map05111","ko05132","map05132","ko05134","map05134",
    "ko04621","map04621","ko04626","map04626","ko01503","map01503")
)

group_colors <- c(
  "Cellular processes (virulence, secretion, biofilm)" = "#d62728",
  "Pathogenicity and host-bacteria interactions" = "#9467bd"
)

# Crear vector de grupo para cada código
todos_codigos <- unlist(groups_interes, use.names = FALSE)
grupo_asignado <- rep(names(groups_interes), times = sapply(groups_interes, length))
names(grupo_asignado) <- todos_codigos

# ------------------------------------------------------------
# 2. Leer matriz de conteo de rutas KEGG
# ------------------------------------------------------------
archivo_kegg <- "conteo_rutas_KEGG.csv"
if (!file.exists(archivo_kegg)) {
  stop("No se encontró ", archivo_kegg,
       ". Genera primero 'conteo_rutas_KEGG.csv'.")
}

datos_kegg <- read_delim(archivo_kegg, delim = ",", col_names = TRUE, show_col_types = FALSE) %>%
  column_to_rownames(var = names(.)[1])

# ------------------------------------------------------------
# 3. Filtrar solo las rutas de interés
# ------------------------------------------------------------
rutas_presentes <- intersect(todos_codigos, rownames(datos_kegg))
if (length(rutas_presentes) == 0) {
  stop("Ninguna de las rutas seleccionadas está en el CSV.")
}

matriz <- datos_kegg[rutas_presentes, , drop = FALSE]

# Ordenar por grupo y código
grupo_fila <- grupo_asignado[rownames(matriz)]
matriz <- matriz[order(grupo_fila, rownames(matriz)), , drop = FALSE]
grupo_fila <- grupo_asignado[rownames(matriz)]

# ------------------------------------------------------------
# 4. Crear anotación de filas (usando nombres originales)
# ------------------------------------------------------------
annotation_row <- data.frame(Group = grupo_fila, row.names = rownames(matriz))
ann_colors <- list(Group = group_colors)

# ------------------------------------------------------------
# 5. Etiquetas cortas para el eje Y (solo para visualización)
# ------------------------------------------------------------
etiquetas_cortas <- sub("^ko", "K", rownames(matriz))   # koXXXXX -> KXXXXX
etiquetas_cortas <- sub("^map", "M", etiquetas_cortas)   # mapXXXXX -> MXXXXX

# ------------------------------------------------------------
# 6. Heatmap compacto
# ------------------------------------------------------------
pheatmap(matriz,
         color = colorRampPalette(c("white", "#67001f"))(100),
         cluster_rows = FALSE,
         cluster_cols = TRUE,
         annotation_row = annotation_row,
         annotation_colors = ann_colors,
         labels_row = etiquetas_cortas,     # <-- clave para etiquetas cortas
         main = "Rutas KEGG relevantes en proteínas patógenas",
         filename = "heatmap_kegg_seleccion.png",
         width = 10,          
         height = 7,          
         fontsize_row = 7,
         fontsize_col = 7,  
         angle_col = 45,     
         cellwidth = 12,
         cellheight = 10,
         dpi = 300)
