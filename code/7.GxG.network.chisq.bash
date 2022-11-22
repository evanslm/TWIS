#!/bin/bash
#SBATCH -J gxg.network
#SBATCH -N 1-1
#SBATCH --ntasks=2
#SBATCH --time=72:00:00
#SBATCH --mem=85000
#SBATCH -o GeneSets.chisq.%A.outerr


date
hostname

module load R/4.0.4
export OMP_NUM_THREADS=1


## To run E-TWIS analysis using meta-analyzed results from multiple datasets. See the example input file in the example directory for the format of the input data.
## The gene set names are listed in test.genesets.txt, found in the example directory.
Rscript GxG.network.chisq.allsets2.R \
	--input example/cpdL10H20_cortex.PEC.chr21.csv \
	--geneset example/test.genesets.txt \
	> cpdL10H20.cortex.PEC.e_twis.txt 2> cpdL10H20.cortex.PEC.e_twis.err
