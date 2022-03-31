getParams <- function() {
  Params.Dir <- "data/data-gen/Model-Params"
  if(isFALSE(dir.exists(Params.Dir))) {
    usethis::ui_oops("Missing {usethis::ui_path(Params.Dir)} sub-directory.")
    
    dir.create(path = Params.Dir)
    
    usethis::ui_done("Created {usethis::ui_path(Params.Dir)} sub-directory.")
  }
  
  Dir.Content <- list.files(path = Params.Dir)
  if (length(Dir.Content) == 0) {
    usethis::ui_info("Model Parameters have not been generated!")
    usethis::ui_info("Preparing dataset from raw data")
    
    StateCounts.mono <- readr::read_rds(path_wd("data", 
                                                "data-raw", 
                                                "StateTransitions_Count_Mono", 
                                                ext = "rds"))
    
    AnnCosts <- readr::read_rds(path_wd("data", 
                                        "data-raw", 
                                        "HIV_Annual-Costs", ext = "rds"))
    
    HIV_Params <- 
      list(StateCount = StateCounts.mono, 
           RR = c(Mean = 0.509, 
                  CI_lower = 0.365, 
                  CI_upper = 0.710), 
           AnnualCost = AnnCosts, 
           RxPrices = c(AZT = 2278, LAM = 2087))
    
    Param.Path <- file.path(Params.Dir, "HIV-Params.rds")
    
    readr::write_rds(x = HIV_Params, 
                     file = Param.Path)
    
    usethis::ui_done("{usethis::ui_field('HIV_Params')} saved to {usethis::ui_path(Param.Path)}")
  } else {
    Param.Path <- file.path(Params.Dir, "HIV-Params.rds")
    usethis::ui_info("Load parameters from: {usethis::ui_path(Param.Path)}")
  }
  
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


DrawParams <- function(ParamList, prob = 0, n) {
  # Relative Risk of Disease Progression ---------------------------------------
  ## Distribution: Log Normal
  if (prob == 0) {
    ParamList$RR <- ParamList$RR[["Mean"]]
  } 
  if (prob == 1) {
    RRsd <- (log(ParamList$RR[["CI_upper"]]) - 
               log(ParamList$RR[["CI_lower"]]))/(1.96*2)
    
    ParamList$RR <- 
      rlnorm(n = n, 
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

  
  ParamList <- ParamList[c("RR", "Q", "AnnualCost", "RxPrices")]
  
  
  return(ParamList)
}