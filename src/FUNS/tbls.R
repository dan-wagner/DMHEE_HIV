adopt_tbl <- function(x, 
                      effect_measure, 
                      lambda, 
                      nbType = "NMB", 
                      currency = "CAD"){
  
  # Perform Cost-Effectiveness Analysis
  cea_result <- list(ia = NULL, nb = NULL)
  cea_result$ia <- inc_analysis(data = x, effect_measure = effect_measure)
  cea_result$nb <- nb_analysis(data = x,
                               lambda = lambda,
                               effect_measure = effect_measure, 
                               nbType = nbType,
                               show.error = TRUE)
  # TODO: Add logic to restrict p_error to max(eNB)
  # TODO: Add function to conduct a cost-effectiveness analysis
  
  # Convert Output to Data Frame
  cea_result <- lapply(X = cea_result, FUN = as.data.frame)
  cea_result <- Reduce(f = cbind, x = cea_result)
  
  # Misc Tasks
  currency_sym <- switch(currency, 
                         "CAD" = "\u0024", 
                         "GBP" = "\u00A3",
                         "USD" = "\u0024",
                         "EUR" = "\u20AC")
  
  # Create Display Table
  TBL <- gt::gt(data = cea_result, rownames_to_stub = TRUE)
  TBL <- gt::tab_stubhead(data = TBL, label = "j")
  
  # Format: Incremental Analysis Results
  # Reference ICER
  TBL <- gt::sub_missing(data = TBL, 
                         columns = "ICER", 
                         rows = (Dom == 0) & (ExtDom == 0), 
                         missing_text = "---")
  # Assign Dominance/Extended Dominance
  TBL <- gt::sub_missing(data = TBL, 
                         columns = "ICER",
                         rows = Dom == 1,
                         missing_text = "D")
  TBL <- gt::sub_missing(data = TBL, 
                         columns = "ICER", 
                         rows = ExtDom == 1)
  
  TBL <- gt::tab_footnote(data = TBL,
                          footnote = "D: Dominated", 
                          locations = gt::cells_body(columns = c(ICER), 
                                                     rows = Dom == 1))
  TBL <- gt::tab_footnote(data = TBL,
                          footnote = "ED: Extendedly Dominated", 
                          locations = gt::cells_body(columns = c(ICER), 
                                                     rows = ExtDom == 1))
  TBL <- gt::cols_hide(data = TBL, columns = gt::contains("Dom"))
  # Format: Net-Benefit Results
  # Add Spanner Column for each lambda considered
  for (i in lambda) {
    spanner_lab <- paste0("\u03BB = ", 
                          currency_sym, 
                          paste(i, effect_measure, sep = "/"))
    
    TBL <- gt::tab_spanner(data = TBL, 
                           label = spanner_lab, 
                           columns = contains(as.character(i)))
  }
  # Apply Column Labels within each spanner column
  TBL <- gt::cols_label(.data = TBL, 
                        gt::contains(match = "eNB") ~ "NMB", 
                        gt::contains(match = "prob_CE") ~ "P(CE)", 
                        gt::contains(match = "p_error") ~ "P(Error)")
  if (nbType == "NHB") {
    TBL <- gt::cols_label(.data = TBL, 
                          gt::contains(match = "eNB") ~ "NHB")
  }
  TBL <- gt::sub_missing(data = TBL, 
                         columns = contains(match = "p_error"), 
                         missing_text = "---")
  # Format: Currency and Numbers
  TBL <- gt::fmt_currency(data = TBL, 
                          columns = c("Costs", "ICER", gt::contains("NB")),
                          currency = currency)
  TBL <- gt::fmt_number(data = TBL, 
                        columns = c(gt::contains(match = effect_measure), 
                                    gt::contains(match = "prob")),
                        decimals = 2)
  # Add Title. 
  TBL <- gt::tab_header(data = TBL, 
                        title = "Cost-Effectiveness Results")
  # Format: Table Theme
  TBL <- HEE_theme(x = TBL)
  
  return(TBL)
}

HEE_theme <- function(x){
  tbl <- gt::tab_style(data = x, 
                       style = gt::cell_text(weight = "bold", align = "center"),
                       locations = gt::cells_column_labels())
  tbl <- gt::tab_style(data = tbl, 
                       style = gt::cell_text(style = "italic", 
                                             weight = "bold", 
                                             align = "right"), 
                       locations = gt::cells_stubhead())
  tbl <- gt::tab_style(data = tbl,
                       style = gt::cell_text(align = "center"), 
                       locations = gt::cells_body())
  tbl <- gt::tab_style(data = tbl, 
                       style = gt::cell_text(align = "left", weight = "bold"), 
                       locations = list(gt::cells_title(groups = "title"), 
                                        gt::cells_title(groups = "subtitle")))
  
  tbl <- gt::tab_options(data = tbl, 
                         table_body.border.bottom.color = "black",
                         table.border.bottom.color = "black", 
                         table.border.top.color = "black")
  
  return(tbl)
}