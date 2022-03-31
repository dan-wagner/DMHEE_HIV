# DMHEE_HIV

The goal of this repo is to develop and execute the HIV model from DMHEE. Instructions from textbook are organized around spreadsheet development. Different approach and sequence needed when using a programming language like R.

## Progress

### :white_check_mark:Develop HIV Model

The HIV model can be evaluated by changing the parameter inputs to `runModel()`. This function is designed to capture three distinct components within a single module. Each time this function is called, other function calls are made to:

-   track the cohort through the markov structure (`track_cohort()`)

-   Calculate Life Years in that arm of the model. This did not require it's own function, as it depends on a single function call to sum the rows across the "alive" states.

-   Estimate costs in each cycle using `est_costs()`.

The function will then return a vector with the estimated costs and QALYs according to the inputs.

The inputs to `runModel()` must be generated using a separate call stack:

-   Use `getParams()` to look for a parameter set in the `data/data-gen/Model-Params` sub-directory. If the directory is empty, the function will re-generate the parameters from raw data and save it there. It will return a statement with a relative file path to read the data into memory.

-   Use `DrawParams()` to generate the inputs required to execute `runModel()`. The code is designed such that this function must be called whether one wants to evaluate the model with deterministic or probabilistic inputs.

### :warning:Perform Simulations

-   :white_check_mark:Determinsitic Simulation

    -   Save to `data/data-gen/Simulation-Output` directory as `HIV_Deter.rds`.

-   :x:Monte Carlo Simulation (1,000 iterations)

    -   Save to `data/data-gen/Simulation-Output` directory as `HIV-Sim_MC_1000.rds`

### :x:Analyze Simulation Results

-   :x:Deterministic Results Table

-   :x:Probabilistic Analysis

    -   :x:Perform incremental analysis

    -   :x:Perform net-benefits analysis

    -   :x:Prepare CEA Results Table.

    -   :x:Plot Cost-Effectiveness Plane.

    -   :x:Plot CEAC.

## Project Admin

-   Write RunAll script for distinct scenarios.
