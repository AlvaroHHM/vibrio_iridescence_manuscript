#!/usr/bin/env Rscript
# ============================================================
# update_github_figures.R
# Deja solo los 5 SVG finales en figures/ y actualiza GitHub
# ============================================================

repo <- normalizePath(".")
figures_dir <- file.path(repo, "figures")
readme <- file.path(repo, "README.md")

# ------------------------------------------------------------
# 1. Archivos que SÍ queremos conservar
# ------------------------------------------------------------
keep <- c(
  "Figure4_AMR_antibiograms.svg",
  "Figure5_genome_metrics_BGC.svg",
  "Figure6_pathogenicity.svg",
  "FigureS1_GO_enrichment.svg",
  "FigureS2_KEGG_heatmap.svg"
)

# ------------------------------------------------------------
# 2. Eliminar todo lo que no esté en 'keep'
# ------------------------------------------------------------
all_files <- list.files(figures_dir, full.names = FALSE)
to_remove <- setdiff(all_files, keep)

if (length(to_remove) > 0) {
  for (f in to_remove) {
    fp <- file.path(figures_dir, f)
    if (file.exists(fp)) {
      file.remove(fp)
      message("🗑️  Eliminado localmente: ", f)
    }
  }
}

# ------------------------------------------------------------
# 3. Actualizar README (nombres viejos → nuevos)
# ------------------------------------------------------------
if (file.exists(readme)) {
  txt <- readLines(readme, warn = FALSE)
  # Reemplazos de nombres viejos por los finales
  txt <- gsub("Figura6_ABCD\\.svg", "Figure6_pathogenicity.svg", txt)
  txt <- gsub("figure_panel_ABC_final_v3\\.svg", "Figure5_genome_metrics_BGC.svg", txt)
  txt <- gsub("panel_amr_antibiogramas_invertido\\.svg", "Figure4_AMR_antibiograms.svg", txt)
  txt <- gsub("Figure5A_genome_size\\.svg", "Figure5_genome_metrics_BGC.svg", txt)
  txt <- gsub("Figure5B_genome_metrics\\.svg", "Figure5_genome_metrics_BGC.svg", txt)
  writeLines(txt, readme)
  message("📄 README actualizado")
}

# ------------------------------------------------------------
# 4. Git: add, commit, push
# ------------------------------------------------------------
setwd(repo)
system2("git", c("add", "-A"))
system2("git", c("commit", "-m", shQuote("Keep only final 5 SVG figures in figures/")))
system2("git", c("push", "origin", "main"))

message("\n🎉 GitHub actualizado. figures/ ahora contiene:")
print(list.files(figures_dir))
