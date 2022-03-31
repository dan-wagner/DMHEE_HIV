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

# Estimate Costs ###############################################################
# j = Model Arm | Mono or Comb. 
# trace = Markov Trace. 
# RxPrice = Treatment prices for AZT and LAM. 
# AnnualCosts = Health State Costs

est_costs <- function(j, trace, RxPrice, AnnualCosts) {
  j <- match.arg(arg = j, choices = c("Mono", "Comb"))
  # Calculate Annual Costs for each Markov State -------------------------------
  M.Costs <- colSums(x = AnnualCosts, dims = 1)
  # Calculate Total Cost for each State and Cycle ------------------------------
  ## NOTE: AZT is given in every cycle for both arms. 
  Costs <- trace[,-4]
  for (i in seq_along(1:dim(trace)[1])) {
    Costs[i,] <- Costs[i,] * (M.Costs + RxPrice[["AZT"]])
  }
  
  if (j == "Comb") {
    # LAM given in the first two cycles only. 
    Costs[c(1,2), ] <- Costs[c(1,2),] + RxPrice[["LAM"]]
  }
  
  return(Costs)
}

# Run Model ####################################################################
## - Model can be broken down into three components: 
##    i) Track Cohort through Markov Structure. 
##    ii) Estimate Life Years
##    iii) Estimated Costs. 

runModel <- function(j, 
                     ParamList, 
                     nCycles = 20, 
                     oDR = 0, 
                     cDR = 0.06){
  ## 2) Track Cohort -----------------------------------------------------------
  cohort <- track_cohort(j = j, Q = ParamList$Q, nCycles = nCycles)
  ## 3) Calculate LYs ----------------------------------------------------------
  LYs <- rowSums(x = cohort[,c("A", "B", "C")], dims = 1)
  ## 4) Estimate Costs ---------------------------------------------------------
  Costs <- est_costs(j = j, 
                     trace = cohort, 
                     RxPrice = ParamList$RxPrices, 
                     AnnualCosts = ParamList$AnnualCost)
  Costs <- rowSums(x = Costs, dims = 1) # Sum Costs for each cycle. 
  
  ## 5) Discount LYs and Costs -------------------------------------------------
  LYs <- LYs/((1+oDR)^(1:nCycles))
  Costs <- Costs/((1+cDR)^(1:nCycles))
  
  ## 6) Combine Costs and Effects ----------------------------------------------
  Result <- cbind(Costs, LYs)
  ## 7) Sum Totals -------------------------------------------------------------
  Result <- colSums(x = Result, dims = 1)
  
  return(Result)
}