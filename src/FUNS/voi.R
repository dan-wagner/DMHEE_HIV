report_voi_tbl <- function(x, effect_measure){
  # Tabular Display of VOI Results
  #
  # Args:
  #   x: A data frame containing EVPI/EVPPI results at specified lambda.
  #   effect_measure: Character. 
  #
  # Returns:
  #   A gt object. 
  
  # Initialize table
  tbl <- gt::gt(data = x)
  
  # Add Spanner Columns: EVPI
  tbl <- gt::tab_spanner(data = tbl, 
                         label = "\U03B8", 
                         columns = gt::contains(match = "evpi"))
  tbl <- gt::tab_spanner(data = tbl, label = "EVPI", 
                         columns = gt::contains(match = "EVPI"))
  tbl <- gt::tab_spanner(data = tbl, label = "EVPPI", 
                         columns = gt::contains(match = "EVPPI"))
  # Update Column Names
  tbl <- 
    gt::cols_label(
      .data = tbl, 
      gt::contains(match = "pt") ~ "Per-Patient", 
      gt::contains(match = "pop") ~ "Population"
    ) |> 
    gt::cols_label_with(
      data = _, 
      columns = gt::matches(match = "lambda"), 
      fn = ~ sprintf(fmt = "%s \n (%s / %s)", 
                     "\U03BB", 
                     "\U00A3", 
                     effect_measure)
    )
  # Format Values to reflect currency
  tbl <- 
    gt::fmt_currency(
      data = tbl, 
      columns = gt::everything(), 
      rows = gt::everything(), 
      currency = "GBP", 
      decimals = 0
    )
  # Add Table Header
  tbl <- 
    gt::tab_header(
      data = tbl, 
      title = "Value of Information Analysis"
    )
  # Add Table Footer
  #   Prepare Abbreviations
  term_list <- 
    c("\U03BB = threshold ratio", 
      "\U03B8 = all uncertain parameters", 
      "\U03C6 = subset of all uncertain parameters", 
      "EVPI = expected value of perfect information", 
      "EVPPI = expected value of perfect parameter information", 
      "LY = life year")
  #   Sort List Alphabetically
  term_list <- sort(x = term_list)
  #   Collapse into single string
  term_list <- paste0(paste0(term_list, collapse = "; "), ".")
  tbl <- gt::tab_source_note(data = tbl, source_note = term_list)
  
  return(tbl)
}

report_voi_tbl(x = hiv_evpi, effect_measure = "LYs")

plot_evpi <- function(x, patient = FALSE){
  # Generate Line Graph of EVPI/EVPPI at Lambda
  #
  # Args:
  #   x: Data frame or tibble. Containing the different VOI Results. 
  #
  # Returns: 
  #   A ggplot2 object. 
  fig_data <- 
    tidyr::pivot_longer(
      data = x, 
      cols = -"lambda",
      names_to = c("stat_type", "lvl"), 
      names_sep = c("_"), 
      values_to = "values"
    ) |> 
    tidyr::pivot_wider(
      names_from = "stat_type", 
      values_from = "values"
    )
  
  if (isFALSE(patient)) {
    fig_data <- 
      dplyr::filter(.data = fig_data, .data$lvl == "pop")
  } else {
    fig_data <- 
      dplyr::filter(.data = fig_data, .data$lvl == "pt")
  }
  
  # Initialize Figure
  fig <- 
    ggplot2::ggplot(
      data = fig_data, 
      mapping = ggplot2::aes(x = .data$lambda, y = .data$evpi)
    ) + 
    ggplot2::geom_line() + 
    ggplot2::scale_x_continuous(
      labels = scales::label_dollar(prefix = "\U00A3")
    ) + 
    ggplot2::scale_y_continuous(
      labels = scales::label_dollar(prefix = "\U00A3")
    ) + 
    ggplot2::theme_minimal(base_size = 14) + 
    ggplot2::labs(
      title = "Value of Information Analysis", 
      subtitle = "Expected Value of Perfect (Parameter) Information", 
      x = "Threshold Ratio", 
      y = "EVPI", 
      caption = "Source: TODO."
    )
  
  return(fig)
}

plot_evpi(x = hiv_evpi, patient = FALSE)