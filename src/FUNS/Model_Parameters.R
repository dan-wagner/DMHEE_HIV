getParams <- function(FileName = "HIV-Params.rds") {
  # Set Path to Output File
  param_path <- file.path("data", "data-gen", "Model-Params", FileName)
  # Check if File exists
  params_exist <- file.exists(param_path)
  
  if (isFALSE(params_exist)) {
    usethis::ui_info("Model Parameters have not been generated!")
    # Check if sub-directory exists
    param_dir <- file.path("data", "data-gen", "Model-Params")
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

# Define Transition Matrix (Q) #################################################
## StateCounts = A matrix of state transitions. 
## RR = Relative risk of severe disease from combination therapy.  
define_tmat <- function(StateCounts, RR = 0.509, prob = 0) {
  
  # Calculate Probability of State Transitions using Mono Counts
  Q <- prop.table(x = StateCounts, margin = 1)
  Q["D", ] <- c(rep(0, 3),1)
  
  # Apply Random Draws if Required 
  if (prob == 1) {
    # AIDS ("C") to Death ("D")
    ## Distribution: Beta
    Q["C", "D"] <- rbeta(n = 1, shape1 = Q["C", "D"], shape2 = Q["C", "C"])
    Q["C", "C"] <- 1 - Q["C", "C"]
    
    # Remaining Polytonomous Transitions
    ## Distribution: Dirichlet
    Q["A", ] <- MCMCpack::rdirichlet(n = 1, alpha = Q["A",])
    Q["B", ] <- MCMCpack::rdirichlet(n = 1, alpha = Q["B",])
  }
  
  # Add Dimension for each comparator
  Q <- array(data = Q, 
             dim = c(nrow(Q), ncol(Q), length(c("Mono", "Comb"))), 
             dimnames = list(Start = rownames(Q), 
                             End = colnames(Q), 
                             j = c("Mono", "Comb")))
  
  
  # Adjust transition probabilities for Comb using RR
  Q[,,"Comb"] <- Q[,,"Comb"] * RR
  diag(Q[,,"Comb"]) <- 1 - (rowSums(x = Q[,,"Comb"]) - diag(Q[,,"Comb"]))
  
  return(Q)
}

# Draw Parameters deterministically or probabilsitically =======================
MoM_Costs <- function(Mean, SE){
  Alpha <- Mean^2/SE^2
  Beta <- SE^2/Mean
  
  Result <- list(Alpha = Alpha, 
                 Beta = Beta)
  
  return(Result)
}


DrawParams <- function(ParamList, prob = 0) {
  # Relative Risk of Disease Progression ---------------------------------------
  ## Distribution: Log Normal
  if (prob == 0) {
    ParamList$RR <- ParamList$RR[["Mean"]]
  } 
  if (prob == 1) {
    RRsd <- (log(ParamList$RR[["CI_upper"]]) - 
               log(ParamList$RR[["CI_lower"]]))/(1.96*2)
    
    ParamList$RR <- 
      rlnorm(n = 1, 
             meanlog = log(ParamList$RR[["Mean"]]), 
             sdlog = RRsd)
  }
  
  # State Transitions ----------------------------------------------------------
  ParamList$Q <- define_tmat(StateCounts = ParamList$StateCount, 
                             RR = ParamList$RR, 
                             prob = prob)
  
  # Annual Cost ----------------------------------------------------------------
  ## Distribution: Gamma
  ## These values are mean costs. The original article did not include 
  ## information about the variance of the costs. Therefore, it is assumed that 
  ## SE of annual costs is equal to the mean. 
  
  if (prob == 1) {
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

  
  ParamList <- ParamList[c("Q", "AnnualCost", "RxPrices")]
  
  
  return(ParamList)
}