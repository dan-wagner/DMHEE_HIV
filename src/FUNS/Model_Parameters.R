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

# Draw Parameters deterministically or probabilsitically =======================



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
  
  
  
  return(ParamList)
}