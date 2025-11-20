This document summarizes the sequence of tasks that were required to
redevelop the THR model in a reproducible fashion. 

Status indicators for each task (or sub-task) are defined as: 

:white_check_mark: Complete
:warning: In-Progress
:x: Ice-Box

| Task                                     | Status             | 
|-----------------------------------------|:------------------:|
| [Model Development](#model-development) | :white_check_mark:  | 
| [Simulations](#simulations) | :white_check_mark: | 
| Analysis: [Adoption Decision](#adoption-decision) | :white_check_mark: | 
| Analysis: [Research Decision](#research-decision) | :warning: |

# Model Development
Model development is comprised of the following sub-components. It is considered
complete when costs and effects (LYs) can be generated from the raw data using 
deterministic or probabilistic simulation. 

## Prepare Parameter Inputs From Raw Data
**STATUS**: :white_check_mark:

  * :white_check_mark: Define Function to load parameters from raw data
    - Function: `get_params()`
  * :white_check_mark: Monotherapy Transitions
    - Add state transitions table for monotherapy to `data/data-raw`.
      - File: `data/data-raw/StateTranstions_Count_Mono.rds`
    - Add relative risk of disease progression for combination therapy to 
    `data/data-raw`. 
      - File: `data/data-raw/Relative-Risk_Progression.rds`.
  * :white_check_mark: Costs
    - Add annual costs for each health state to `data/data-raw`.
      - File: `data/data-raw/HIV_Annual-Costs.rds`
    - Add treatment costs. 
      - AZT: 2278 GBP, LAM: 2087 GBP.
      - Defined in body of `get_params()`.
      
## Develop Model Code
**STATUS**: :white_check_mark: 
Organized into three separate call stacks. 

  * :white_check_mark: Function to generate simulation-ready model parameters
  from raw data.
    - Function Name: `get_params()`. 
    - Description: Looks in the `data/data-gen/Model-Params` sub-directory for a data set. If the directory is empty, the function will re-generate teh parameters from teh raw data and save it there. In this situation, it will also return a message stating the relative file path for the generated parameter data set. 
  * :white_check_mark: Function to draw parameter values from the assigned
  distributions. 
    - Function Name: `DrawParams()`
    - Description: This function is designed to support deterministic or probabilistic analyses. If deterministic, mean values are returned for each parameter. If probabilistic, a value is drawn for each assigned distribution.
  * :white_check_mark: Function to generate output from the decision model.
    - Function Name: `run_arm()`. 
    - Description: Responsible for estimating the costs and effects in each arm of the specified decision model. Note that the function only calculates output for a single arm. This was a deliberate design choice to reduce/eliminate code duplication. Assessment of multiple arms (ie. `"Mono"` and `"Comb"`) should be achieved using functional programming techniques.
    
# Simulations
Consistent with the exercises in the DMHEE textbook [^1], the HIV model was 
evaluated using deterministic and stochastic approaches. Each simulation 
considered a time horizon of 20 years (20 cycles), and discounted costs and 
effects at 6% and 0%, respectively. 

Data generated from each simulation were stored in the following sub-directory: `data/data-gen/Simulation-Output`. 

  * Deterministic Simulation: :white_check_mark:
  * Monte Carlo Simulation: :white_check_mark:
  * Nested Monte Carlo Simulations: :warning:
    - &phi; = State Counts (Monotherapy): :white_check_mark:
    - &phi; = Relative Risk: :white_check_mark:
    - &phi; = Annual Costs: :white_check_mark:

# Analysis
## Adoption Decision

  * :white_check_mark: Results table | Deterministic 
  * :white_check_mark: Results table | Probabilistic
  * :white_check_mark: Cost-Effectiveness Plane
  * :white_check_mark: CEAC
  
## Research Decision

  * :x: VoI Results Table (in-development)
  * :white_check_mark: Figures
    - :white_check_mark: EVPI Plot
    - :white_check_mark: EVPPI Plot
      - Includes all uncertain parameters in one figure. 

