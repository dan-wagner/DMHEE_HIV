# DMHEE_HIV

The goal of this repo is to develop and execute the HIV model from DMHEE. This 
exercise was developed in response to the fact that the textbook instructions 
are designed and organized for a spreadsheet environment. A different approach 
is required when using a programming language like R. 

## Important Note on Scope
The functions included in this repo are restricted to the development of the 
HIV model itself. Given that consistent analytic frameworks must be applied to 
all decision models, a separate R package (`HEEToolkit`) was developed to 
promote re-usability and save future development time. At present, I do not 
provide access to this package. 

# Model Summary

The HIV model was originally developed for a cost-effectiveness analysis of zidovudine monotherapy compared with combination therapy of zidovudine and lamivudine. These strategies were compared in patients with HIV infection, and is originally reported in Chancellor et al. 1997 (1).

A summary of the model structure is presented in the figure below.

![Structure of HIV Cohort Model](docs/Diagrams/HIV-Model.png)

The diagram depicts a model which characterizes the prognosis of an HIV-positive patient in terms of four health states. Importantly, the model assumes that a patient cannot move to a less severe disease state. While this assumption may not be true today, this exercise is strictly meant as a teaching tool to illustrate the underlying methods.

-   **State A**: Less severe HIV state with CD4 cell count of 200-500 cells/mm^3.

-   **State B**: More severe HIV state with CD4 cell count less than 200 cells/mm^3.

-   **State C**: AIDS.

-   **State D**: Death (Absorbing state).

For the purpose of this exercise, treatment effects are measured in terms of Life-Years. Meanwhile, costs are measured in terms of the annual treatment costs in hospital and community care settings.

1.  Chancellor JV, Hill AM, Sabin CA, Simpson KN, Youle M. Modelling the Cost Effectiveness of Lamivudine/Zidovudine Combination Therapy in HIV Infection. Pharmacoeconomics. 1997 Jul 1;12(1):54–66.

## Model Parameters
:warning: Add a description of the model parameters here. 

# Project Organization
:warning: Provide an explanation of how the project is organized here. 

# Progress

## :white_check_mark:Develop HIV Model

The HIV model can be evaluated by changing the parameter inputs to `runModel()`. 
This function is designed to capture three distinct components within a single 
module. Each time this function is called, other function calls are made to:

-   [x] track the cohort through the markov structure over a certain number of 
cycles. (see `track_cohort()`).
-   [x] calculate life years for the specified model comparator. This did not 
require it's own function, as the procedure to calculate this value only 
required a single function call to sum the rows across the "alive" (A,B,C) 
states.
-   [x] Estimate costs in each cycle using `est_costs()`.

The function will then return a vector with the estimated costs and QALYs 
according to the inputs.

The inputs to `runModel()` must be generated using a separate call stack:

-   Use `getParams()` to look for a parameter set in the 
`data/data-gen/Model-Params` sub-directory. If the directory is empty, the 
function will re-generate the parameters from raw data and save it there. It 
will return a statement with a relative file path to read the data into memory.

-   Use `DrawParams()` to generate the inputs required to execute `runModel()`. 
The code is designed such that this function must be called whether one wants 
to evaluate the model with deterministic or probabilistic inputs.

## :warning: Simulations and Analysis
Both deterministic and probabilistic methods will be used to evaluate the 
decision model. Each approach was restricted to the base case configuration 
which considered a time horizon of 20 years (20 cycles), and discounted costs 
and effects at 6% and 0%, respectively. 

### :white_check_mark: Perform Simulations

-   :white_check_mark: Determinsitic Simulation

    -   Save to `data/data-gen/Simulation-Output` directory as `HIV_Deter.rds`.

-   :white_check_mark:Monte Carlo Simulation (5,000 iterations)

    -   Save to `data/data-gen/Simulation-Output` directory as `HIV_MC-Sim_5000.rds`

### :x:Analyze Simulation Results


-   :x:Deterministic Results Table

-   :x:Probabilistic Analysis

    -   :x:Perform incremental analysis

    -   :x:Perform net-benefits analysis

    -   :x:Prepare CEA Results Table.

    -   :x:Plot Cost-Effectiveness Plane.

    -   :x:Plot CEAC.

## Project Admin

-   [ ] write a "RunAll" script for distinct scenarios.
    -   Start with a windows batch file?
