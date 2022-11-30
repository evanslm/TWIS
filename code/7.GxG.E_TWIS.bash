#!/bin/bash

### Below is an example slurm header for running this script

#SBATCH -J e_twis
#SBATCH -N 1-1
#SBATCH --ntasks=2
#SBATCH --time=72:00:00
#SBATCH --mem=150gb
#SBATCH -o E_TWIS.%A.outerr

## Performs both the chi-squared-based enrichment test and a ramdom resampling approach
## --nsamp set here to 20 so that it will complete in a relatively short time, but we suggest at least 500+ randomly resampled genesets

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

## Below are the parameters that can be specified for GxG.E_TWIS.R
# --input "the input file with meta-analyzed TWIS statistics, in csv format"
# --output "E_TWIS.resampling.%Y_%b_%d_%X.txt"
# --rthreshold "Threshold for (absolute value) pairwise correlation of predicted expression for removing from analysis. Default=0.05."
# --dist.thresh "bp threshold between gene midpoints beyond which to keep in analyses when on the same chromosome. Default=1e6."
# --genesets "the list of genesets, each a file with one column of ENSG gene IDs"
# --nsamp "The number of resampled replicates to perform. Default=1000."
# --gene_info "the list of genesets, each a file with one column of ENSG gene IDs"

module load R/4.0.4
export OMP_NUM_THREADS=1
Rscript GxG.E_TWIS.R \
	--input=example/cpdL10H20_cortex.PEC.meta.txt \
	--genesets=example/test.genesets.txt \
	--gene_info=example/cortex.PEC.prediction_gene_model_info.txt \
	--nsamp=20

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

