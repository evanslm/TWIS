#!/bin/bash

#### This script creates the score files from the TWAS weights, required to make expression predictions
#### Uses the FUSION-supplied make_scores.R script to create the scores (you should download this separately before you start)
#### Currently uses the sCCA cross-tissue weights from FUSION documentation website preprint
#### Gets the gene IDs split by chromosome for later parallelization across chromosomes

ncore=12 ### However many cores you have available on your machine


tissue="sCCA3"
weight_loc="sCCA_weights_v8/"$tissue"/"
scores="scores/"$tissue

mkdir -p $scores ### Directory for score files & ENSG gene IDs
mkdir -p $scores/ensgIDs


##############################################################################
### 1. Download pre-computed GTEx cross-tissue (sCCA) expression prediction models & unzip, and download the FUSION make_scores.R script from the fusion github site (https://github.com/gusevlab/fusion_twas)
wget http://gusevlab.org/projects/fusion/weights/sCCA_weights_v8_2.zip
unzip sCCA_weights_v8_2.zip



##############################################################################
### 2. Download 1000 Genomes reference data to use. Here, just using a single chromosome (21) from the hg19 build, and convert it to plink2 format while extracting EUR group individuals only.
### Build hg19 can be downloaded from http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/
### You will also need a list of the 1KG individuals in the EUR continental group for the plink2 command below.
wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr21.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz
mkdir 1kg
mv ALL.chr21.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz 1kg
plink2 --vcf 1kg/ALL.chr21.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz --double-id --keep 1kg/1000g_individuals.EUR.txt --make-pgen --out 1kg/eur --maf 0.01


##############################################################################
### 3. Make score files for each transcript. Here, just for chromosome 21.
awk '$3==21 {print $2}' sCCA_weights_v8/sCCA3.pos | \
    xargs -i -P $ncore sh -c "Rscript make_score.R sCCA_weights_v8/'$tissue'/'$tissue'.{}.wgt.RDat > scores/'$tissue'/{}.score"


##############################################################################
### 4.Getting the ENSG IDs for each chromosome separately to parallelize it later across chroms
cc=21 ### This would be done for each chromosome separately, when doing all chromosomes
awk -v var=$cc 'FNR>1 && $3==var {print $2}' sCCA_weights_v8/$tissue.pos > "$scores"/ensgIDs/chr"$cc".ensgID.txt


##############################################################################
### 5. Get the unique positions to be retained from the score files
### DO ONCE FOR EACH NEW TISSUE, do not need to do again
### Get only the unique rsNumbers that are retained in the TWAS score files (files generated from
cut -f -1 $scores/*.score | sort | uniq > $scores/rsNum.unique.txt ## Done once, do not need to do again


