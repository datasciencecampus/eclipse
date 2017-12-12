# ECLIPSE
Evaluating CaLorie Intake for Population Statistical Estimates

ECLIPSE was established as part of a program of work invetsigating the apparent issue of under-reporting
in food consumption surveys.

The analysis made use of bio-metric data considered to be the indicustry gold standard measure for comparing self-reported food intake with an objective estimate of energy expended.

This repo contains the code for quanitfying the error, including sensitivity analysis on error estimates carried out using bootstrapped sampling. The analysis method adjusts individual energy intake values for survey participants. 

Simulated samples of individuals initialised with the standard european population are created using randomly selected measures for weight, height, age and sex. Simulated samples can be evaluated in terms of accuracy gains, indicated by the percentage of adjusted estimates outside a biologically plausible range.

