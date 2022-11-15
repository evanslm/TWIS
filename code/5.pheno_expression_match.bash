#!/bin/bash


### Script to match the phenotype and expression data, merge them into one file, and output that for next GxG association test array jobs
### IMPORTANT: The residualized phenotype file and the residualized gene expression files should all have ***exactly*** the same IDs and order of IDs

phenotype="SIMULATE" ### Phenotype to merge

residualized="residualized" ### Location of the residualized expression data

### Make a list of genes with data
printf '%s\n' $residualized/ENSG* | sed 's/residualized\///g;s/_predicted_residuals.RDat//g' > $residualized/genelist.txt

### Merge it all together
Rscript pheno_expression_match.R $residualized $phenotype
