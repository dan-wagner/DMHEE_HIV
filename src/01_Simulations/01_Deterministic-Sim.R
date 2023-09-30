# Conduct Deterministic Simulation of Cohort Model

source(file.path("src", "FUNS", "HIV_Model.R"))
source(file.path("src", "FUNS", "Model_Parameters.R"))

# Get Model Parameters =========================================================
HIV_Params <- getParams()

# Estimate Costs and Effects ===================================================
Param_i <- DrawParams(ParamList = HIV_Params, prob = FALSE)

HIV_result <- 
  sapply(X = list(Mono = "Mono", Comb = "Comb"), 
         FUN = runModel, 
         ParamList = Param_i,
         comb_yrs = 2,
         n_cycles = 20, 
         oDR = 0, 
         cDR = 0.06, 
         simplify = "array") |> 
  t()

names(dimnames(HIV_result)) <- c("j", "Result")

# Save Output ==================================================================
readr::write_rds(x = HIV_result, 
                 file = file.path("data", 
                                  "data-gen", 
                                  "Simulation-Output", 
                                  "Deter.rds"))
