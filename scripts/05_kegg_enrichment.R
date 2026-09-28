#!/usr/bin/env Rscript
# enriquecimiento_kegg_fisher_actualizado.R
# Análisis exploratorio de enriquecimiento de rutas KEGG
# 1) Por cepa individual (p nominal)
# 2) Metálicas vs no metálicas (p nominal y p ajustado)

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(tibble)
})

# setwd() eliminado; usar here::here() o ruta relativa

# ------------------------------------------------------------
# 1. Leer matriz de conteo de rutas KEGG
# ------------------------------------------------------------
archivo <- "conteo_rutas_KEGG.csv"
if (!file.exists(archivo)) stop("No se encontró ", archivo)

datos <- read_delim(archivo, delim = ",", col_names = TRUE, show_col_types = FALSE) %>%
  column_to_rownames(var = names(.)[1])

matriz <- as.matrix(datos)
storage.mode(matriz) <- "numeric"

cepas <- colnames(matriz)
rutas <- rownames(matriz)

# Cepas metálicas y no metálicas
metalicas <- c("15_CESAIBC", "AT_BV")
no_metalicas <- setdiff(cepas, metalicas)

# ------------------------------------------------------------
# Función para prueba exacta de Fisher
# ------------------------------------------------------------
test_fisher <- function(a, b, c_total, d_total) {
  tabla <- matrix(c(a, c_total, b, d_total), nrow = 2,
                  dimnames = list(c("Ruta", "Otras_rutas"),
                                  c("Grupo_focal", "Grupo_referencia")))
  test <- fisher.test(tabla, alternative = "greater")
  data.frame(p_valor = test$p.value,
             odds_ratio = as.numeric(test$estimate),
             stringsAsFactors = FALSE)
}

# ------------------------------------------------------------
# 2. Análisis por cepa individual (exploratorio, sin corrección)
# ------------------------------------------------------------
cat("🔎 Análisis por cepa individual (p nominal)\n")
totales_cepa <- colSums(matriz)
resultados_cepa <- list()

for (cepa in cepas) {
  for (ruta in rutas) {
    a <- matriz[ruta, cepa]
    b <- sum(matriz[ruta, cepas != cepa])
    c_total <- totales_cepa[cepa] - a
    d_total <- sum(totales_cepa[cepas != cepa]) - b

    res <- test_fisher(a, b, c_total, d_total)
    resultados_cepa[[paste(cepa, ruta, sep = "|")]] <- data.frame(
      Cepa = cepa,
      Ruta = ruta,
      p_valor = res$p_valor,
      odds_ratio = res$odds_ratio,
      stringsAsFactors = FALSE)
  }
}

res_cepa <- bind_rows(resultados_cepa)
res_cepa <- res_cepa[order(res_cepa$p_valor), ]  # ordenar por p nominal

# Guardar
write_csv(res_cepa, "resultados_fisher_cepa_individual.csv")

# Mostrar las 20 mejores rutas por p nominal
cat("\nTop 20 asociaciones cepa-ruta (p nominal):\n")
print(head(res_cepa, 20))

# ------------------------------------------------------------
# 3. Metálicas vs no metálicas
# ------------------------------------------------------------
cat("\n⚖️ Análisis agrupado: metálicas vs no metálicas\n")

totales_metal <- sum(totales_cepa[metalicas])
totales_no_metal <- sum(totales_cepa[no_metalicas])

resultados_metal <- list()

for (ruta in rutas) {
  a <- sum(matriz[ruta, metalicas])
  b <- sum(matriz[ruta, no_metalicas])
  c_total <- totales_metal - a
  d_total <- totales_no_metal - b

  res <- test_fisher(a, b, c_total, d_total)
  resultados_metal[[ruta]] <- data.frame(
    Ruta = ruta,
    p_valor = res$p_valor,
    odds_ratio = res$odds_ratio,
    stringsAsFactors = FALSE)
}

res_metal <- bind_rows(resultados_metal)
res_metal$p_ajustado <- p.adjust(res_metal$p_valor, method = "BH")
res_metal <- res_metal[order(res_metal$p_ajustado), ]

# Guardar
write_csv(res_metal, "resultados_fisher_metal_vs_no_metal.csv")

cat("\nResultados metálicas vs no metálicas (ordenados por p ajustado):\n")
print(res_metal)

# ------------------------------------------------------------
# 4. Resumen descriptivo de rutas de interés
# ------------------------------------------------------------
rutas_interes <- c("ko02010", "ko02020", "ko02040", "ko02060", "ko05111")

cat("\n📌 Resumen descriptivo de rutas seleccionadas\n")
for (ruta in rutas_interes) {
  if (!(ruta %in% rownames(matriz))) next
  # Conteos por grupo
  c_metal <- sum(matriz[ruta, metalicas])
  c_no_metal <- sum(matriz[ruta, no_metalicas])
  # Proporciones
  prop_metal <- c_metal / totales_metal
  prop_no_metal <- c_no_metal / totales_no_metal
  # p nominal y ajustado de la tabla agrupada
  fila <- res_metal[res_metal$Ruta == ruta, ]
  cat(sprintf(
    "%s | Metálicas: %d (%.4f) | No metálicas: %d (%.4f) | p nominal: %.4g | p ajustado: %.4g\n",
    ruta,
    c_metal, prop_metal,
    c_no_metal, prop_no_metal,
    fila$p_valor,
    fila$p_ajustado
  ))
}

cat("\n✅ Análisis completado.\n")
cat("Archivos generados:\n")
cat("- resultados_fisher_cepa_individual.csv\n")
cat("- resultados_fisher_metal_vs_no_metal.csv\n")
