# Analyze Simulation Results
#   Decision: Adoption
#   Data Source: Deterministic

# Load Functions ===============================================================
source(file.path("src", "FUNS", "tbls.R"))


# Load Data ====================================================================
simResult <- readr::read_rds(file = file.path("data", 
                                              "data-gen", 
                                              "Simulation-Output", 
                                              "Deter.rds"))
##  Modify Names of j ----------------------------------------------------------
dimnames(simResult)$j <- c("zidovudine", "zidovudine + lamivudine")

# Adoption Table ===============================================================
deter_tbl <- 
  adopt_tbl(x = simResult, 
            effect_measure = "LYs", 
            lambda = 20000, 
            nbType = "NMB", 
            currency = "GBP")

# Write to Disk
gt::gtsave(data = displayTBL, 
           filename = "adopt-tbl_deterministic.html", 
           path = file.path("results"))

# Figures ======================================================================
## i) Cost-Effectiveness Plane -------------------------------------------------
## ii) CEAC --------------------------------------------------------------------
