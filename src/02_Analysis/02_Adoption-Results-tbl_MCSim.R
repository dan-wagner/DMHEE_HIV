# Analyze Simulation Results
#   Adoption Decision
#   Monte-Carlo Output

# Deterministic Simulation #####################################################
simResult <- readr::read_rds(file = file.path("data", 
                                              "data-gen", 
                                              "Simulation-Output", 
                                              "MC-Sim.rds"))

# Perform Analyses =============================================================
## Incremental Analysis --------------------------------------------------------
library(HEEToolkit)
IA.result <- inc_analysis(data = simResult, effect_measure = "LYs")

## Net-Benefits Framework ------------------------------------------------------
##    -Lambda: 20,000 & 30,000 GBP

NB.result <- nb_analysis(data = simResult, 
                         lambda = c(20000, 30000), 
                         effect_measure = "LYs", 
                         nbType = "NMB", 
                         show.error = TRUE)

for (l in seq_along(c(20000, 30000))) {
  j.na.error <- which(NB.result[,"prob_CE",l] != max(NB.result[,"prob_CE",l]))
  NB.result[j.na.error,"p_error",l] <- NA
}

# Build Table ==================================================================
## Convert Output to Data Frame ------------------------------------------------
DF <- cbind(as.data.frame(IA.result), 
            as.data.frame(NB.result))


## Build Table -----------------------------------------------------------------
library(gt)

displayTBL <- gt(data = DF, 
                 rownames_to_stub = "TRUE")
displayTBL <- tab_stubhead(data = displayTBL, 
                           label = "j")


### Format: Incremental Analysis - Assign Dominance/Extended Dominance
displayTBL <- sub_missing(data = displayTBL, 
                          columns = "ICER", 
                          rows = Dom == 1, 
                          missing_text = "D")
displayTBL <- tab_footnote(data = displayTBL, 
                           footnote = "D: Dominanted", 
                           locations = cells_body(columns = c(ICER),
                                                  rows = Dom == 1))

displayTBL <- sub_missing(data = displayTBL, 
                          columns = "ICER", 
                          rows = ExtDom == 1, 
                          missing_text = "ED")
displayTBL <- tab_footnote(data = displayTBL, 
                           footnote = "ED: Extendedly Dominanted", 
                           locations = cells_body(columns = c(ICER), 
                                                  rows = ExtDom == 1))

displayTBL <- sub_missing(data = displayTBL, 
                          columns = "ICER", 
                          rows = (Dom == 0) & (ExtDom == 0), 
                          missing_text = "---")
displayTBL <- cols_hide(data = displayTBL, 
                        columns = contains("Dom"))

### Format: Net-Benefits
displayTBL <- tab_spanner(data = displayTBL, 
                          label = paste0("\u03BB = ", "\u00A3", "20000/LY"), 
              columns = contains("20000")) |> 
  tab_spanner(label = paste0("\u03BB = ", "\u00A3", "30000/LY"), 
              columns = contains("30000"))

displayTBL <- cols_label(.data = displayTBL, 
                         "eNB.20000" = "NMB",
                         "eNB.30000" = "NMB", 
                         "prob_CE.20000" = "P(CE)", 
                         "prob_CE.30000" = "P(CE)", 
                         "p_error.20000" = "P(Error)", 
                         "p_error.30000" = "P(Error)")

displayTBL <- sub_missing(data = displayTBL, 
                          columns = contains(match = "p_error"), 
                          missing_text = "---")

### Format: Currency and Numbers 
displayTBL <- fmt_currency(data = displayTBL, 
                           columns = c("Costs", "ICER", contains("NB")), 
                           currency = "GBP")
displayTBL <- fmt_number(data = displayTBL, 
                         columns = c(contains(match = "LY"), 
                                     contains(match = "prob")), 
                         decimals = 2)

### Add Title/Sub-Title
displayTBL <- tab_header(data = displayTBL, 
                         title = "Cost-Effectiveness Results", 
                         subtitle = "HIV Model")

### Add Footnotes or Source Notes
SNote <- paste0("Data generated from a Monte Carlo simulation of ", 
                format(x = nrow(simResult), big.mark = ",", big.interval = 3L), 
                " iterations.")

displayTBL <- tab_source_note(data = displayTBL, 
                              source_note = SNote)
displayTBL <- tab_footnote(data = displayTBL, 
                           footnote = paste("Mono: Zidovudine Monotherapy", 
                                            paste("Comb: Zidovudine &", 
                                                  "Lamivudine Combination", 
                                                  "Therapy."), 
                                            sep = "; "), 
                           locations = cells_stubhead())

### Modify Table Theme
displayTBL <- tab_style(data = displayTBL, 
                        style = cell_text(weight = "bold", 
                                          align = "center"), 
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
                        style = cell_text(align = "left", weight = "bold"), 
                        locations = list(cells_title(groups = "title"), 
                                         cells_title(groups = "subtitle")))

displayTBL <- tab_options(data = displayTBL, 
                          table.border.bottom.color = "black", 
                          table.border.top.color = "black")

# Write Table to Results sub-directory =========================================
gtsave(data = displayTBL, 
       filename = "tbl_Adoption-Decision.png", 
       path = file.path("results"))