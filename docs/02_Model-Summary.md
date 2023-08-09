# Model Summary
The HIV model was originally developed for a cost-effectiveness analysis of 
zidovudine monotherapy compared with combination therapy of zidovudine and 
lamivudine. These strategies were compared in patients with HIV infection, and 
is originally reported in Chancellor et al. 1997[^1]. The version used in this 
project is adapted from the popular modelling textbook by Briggs et al.[^2].

A summary of the model structure is presented in the figure below.

![Structure of HIV Cohort Model](Diagrams/HIV-Model.png)

The diagram depicts a model which characterizes the prognosis of an HIV-positive 
patient in terms of four health states. Importantly, the model assumes that a 
patient cannot move to a less severe disease state. While this assumption may 
not be true today, this exercise is strictly meant as a teaching tool to 
illustrate the underlying methods.

State A
  : Less severe HIV state with CD4 cell count of 200-500 celss/mm^3. 

State B
  : More severe HIV state with CD4 cell count less than 200 cells/mm^3. 
  
State C
  : AIDS. 
  
State D
  : Death (Absorbing state).

For the purpose of this exercise, treatment effects are measured in terms of 
Life-Years. Meanwhile, costs are measured in terms of the annual treatment costs 
in hospital and community care settings.

## Model Parameters
Add a summary of the model parameters here.

[^1]: Chancellor JV, Hill AM, Sabin CA, Simpson KN, Youle M. Modelling the Cost Effectiveness of Lamivudine/Zidovudine Combination Therapy in HIV Infection. Pharmacoeconomics. 1997 Jul 1;12(1):54–66.
[^2]: Briggs AH, Claxton K, Sculpher MJ. Decision modelling for health economic evaluation. Oxford: Oxford University Press; 2006. 237 p. (Briggs A, Gray A, editors. Oxford handbooks in health economic evaluation.)