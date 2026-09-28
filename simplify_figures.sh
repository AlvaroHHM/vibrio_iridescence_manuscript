#!/usr/bin/env bash
# ============================================================
# fix_pdf_only.sh
# Elimina bloques completos de ggsave para PNG y SVG
# ============================================================
set -euo pipefail

REPO="${HOME}/Downloads/10_cepas/vibrio_iridescence_manuscript"
cd "$REPO/scripts"

echo "🔧 Eliminando bloques PNG y SVG..."

# ------------------------------------------------------------
# 02_figure6_pathogenicity.R
# ------------------------------------------------------------
F="02_figure6_pathogenicity.R"
if [ -f "$F" ]; then
  # Eliminar bloque PNG (2 líneas)
  awk '
    /^ggsave\("Figura6_ABCD\.png"/ {skip=1; next}
    skip && /^[[:space:]]+width/ {skip=0; next}
    {print}
  ' "$F" > "${F}.tmp" && mv "${F}.tmp" "$F"
  # Eliminar bloque SVG
  awk '
    /^ggsave\("Figura6_ABCD\.svg"/ {skip=1; next}
    skip && /^[[:space:]]+width/ {skip=0; next}
    {print}
  ' "$F" > "${F}.tmp" && mv "${F}.tmp" "$F"
  echo "✅ $F"
fi

# ------------------------------------------------------------
# 03_amr_antibiograms.R
# ------------------------------------------------------------
F="03_amr_antibiograms.R"
if [ -f "$F" ]; then
  awk '
    /^ggsave\("panel_amr_antibiogramas_invertido\.png"/ {skip=1; next}
    skip && /^[[:space:]]+width/ {skip=0; next}
    {print}
  ' "$F" > "${F}.tmp" && mv "${F}.tmp" "$F"
  awk '
    /^ggsave\("panel_amr_antibiogramas_invertido\.svg"/ {skip=1; next}
    skip && /^[[:space:]]+width/ {skip=0; next}
    {print}
  ' "$F" > "${F}.tmp" && mv "${F}.tmp" "$F"
  echo "✅ $F"
fi

# ------------------------------------------------------------
# 06_genome_metrics.R
# ------------------------------------------------------------
F="06_genome_metrics.R"
if [ -f "$F" ]; then
  # Eliminar líneas individuales de PNG
  sed -i '/^ggsave("genome_size_horizontal\.png"/d' "$F"
  sed -i '/^ggsave("genome_metrics_vertical\.png"/d' "$F"
  echo "✅ $F"
fi

# ------------------------------------------------------------
# 07_figure5_panels_ABC.R
# ------------------------------------------------------------
F="07_figure5_panels_ABC.R"
if [ -f "$F" ]; then
  awk '
    /^ggsave\("figure_panel_ABC_final_v3\.png"/ {skip=1; next}
    skip && /^[[:space:]]+width/ {skip=0; next}
    {print}
  ' "$F" > "${F}.tmp" && mv "${F}.tmp" "$F"
  awk '
    /^ggsave\("figure_panel_ABC_final_v3\.svg"/ {skip=1; next}
    skip && /^[[:space:]]+width/ {skip=0; next}
    {print}
  ' "$F" > "${F}.tmp" && mv "${F}.tmp" "$F"
  echo "✅ $F"
fi

echo ""
echo "🎉 Bloques PNG/SVG eliminados. Verifica con:"
echo "   grep -n 'ggsave' scripts/*.R"
