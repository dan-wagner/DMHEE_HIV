# Conduct Deterministic Simulation of Cohort Model

library(fs)
source(path_wd("src", "FUNS", "HIV_Model", ext = "R"))
source(path_wd("src", "FUNS", "Model_Parameters", ext = "R"))

# Get Model Parameters =========================================================
getParams()
HIV_Params <- readr::read_rds(path_wd("data", 
                                      "data-gen", 
                                      "Model-Params", 
                                      "HIV-Params", 
                                      ext = "rds"))

# Estimate Costs and Effects ===================================================
Param_i <- DrawParams(ParamList = HIV_Params, prob = 0)

HIV_result <- 
  sapply(X = list(Mono = "Mono", Comb = "Comb"), 
         FUN = runModel, 
         ParamList = Param_i, 
         nCycles = 20, 
         oDR = 0, 
         cDR = 0.06, 
         simplify = "array") |> 
  t()

# Save Output ==================================================================
readr::write_rds(x = HIV_result, 
                 file = path_wd("data", 
                                "data-gen", 
                                "Simulation-Output", 
                                "HIV_Deter", 
                                ext = "rds"))
