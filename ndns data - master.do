********************************************************************************
* set up...

set linesize 80
set more off, perm
set scheme burd

* need to create global filepath mypath for local ECLIPSE folder
cd `"${mypath}ECLIPSE"'

*-------------------------------------------------------------------------------
*_______________________________________________________________________________
* open log...

* needed to create markdown doc
* generates log file in project folder
quietly log using "ndns data", replace smcl

//ON

/***
Evaluating Calorie Intake for Population Statistical Estimates (ECLIPSE)
================================================================================

This is the master file the data analysis carried out for the ECLIPSE project 
It executes a series of STATA do files to prepare and analyse the data,
generate outputs and charts as well as a markdown document with detailed results.

The model results used to predict errors are saved as stored estimates, 
as well as a scalar vector, which could be used independently of the data files.

***/

//OFF
*-------------------------------------------------------------------------------
*_______________________________________________________________________________
* run data preperation...

* merges data for average daily nutrional values
* demographic information and physiological data - including dlw measures
* generates raw data file saved in source file location

do "ndns data - prep.do"
*-------------------------------------------------------------------------------
*_______________________________________________________________________________
* run formatting...

* uses raw merged data file generated in data prep do file (above)
* formats and labels variables
* calculate derived variables
* generates formatted data set ready for analysis 

do "ndns data - format.do"
*-------------------------------------------------------------------------------
*_______________________________________________________________________________
* run descriptive analysis...

* uses formatted data set generated above
* descriptive analysis on key variables
* cohort profiles
* generates charts and summary statistics
* saved in Outputs folder

do "ndns data - explore.do"
*-------------------------------------------------------------------------------
*_______________________________________________________________________________
* run main Analysis...

* uses formatted data set generated from from format.do
* examines dependent variable
* univariate analysis on the predictor variables
* variable selection via bootstrap
* variable selection - check for colineariaty

do "ndns data - analysis.do"

* run bootsrap simulator (set up before main analysis - with initial config?)			


*-------------------------------------------------------------------------------
*_______________________________________________________________________________
* close log and print output file...
		
//OFF
log close
 
* print log	and outputs to pdf
markdoc "ndns data", export(pdf) replace install title("ECLIPSE")

********************************************************************************
********************************************************************************
