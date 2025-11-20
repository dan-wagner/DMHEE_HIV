getParams <- function(FileName = "HIV-Params.rds", child_dir = FALSE) {
  # Get Model Parameters
  #
  # Args: 
  #   FileName: The name to give to the parameter file. Default is 
  #   "HIV-Params.rds"
  #   child_dir: Logical (Default: FALSE). Controls whether the current working
  #     directory is the same as the project root (FALSE) or in a child 
  #     directory of that location (TRUE). 
  #       - Needed for quarto reporting. 
  #
  # Returns: 
  # A list with four named elements: 
  #   StateCount: The count of patients who moved between health states in 
  #   the reference study for monotherapy.
  #   RR: The relative risk of severe disease from combination therapy.
  #   AnnualCost: A matrix of the direct medical and community costs associated
  #   with Health States A, B, and C.
  #   RxPrices: A named vector of the price for each drug considered in the 
  #   model.
  
  # Set Path to Output File
  if (isTRUE(child_dir)) {
    param_path <- file.path("..", "data", "data-gen", "Model-Params", FileName)
  } else {
    param_path <- file.path("data", "data-gen", "Model-Params", FileName)
  }
  # Check if File exists
  params_exist <- file.exists(param_path)
  
  if (isFALSE(params_exist)) {
    usethis::ui_info("Model Parameters have not been generated!")
    # Check if sub-directory exists
    if (isTRUE(child_dir)) {
      param_dir <- file.path("..", "data", "data-gen", "Model-Params")
    } else {
      param_dir <- file.path("data", "data-gen", "Model-Params")
    }
    
    dir_present <- dir.exists(paths = param_dir)
    
    if (isFALSE(params_dir)) {
      usethis::ui_oops("Missing {usethis::ui_path(param_dir)} sub-directory.")
      dir.create(path = param_dir)
      usethis::ui_done("Created {usethis::ui_path(param_dir)} sub-directory.")
    }
    # Set Directory for Raw Data
    raw_dir <- file.path("data", "data-raw")
    usethis::ui_info("Generating Parameters from raw data")
    params <- list.files(path = file.path("data", "data-raw"), 
                         pattern = ".rds", 
                         full.names = TRUE)
    names(params) <- sub(pattern = "data/data-raw/", 
                         replacement = "", 
                         x = params)
    names(params) <- sub(pattern = ".rds", "", names(params))
    names(params) <- sub(pattern = "StateTransitions_Count_Mono", 
                         replacement = "StateCount", 
                         x = names(params))
    names(params) <- sub(pattern = "Relative-Risk_Progression", 
                         replacement = "RR", 
                         x = names(params))
    names(params) <- sub(pattern = "HIV_Annual-Costs", 
                         replacement = "AnnualCost", 
                         x = names(params))
    params <- lapply(X = params, FUN = readr::read_rds)
    # Write Data to param_path
    readr::write_rds(x = params, file = param_path)
    usethis::ui_done("Parameter list saved to {usethis::ui_path(param_path)}")
  } else {
    params <- readr::read_rds(file = param_path)
    usethis::ui_info("Loaded parameters from: {usethis::ui_path(param_path)}")
  }
  return(params)
}

# Draw Parameters deterministically or probabilsitically =======================
## Method of Moments Implementation: Gamma Distribution ------------------------
MoM_Costs <- function(Mean, SE){
  Alpha <- Mean^2/SE^2
  Beta <- SE^2/Mean
  
  Result <- list(Alpha = Alpha, 
                 Beta = Beta)
  
  return(Result)
}

## Perform Single Mone Carlo draw of each model parameter ----------------------
DrawParams <- function(ParamList, prob = FALSE) {
  # Draw Deterministic or Random Values for Simulation
  #
  # Args:
  #   ParamList: A list of parameter values required by the simulation.
  #   Prob: Logical (Default = `FALSE`). Controls whether parameter values 
  #   represent the mean (`FALSE`) or a random value from an assigned 
  #   distribution. 
  #
  # Returns: 
  #   A list of 5 elements, representing the sampled values. 
  
  # Relative Risk of Disease Progression ---------------------------------------
  ## Distribution: Log Normal
  if (isTRUE(prob)) {
    RRsd <- (log(ParamList$RR[["CI_upper"]]) - 
               log(ParamList$RR[["CI_lower"]]))/(1.96*2)
    
    ParamList$RR <- 
      rlnorm(n = 1, 
             meanlog = log(ParamList$RR[["Mean"]]), 
             sdlog = RRsd)
  } else {
    ParamList$RR <- ParamList$RR[["Mean"]]
  }
  
  # State Transitions ----------------------------------------------------------
  ParamList$StateCount <- prop.table(x = ParamList$StateCount, margin = 1)
  ParamList$StateCount["D", ] <- c(rep(0, 3), 1)
  if (isTRUE(prob)) {
    # AIDS ("C") to Death ("D")
    ## Distribution: Beta
    ParamList$StateCount["C", "D"] <- 
      rbeta(n = 1, 
            shape1 = ParamList$StateCount["C", "D"],
            shape2 = ParamList$StateCount["C", "C"])
    ParamList$StateCount["C", "C"] <- 1 - ParamList$StateCount["C", "D"]
    # Remaining Polytonomous Transitions
    ## Distribution: Dirichlet
    ParamList$StateCount["A", ] <- 
      MCMCpack::rdirichlet(n = 1, alpha = ParamList$StateCount["A",])
    ParamList$StateCount["B", ] <- 
      MCMCpack::rdirichlet(n = 1, alpha = ParamList$StateCount["B",])
  }
  
  # Annual Cost ----------------------------------------------------------------
  ## Distribution: Gamma
  ## These values are mean costs. The original article did not include 
  ## information about the variance of the costs. Therefore, it is assumed that 
  ## SE of annual costs is equal to the mean. 
  
  if (isTRUE(prob)) {
    ABcosts <- MoM_Costs(Mean = ParamList$AnnualCost, 
                         SE = ParamList$AnnualCost)
    
    ParamList$AnnualCost <- 
      sapply(X = setNames(rownames(ParamList$AnnualCost), 
                          rownames(ParamList$AnnualCost)), 
             FUN = \(x){
               mapply(rgamma, 
                      shape = ABcosts$Alpha[x,], 
                      scale = ABcosts$Beta[x,], 
                      MoreArgs = list(n = 1)
               )
             }, 
             simplify = "array")
    
    ParamList$AnnualCost <- t(ParamList$AnnualCost)
  }

  return(ParamList)
}