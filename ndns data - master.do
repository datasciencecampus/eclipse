

********************************************


set linesize 80
set more off, perm
set scheme burd

*need to create global filepath mypath locating ECLIPSE folder
cd `"${mypath}ECLIPSE/ndns data dlw vs self reported"'

quietly log using "ndns data", replace smcl

/***
Estimating accuracy of self-reported food intake
================================================

This document describes data analysis used to evaluate the accuracy of 
self reported food intake measures using estimates of energy expenditure from
bio-metric data.

***/


//OFF

* run data prep do file...
do "ndns data - prep.do"

* run formatting 
do "ndns data - format.do"

//OFF
* run descriptive analysis
do "ndns data - explore.do"

* run main Analysis
do "ndns data - analysis.do"
			
		
//OFF
log close
 
* print log	and outputs to pdf
markdoc "ndns data - analysis", export(pdf) replace install title("ECLIPSE")

