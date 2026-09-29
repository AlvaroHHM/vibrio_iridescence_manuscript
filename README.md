# Vibrio iridescence manuscript – reproducibility package

This repository contains the R scripts and intermediate data used to generate the figures and supplementary tables of the manuscript:

**Phenotypic and Exploratory Genomic Characterization of Metallic Iridescence in Aquaculture-Associated Vibrio Isolates**

Mata-Torres, F. G., Millán-Aguiñaga, N., Ugalde, J. A., Torres-Beltrán, M., Rocha-Mendoza, I., Hernández-Montiel, A. H., & Giffard-Mena, I.

## Requirements

- R >= 4.3.3
- Packages: readr, dplyr, tidyr, ggplot2, survival, multcompView, cowplot, rstatix, pheatmap, MASS, boot, pzfx, ggsci, seqinr

## Repository structure

- scripts/ — R scripts
- data/ — Intermediate CSV files
  - processed/ — Processed data
  - raw/ — Raw data (empty; raw reads in SRA)
- figures/ — Generated figures (PDF)
- supplementary_tables/ — Final supplementary tables
- docs/ — commands.sh, versions_databases.txt, data_dictionary.md
- LICENSE
- README.md

## Scripts

| Script | Description | Figure/Table |
|--------|-------------|--------------|
| `01_probit_lc50_analysis.R` | Estimates LC50 and 95% CI by Probit with bootstrap | Figure 6A |
| `02_figure6_pathogenicity.R` | Generates Figure 6 (panels A–D) | Figure 6 |
| `03_amr_antibiograms.R` | Generates antibiograms and AMR heatmap | Figure 4A, 4B |
| `04_kegg_heatmap.R` | Generates KEGG pathway heatmap | Figure S2 |
| `05_kegg_enrichment.R` | KEGG enrichment analysis | Supplementary tables |
| `06_genome_metrics.R` | Generates genome size and quality plots | Figure 5A, 5B |
| `07_figure5_panels_ABC.R` | Generates Figure 5 (panels A, B, C) | Figure 5 |
| `08_go_enrichment_figure.R` | Generates GO enrichment heatmap across strains | Figure S1 |

## Figures

| File | Description |
|------|-------------|
| `Figure4_AMR_antibiograms.pdf` | Antibiograms and AMR heatmap (panels A and B) |
| `Figure5_genome_metrics_BGC.pdf` | Genome size, quality metrics, and BGC heatmap (panels A, B, C) |
| `Figure6_pathogenicity.pdf` | Pathogenicity bioassays (panels A–D) |
| `FigureS1_GO_enrichment.pdf` | GO enrichment across strains (top 3 terms per strain) |
| `FigureS2_KEGG_heatmap.pdf` | KEGG pathway heatmap (supplementary) |

## Supplementary tables

| File | Description |
|------|-------------|
| `Table_S1_sequencing_stats.csv` | Sequencing and assembly statistics |
| `Table_S2_biolog_geniii.csv` | Biolog Gen III biochemical identification |
| `Table_S3_chitinase_adhesin_pilus.csv` | Chitinase, adhesin, and pilus assembly genes |
| `Table_S4_genome_metrics.csv` | Genome size, GC, completeness, contamination |
| `Table_S5_blast_reciprocal_pairs.csv` | BLASTp reciprocal pairs |
| `Table_S6_AMR.csv` | AMR determinants |
| `Table_S7_PathogenFinder.csv` | PathogenFinder predictions |
| `Table_S8_PathogenFinder_annotated.csv` | PathogenFinder annotated families |
| `Table_S9_KEGG_pathway_counts.csv` | KEGG pathway counts |
| `Table_S10_GO_enrichment.csv` | GO enrichment |
| `Table_S11_eggNOG_annotations.tsv` | eggNOG annotations |

## How to run

1. Clone the repository.
2. Open R in the repository root.
3. Run scripts in order (01 → 08):

- Rscript scripts/01_probit_lc50_analysis.R
- Rscript scripts/02_figure6_pathogenicity.R
- Rscript scripts/03_amr_antibiograms.R
- Rscript scripts/04_kegg_heatmap.R
- Rscript scripts/05_kegg_enrichment.R
- Rscript scripts/06_genome_metrics.R
- Rscript scripts/07_figure5_panels_ABC.R
- Rscript scripts/08_go_enrichment_figure.R

## Data availability

Assembled and annotated genomes were deposited in NCBI GenBank under BioProjects:

- PRJNA1497354 (1_MXM)
- PRJNA1502407 (3_MXM)
- PRJNA1499907 (6_VM)
- PRJNA1499920 (11_VM)
- PRJNA1499939 (15_CESAIBC)
- PRJNA1502472 (8_VM)
- PRJNA1502475 (13_VM)

## Code availability

All custom R scripts and intermediate CSV files are available in this repository. The repository is archived at Zenodo under DOI: [TO BE ASSIGNED].

## License

MIT License. See LICENSE for details.

Copyright (c) 2026 Universidad Autónoma de Baja California (UABC).
Authors: Fernando G. Mata-Torres, Ivone Giffard-Mena, Natalie Millán-Aguiñaga, Álvaro H. Hernández-Montiel, Mónica Torres-Beltrán, Israel Rocha-Mendoza, and contributors.
