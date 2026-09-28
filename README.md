# Phenotypic and Exploratory Genomic Characterization of Metallic Iridescence in Aquaculture-Associated *Vibrio* Isolates

This repository contains the R scripts and processed data needed to reproduce the statistical analyses and figures presented in the manuscript.

## Structure

~~~
.
├── data/
│   ├── processed/       # Processed data used by the scripts
│   └── raw/             # Raw data (if publicly available)
├── scripts/
│   ├── 01_probit_lc50_analysis.R
│   └── 02_figure6_pathogenicity.R
└── docs/
    └── data_dictionary.md
~~~

## How to reproduce

### Requirements

- R >= 4.3.0
- Packages: pzfx, dplyr, tidyr, MASS, boot, survival, ggplot2, cowplot, rstatix, multcompView, readr

Install dependencies:

~~~r
install.packages(c("pzfx", "dplyr", "tidyr", "MASS", "boot",
                   "survival", "ggplot2", "cowplot",
                   "rstatix", "multcompView", "readr"))
~~~

### Run

~~~bash
Rscript scripts/01_probit_lc50_analysis.R
Rscript scripts/02_figure6_pathogenicity.R
~~~

## Main results

- LC50 for 15_CESAIBC: 3.31 x 10^4 CFU/mL (95% CI: 9.48 x 10^3 - 7.34 x 10^5 CFU/mL) at 90.5 h post-exposure, with Abbott's correction for baseline control mortality (19.6%) and bootstrap CI (2000 replicates).

## Notes on CSA25-control

The isolate CSA25-control (Microbacterium esteraromaticum) was used exclusively as a non-iridescent phenotypic control in plate assays and in vivo bioassays. It was not included in the genomic analyses (pangenomics, AMR, antiSMASH, phylogenetic tree) because its genome will be published independently by Dr. Hortencia Silva.

## Strain code mapping

| Code in manuscript | Code in tesis | Species |
|--------------------|---------------|---------|
| 15_CESAIBC         | VpEMS-15      | Vibrio parahaemolyticus |
| AT_BV              | Va-H2Oubp     | Vibrio alginolyticus |
| 6_VM               | Bi-HpVm       | Vibrio parahaemolyticus |
| 11_VM              | Bi-BrC4       | Vibrio parahaemolyticus |
| 8_VM               | Bi-HLvm       | Aeromonas sp. |
| 13_VM              | Bi-E1Fon      | Micrococcus sp. |
| 1_MXM              | Rb-MM1        | Vibrio sp. |
| 3_MXM              | Rb-MM3        | Mammaliicoccus sciuri |
| 9_VM               | Bi-E1-Sup-VM  | Staphylococcus sp. |
| 10_VM              | Bi-E1-Fon-VM  | Bacillus sp. |

## Citation

If you use these scripts or data, please cite:

> Mata-Torres FG, et al. (2025). Phenotypic and Exploratory Genomic Characterization of Metallic Iridescence in Aquaculture-Associated Vibrio Isolates. [Journal name]. DOI: [to be added]

## Contact

For questions about the analyses, contact: [your email]
