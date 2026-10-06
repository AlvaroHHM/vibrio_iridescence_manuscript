#!/usr/bin/env bash
# ============================================================
# actualizar_figuras.sh
# Corre los scripts de figuras, mueve PDFs a figures/,
# limpia scripts/ y actualiza GitHub.
# ============================================================
set -euo pipefail

REPO="${HOME}/Downloads/10_cepas/vibrio_iridescence_manuscript"
cd "$REPO"

echo "🚀 Corriendo scripts de figuras..."

cd scripts
Rscript 02_figure5_pathogenicity.R
Rscript 03_amr_antibiograms.R
Rscript 04_kegg_heatmap.R
Rscript 07_figure4_panels_ABC.R
Rscript 08_go_enrichment_figure.R
cd ..

echo ""
echo "🔍 Verificando que los PDFs se generaron..."

PDFS=(
  "scripts/Figure5_pathogenicity.pdf"
  "scripts/Figure3_AMR_antibiograms.pdf"
  "scripts/FigureS2_KEGG_heatmap.pdf"
  "scripts/Figure4_genome_metrics_BGC.pdf"
  "scripts/FigureS1_GO_enrichment.pdf"
)

for f in "${PDFS[@]}"; do
  if [ -s "$f" ]; then
    echo "✅ $f ($(du -h "$f" | cut -f1))"
  else
    echo "⚠️  $f está vacío o no existe. Revisa el script que lo genera."
  fi
done

echo ""
echo "📂 Moviendo PDFs a figures/..."

mv -f scripts/Figure5_pathogenicity.pdf      figures/Figure5_pathogenicity.pdf
mv -f scripts/Figure3_AMR_antibiograms.pdf   figures/Figure3_AMR_antibiograms.pdf
mv -f scripts/FigureS2_KEGG_heatmap.pdf      figures/FigureS2_KEGG_heatmap.pdf
mv -f scripts/Figure4_genome_metrics_BGC.pdf figures/Figure4_genome_metrics_BGC.pdf
mv -f scripts/FigureS1_GO_enrichment.pdf     figures/FigureS1_GO_enrichment.pdf

echo ""
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
echo "📤 Subiendo a GitHub..."

git add .
git commit -m "Update PDF figures from latest scripts"
git push origin main

echo ""
echo "🎉 Listo. Estado final:"
echo "=== figures/ ==="
ls -1 figures/
echo ""
echo "=== scripts/ ==="
ls -1 scripts/
