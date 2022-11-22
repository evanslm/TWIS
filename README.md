# TWIS: Transcriptome Wide Interaction Study
**Code and scripts to run TWIS**

The method and steps are described in https://doi.org/10.1101/2022.08.16.504187


### Organization

1. `code/` contains all the scripts to perform TWIS and E-TWIS
2. `figure_data/` contains all the data and scripts to recreate the data from the publication

The code here includes bash and R scripts used to perform a TWIS and E-TWIS analysis. It is organized by each step in the process, not as a unified single program. It is set up to perform an example analysis using publicly available 1000 Genomes data, and publicly released TWAS weights.

Some of the steps are performed in pieces, where the analysis is split into some number of chunks, and each chunk or piece is run on a separate compute node. The research computing facility at CU Boulder, where I work, uses SLURM as its scheduler, and SBATCH commands are included, but you can modify any and all of the code to match your own system.


List of R packages to be installed for the pipeline:
```
RcppArmadillo
optparse
data.table
Matrix
RcppArmadillo
foreach
iterators
doMC

#in R, these packages can be installed with:
install.packages(c("RcppArmadillo","optparse","data.table","Matrix","RcppArmadillo","foreach","iterators","doMC"))
```

Run the bash scripts in order.  Example slurm sbatch submissions are shown below.
Note that the slurm specifications will be different for larger datasets and different compute platforms.

```
#############################################################################################
################ 1.twas_scores.bash #########################################################
#############################################################################################

# This script creates the score files from the TWAS weights, required to make expression predictions

efile="./logs/1_twas_scores.err"
ofile="./logs/1_twas_scores.log"
sbatch -J 1_twas_scores -N 1-1 --ntasks=6 --qos=preemptable --constraint=skylake --time=1:00:00 --mem=5000 --error=$efile --output=$ofile 1.twas_scores.bash 

#############################################################################################
################ 2.predict.bash #############################################################
#############################################################################################

# This script creates the predicted expression files from the TWAS weights in the target sample

efile="./logs/2_predict.err"
ofile="./logs/2_predict.log"
sbatch -J 2_predict -N 1-1 --ntasks=6 --qos=preemptable --constraint=skylake --time=1:00:00 --mem=5000 --error=$efile --output=$ofile 2.predict.bash 

#############################################################################################
################ 3.residualize_expression.bash ##############################################
#############################################################################################

# This script residualizes the imputed gene expression data on covariates

efile="./logs/3_residualize_expression.err"
ofile="./logs/3_residualize_expression.log"
sbatch -J 3_residualize_expression -N 1-1 --ntasks=6 --qos=preemptable --constraint=skylake --time=1:00:00 --mem=5000 --error=$efile --output=$ofile 3.residualize_expression.bash

#############################################################################################
################ 4.residualize_pheno.bash ###################################################
#############################################################################################

# This script residualizes phenotype on covariates. Typically, one would first identify unrelated individuals (e.g., using GCTA)

efile="./logs/4_residualize_pheno.err"
ofile="./logs/4_residualize_pheno.log"
sbatch -J 4_residualize_pheno -N 1-1 --ntasks=6 --qos=preemptable --constraint=skylake --time=1:00:00 --mem=5000 --error=$efile --output=$ofile 4.residualize_pheno.bash

#############################################################################################
################ 5.pheno_expression_match.bash ##############################################
#############################################################################################

# This script matches the phenotype and expression data, merge them into one file, and output that for next GxG association test array jobs
# The residualized phenotype file and the residualized gene expression files should all have ***exactly*** the same IDs and order of IDs

efile="./logs/5_pheno_expression_match.err"
ofile="./logs/5_pheno_expression_match.log"
sbatch -J 5_pheno_expression_match -N 1-1 --ntasks=6 --qos=preemptable --constraint=skylake --time=1:00:00 --mem=5000 --error=$efile --output=$ofile 5.pheno_expression_match.bash

#############################################################################################
################ 6.twis.bash ################################################################
#############################################################################################

# This script runs the gxg TWAS analysis using predicted expression values
# Make sure that slurm array number matches the nparts variable, which specifies how many chunks the analysis is split into

efile="./logs/6_twis.err"
ofile="./logs/6_twis.log"
sbatch -J 6_twis -N 1-1 --ntasks=8 --qos=preemptable --constraint=skylake --time=4:00:00 --array=1-5 --mem=5000 -o ./logs/step6.twis.%A_%a.outerr 6.twis.bash

# Final results will be saved to the ./results/ folder in tab-delimited .txt format
# To instead save the results in .RDat format, see the commented code at the end of twis.R
```
