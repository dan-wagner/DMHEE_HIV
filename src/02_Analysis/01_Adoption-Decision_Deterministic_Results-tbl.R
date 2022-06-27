# Analyze Simulation Results
#   Adoption Decision
#   Deterministic Output

# Deterministic Simulation #####################################################
Dpath <- file.path("data", 
                   "data-gen", 
                   "Simulation-Output", 
                   "Deter.rds")
Dresult <- readr::read_rds(file = Dpath)

# Perform Incremental Analysis =================================================
library(HEEToolkit)

D.ICER <- inc_analysis(data = Dresult, Effects = "LYs")


# Build Table ==================================================================
## Convert Output to Data Frame ------------------------------------------------
D.ICER <- as.data.frame(x = D.ICER)
## Build Table -----------------------------------------------------------------
library(gt)

IA.tbl.d <- gt(data = D.ICER, rownames_to_stub = TRUE) |> 
  tab_stubhead(label = "j")
### Format: Assign Dominance/Extended Dominance
IA.tbl.d <- 
  IA.tbl.d |> 
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

### Format: Currency and Numbers 
IA.tbl.d <- 
  IA.tbl.d |> 
  fmt_currency(columns = c("Costs", "ICER"), currency = "GBP") |> 
  fmt_number(columns = contains(match = "LY"), decimals = 2)

### Add Title/Sub-Title
IA.tbl.d <- 
  IA.tbl.d |> 
  tab_header(title = "Cost-Effectiveness Results: Incremental Analysis", 
             subtitle = "HIV Model, Deterministic Simulation")

### Add Footnotes
IA.tbl.d <- 
  IA.tbl.d |> 
  tab_footnote(footnote = "Mono: Zidovudine Monotherapy", 
               locations = cells_stub(rows = "Mono")) |> 
  tab_footnote(footnote = "Comb: Zidovudine & Lamivudine Combination Therapy", 
               locations = cells_stub(rows = "Comb"))

### Modify Table Theme
IA.tbl.d <- 
  IA.tbl.d |> 
  tab_style(style = cell_text(weight = "bold", align = "center"), 
            locations = cells_column_labels(columns = everything())) |> 
  tab_style(style = cell_text(style = "italic", weight = "bold", align = "right"), 
            locations = cells_stubhead()) |> 
  tab_style(style = cell_text(align = "center"), 
            locations = cells_body()) |> 
  tab_style(style = cell_text(align = "left", weight = "bold"), 
            locations = list(cells_title(groups = "title"), 
                             cells_title(groups = "subtitle"))) |> 
  tab_options(table.border.bottom.color = "black", 
              table.border.top.color = "black")

# Write Table to Results sub-directory =========================================
gtsave(data = IA.tbl.d, 
       filename = "tbl_Incremental-Analysis_Deterministic.html", 
       path = file.path("results"))