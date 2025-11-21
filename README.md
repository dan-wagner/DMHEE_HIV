# DMHEE_HIV

The goal of this repo is to develop and execute the HIV model from the DMHEE 
textbook in a reproducible manner [^1]. This necessitated the creation of an 
automated workflow which was designed to capture the procedures of the 
economic evaluation as well as those used to estimate the parameter inputs 
[^scope]. 

This project was initiated in response to the fact that the original 
textbook exercises are designed and organized for a spreadsheet environment. 
Adapting these exercises to a programming language offered the ability to show 
how this model could be developed in a reproducible fashion. A collection of 
previously identified strategies for reproducibility were used to achieve a 
level of reproducibility that would allow for the reliable re-generation of 
results, including intermediate data sets. 

# Installation
Clone the repository to access the material and explore it interactively!
The model itself can be run without any external dependencies. 

# Quickstart
##  Basic Workflow
This section summarizes the basic workflow to load the model code and input
data, and then evaluate the model to simulate the costs and effects for the 
competing alternatives. 

Begin by loading the relevant functions to the active R session. 
```
# Load Functions to access/sample the model input paramters
source(file.path("src", "FUNS", "Model_Parameters.R"))
# Load Functions which specify the model itself
source(file.path("src", "FUNS", "HIV_Model.R"))
```

Next, load the input parameters to the global environment. 
```
params <- get_params()
```

With the input parameters available, use the `simulate_model()` function to 
obtain the simulated costs and benefits. In this function, the `arms` argument
is used to specify the competing alternatives that will be considered in the 
analysis. To perform a probabilistic simulation, set the `prob` argument to 
`TRUE`. This will generate distributions of cost and LYs, the size of which is
determined by the `n` parameter. For a deterministic simulation, simply set
the `prob` argument to `FALSE` (the `n` parameter is ignored).  

```
# Deterministic Simulation
simulate_model(
  j = c("Mono", "Comb"), 
  params = params,
  prob = FALSE, 
  n = 1000,
  comb_yrs = 2, 
  n_cycles = 20, 
  oDR = 0, 
  cDR = 0.06
)
# Monte Carlo Simulation
simulate_model(
  j = c("Mono", "Comb"), 
  params = params,
  prob = TRUE, 
  n = 1000,
  comb_yrs = 2, 
  n_cycles = 20, 
  oDR = 0, 
  cDR = 0.06
)
```

Once the simulation is complete, the workflow would need to proceed by 
performing a cost-effectiveness analysis. While code to achieve this is included
in the analysis scripts, the underlying package is not publicly available 
at this time. 

Feel free to inspect the design of the functions to see how everything works. 
Documentation summarizing the design of the code may be included at a later 
date. 

# Documentation

* [Progress](docs/01_Progress.md)
* [Summary of the HIV Model](docs/02_Model-Summary.md)

# Project Organization
This project is organized using a consistent directory structure which could be 
applied to most projects. Additionally, it allows for the use of relative file 
paths within scripts - which is essential for portability. An outline of the 
directory structure is presented below. 

```
PROJECT-DIRECTORY
|-data\
|   |-data-raw\
|   |-data-gen\
|     |-Model-Params\
|     |-Simulation-Output\
|-docs\
|-results\
|-src\
|   |-FUNS\
|   |-01_Simulations
|   |-02_Analysis
```

`data`
  : The data directory is used to store both raw (`data-raw`) and generated 
  (`data-gen`) data set. In the latter category, additional sub-directories are 
  used to distinguish between Model Parameters and Simulation Output. 
  
`docs`
  : The docs directory is used to store documents relevant to the project. This 
  may include project-specific [documentation](#documentation), diagrams, or 
  even manuscripts and reports. 
  
`results`
  : The results directory is used to store results from the project. In this 
  case a result is conceptualized as output which is ready to be placed in a 
  manuscript or report. This may include a formatted display table or different 
  kinds of plots produced for the project. 
  
`src`
  : The src is used to store all of the scripts for a project. It is organized 
  into three specific sub-directories. The first sub-directory, `FUNS`, is used 
  to store *functions* which are specific to the project in general. This is 
  where all of the functions used to define the decision model and prepare its 
  parameter inputs are stored. The second sub-directory, `01_Simulations`, is 
  used to store *scripts* which execute all relevant simulations for this 
  project. The third sub-directory, `02_Analysis`, is used to store *scripts* 
  which perform the relevant steps to produce a specific result. In other words, 
  these scripts accept simulation output as input and return a result (i.e. 
  tabular or graphical) which will be stored in the `results` directory.  

[^1]: Briggs AH, Claxton K, Sculpher MJ. Decision modelling for health economic evaluation. Oxford: Oxford University Press; 2006. 237 p. (Briggs A, Gray A, editors. Oxford handbooks in health economic evaluation.)    
[^2]: Chancellor JV, Hill AM, Sabin CA, Simpson KN, Youle M. Modelling the Cost Effectiveness of Lamivudine/Zidovudine Combination Therapy in HIV Infection. Pharmacoeconomics. 1997 Jul 1;12(1):54–66.
[^scope]: The functions included in this repo are restricted to the development 
of the HIV model itself. Given that consistent analytic frameworks must be 
applied to all decision models, a separate R package was developed to 
promote re-usability and save future development time. This package is not yet 
publicly available.  
[^tmat]: The function to define the transition matrix is executed within the 
call stack when drawing parameters. This design choice was simply due to the 
nature of the input data. In other circumstances, like the THR model, this 
function will be incorpored within the model call stack instead. 
