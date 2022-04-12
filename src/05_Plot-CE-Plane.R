# Analyze Simulation Results
#   Adoption Decision
#   GOAL: Plot Cost-Effectiveness Plane

source(file.path("src", "FUNS", "Plots.R"))

# Deterministic Model Result ===================================================
## Import Data -----------------------------------------------------------------
HIVresult <- readr::read_rds(file = file.path("data", 
                                              "data-gen", 
                                              "Simulation-Output", 
                                              "HIV_Deter.rds"))
names(dimnames(HIVresult)) <- c("Result", "j")

## Generate Plot ---------------------------------------------------------------
HIV.cep.deter <- 
  viz_CEplane(data = HIVresult, 
              Effect = "LYs", 
              Currency = "GBP", 
              show.EV = FALSE, 
              lambda = NULL)

HIV.cep.deter <- 
  HIV.cep.deter + 
  ggplot2::labs(title = "Cost-Effectiveness Plane for HIV Model.", 
                subtitle = "Comparison: Mono vs Comb")

ggplot2::ggsave(filename = file.path("results", "CE-Plane_Deter.png"), 
                plot = HIV.cep.deter, 
                device = "png", 
                width = 5.73, 
                height = 4.68)

# MC Simulation Result =========================================================
## Import Data -----------------------------------------------------------------
HIVresult.MC <- readr::read_rds(file = file.path("data", 
                                                 "data-gen", 
                                                 "Simulation-Output", 
                                                 "HIV_MC-Sim_5000.rds"))
## Generate Plot ---------------------------------------------------------------
HIV.cep.MC <- 
  viz_CEplane(data = HIVresult.MC, 
              Effect = "LYs", 
              Currency = "GBP", 
              show.EV = TRUE, 
              lambda = NULL)

HIV.cep.MC <- 
  HIV.cep.MC + 
  ggplot2::labs(title = "Estimated joint cost-effectiveness density for HIV Model", 
                subtitle = "Cost-effectiveness plane comparing 'Comb' with 'Mono'") + 
  ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white"))

ggplot2::ggsave(filename = file.path("results", "CE-Plane_MC.png"), 
                plot = HIV.cep.MC, 
                device = "png", 
                width = 5.73, 
                height = 4.68)






# Plot Cost-Effectiveness Plane ================================================
## The number of alternatives in the model will play a key role in determining 
## the approach used to plot the scatter plot of costs versus effects. 
##    If there are only two alternatives in the model: 
##        - Plot change in Effects vs. change in Cost. 
##    If there are more than two alternatives in the model: 
##        - Plot costs vs effects for each alternative. 
##        - Include ICER calculations, show expected values, and display the 
##          cost-effectiveness frontier. 
