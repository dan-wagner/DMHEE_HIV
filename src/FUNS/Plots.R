# PLOT THE COST-EFFECTIVENESS PLANE ############################################
## The number of alternatives in the model will play a key role in determining 
## the approach used to plot the scatter plot of costs versus effects. 
##    If there are only two alternatives in the model: 
##        - Plot change in Effects vs. change in Cost. 
##    If there are more than two alternatives in the model: 
##        - Plot costs vs effects for each alternative. 
##        - Include ICER calculations, show expected values, and display the 
##          cost-effectiveness frontier. 

## OLD CODE TO BE USEFUL FOR 3 COMPARATORS!!!
### Transform Data set from array data frame
#### HIVdf <- as.data.frame(x = HIV.sim)
##### Reformat from wide to long
##### HIVdf <- reshape(data = HIVdf, 
#####                  varying = c(1:4), 
#####                  timevar = "j", 
#####                  direction = "long", 
#####                  new.row.names = 1:(dim(HIV.sim)[1]*dim(HIV.sim)[3]))
##### HIVdf <- HIVdf[,-4]


viz_CEplane <- function(data,
                        Effect,
                        Currency, 
                        show.EV = FALSE, 
                        lambda = NULL) {
  # Check Inputs
  CurSYM <- c(GBP = "\U00A3", CAD = "\U0024", USD = "\U0024", EUR = "\U20AC")
  Currency <- match.arg(arg = Currency, choices = names(CurSYM))
  CurSYM <- scales::label_dollar(prefix = CurSYM[[Currency]])
  
  # Plot conditions based on data attributes.
  n_j <- length(dimnames(data)$j) # Number of alternatives.
  n.dim <- length(dim(data))  # Number of dimensions. 
  
  if (n_j == 2) {
    usethis::ui_info("Plotting two alternative interventions.")
    if (n.dim == 2) {
      usethis::ui_info("Input data obtained from deterministic simulation")
      Fig.Cap <- "Data generated from deterministic simulation."
      
      point.attr <- list(alpha = 1, colour = "black")
      
      dlta.DF <- data[2,] - data[1,]
      dlta.DF <- as.data.frame(x = as.list(dlta.DF))
    } else if (n.dim == 3) {
      usethis::ui_info("Input data obtained from stochastic model evaluation.")
      dlta.DF <- data[,,2] - data[,,1]
      Fig.Cap <- paste("Data generated from Monte Carlo simulation of", 
                       nrow(data), "iterations.")
      point.attr <- list(alpha = 0.1, colour = "grey") 
      
      dlta.DF <- data[,,2] - data[,,1]
      dlta.DF <- as.data.frame(x = dlta.DF)
    }
    
    # Define Plot Background and Margins
    CEplane <- 
      ggplot2::ggplot(data = dlta.DF, 
                      mapping = ggplot2::aes_(x = as.name(Effect), 
                                              y = quote(Costs))) + 
      ggplot2::theme(panel.grid.minor = ggplot2::element_blank()) + 
      ggplot2::geom_hline(yintercept = 0) + 
      ggplot2::geom_vline(xintercept = 0) + 
      ggplot2::scale_y_continuous(labels = CurSYM) + 
      ggplot2::labs(x = paste("Effect Difference, ", 
                              paste0("\U0394", names(dlta.DF)[2])), 
                    y = paste("Cost Difference, ", 
                              paste0("\U0394", names(dlta.DF)[1])), 
                    caption = Fig.Cap)
    
    # Add Points to Plot
    CEplane <- 
      CEplane + 
      ggplot2::geom_point(alpha = point.attr$alpha, 
                          colour = point.attr$colour)
    
    if (isTRUE(show.EV) && n.dim == 3) {
      EV <- colMeans(x = dlta.DF, na.rm = FALSE, dims = 1)
      EV <- data.frame(as.list(EV))
      usethis::ui_done(x = "Expected Costs and Effects Calculated.")
      
      CEplane <- 
        CEplane + 
        ggplot2::geom_point(data = EV, size = 2, colour = "black")
    }
    
    
  } else if (n_j > 2) {
    usethis::ui_info("Plotting more than 2 alternative interventions.")
    usethis::ui_todo("Define plot for Multiple treatment alternatives.")
  }
  
  # Display Lines for values of the cost-effectiveness threshold. 
  noLambda <- is.null(lambda)
  if (isFALSE(noLambda)) {
    xmax <- max(ggplot2::layer_scales(CEplane)$x$range$range)
    ymax <- max(ggplot2::layer_scales(CEplane)$y$range$range)
    
    # Define new Data frame to add lines as separate plot layer. 
    LDA.df <- data.frame(slope = lambda, 
                         intercept = 0, 
                         xpos = pmin((ymax - 0)/lambda, xmax), 
                         ypos = pmin((lambda*xmax + 0), ymax))
    # Update Plot
    CEplane <- 
      CEplane + 
      ggplot2::geom_abline(slope = lambda, 
                           intercept = 0, 
                           linetype = "dashed") + 
      ggplot2::geom_label(data = LDA.df, 
                          ggplot2::aes(x = xpos, 
                                       y = ypos, 
                                       label = paste0("\U03BB=",
                                                      as.character(slope))))
  }
  
  return(CEplane)
}


# PLOT THE COST-EFFECTIVENESS ACCEPTABILITY CURVE ##############################
viz_CEAC <- function(data, 
                     lambda, 
                     Effects, 
                     NB_type = "NMB", 
                     Frontier = FALSE){
  # Calculate Net Benefits
  eNB <- HEEToolkit::nb_analysis(data = data, 
                                 Effects = Effects, 
                                 type = NB_type, 
                                 lambda = lambda)
  # Transform from array to data frame
  eNB <- as.data.frame(x = eNB)
  eNB <- tibble::rownames_to_column(.data = eNB, var = "j")
  ## Convert from Wide to Long Format
  eNB <- 
    tidyr::pivot_longer(data = eNB, 
                        cols = -"j", 
                        names_to = c("stat", "lambda"), 
                        names_transform = list(lambda = as.double), 
                        names_sep = "\\.",
                        values_to = "result") |> 
    tidyr::pivot_wider(names_from = "stat", 
                       values_from = "result")
  if (isTRUE(Frontier)) {
    # Identify rows on the CEA-Frontier
    eNB <- 
      eNB |> 
      dplyr::group_by(lambda) |> 
      dplyr::mutate(onFrontier = dplyr::if_else(prob_CE == max(prob_CE), 
                                                1, 0)) |> 
      dplyr::ungroup()
  }
  
  # Create Plot
  CEAC <- 
    ggplot2::ggplot(data = eNB, 
                    mapping = ggplot2::aes(x = lambda, 
                                           y = prob_CE,
                                           colour = j)) + 
    ggplot2::geom_line() + 
    ggplot2::labs(caption = paste("Data generated from Monte Carlo simulation", 
                                  "of", nrow(data), "iterations."),
                  x = "Value of Threshold Ratio (\U03BB)", 
                  y = "Probability Cost-Effective")
  
  if (isTRUE(Frontier)) {
    CEAC <- 
      CEAC + 
      ggplot2::geom_line(data = dplyr::filter(eNB, onFrontier == 1), 
                         mapping = ggplot2::aes(x = lambda, y = prob_CE), 
                         colour = "yellow", 
                         size = 2, 
                         alpha = 0.3)
  }
  
  
  # Return Output
  return(CEAC)
}