# Analyze Simulation Results
# Goal: Plot Cost-Effectiveness Acceptability Curve

source(file.path("src", "FUNS", "Plots.R"))

# Import Simulation Results ####################################################
HIVresult.MC <- readr::read_rds(file = file.path("data", 
                                                 "data-gen", 
                                                 "Simulation-Output", 
                                                 "HIV_MC-Sim_5000.rds"))


# Generate Plots ###############################################################
## CEAC, without Frontier ======================================================
CEAC_F0 <- viz_CEAC(data = HIVresult.MC, 
                    lambda = seq(from = 0, to = 20000, by = 500), 
                    Effects = "LYs", 
                    NB_type = "NMB", 
                    Frontier = FALSE)

## CEAC, with Frontier =========================================================
CEAC_F1 <- viz_CEAC(data = HIVresult.MC, 
                    lambda = seq(from = 0, to = 20000, by = 500), 
                    Effects = "LYs", 
                    NB_type = "NMB", 
                    Frontier = TRUE)

# Save Output ##################################################################
ggplot2::ggsave(filename = file.path("results", 
                                     "CEAC_Frontier-0.png"), 
                plot = CEAC_F0, 
                device = "png", 
                width = 5.73, 
                height = 4.68)

ggplot2::ggsave(filename = file.path("results", 
                                     "CEAC_Frontier-1.png"), 
                plot = CEAC_F1, 
                device = "png", 
                width = 5.73, 
                height = 4.68)
