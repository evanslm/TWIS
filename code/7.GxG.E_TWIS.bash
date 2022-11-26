#!/bin/bash
#SBATCH -J e_twis
#SBATCH -N 1-1
#SBATCH --ntasks=2
#SBATCH --time=72:00:00
#SBATCH --mem=150gb
#SBATCH -o E_TWIS.%A.outerr


date
hostname

module load R/4.0.4
export OMP_NUM_THREADS=1


## Performs both the chi-squared-based enrichment test and a ramdom resampling approach
## --nsamp set here to 20 so that it will complete in a relatively short time, but we suggest at least 500+ randomly resampled genesets

Rscript GxG.E_TWIS.R \
	--input=example/cpdL10H20_cortex.PEC.meta.txt \
	--genesets=example/test.genesets.txt \
	--gene_info=example/cortex.PEC.prediction_gene_model_info.txt \
	--nsamp=20




date
