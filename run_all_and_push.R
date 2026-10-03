#!/usr/bin/env Rscript
# ============================================================
# run_all_and_push.R
# Runs all analysis scripts, moves SVGs to figures/,
# cleans temporaries, and pushes to GitHub.
# ============================================================

# ------------------------------------------------------------
# 0. Setup
# ------------------------------------------------------------
repo <- normalizePath(".")
scripts_dir <- file.path(repo, "scripts")
figures_dir <- file.path(repo, "figures")

stopifnot(dir.exists(scripts_dir))
stopifnot(dir.exists(figures_dir))

setwd(scripts_dir)

# ------------------------------------------------------------
# 1. Run analysis scripts
# ------------------------------------------------------------
scripts_to_run <- c(
  "02_figure6_pathogenicity.R",
  "03_amr_antibiograms.R",
  "04_kegg_heatmap.R",
  "06_genome_metrics.R",
  "07_figure5_panels_ABC.R",
  "08_go_enrichment_figure.R"
)

for (s in scripts_to_run) {
  message("🚀 Running: ", s)
  system2("Rscript", s, stdout = TRUE, stderr = TRUE)
}

setwd(repo)

# ------------------------------------------------------------
# 2. Move SVGs to figures/ with final names
# ------------------------------------------------------------
moves <- list(
  c("scripts/Figura6_ABCD.svg",               "figures/Figure6_pathogenicity.svg"),
  c("scripts/panel_amr_antibiogramas_invertido.svg", "figures/Figure4_AMR_antibiograms.svg"),
  c("scripts/FigureS2_KEGG_heatmap.svg",      "figures/FigureS2_KEGG_heatmap.svg"),
  c("scripts/genome_size_horizontal.svg",     "figures/Figure5A_genome_size.svg"),
  c("scripts/genome_metrics_vertical.svg",    "figures/Figure5B_genome_metrics.svg"),
  c("scripts/figure_panel_ABC_final_v3.svg",  "figures/Figure5_genome_metrics_BGC.svg"),
  c("scripts/FigureS1_GO_enrichment.svg",     "figures/FigureS1_GO_enrichment.svg")
)

for (m in moves) {
  if (file.exists(m[1])) {
    file.rename(m[1], m[2])
    message("✅ Moved: ", m[1], " → ", m[2])
  } else {
    message("⚠️  Not found: ", m[1])
  }
}

# ------------------------------------------------------------
# 3. Clean temporary files in scripts/
# ------------------------------------------------------------
temp_files <- list.files(scripts_dir,
  pattern = "\\.(pdf|png|svg|bak)$|^Rplots\\.pdf$|^TablaS_",
  full.names = TRUE)
if (length(temp_files) > 0) {
  file.remove(temp_files)
  message("🧹 Removed ", length(temp_files), " temporary files from scripts/")
}

# ------------------------------------------------------------
# 4. Update README (.pdf and .png → .svg)
# ------------------------------------------------------------
readme <- file.path(repo, "README.md")
if (file.exists(readme)) {
  txt <- readLines(readme, warn = FALSE)
  txt <- gsub("\\.pdf", "\\.svg", txt)
  txt <- gsub("\\.png", "\\.svg", txt)
  txt <- gsub("\\.svg\\.svg", "\\.svg", txt)
  writeLines(txt, readme)
  message("📄 README updated to SVG references")
}

# ------------------------------------------------------------
# 5. Git add, commit, push
# ------------------------------------------------------------
setwd(repo)

system2("git", c("add", "."))
commit_msg <- sprintf("Switch all figures to SVG format (%s)", Sys.Date())
system2("git", c("commit", "-m", shQuote(commit_msg)))
system2("git", c("push", "origin", "main"))

message("\n🎉 Done!")
message("=== figures/ ===")
print(list.files(figures_dir))
message("=== scripts/ ===")
print(list.files(scripts_dir))
