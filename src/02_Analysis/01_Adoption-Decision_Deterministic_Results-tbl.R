# Analyze Simulation Results
#   Adoption Decision
#   Deterministic Output

# Deterministic Simulation #####################################################
simResult <- readr::read_rds(file = file.path("data", 
                                              "data-gen", 
                                              "Simulation-Output", 
                                              "Deter.rds"))

# Perform Incremental Analysis =================================================
library(HEEToolkit)

D.ICER <- inc_analysis(data = simResult, Effects = "LYs")


# Build Table ==================================================================
## Convert Output to Data Frame ------------------------------------------------
D.ICER <- as.data.frame(x = D.ICER)
## Build Table -----------------------------------------------------------------
library(gt)

displayTBL <- gt(data = D.ICER, rownames_to_stub = TRUE) |> 
  tab_stubhead(label = "j")

### Format: Assign Dominance/Extended Dominance
displayTBL <- sub_missing(data = displayTBL, 
                          columns = "ICER", 
                          rows = Dom == 1, 
                          missing_text = "D")
displayTBL <- tab_footnote(data = displayTBL, 
                           footnote = "D: Dominated", 
                           locations = cells_body(columns = "ICER", 
                                                  rows = Dom == 1), 
                           placement = "right")

displayTBL <- sub_missing(data = displayTBL, 
                          columns = "ICER", 
                          rows = ExtDom == 1, 
                          missing_text = "ED")
displayTBL <- tab_footnote(data = displayTBL, 
                           footnote = "ED: Extendedly Dominated", 
                           locations = cells_body(columns = "ICER", 
                                                  rows = ExtDom == 1), 
                           placement = "right")

displayTBL <- sub_missing(data = displayTBL, 
                          columns = "ICER", 
                          rows = (Dom == 0) & (ExtDom == 0), 
                          missing_text = "---")

displayTBL <- cols_hide(data = displayTBL, 
                        columns = c("Dom", "ExtDom"))

### Format: Currency and Numbers 
displayTBL <- fmt_currency(data = displayTBL, 
                           columns = c("Costs", "ICER"), currency = "GBP")
displayTBL <- fmt_number(data = displayTBL, 
                         columns = contains(match = "LY"), decimals = 2)

### Add Title/Sub-Title
displayTBL <- tab_header(data = displayTBL, 
                         title = "Cost-Effectiveness Results: Incremental Analysis", 
                         subtitle = "HIV Model, Deterministic Simulation")



### Add Footnotes
displayTBL <- tab_footnote(data = displayTBL, 
                           footnote = paste("Mono: Zidovudine Monotherapy",
                                            paste("Comb: Zidovudine &", 
                                                  "Lamivudine Combination", 
                                                  "Therapy."), 
                                            sep = "; "), 
                           locations = cells_stubhead())

### Modify Table Theme
displayTBL <- tab_style(data = displayTBL, 
                        style = cell_text(weight = "bold", align = "center"), 
                        locations = cells_column_labels(columns = everything()))
displayTBL <- tab_style(data = displayTBL, 
                        style = cell_text(style = "italic", 
                                          weight = "bold", 
                                          align = "right"), 
                        locations = cells_stubhead())
displayTBL <- tab_style(data = displayTBL, 
                        style = cell_text(align = "center"), 
                        locations = cells_body())
displayTBL <- tab_style(data = displayTBL, 
                        style = cell_text(align = "left", 
                                          weight = "bold"), 
                        locations = list(cells_title(groups = "title"), 
                                         cells_title(groups = "subtitle")))

displayTBL <- tab_options(data = displayTBL, 
                          table.border.bottom.color = "black", 
                          table.border.top.color = "black")

# Write Table to Results sub-directory =========================================
gtsave(data = displayTBL, 
       filename = "tbl_Incremental-Analysis_Deterministic.html", 
       path = file.path("results"))