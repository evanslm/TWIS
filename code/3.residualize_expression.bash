#!/bin/bash

### Script to residualize the imputed gene expression data on covariates
### Requires R packages: RcppArmadillo and optparse

# % # % # % # % # % # % # % # % # % # % # % # % #
#  -------------------------------------------  #
# |               TWIS Pipeline               | #
# |      University of Colorado Boulder       | #
# |     Institute for Behavioral Genetics     | #
# | ========================================= | #
# |               Luke M. Evans               | #
# |         luke.m.evans@colorado.edu         | #
# | ========================================= | #
# |        Written in November of 2022        | #
#  -------------------------------------------  #
# % # % # % # % # % # % # % # % # % # % # % # % #

### start timer for script
date
startTime="$(date +%s)"

### setup
covar="covariates.txt"
tissue="pfc"
study="1kg"
predicted="predicted/"$tissue"/"$study
residualized="residualized"
mkdir -p $residualized

### copy gene list file to generic filename to serve as input for expression_residualize.R
cp $predicted/predicted.genelist.$study.txt $predicted/predicted.genelist.txt

### Residualize imputed gene expression. 
Rscript expression_residualize.R --pred_scores $predicted --resid_out $residualized --covar SIMULATE > ./logs/log.3.residualize.outerr 2>&1
echo "completed residualizing predicted gene expression"

### end timer for script and print the runtime that has elapsed
echo " *-* *-* *-* *-* *-* END OF SCRIPT *-* *-* *-* *-* *-* "
date
endTime="$(date +%s)"
diff=$(echo "$endTime-$startTime" |bc)
diff=$(($diff + 0))

if [ $diff -lt "$((60))" ]
then
  printf %.3f "$((1000 * $diff/1))e-3"; echo " seconds"
elif [ $diff -lt "$((60 * 60))" ]
then
  printf %.3f "$((1000 * $diff/60))e-3"; echo " minutes"
elif [ $diff -lt "$((60 * 60 * 24))" ]
then
  printf %.3f "$((1000 * $diff/3600))e-3"; echo " hours"
else
  printf %.3f "$((1000 * $diff/86400))e-3"; echo " days"
fi
