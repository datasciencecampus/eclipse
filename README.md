# ECLIPSE
Evaluating CaLorie Intake for Population Statistical Estimates

The ECLIPSE project aimed to explore the apparent issue of under-reporting in food consumption surveys.

Data from the National Diet and Nutrition Survey (NDNS) Years 1-6, 2008/09-2013/14 were obtained from
The UK Data Service. https://www.ukdataservice.ac.uk/

The analysis made use of bio-metric data collected for a sub-sample of NDNS participants which provided an objective estimate of energy expended, measured using Doubly Labeled Water. This was compared with individual energy intake estimates and percentage difference was calculated and modelled using demograohic and anthropomorphic characteristics.

This repo contains the code used to for the data analysis. All analysis was carried out using STATA 14.
The master.do file should be used to set up the analysis, including the installation of required programs. Weaver is required to print markdoc files of
output embedded in code. https://github.com/haghish/weaver.
The code makes use of a file path which points to a local folder containing the code and data folder from the UK Data Service,
this should be set using a global macro named 'mypath'.

The master file runs the entire program of analysis including preparing the raw data files, formatting variables, creating derived values, calculating percentage differences between self-reported and bio-metric measures. The analysis produces a model of estimated error, which are stored locally and are then applied to the test sample using the stored linear equation.
The model estimates can be used to predict error on any data set containing the variables used in the mode and adjust energy intake values to be used for aggregated averages. Note that this method is not suitable for predicting individual differences.

The analysis also includes a sensitivity analysis on error estimates carried out using bootstrapped sampling. An output containing model coefficients from 1000 models are produced from the bootstrapped samples which can be used to explore the variation in error associated with each individual factor within the model.

Simulated samples of individuals initialised with the standard european population are created using randomly selected measures for weight, height, age and sex from individuals in the testing sample. An output data set from 1000 simulated samples containing avergae calorie intake and percentage of undajusted and adjusted energy intake estimates within biologically plausible ranges for each sample. This dataset can be used to explore the robustness of the average calorie intake estimated using adjusted data derived from different sample populations.
