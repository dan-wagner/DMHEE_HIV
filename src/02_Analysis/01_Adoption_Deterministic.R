# Analyze Simulation Results
#   Decision: Adoption
#   Data Source: Deterministic

# Load Functions ===============================================================
library(HEEToolkit)

# Load Data ====================================================================
simResult <- readr::read_rds(file = file.path("data", 
                                              "data-gen", 
                                              "Simulation-Output", 
                                              "Deter.rds"))
##  Modify Names of j ----------------------------------------------------------
dimnames(simResult)$j <- c("zidovudine", "zidovudine + lamivudine")

# Adoption Table ===============================================================
deter_tbl <- 
  adopt_tbl(data = simResult, 
            effect_measure = "LYs", 
            lambda = 20000, 
            nb_type = "NMB", 
            currency = "GBP")

# Write to Disk
gt::gtsave(data = deter_tbl, 
           filename = "adopt-tbl_deterministic.html", 
           path = file.path("results"))

# Figures ======================================================================
## i) Cost-Effectiveness Plane -------------------------------------------------
FigData <- ceplane_data(data = simResult,
                        effect_measure = "LYs",
                        lambda = 20000,
                        currency = "CAD")

HIV_CEPlane <- 
  viz_ceplane(x = FigData, 
              show_uncertainty = FALSE,
              show_lambda = TRUE,
              decision_rule = list(show = FALSE, id = NULL))

ggplot2::ggsave(filename = file.path("results", "CE-Plane_Deter.png"), 
                plot = HIV_CEPlane, 
                device = "png", 
                width = 5.73, 
                height = 4.68)
