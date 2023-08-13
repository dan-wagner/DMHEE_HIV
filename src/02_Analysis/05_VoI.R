library(HEEToolkit)

# Import Data
#  Monte Carlo Simulation (EVPI)
mc_sim <- readr::read_rds(file = file.path("data", 
                                           "data-gen", 
                                           "Simulation-Output", 
                                           "MC-Sim.rds"))
#   Nested Monte Carlo Simulations (EVPPI) 
nmc_sim <- list.files(path = file.path("data", 
                                       "data-gen", 
                                       "Simulation-Output"), 
                      pattern = "^Nested_MC-Sim", 
                      full.names = TRUE)
names(nmc_sim) <- sub(pattern = "data/data-gen/Simulation-Output/Nested_MC-Sim_", 
                      replacement = "", 
                      x = nmc_sim)
names(nmc_sim) <- sub(pattern = ".rds$",
                      replacement = "", 
                      x = names(nmc_sim))

nmc_sim <- lapply(X = nmc_sim, FUN = readr::read_rds)

# Analyze Data #####
#   Set Threshold Values
threshold_vals <- seq(from = 0, to = 150000, by = 5000)
#   Set Size of the Effective Population
EP <- voi_EP(Yrs = 10, I_t = 20000, DR = 0.03)
# EVPI =========================================================================
EVPI <- calc_EVPI(data = mc_sim, 
                  lambda = threshold_vals, 
                  EffPop = EP, 
                  effect_measure = "LYs", 
                  nbType = "NMB")
# EVPPI ========================================================================
EVPPI <- sapply(X = nmc_sim, 
                FUN = calc_EVPPI, 
                lambda = threshold_vals, 
                EffPop = EP, 
                effect_measure = "LYs", 
                nbType = "NMB", 
                simplify = "array")

# Build Report Artifacts =======================================================
# TODO: Display Table  ---------------------------------------------------------
# Plots ------------------------------------------------------------------------
library(tidyverse)


EVPI_df <- array2DF(x = EVPI, responseName = "value")
EVPI_df <- pivot_wider(data = EVPI_df, 
                       names_from = "result", 
                       values_from = "value") |> 
  mutate(.data = _, lambda = as.double(lambda))

fig_evpi <- 
  ggplot(data = EVPI_df, 
         mapping = aes(x = lambda, y = EVPI.pt)) + 
  geom_line() + 
  scale_x_continuous(labels = scales::label_dollar(prefix = "\U00A3")) + 
  scale_y_continuous(labels = scales::label_dollar(prefix = "\U00A3")) + 
  theme_minimal() + 
  labs(title = "EVPI (Per-Patient)", 
       subtitle = "HIV Model: Monotherapy vs Combination Therapy", 
       x = "Threshold Ratio (\U03BB)", 
       y = "EVPI", 
       caption = paste("Data generated from a Monte Carlo simulation of", 
                       nrow(mc_sim), "iterations."))

ggsave(filename = file.path("results", "VoI_EVPI-pt.png"), 
       plot = fig_evpi, 
       device = "png", 
       width = 10, 
       height = 10, 
       bg = "white")

EVPPI_df <- array2DF(x = EVPPI, responseName = "value")
EVPPI_df <- pivot_wider(data = EVPPI_df, 
                        names_from = "result", 
                        values_from = "value") |> 
  rename(.data = _, "PHI" = "Var3") |> 
  mutate(.data = _, 
         lambda = as.double(lambda))

fig_evppi <- 
  ggplot(data = EVPPI_df, 
         mapping = aes(x = lambda, y = EVPPI.pt, colour = PHI)) + 
  geom_line() + 
  scale_x_continuous(labels = scales::label_dollar(prefix = "\U00A3")) + 
  scale_y_continuous(labels = scales::label_dollar(prefix = "\U00A3")) + 
  theme_minimal() + 
  labs(title = "EVPPI (Per-Patient)", 
       subtitle = "HIV Model: Monotherapy vs Combination Therapy", 
       x = "Threshold Ratio (\U03BB)", 
       y = "EVPPI", 
       colour = "\U03c6", 
       caption = paste("Data generated from a nested monte carlo simulation of", 
                       1000, "\nouter-loop iterations and", 1000, 
                       "inner-loop iterations."))

ggsave(filename = file.path("results", "VoI_EVPPI-pt.png"), 
       plot = fig_evppi, 
       device = "png", 
       width = 10, 
       height = 10, 
       bg = "white")