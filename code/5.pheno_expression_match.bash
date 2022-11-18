#!/bin/bash

### Script to match the phenotype and expression data, merge them into one file, and output that for next GxG association test array jobs
### IMPORTANT: The residualized phenotype file and the residualized gene expression files should all have ***exactly*** the same IDs and order of IDs

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

phenotype="SIMULATE" ### Phenotype to merge

residualized="residualized" ### Location of the residualized expression data

### Make a list of genes with data
printf '%s\n' $residualized/ENSG* | sed 's/residualized\///g;s/_predicted_residuals.RDat//g' > $residualized/genelist.txt

### Merge it all together
Rscript pheno_expression_match.R $residualized $phenotype


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
