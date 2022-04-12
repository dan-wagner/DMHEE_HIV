# Analyze Simulation Results
#   Adoption Decision
#   Monte-Carlo Output

# Deterministic Simulation #####################################################
MCpath <- file.path("data", 
                   "data-gen", 
                   "Simulation-Output", 
                   "HIV_MC-Sim_5000.rds")
MCresult <- readr::read_rds(file = MCpath)

# Perform Analyses =============================================================
## Incremental Analysis --------------------------------------------------------
EV <- colMeans(x = MCresult, na.rm = FALSE, dims = 1)
EV <- t(EV)

library(HEEToolkit)
IA.result <- inc_analysis(data = EV, Effect = "LYs")

## Net-Benefits Framework ------------------------------------------------------
##    -Lambda: 20,000 & 30,000 GBP

NB.result <- nb_analysis(data = MCresult, 
                         lambda = c(20000, 30000), 
                         Effects = "LYs", 
                         type = "NMB")

### Add column for P_Error for j which is max CE

maxP.CE <- 
apply(X = NB.result[,"prob_CE",], 
      MARGIN = c("lambda"), 
      FUN = max)

NB.result <- 
sapply(X = dimnames(NB.result)$lambda, 
       FUN = \(x){
         cbind(NB.result[,,x], prob_ER = 0)
       }, 
       simplify = "array")

for (i in seq_along(names(maxP.CE))) {
  NB.result[,"prob_ER", i] <- ifelse(NB.result[,"prob_CE",i] == maxP.CE[[i]], 
                                     1-NB.result[,"prob_CE", i], NA)
}

# Build Table ==================================================================
## Convert Output to Data Frame ------------------------------------------------
DF <- cbind(as.data.frame(IA.result), 
            as.data.frame(NB.result))


## Build Table -----------------------------------------------------------------
library(gt)

Adopt.tbl <- gt(data = DF, rownames_to_stub = TRUE) |> 
  tab_stubhead(label = "j")
### Format: Incremental Analysis - Assign Dominance/Extended Dominance
Adopt.tbl <- 
  Adopt.tbl |> 
  fmt_missing(columns = "ICER", 
              rows = Dom == 1, missing_text = "D") |> 
  fmt_missing(columns = "ICER", 
              rows = ExtDom == 1, missing_text = "ED") |> 
  fmt_missing(columns = "ICER", 
              rows = (Dom == 0) & (ExtDom == 0), missing_text = "---") |> 
  tab_footnote(footnote = "D: Dominanted", 
               locations = cells_body(columns = c(ICER), 
                                      rows = Dom == 1)) |> 
  tab_footnote(footnote = "ED: Extendedly Dominanted", 
               locations = cells_body(columns = c(ICER), 
                                      rows = ExtDom == 1)) |> 
  cols_hide(columns = contains("Dom"))

### Format: Net-Benefits
Adopt.tbl <- 
  Adopt.tbl |> 
  tab_spanner(label = paste0("\u03BB = ", "\u00A3", "20000/LY"), 
              columns = contains("20000")) |> 
  tab_spanner(label = paste0("\u03BB = ", "\u00A3", "30000/LY"), 
              columns = contains("30000")) |> 
  cols_label("eNB.20000" = "NMB", 
             "eNB.30000" = "NMB", 
             "prob_CE.20000" = "P(CE)", 
             "prob_CE.30000" = "P(CE)", 
             "prob_ER.20000" = "P(Error)", 
             "prob_ER.30000" = "P(Error)") |> 
  fmt_missing(columns = contains(match = "ER"), 
              missing_text = "---")

### Format: Currency and Numbers 
Adopt.tbl <- 
  Adopt.tbl |> 
  fmt_currency(columns = c("Costs", 
                           "ICER", 
                           contains("NB")), 
               currency = "GBP") |> 
  fmt_number(columns = c(contains(match = "LY"), 
                         contains(match = "prob")), 
             decimals = 2)

### Add Title/Sub-Title
Adopt.tbl <- 
  Adopt.tbl |> 
  tab_header(title = "Cost-Effectiveness Results", 
             subtitle = "HIV Model, Monte-Carlo Simulation")

### Add Footnotes
Adopt.tbl <- 
  Adopt.tbl |> 
  tab_footnote(footnote = 
                 paste0("Data generated from Monte Carlo simulation of ", 
                        nrow(MCresult), " iterations."), 
               locations = cells_title(groups = "subtitle")) |> 
  tab_footnote(footnote = "Mono: Zidovudine Monotherapy", 
               locations = cells_stub(rows = "Mono")) |> 
  tab_footnote(footnote = "Comb: Zidovudine & Lamivudine Combination Therapy", 
               locations = cells_stub(rows = "Comb"))

### Modify Table Theme
Adopt.tbl <- 
  Adopt.tbl |> 
  tab_style(style = cell_text(weight = "bold", align = "center"), 
            locations = cells_column_labels(columns = everything())) |> 
  tab_style(style = cell_text(style = "italic", 
                              weight = "bold", 
                              align = "right"), 
            locations = cells_stubhead()) |> 
  tab_style(style = cell_text(align = "center"), 
            locations = cells_body()) |> 
  tab_style(style = cell_text(align = "left", weight = "bold"), 
            locations = list(cells_title(groups = "title"), 
                             cells_title(groups = "subtitle"))) |> 
  tab_options(table.border.bottom.color = "black", 
              table.border.top.color = "black")

# Write Table to Results sub-directory =========================================
gtsave(data = Adopt.tbl, 
       filename = "tbl_Adoption-Decision.png", 
       path = file.path("results"))