#!/bin/bash
#SBATCH -J twas_gxg
#SBATCH -N 1-1
#SBATCH --ntasks=8
#SBATCH --time=4:00:00
#SBATCH --array=1-20
#SBATCH -o step6.twis.%A_%a.outerr
#SBATCH --mem=5000

### Script to run gxg TWAS analysis using predicted expression values
### Requires the following R libraries: data.table, optparse, Matrix, RcppArmadillo, foreach, iterators, and doMC


date
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




date

