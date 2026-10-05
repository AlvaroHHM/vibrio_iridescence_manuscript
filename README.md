# Vibrio iridescence manuscript – reproducibility package

This repository contains the R scripts and intermediate data used to generate the figures and supplementary tables of the manuscript:

**Exploratory phenotypic and comparative genomic analysis of angle-dependent metallic coloration in aquaculture-associated Vibrio isolates**

Mata-Torres, F. G., Giffard-Mena, I., Ugalde, J. A., Millán-Aguiñaga, N., Hernández-Montiel, A. H., Torres-Beltrán, M., & Rocha-Mendoza, I.

## Requirements

- R >= 4.3.3
- Packages: readr, dplyr, tidyr, ggplot2, survival, multcompView, cowplot, rstatix, pheatmap, MASS, boot, pzfx, ggsci, seqinr, ggplotify

## Repository structure

- `scripts/` — R scripts
- `data/` — Intermediate CSV files
  - `processed/` — Processed data
  - `raw/` — Raw data (empty; raw reads in SRA)
- `figures/` — Generated figures (SVG)
- `supplementary_tables/` — Final supplementary tables
- `docs/` — commands.sh, versions_databases.txt, data_dictionary.md
- `LICENSE`
- `README.md`

## Scripts

| Script | Description | Figure/Table |
|--------|-------------|--------------|
| `01_probit_lc50_analysis.R` | Estimates LC50 and 95% CI by Probit with bootstrap | Figure 5 |
| `02_figure5_pathogenicity.R` | Generates Figure 5 (panels A–D) | Figure 5 |
| `03_amr_antibiograms.R` | Generates antibiograms and AMR heatmap | Figure 3A, 3B |
| `04_kegg_heatmap.R` | Generates KEGG pathway heatmap | Figure S2 |
| `05_kegg_enrichment.R` | KEGG enrichment analysis | Intermediate data |
| `06_genome_metrics.R` | Generates genome size and quality plots | Figure 4A, 4B |
| `07_figure4_panels_ABC.R` | Generates Figure 4 (panels A, B, C) | Figure 4 |
| `08_go_enrichment_figure.R` | Generates GO enrichment heatmap across strains | Figure S1 |

## Figures

| File | Description |
|------|-------------|
| `Figure3_AMR_antibiograms.svg` | Antibiograms and AMR heatmap (panels A and B) |
| `Figure4_genome_metrics_BGC.svg` | Genome size, quality metrics, and BGC heatmap (panels A, B, C) |
| `Figure5_pathogenicity.svg` | Pathogenicity bioassays (panels A–D) |
| `FigureS1_GO_enrichment.svg` | GO enrichment across strains |
| `FigureS2_KEGG_heatmap.svg` | KEGG pathway heatmap (supplementary) |

## Supplementary tables

| File | Description |
|------|-------------|
| `Table_S1_sequencing_stats.csv` | Sequencing and assembly statistics |
| `Table_S2_chitinase_adhesin_pilus.csv` | Chitinase, adhesin, and pilus assembly genes |
| `Table_S3_genome_metrics.csv` | Genome size, GC, completeness, contamination |
| `Table_S4_blast_reciprocal_pairs.csv` | BLASTp reciprocal pairs |
| `Table_S5_PathogenFinder.csv` | PathogenFinder predictions |
| `Table_S5_PathogenFinder_annotated.csv` | PathogenFinder annotated families |
| `Table_S6_presence_absence_candidates.csv` | Presence/absence of arylsulfatase and MFS permease |

## How to run

1. Clone the repository.
2. Open R in the repository root.
3. Run scripts in order (01 → 08):

```bash
Rscript scripts/01_probit_lc50_analysis.R
Rscript scripts/02_figure5_pathogenicity.R
Rscript scripts/03_amr_antibiograms.R
Rscript scripts/04_kegg_heatmap.R
Rscript scripts/05_kegg_enrichment.R
Rscript scripts/06_genome_metrics.R
Rscript scripts/07_figure4_panels_ABC.R
Rscript scripts/08_go_enrichment_figure.R
```

## Data and code availability

Assembled and annotated genomes have been deposited in NCBI GenBank under BioProjects PRJNA1497354, PRJNA1502407, PRJNA1499907, PRJNA1499920, PRJNA1499939, PRJNA1502400, PRJNA1502472, PRJNA1502475, PRJNA1502480, and PRJNA1502481. Individual BioSample, WGS, and Assembly accession numbers—distinguishing the seven publicly released genomes from the three entries currently in final NCBI processing (AT_BV, 9_VM, and 10_VM)—are fully detailed in Table 1 and Table S1. All analytical R scripts, command-line execution parameters, raw bioassay datasets, GraphPad Prism files (.pzfx), antiSMASH output files, BLAST alignment matrices, metadata, colony image datasets, and supplementary files are publicly maintained in GitHub (AlvaroHHM/vibrio_iridescence_manuscript) and permanently archived in Zenodo at DOI: 10.5281/zenodo.23005623.

## License

MIT License. See `LICENSE` for details.

Copyright (c) 2026 Universidad Autónoma de Baja California (UABC).

Authors: Fernando G. Mata-Torres, Ivone Giffard-Mena, Natalie Millán-Aguiñaga, Álvaro H. Hernández-Montiel, Mónica Torres-Beltrán, Israel Rocha-Mendoza, and contributors.
