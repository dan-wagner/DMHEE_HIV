# Analyze Simulation Results
#   Decision: Adoption
#   Data Source: Monte Carlo Simulation

# Load Functions ===============================================================
library(HEEToolkit)

# Load Data ====================================================================
simResult <- readr::read_rds(file = file.path("data", 
                                              "data-gen", 
                                              "Simulation-Output", 
                                              "MC-Sim.rds"))
##  Modify Names of j ----------------------------------------------------------
dimnames(simResult)$j <- c("zidovudine", "zidovudine + lamivudine")

# Adoption Table ===============================================================
adoptionTBL <- 
  adopt_tbl(data = simResult, 
            effect_measure = "LYs", 
            lambda = 20000, 
            nb_type = "NMB", 
            currency = "GBP")

# Write to Disk
gt::gtsave(data = adoptionTBL, 
           filename = "adopt-tbl_MC-Sim.html", 
           path = file.path("results"))

# Figures ======================================================================
## i) Cost-Effectiveness Plane -------------------------------------------------
FigData <- ceplane_data(data = simResult, 
                        effect_measure = "LYs", 
                        lambda = 20000, 
                        currency = "GBP")
hiv_ceplane <- viz_ceplane(x = FigData, 
                           show_uncertainty = FALSE, 
                           show_lambda = TRUE,
                           decision_rule = list(show = TRUE, id = NULL))
hiv_ceplane <- 
  hiv_ceplane + 
  ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white"), 
                 plot.background = ggplot2::element_rect(fill = "white"))

ggplot2::ggsave(filename = file.path("results", "CE-Plane_MC.png"), 
                plot = hiv_ceplane, 
                device = "png", 
                width = 6.25, 
                height = 5.50)

## ii) CEAC --------------------------------------------------------------------
FigData <- ceac_data(data = simResult,
                     effect_measure = "LYs",
                     max_lambda = 150000, 
                     nb_type = "NMB", 
                     currency = "GBP")
hiv_ceac_f0 <- 
  viz_ceac(x = FigData, show_frontier = FALSE) + 
  ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white"), 
                 plot.background = ggplot2::element_rect(fill = "white"))

hiv_ceac_f1 <- 
  viz_ceac(x = FigData, show_frontier = TRUE) + 
  ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white"), 
                 plot.background = ggplot2::element_rect(fill = "white"))

ggplot2::ggsave(filename = file.path("results", 
                                     "CEAC_Frontier-0.png"), 
                plot = hiv_ceac_f0, 
                device = "png", 
                width = 6.25, 
                height = 5.50)

ggplot2::ggsave(filename = file.path("results", 
                                     "CEAC_Frontier-1.png"), 
                plot = hiv_ceac_f1, 
                device = "png", 
                width = 6.25, 
                height = 5.50)