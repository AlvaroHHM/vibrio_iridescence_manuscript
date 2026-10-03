#!/usr/bin/env bash
# ============================================================
# update_to_svg_with_white_bg.sh
# Modifica los scripts R para que generen SVG con fondo blanco
# ============================================================
set -euo pipefail

REPO="${HOME}/Downloads/10_cepas/vibrio_iridescence_manuscript"
cd "$REPO"

# Asegurar que svglite esté instalado
Rscript -e 'if (!requireNamespace("svglite", quietly = TRUE)) install.packages("svglite")'

python3 << 'PYTHON'
import re
import os

def update_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    original = content

    # 1. Cambiar .pdf a .svg en ggsave() y añadir bg = "white" si no está
    content = re.sub(r'(ggsave\([^)]*?)\.pdf', r'\1.svg', content)
    # Añadir bg = "white" a ggsave si no está presente
    if 'ggsave(' in content and 'bg = ' not in content:
        content = re.sub(r'(ggsave\([^)]*?)(\))', r'\1, bg = "white"\2', content)

    basename = os.path.basename(filepath)

    # 04_kegg_heatmap.R: usar svglite con fondo blanco
    if basename == '04_kegg_heatmap.R':
        # Insertar library(svglite), svglite(), grid.rect() antes de pheatmap(mat,
        content = re.sub(
            r'(\npheatmap\(mat,)',
            r'\nlibrary(svglite)\nlibrary(grid)\nsvglite("FigureS2_KEGG_heatmap.svg", width = 10, height = 7, bg = "white")\ngrid.rect(gp = gpar(fill = "white", col = NA))\n\1',
            content
        )
        # Eliminar la línea filename
        content = re.sub(r'\s*filename = "FigureS2_KEGG_heatmap\.pdf",\n', '\n', content)
        # Añadir dev.off() después del cierre de pheatmap
        content = re.sub(r'(cellheight = 10\))', r'\1\ndev.off()', content)

    # 03_amr_antibiograms.R: usar grid.grabExpr con fondo blanco
    elif basename == '03_amr_antibiograms.R':
        pheatmap_match = re.search(r'pheatmap\(\s*amr_wide,(.*?)\)', content, re.DOTALL)
        if pheatmap_match:
            args = pheatmap_match.group(1)
            new_block = f"""grob_heatmap <- grid::grid.grabExpr({{
  grid::grid.rect(gp = grid::gpar(fill = "white", col = NA))
  pheatmap(
    amr_wide,{args}
  )
}})
p_heatmap <- cowplot::ggdraw() + cowplot::draw_grob(grob_heatmap)"""
            content = re.sub(
                r'pheatmap\(\s*amr_wide,.*?\)\s*img <- png::readPNG\(.*?\)\s*'
                r'p_heatmap <- cowplot::ggdraw\(\) \+ cowplot::draw_grob\(grid::rasterGrob\(img, interpolate = TRUE\)\)',
                new_block,
                content,
                flags=re.DOTALL
            )
        else:
            print(f"⚠️  No se encontró bloque pheatmap en {filepath}")

    # 07_figure5_panels_ABC.R: usar grid.grabExpr con fondo blanco
    elif basename == '07_figure5_panels_ABC.R':
        pheatmap_match = re.search(r'pheatmap\(\s*bgc_wide,(.*?)\)', content, re.DOTALL)
        if pheatmap_match:
            args = pheatmap_match.group(1)
            new_block = f"""grob_bgc <- grid::grid.grabExpr({{
  grid::grid.rect(gp = grid::gpar(fill = "white", col = NA))
  pheatmap(
    bgc_wide,{args}
  )
}})
pC <- cowplot::ggdraw() + cowplot::draw_grob(grob_bgc)"""
            content = re.sub(
                r'pheatmap\(\s*bgc_wide,.*?\)\s*heatmap_img <- png::readPNG\(.*?\)\s*'
                r'pC <- cowplot::ggdraw\(\) \+ cowplot::draw_image\(heatmap_img\)',
                new_block,
                content,
                flags=re.DOTALL
            )
        else:
            print(f"⚠️  No se encontró bloque pheatmap en {filepath}")

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"✅ Actualizado: {filepath}")
    else:
        print(f"ℹ️  Sin cambios: {filepath}")

files = [
    'scripts/02_figure6_pathogenicity.R',
    'scripts/03_amr_antibiograms.R',
    'scripts/04_kegg_heatmap.R',
    'scripts/06_genome_metrics.R',
    'scripts/07_figure5_panels_ABC.R',
    'scripts/08_go_enrichment_figure.R'
]

for f in files:
    if os.path.exists(f):
        update_file(f)
    else:
        print(f"❌ No encontrado: {f}")
PYTHON

echo "🎉 Scripts modificados para generar SVG con fondo blanco."
