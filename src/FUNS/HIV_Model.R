# TRACK COHORT #################################################################
## Q: Transition Matrix (Monotherapy)
## nCycles: Number of cycles to consider in the model. Assume years. 

track_cohort <- function(Q, nCycles = 20){
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
      trace[i,] <- Cohort0 %*% Q
    } else {
      trace[i,] <- trace[i-1,] %*% Q
    }
  }
  
  return(trace)
}