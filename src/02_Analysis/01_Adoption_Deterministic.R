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
##  Initialize SimData Object --------------------------------------------------
simResult <- new_sim_data(x = simResult, currency = "GBP")
# Perform CEA ==================================================================
hiv_cea <- 
  new_cea(
    x = simResult, 
    effect_measure = "LYs", 
    req_lambda = 20000, 
    nb_type = "NMB"
  )
##  Print CEA Object -----------------------------------------------------------
##  Note: This is not very useful yet. 
print(hiv_cea)

##  CEA Result Table -----------------------------------------------------------
cea_tbl <- result_tbl(x = hiv_cea, lambda = 20000, scope = "none")
# Preview
cea_tbl

# Write to disk
gt::gtsave(
  data = cea_tbl, 
  filename = "adopt-tbl_deterministic.html", 
  path = file.path("results")
)

##  Figure: Cost-Effectiveness Plane -------------------------------------------
fig_1 <- 
  plot_ceplane(x = hiv_cea, lambda = NULL, scope = "none")
fig_1

# Write to disk
ggplot2::ggsave(filename = file.path("results", "CE-Plane_Deter.png"), 
                plot = fig_1, 
                device = "png", 
                width = 6.25, 
                height = 5.50)
