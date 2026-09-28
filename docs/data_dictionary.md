# Data dictionary

## data/processed/probit_lc50_data.csv

Mortality percentages per replicate used for the Probit analysis.

| Column | Description |
|--------|-------------|
| ROWTITLE | Concentration label (3.9, 39, 390, 3900, 39000, 390000) |
| _1 | Mortality percentage, replicate 1 |
| _2 | Mortality percentage, replicate 2 |
| _3 | Mortality percentage, replicate 3 |
| _4 | Mortality percentage, replicate 4 |

Note: The original dataset from GraphPad Prism assumed N = 100 per replicate.

## data/processed/survival_kaplan_meier.csv

Individual survival data for the dose-response bioassay (15_CESAIBC).

| Column | Description |
|--------|-------------|
| id | Individual ID |
| Horas | Time of death or censoring (hours post-infection) |
| Control | Status for control group (1 = dead, 0 = alive) |
| 3.9e1 | Status for 3.9 x 10^1 CFU/mL |
| 3.9e2 | Status for 3.9 x 10^2 CFU/mL |
| 3.9e3 | Status for 3.9 x 10^3 CFU/mL |
| 3.9e4 | Status for 3.9 x 10^4 CFU/mL |
| 3.9e5 | Status for 3.9 x 10^5 CFU/mL |

## data/processed/lc50_results.csv

Results of the Probit analysis.

| Column | Description |
|--------|-------------|
| parameter | Parameter name (LC50, CI_lower, CI_upper) |
| value | Estimated value |
| units | Units (CFU/mL) |
