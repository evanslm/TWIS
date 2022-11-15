#!/bin/bash

### Script to residualize the imputed gene expression data on covariates
### Requires R packages: RcppArmadillo and optparse

covar="covariates.txt"
predicted="predicted/"
residualized="residualized/"
mkdir -p $residualized

### Residualize imputed gene expression. 
Rscript expression_residualize.R --pred_scores $predicted --resid_out $residualized --covar SIMULATE > log.3.residualize.outerr 2>&1
echo "completed residualizing predicted gene expression"

