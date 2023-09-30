# Analyze Simulation Results
#   Decision: Adoption
#   Data Source: Monte Carlo Simulation

# Load Functions ===============================================================
source(file.path("src", "FUNS", "tbls.R"))
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
  adopt_tbl(x = simResult, 
            effect_measure = "LYs", 
            lambda = 20000, 
            nbType = "NMB", 
            currency = "GBP")

# Write to Disk
gt::gtsave(data = adoptionTBL, 
           filename = "adopt-tbl_MC-Sim.pdf", 
           path = file.path("results"))

# Figures ======================================================================
## i) Cost-Effectiveness Plane -------------------------------------------------
## ii) CEAC --------------------------------------------------------------------
