# Conduct Monte Carlo Simulation of HIV Cohort Model

source(file.path("src", "FUNS", "HIV_Model.R"))
source(file.path("src", "FUNS", "Model_Parameters.R"))

# Get Model Parameters =========================================================
HIV_Params <- get_params()

# Run Simulation ===============================================================
PHI <- "StateCount"

sim_start <- Sys.time()
nmc_out <- 
  replicate(n = 1000, 
            expr = {
              # Draw Outer Loop Parameter
              PHI_i <- DrawParams(ParamList = HIV_Params, prob = 1)[PHI]
              
              # Initiate Inner Loop
              replicate(n = 1000,
                        expr = {
                          # Draw Inner Loop Parameters (PSI)
                          PSI_i <- DrawParams(ParamList = HIV_Params, prob = 1)
                          # Fix the value of PHI to the correct element of PSI
                          PSI_i[PHI] <- PHI_i
                          # Run Model
                          result_i <- 
                            sapply(X = list(Mono = "Mono", Comb = "Comb"), 
                                   FUN = run_arm, 
                                   ParamList = PSI_i, 
                                   nCycles = 20, 
                                   oDR = 0, 
                                   cDR = 0.06, 
                                   simplify = "array")
                        }, 
                        simplify = "array")
                     }, 
                     simplify = "array")
names(dimnames(nmc_out)) <- c("Result", "j", "PSI", "PHI")
nmc_out <- aperm(a = nmc_out, perm = c("PSI", "Result", "j", "PHI"))
sim_stop <- Sys.time()

# Calculate Simulation Run Time
sim_time <- sim_stop - sim_start
sim_time

# Save Output to data-gen
FileName <- paste("Nested", "MC-Sim", PHI, sep = "_")
FileName <- sub(pattern = "$", replacement = ".rds", x = FileName)

readr::write_rds(x = nmc_out, 
                 file = file.path("data", 
                                  "data-gen", 
                                  "Simulation-Output", 
                                  FileName))