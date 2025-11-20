# Value of Information Analysis
# HIV Model

# Load Functions ===============================================================
library(HEEToolkit)

# Load Data ====================================================================
##  Monte Carlo Simulation -----------------------------------------------------
simMC <-
  readr::read_rds(
    file = file.path("data", "data-gen", "Simulation-Output", "MC-Sim.rds")
  ) |> 
  new_sim_data(x = _, currency = "GBP")

##  Nested Monte Carlo Simulation ----------------------------------------------
##    Note: Scope is limited to command line output


##    Read File names
simNMC <- 
  list.files(
    path = file.path("data", "data-gen", "Simulation-Output"), 
    pattern = "^Nested_MC-Sim", 
    full.names = TRUE
  )
##    Set Parameter Name to element names
file_prefix <- 
  file.path("data", "data-gen", "Simulation-Output", "Nested_MC-Sim_")

names(simNMC) <- sub(pattern = file_prefix, replacement = "", x = simNMC)
names(simNMC) <- sub(pattern = ".rds$", replacement = "", x = names(simNMC))
##  Import Data
simNMC <- lapply(X = simNMC, FUN = readr::read_rds)

# Prepare for Analysis =========================================================
#   Set threshold values -------------------------------------------------------
#     Note: values selected arbitrarily for demonstration
user_lambda <- c(5000, 20000, 50000, 70000)

#   Set Effective Population Size ----------------------------------------------
#     Note: These values are assumed for the purpose of demonstration. 
EP <- voi_EP(Yrs = 10, I_t = 20000, DR = 0.03)

# EVPI =========================================================================
hiv_evpi <- 
  calc_evpi(
    x = simMC, 
    effect_measure = "LYs",
    lambda = user_lambda, 
    nb_type = "NMB", 
    eff_pop = 500
  )

# EVPPI ========================================================================
##  Parameter: Annual Cost
calc_evppi(
  data = simNMC$AnnualCost, 
  lambda = user_lambda, 
  eff_pop = 500, 
  effect_measure = "LYs", 
  nb_type = "NMB"
)
##  Parameter: Relative Risk
calc_evppi(
  data = simNMC$RR, 
  lambda = user_lambda, 
  eff_pop = 500, 
  effect_measure = "LYs", 
  nb_type = "NMB"
)
##  Parameter: State Count
calc_evppi(
  data = simNMC$StateCount, 
  lambda = user_lambda, 
  eff_pop = 500, 
  effect_measure = "LYs", 
  nb_type = "NMB"
)

# Build Report Artifacts =======================================================
