#!/bin/bash

### Script to residualize phenotype on covariates
### Typically, one would first identify unrelated individuals (e.g., using GCTA)

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

mkdir -p phenos/

phenotype="SIMULATE" ### Either the name of the file (with columns FID,IID,<phenotypename>), or "SIMULATE" for a simulated phenotype
covariate="SIMULATE" ### Either the name of the file (with columns FID,IID,cov1,cov2...), or "SIMULATE" for a simulated simulated covariates
simpheno="norm" ### can be left out, or "binom" or "norm" for a binomially or normally distributed phenotype, respectively

Rscript phenos_residualize.R $phenotype $covariate $simpheno > ./logs/log.4.residualize.outerr 2>&1


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
