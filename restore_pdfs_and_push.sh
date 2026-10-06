#!/usr/bin/env bash
# ============================================================
# restore_pdfs_and_push.sh
# Restaura la generación de PDFs, los mueve a figures/,
# limpia scripts/ y actualiza GitHub.
# ============================================================
set -euo pipefail

REPO="${HOME}/Downloads/10_cepas/vibrio_iridescence_manuscript"
cd "$REPO"

echo "🔍 Evaluando formato actual de los scripts..."
grep -n "ggsave\|pheatmap\|svglite\|filename" scripts/*.R || true

echo ""
echo "🔧 Modificando scripts para generar solo PDF..."

# Backup
mkdir -p scripts_backup
cp scripts/*.R scripts_backup/

# 1. Reemplazar .svg por .pdf en todos los scripts
sed -i 's/\.svg/\.pdf/g' scripts/*.R

# 2. Eliminar argumentos device = svglite
sed -i 's/, device = svglite//g' scripts/*.R
sed -i 's/device = svglite//g' scripts/*.R
sed -i 's/device = "svglite"//g' scripts/*.R

# 3. Eliminar library(svglite) si existe
sed -i '/library(svglite)/d' scripts/*.R

echo "✅ Scripts modificados. Verificando..."
grep -n "ggsave\|filename" scripts/*.R || true

echo ""
echo "🚀 Ejecutando scripts para generar PDFs..."

cd scripts
Rscript 02_figure5_pathogenicity.R
Rscript 03_amr_antibiograms.R
Rscript 04_kegg_heatmap.R
Rscript 06_genome_metrics.R
Rscript 07_figure4_panels_ABC.R
Rscript 08_go_enrichment_figure.R
cd ..

echo ""
echo "📂 Moviendo PDFs a figures/..."

# Mover y renombrar
mv -f scripts/Figure5_pathogenicity.pdf      figures/Figure5_pathogenicity.pdf
mv -f scripts/Figure3_AMR_antibiograms.pdf   figures/Figure3_AMR_antibiograms.pdf
mv -f scripts/FigureS2_KEGG_heatmap.pdf      figures/FigureS2_KEGG_heatmap.pdf
mv -f scripts/Figure4_genome_metrics_BGC.pdf figures/Figure4_genome_metrics_BGC.pdf
mv -f scripts/FigureS1_GO_enrichment.pdf     figures/FigureS1_GO_enrichment.pdf

# Los PDFs individuales de 06 no se usan (se eliminan)
rm -f scripts/genome_size_horizontal.pdf
rm -f scripts/genome_metrics_vertical.pdf

echo ""
echo "🧹 Limpiando figures/ (eliminando SVG antiguos)..."

rm -f figures/*.svg

echo "🧹 Limpiando scripts/..."

cd scripts
rm -f *.pdf *.png *.svg
rm -f Rplots.pdf
rm -f heatmap_amr_temp.png
rm -f heatmap_bgc_panel.png
rm -f TablaS_*.csv
rm -f *.bak
cd ..

echo ""
echo "📄 Actualizando README (.svg → .pdf)..."

sed -i 's/\.svg/\.pdf/g' README.md

echo ""
echo "📤 Subiendo a GitHub..."

git add .
git commit -m "Restore PDF figures; clean scripts folder"
git push origin main

echo ""
echo "🎉 Proceso completado."
echo ""
echo "=== figures/ ==="
ls -1 figures/
echo ""
echo "=== scripts/ ==="
ls -1 scripts/
