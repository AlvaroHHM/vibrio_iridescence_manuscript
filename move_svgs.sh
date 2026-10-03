#!/usr/bin/env bash
# ============================================================
# move_svgs.sh
# Mueve los SVG de scripts/ a figures/ con nombres finales
# ============================================================
set -euo pipefail

REPO="${HOME}/Downloads/10_cepas/vibrio_iridescence_manuscript"
cd "$REPO"

echo "📂 Moviendo SVG a figures/..."

# Mover y renombrar SVG
[ -f scripts/Figura6_ABCD.svg ]                      && mv -f scripts/Figura6_ABCD.svg                      figures/Figure6_pathogenicity.svg
[ -f scripts/panel_amr_antibiogramas_invertido.svg ] && mv -f scripts/panel_amr_antibiogramas_invertido.svg figures/Figure4_AMR_antibiograms.svg
[ -f scripts/genome_size_horizontal.svg ]            && mv -f scripts/genome_size_horizontal.svg            figures/Figure5A_genome_size.svg
[ -f scripts/genome_metrics_vertical.svg ]           && mv -f scripts/genome_metrics_vertical.svg           figures/Figure5B_genome_metrics.svg
[ -f scripts/figure_panel_ABC_final_v3.svg ]         && mv -f scripts/figure_panel_ABC_final_v3.svg         figures/Figure5_genome_metrics_BGC.svg
[ -f scripts/FigureS2_KEGG_heatmap.svg ]             && mv -f scripts/FigureS2_KEGG_heatmap.svg             figures/FigureS2_KEGG_heatmap.svg
[ -f scripts/FigureS1_GO_enrichment.svg ]            && mv -f scripts/FigureS1_GO_enrichment.svg            figures/FigureS1_GO_enrichment.svg

echo "📂 Moviendo tablas suplementarias a supplementary_tables/..."

[ -f scripts/TablaS_dunn_pairwise_D.csv ]      && mv -f scripts/TablaS_dunn_pairwise_D.csv      supplementary_tables/Table_S_Dunn_pairwise_D.csv
[ -f scripts/TablaS_fisher_pairwise_B.csv ]    && mv -f scripts/TablaS_fisher_pairwise_B.csv    supplementary_tables/Table_S_Fisher_pairwise_B.csv
[ -f scripts/TablaS_kruskal_D.csv ]            && mv -f scripts/TablaS_kruskal_D.csv            supplementary_tables/Table_S_Kruskal_D.csv
[ -f scripts/TablaS_letras_boxplot_D.csv ]     && mv -f scripts/TablaS_letras_boxplot_D.csv     supplementary_tables/Table_S_letters_boxplot_D.csv
[ -f scripts/TablaS_logrank_pairwise_A.csv ]   && mv -f scripts/TablaS_logrank_pairwise_A.csv   supplementary_tables/Table_S_logrank_pairwise_A.csv
[ -f scripts/TablaS_mortalidad_letras_B.csv ]  && mv -f scripts/TablaS_mortalidad_letras_B.csv  supplementary_tables/Table_S_mortality_letters_B.csv

echo "🧹 Limpiando temporales..."

rm -f scripts/heatmap_amr_temp.png
rm -f scripts/heatmap_bgc_panel.png
rm -f scripts/Rplots.pdf
rm -f scripts/*.pdf
rm -f scripts/*.png
rm -f scripts/*.bak

echo ""
echo "✅ Listo. Estado final:"
echo "=== scripts/ ==="
ls -1 scripts/
echo ""
echo "=== figures/ ==="
ls -1 figures/
