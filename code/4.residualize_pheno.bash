#!/bin/bash

### Script to residualize phenotype on covariates
### Typically, one would first identify unrelated individuals (e.g., using GCTA)

mkdir -p phenos/

phenotype="SIMULATE_binom" ### Either the name of the file (with columns FID,IID,<phenotypename>), or "SIMULATE" for a simulated phenotype
covariate="SIMULATE" ### Either the name of the file (with columns FID,IID,cov1,cov2...), or "SIMULATE" for a simulated simulated covariates
simpheno="norm" ### can be left out, or "binom" or "norm" for a binomially or normally distributed phenotype, respectively

Rscript phenos_residualize.R $phenotype $covariate $simpheno > log.4.residualize.outerr 2>&1
