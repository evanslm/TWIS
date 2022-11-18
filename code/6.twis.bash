#!/bin/bash

### Below is an example slurm header for running this script

#SBATCH -J twas_gxg
#SBATCH -N 1-1
#SBATCH --ntasks=8
#SBATCH --time=4:00:00
#SBATCH --array=1-20
#SBATCH -o step6.twis.%A_%a.outerr
#SBATCH --mem=5000

### Script to run gxg TWAS analysis using predicted expression values
### make sure that array number matches the nparts variable, which specifies how many chunks the analysis is split into
### Requires the following R libraries: data.table, optparse, Matrix, RcppArmadillo, foreach, iterators, and doMC

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

hostname
export OMP_NUM_THREADS=1

module load R/4.0.4 ### required for our system, may not be required in your system

nparts=20
pp="${SLURM_ARRAY_TASK_ID}"
ncore=`env | grep SLURM_NTASKS | cut -d '=' -f 2`

phenotype="SIMULATE"
residualized=residualized/
results=results/

mkdir -p $results
mkdir -p outerr/


Rscript twis.R \
	--phenotype $phenotype \
	--residualized $residualized \
	--results $results \
	--ncore $ncore \
	--nparts $nparts \
	--part $pp \
	> outerr/step6.twis.$phenotype.$nparts.$pp.outerr 2>&1

echo "completed running predicted gene expression gxg for phenotype $phenotype"


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

