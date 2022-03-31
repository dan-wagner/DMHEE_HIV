# Model Summary ################################################################
# Comparing zidovudine monotherapy with zidovudine plus lamibudine therpay in 
# patients with HIV infection. 
# The model characterizes a patient's prognosis in terms of four states: 
#  - Two states are based on CD4 count: State A (least severe, 
#    200-500 cells/mm3) & State B (less than 200 cells/mm3). 
#  - State C represents AIDS, and the final state is Death (absorbing). 
#  - The key structural assumption in this model is that patients can only 
#    remain in the same state or progress; they cannot move back to a less 
#    severe state. 
#  - Cycle Length is 1 year. 

# Define Transition Matrix (Q) #################################################
## j = Comparator, must be 'Mono' or 'Comb'. 
## StateCounts = A matrix of state transitions. 
## RR = Relative risk of severe disease from combination therapy.  
define_tmat <- function(StateCounts, RR = 0.509) {
  
  # Calculate Probability of State Transitions using Count
  Q <- sapply(X = list(Mono = StateCounts.mono, Comb = StateCounts.mono), 
              FUN = prop.table, 
              margin = 1, 
              simplify = "array")
  Q["D",,] <- c(rep(0,3),1)
  
  ## Adjust transition probabilities for Comb using RR
  Q[,,"Comb"] <- Q[,,"Comb"] * RR
  diag(Q[,,"Comb"]) <- 1 - (rowSums(x = Q[,,"Comb"]) - diag(Q[,,"Comb"]))
  
  return(Q)
}

# TRACK COHORT #################################################################
## j: Arm, will accept "Mono", or "Comb". 
## Q: Transition Matrix (Monotherapy)
## nCycles: Number of cycles to consider in the model. Assume years. 

track_cohort <- function(j, Q, nCycles = 20){
  j <- match.arg(arg = j, choices = c("Mono", "Comb"))
  # Define Blank Cohort Trace --------------------------------------------------
  trace <- array(data = 0, 
                 dim = c(length(1:nCycles), 
                         length(colnames(Q))), 
                 dimnames = list(Cycle = NULL, 
                                 State = colnames(Q)))
  # Populate Cohort Trace ------------------------------------------------------
  Cohort0 <- c(1, rep(0, 3)) # Set Starting States
  names(Cohort0) <- colnames(Q)
  
  ## Track Cohort
  for (i in seq_along(1:nCycles)) {
    if (i == 1) {
      trace[i,] <- Cohort0 %*% Q[,,j]
    } else if (i == 2 && j == "Comb") {
      trace[i,] <- trace[i-1,] %*% Q[,,j]
    } else {
      trace[i,] <- trace[i-1,] %*% Q[,,"Mono"]
    }
  }
  
  return(trace)
}

# Run Model ####################################################################
## - Model can be broken down into three components: 
##    i) Track Cohort through Markov Structure. 
##    ii) Estimate Life Years
##    iii) Estimated Costs. 

runModel <- function(j, StateCounts, RR = 0.509, nCycles, oDR = 0){
  ## 1) Define Transition Matrix -----------------------------------------------
  Q <- define_tmat(StateCounts = StateCounts, RR = 0.509)
  ## 2) Track Cohort -----------------------------------------------------------
  cohort <- track_cohort(j = j, Q = Q, nCycles = nCycles)
  ## 3) Calculate LYs ----------------------------------------------------------
  LYs <- rowSums(x = cohort[,c("A", "B", "C")], dims = 1)
  
  ## 4) Discount LYs -----------------------------------------------------------
  LYs <- LYs/((1+oDR)^(1:nCycles))
  
  ## Return Costs and Effects
  Result <- sum(LYs)
  
  return(Result)
}