library(pzfx)
library(dplyr)
library(tidyr)
library(MASS)
library(boot)

# Leer la tabla correcta
ruta <- "Infeccion 14 de noviembre 2023 Reporte full(1).pzfx"
probit_data <- read_pzfx(ruta, table = "Probit LC50")

# Convertir ROWTITLE a carácter
probit_data <- probit_data %>%
  mutate(ROWTITLE = as.character(ROWTITLE))

# Formato largo
probit_long <- probit_data %>%
  pivot_longer(cols = -ROWTITLE, names_to = "replica", values_to = "porcentaje") %>%
  filter(!is.na(porcentaje)) %>%
  mutate(
    concentracion = case_when(
      ROWTITLE == "3.9" ~ 0,
      ROWTITLE == "39" ~ 39,
      ROWTITLE == "390" ~ 390,
      ROWTITLE == "3900" ~ 3900,
      ROWTITLE == "39000" ~ 39000,
      ROWTITLE == "390000" ~ 390000,
      TRUE ~ NA_real_
    ),
    log10_conc = log10(concentracion),
    proporcion = porcentaje / 100,
    muertos = round(proporcion * 100),
    vivos = 100 - muertos
  ) %>%
  filter(!is.na(concentracion), concentracion > 0)

# Modelo Probit
modelo <- glm(cbind(muertos, vivos) ~ log10_conc,
              family = binomial(link = "probit"),
              data = probit_long)

# LC50 con dose.p
dosis <- dose.p(modelo, p = 0.5)
lc50 <- 10^dosis[1]
cat("LC50 =", lc50, "CFU/mL\n")

# ============================================================
# IC 95% por bootstrap
# ============================================================

# Función que ajusta el modelo a una muestra bootstrap y devuelve la LC50
boot_lc50 <- function(data, indices) {
  d <- data[indices, ]
  m <- tryCatch(
    glm(cbind(muertos, vivos) ~ log10_conc,
        family = binomial(link = "probit"),
        data = d),
    error = function(e) return(NULL)
  )
  if (is.null(m)) return(NA)
  dp <- tryCatch(dose.p(m, p = 0.5), error = function(e) return(NULL))
  if (is.null(dp)) return(NA)
  10^dp[1]
}

# Ejecutar bootstrap con 2000 réplicas
set.seed(123)
b <- boot(probit_long, boot_lc50, R = 2000)

# Calcular IC 95% percentil
ic_boot <- quantile(b$t, c(0.025, 0.975), na.rm = TRUE)
cat("IC 95% bootstrap =", ic_boot[1], "-", ic_boot[2], "CFU/mL\n")

# Opcional: IC 95% BCa (más robusto)
ic_bca <- boot.ci(b, type = "bca")
cat("IC 95% BCa =", ic_bca$bca[4], "-", ic_bca$bca[5], "CFU/mL\n")
