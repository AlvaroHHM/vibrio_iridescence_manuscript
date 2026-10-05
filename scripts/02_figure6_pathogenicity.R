#!/usr/bin/env Rscript
# ============================================================
# Figura 6 - Cuatro paneles en 2x2
#   A) Curvas de survival por dosis (15_CESAIBC)
#   B) Mortalidad acumulada por dosis con CLD
#   C) Curvas descriptivas de 7 cepas
#   D) Boxplot de mortalidad en 3 cepas de V. parahaemolyticus
#      con letras CLD (Kruskal-Wallis + Dunn BH)
# ============================================================

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(survival)
  library(multcompView)
  library(cowplot)
  library(rstatix)
})

# setwd() eliminado; usar here::here() o ruta relativa

# ============================================================
# 1. DATOS PANELES A y B: dosis de 15_CESAIBC
# ============================================================
df_wide <- read_csv("../data/processed/survival_kaplan_meier.csv", show_col_types = FALSE)
# Renombrar columnas al formato esperado
colnames(df_wide) <- c("id", "time", "Control", "3.9e1", "3.9e2", "3.9e3", "3.9e4", "3.9e5")
colnames(df_wide)[1] <- "id"
colnames(df_wide)[2] <- "time"

orden_niveles <- c("Control", "3.9e1", "3.9e2", "3.9e3", "3.9e4", "3.9e5")

df_long <- df_wide %>%
  pivot_longer(cols = -c(id, time),
               names_to = "group",
               values_to = "status",
               values_drop_na = TRUE) %>%
  mutate(status = as.integer(status),
         group  = factor(group, levels = orden_niveles))

paleta_dosis <- c(
  "Control" = "#000000",
  "3.9e1"   = "#3B0A14",
  "3.9e2"   = "#6E1423",
  "3.9e3"   = "#A01D2B",
  "3.9e4"   = "#D62828",
  "3.9e5"   = "#F03B3B"
)

# ============================================================
# 2. DATOS PANEL C: curvas de 7 cepas
# ============================================================
datos_C <- read_csv("../data/survival_7strains.csv", show_col_types = FALSE) %>%
  mutate(surv = survival / 100)

orden_C <- c("15_CESAIBC", "AT_BV", "1_MXM", "8_VM", "3_MXM",
             "CSA25-control", "Control")

datos_C$series <- factor(datos_C$series, levels = orden_C)

strain_colors_aaas <- c(
  "1_MXM"         = "#3B4992",
  "3_MXM"         = "#008280",
  "15_CESAIBC"    = "#EE0000",
  "8_VM"          = "#BB0021",
  "AT_BV"         = "#631879",
  "CSA25-control" = "#1F77B4",
  "Control"       = "#808000"
)

# ============================================================
# 3. DATOS PANEL D: mortalidad de 3 cepas V. parahaemolyticus
# ============================================================
datos_D <- read_csv("../data/mortality_3strains.csv", show_col_types = FALSE) %>%
  mutate(prop_mortalidad = dead / total * 100,
         strain = factor(strain, levels = c("15_CESAIBC", "6_VM", "11_VM")))

# ============================================================
# 4. Funciones auxiliares
# ============================================================
km_a_df <- function(df) {
  s <- survfit(Surv(time, status) ~ group, data = df, conf.type = "log-log")
  data.frame(time   = s$time,
             surv   = s$surv,
             lower  = s$lower,
             upper  = s$upper,
             group  = rep(names(s$strata), s$strata))
}

logrank_pairwise <- function(df) {
  global <- survdiff(Surv(time, status) ~ group, data = df)
  p_global <- 1 - pchisq(global$chisq, length(global$n) - 1)
  grupos <- levels(df$group)
  pares <- combn(grupos, 2, simplify = FALSE)
  pairwise <- bind_rows(lapply(pares, function(par) {
    sub <- df %>% filter(group %in% par)
    sd  <- survdiff(Surv(time, status) ~ group, data = sub)
    p   <- 1 - pchisq(sd$chisq, length(sd$n) - 1)
    data.frame(group1 = par[1], group2 = par[2], p = p)
  }))
  pairwise$p_adj <- p.adjust(pairwise$p, method = "BH")
  list(global = p_global, pairwise = pairwise)
}

mortalidad_acumulada <- function(df) {
  resumen <- df %>%
    group_by(group) %>%
    summarise(dead = sum(status == 1),
              alive   = sum(status == 0),
              total   = n(), .groups = "drop") %>%
    mutate(prop_mortalidad = dead / total * 100)
  grupos <- levels(df$group)
  pares <- combn(grupos, 2, simplify = FALSE)
  fisher_df <- bind_rows(lapply(pares, function(par) {
    a <- resumen %>% filter(group == par[1])
    b <- resumen %>% filter(group == par[2])
    m <- matrix(c(a$dead, a$alive, b$dead, b$alive),
                nrow = 2, byrow = TRUE)
    test <- fisher.test(m)
    data.frame(group1 = par[1], group2 = par[2],
               p = test$p.value,
               odds_ratio = unname(test$estimate))
  }))
  fisher_df$p_adj <- p.adjust(fisher_df$p, method = "BH")
  list(resumen = resumen, fisher = fisher_df)
}

# ============================================================
# 5. PANEL A: curvas de survival por dosis
# ============================================================
km_df <- km_a_df(df_long)
km_df$group <- factor(km_df$group, levels = paste0("group=", orden_niveles))

p_A <- ggplot(km_df, aes(x = time, y = surv, color = group, fill = group)) +
  geom_step(linewidth = 1) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, color = NA) +
  scale_color_manual(
    values = setNames(paleta_dosis, paste0("group=", orden_niveles)),
    breaks = paste0("group=", orden_niveles),
    labels = orden_niveles,
    limits = paste0("group=", orden_niveles),
    name   = "(CFU/mL)"
  ) +
  scale_fill_manual(
    values = setNames(paleta_dosis, paste0("group=", orden_niveles)),
    breaks = paste0("group=", orden_niveles),
    labels = orden_niveles,
    limits = paste0("group=", orden_niveles),
    name   = "(CFU/mL)"
  ) +
  scale_x_continuous(breaks = seq(0, 90, 30)) +
  scale_y_continuous(limits = c(0, 1.02), breaks = seq(0, 1, 0.5),
                     labels = scales::percent) +
  labs(x = "Time post-infection (h)",
       y = "Cumulative survival (%)") +
  theme_classic(base_size = 16) +
  theme(
    axis.title      = element_text(size = 14),
    axis.text       = element_text(size = 14),
    legend.title    = element_text(size = 14),
    legend.text     = element_text(size = 12),
    legend.key.size = unit(0.5, "cm"),
    legend.position = "bottom"
  )

# ============================================================
# 6. PANEL B: mortalidad acumulada con letras CLD
# ============================================================
ma <- mortalidad_acumulada(df_long)
ma$resumen$group <- factor(ma$resumen$group, levels = orden_niveles)

grupos <- orden_niveles
p_mat <- matrix(1, nrow = length(grupos), ncol = length(grupos),
                dimnames = list(grupos, grupos))
for (i in seq_len(nrow(ma$fisher))) {
  g1 <- as.character(ma$fisher$group1[i])
  g2 <- as.character(ma$fisher$group2[i])
  p_mat[g1, g2] <- ma$fisher$p_adj[i]
  p_mat[g2, g1] <- ma$fisher$p_adj[i]
}

cld    <- multcompLetters(p_mat, threshold = 0.05)
letras <- data.frame(group  = factor(names(cld$Letters), levels = orden_niveles),
                     letter = as.character(cld$Letters))

ma$resumen <- ma$resumen %>%
  left_join(letras, by = "group") %>%
  arrange(group)

p_B <- ggplot(ma$resumen,
              aes(x = group, y = prop_mortalidad, fill = group)) +
  geom_col(color = "black", width = 0.7) +
  geom_text(aes(label = paste0(dead, "/", total)),
            vjust = -0.5, size = 4) +
  geom_text(aes(label = letter),
            vjust = -2.2, size = 6, fontface = "bold") +
  scale_fill_manual(
    values = paleta_dosis,
    breaks = orden_niveles,
    limits = orden_niveles,
    name   = "(CFU/mL)"
  ) +
  scale_x_discrete(
    limits = orden_niveles,
    labels = orden_niveles
  ) +
  scale_y_continuous(
    limits = c(0, max(ma$resumen$prop_mortalidad) + 18),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(x = "(CFU/mL)",
       y = "Cumulative mortality (%)") +
  theme_classic(base_size = 16) +
  theme(
    axis.title      = element_text(size = 14),
    axis.text       = element_text(size = 14),
    legend.title    = element_text(size = 14),
    legend.text     = element_text(size = 12),
    legend.key.size = unit(0.5, "cm"),
    legend.position = "bottom"
  )

# ============================================================
# 7. PANEL C: curvas de 7 cepas (zoom Y: 50–100%)
# ============================================================
p_C <- ggplot(datos_C, aes(x = hours, y = surv,
                           color = series, group = series)) +
  geom_step(linewidth = 1.5, alpha = 0.6) +
  geom_point(size = 2, alpha = 0.6) +
  scale_color_manual(values = strain_colors_aaas,
                     breaks = orden_C,
                     limits = orden_C,
                     name   = "Strain") +
  scale_x_continuous(breaks = seq(0, 120, 40)) +
  scale_y_continuous(limits = c(0.70, 1.00),
                     breaks = seq(0.70, 1.00, 0.10),
                     labels = scales::percent) +
  labs(x = "Time post-infection (h)",
       y = "Cumulative survival (%)") +
  theme_classic(base_size = 16) +
  theme(
    axis.title      = element_text(size = 14),
    axis.text       = element_text(size = 14),
    legend.position = c(0.02, 0.02),      # <-- esquina inferior izquierda
    legend.justification = c(0, 0),       # anclaje en la esquina
    legend.background = element_rect(fill = "white",
                                     color = "white",
                                     linewidth = 0.3),
    legend.key.size = unit(0.4, "cm"),
    legend.title    = element_text(size = 11),
    legend.text     = element_text(size = 11),
    legend.margin   = margin(3, 3, 3, 3)
  ) +
  guides(color = guide_legend(nrow = 3, byrow = TRUE))

# ============================================================
# 8. PANEL D: boxplot de 3 cepas (zoom Y: 30–60%, alpha 0.7)
# ============================================================
kw   <- datos_D %>% kruskal_test(prop_mortalidad ~ strain)
dunn <- datos_D %>% dunn_test(prop_mortalidad ~ strain,
                              p.adjust.method = "BH")

niveles_D <- c("15_CESAIBC", "6_VM", "11_VM")
p_mat_D <- matrix(1, nrow = 3, ncol = 3,
                  dimnames = list(niveles_D, niveles_D))
for (i in seq_len(nrow(dunn))) {
  g1 <- as.character(dunn$group1[i])
  g2 <- as.character(dunn$group2[i])
  p_mat_D[g1, g2] <- dunn$p.adj[i]
  p_mat_D[g2, g1] <- dunn$p.adj[i]
}

cld_D    <- multcompLetters(p_mat_D, threshold = 0.05)
letras_D <- data.frame(
  strain = factor(names(cld_D$Letters), levels = niveles_D),
  letter = as.character(cld_D$Letters)
)

pos_letras <- datos_D %>%
  group_by(strain) %>%
  summarise(y_max = max(prop_mortalidad), .groups = "drop") %>%
  left_join(letras_D, by = "strain") %>%
  mutate(y_letter = pmin(y_max + 1.5, 58))

colores_D <- c(
  "15_CESAIBC" = "#EE0000",
  "6_VM"       = "#A20056",
  "11_VM"      = "#008B45"
)

p_D <- ggplot(datos_D, aes(x = strain, y = prop_mortalidad, fill = strain)) +
  geom_boxplot(alpha = 0.7, width = 0.6, color = "black", outlier.shape = NA) +
  geom_jitter(width = 0.12, size = 2, alpha = 0.85, color = "black") +
  geom_text(data = pos_letras,
            aes(x = strain, y = y_letter, label = letter),
            inherit.aes = FALSE, size = 6, fontface = "bold") +
  scale_fill_manual(values = colores_D, guide = "none") +
  scale_y_continuous(
    limits = c(30, 60),
    breaks = seq(30, 60, 5)
  ) +
  labs(x = "Strain",
       y = "Mortality (%)") +
  theme_classic(base_size = 16) +
  theme(
    axis.title      = element_text(size = 14),
    axis.text       = element_text(size = 14),
    legend.position = "none"
  )

# ============================================================
# 9. Layout 2x2 con cowplot
# ============================================================
fig6 <- plot_grid(
  p_A, p_B,
  p_C, p_D,
  ncol           = 2,
  labels         = c("A", "B", "C", "D"),
  label_size     = 18,
  label_fontface = "bold",
  align          = "hv",
  axis           = "tblr",
  rel_widths     = c(1, 1),
  rel_heights    = c(1, 1)
)

# ============================================================
# 10. Exportar
# ============================================================
ggsave("Figure5_pathogenicity.svg", plot = fig6,
       width = 14, height = 13, units = "in", bg = "white")

# ============================================================
# 11. Tablas suplementarias
# ============================================================
lr_A <- logrank_pairwise(df_long)

write_csv(lr_A$pairwise, "TablaS_logrank_pairwise_A.csv")
write_csv(ma$resumen %>% select(group, dead, alive, total,
                                prop_mortalidad, letter),
          "TablaS_mortalidad_letras_B.csv")
write_csv(ma$fisher, "TablaS_fisher_pairwise_B.csv")
write_csv(kw,   "TablaS_kruskal_D.csv")
write_csv(dunn, "TablaS_dunn_pairwise_D.csv")
write_csv(pos_letras, "TablaS_letras_boxplot_D.csv")

message("Figura 6 (paneles A, B, C y D en 2x2) generada.")
