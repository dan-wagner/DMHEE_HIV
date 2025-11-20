# Analyze Simulation Results
#   Decision: Adoption
#   Data Source: Monte Carlo Simulation

# Load Functions ===============================================================
library(HEEToolkit)

# Load Data ====================================================================
simResult <- readr::read_rds(file = file.path("data", 
                                              "data-gen", 
                                              "Simulation-Output", 
                                              "MC-Sim.rds"))
##  Modify Names of j ----------------------------------------------------------
dimnames(simResult)$j <- c("zidovudine", "zidovudine + lamivudine")
##  Initialize SimData Object --------------------------------------------------
simResult <- new_sim_data(x = simResult, currency = "GBP")

# Perform CEA ==================================================================
hiv_cea <- 
  new_cea(
    x = simResult, 
    effect_measure = "LYs", 
    req_lambda = 20000, 
    nb_type = "NMB"
  )
print(hiv_cea) # Print the object (not very useful yet)
# Generate Table/Figures =======================================================
##  CEA Table ------------------------------------------------------------------
tab_1 <- result_tbl(x = hiv_cea, lambda = 20000, scope = "none")
tab_1 # Preview

# Write to Disk
gt::gtsave(data = tab_1, 
           filename = "adopt-tbl_MC-Sim.html", 
           path = file.path("results"))

##  Figure: Cost-Effectiveness Plane -------------------------------------------
fig_1 <- plot_ceplane(x = hiv_cea, lambda = NULL, scope = "none")
fig_1 # preview

# Write to disk
ggplot2::ggsave(filename = file.path("results", "CE-Plane_MC.png"), 
                plot = fig_1, 
                device = "png", 
                width = 6.25, 
                height = 5.50)

##  Figure: CEAC ---------------------------------------------------------------
fig_2a <- plot_ceac(x = hiv_cea, lambda = NULL, show_frontier = FALSE)
fig_2a # Preview

fig_2b <- plot_ceac(x = hiv_cea, lambda = NULL, show_frontier = TRUE)
fib_2b # Preview

# Write to disk
ggplot2::ggsave(filename = file.path("results", "CEAC.png"), 
                plot = fig_2a, 
                device = "png", 
                width = 6.25, 
                height = 5.50)
ggplot2::ggsave(filename = file.path("results", "CEAF.png"), 
                plot = fig_2b, 
                device = "png", 
                width = 6.25, 
                height = 5.50)