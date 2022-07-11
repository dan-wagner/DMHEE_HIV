# Conduct Monte Carlo Simulation of HIV Cohort Model

source(file.path("src", "FUNS", "HIV_Model.R"))
source(file.path("src", "FUNS", "Model_Parameters.R"))

# Get Model Parameters =========================================================
getParams()
HIV_Params <- readr::read_rds(file = file.path("data", 
                                               "data-gen", 
                                               "Model-Params", 
                                               "HIV-Params.rds"))

# Estimate Costs and Effects ===================================================
HIV_result <- 
replicate(n = 5000, 
          expr = {
            Param_i <- DrawParams(ParamList = HIV_Params, prob = 1)
            Result_i <- 
              sapply(X = list(Mono = "Mono", Comb = "Comb"), 
                     FUN = runModel, 
                     ParamList = Param_i, 
                     nCycles = 20, 
                     oDR = 0, 
                     cDR = 0.06, 
                     simplify = "array")
          }, 
          simplify = "array")
names(dimnames(HIV_result)) <- c("Result", "j", "i")
HIV_result <- aperm(a = HIV_result, perm = c("i", "Result", "j"))

# Save Output ==================================================================
readr::write_rds(x = HIV_result, 
                 file = file.path("data", 
                                  "data-gen", 
                                  "Simulation-Output", 
                                  "MC-Sim.rds"))
