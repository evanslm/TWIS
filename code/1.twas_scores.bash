#!/bin/bash

#### This script creates the score files from the TWAS weights, required to make expression predictions
#### Uses the [FUSION](https://github.com/gusevlab/fusion_twas) -supplied make_scores.R script to create the scores (you should download this separately before you start)
### Download GRCh37 ENSEMBLE Gene IDs from biomart here: http://grch37.ensembl.org/biomart/ or use this file with the hg37 data: ensg.ids.hg37.txt
#### Currently uses the PsychENCODE Prefrontal Cortex TWAS weights of Gandal et al.

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

ncore=6 ### However many cores you have available on your machine

### start timer for script
date
startTime="$(date +%s)"

### Set names and create directories for score files & ENSG gene IDs
tissue="pfc" ## prefrontal cortex
weight_loc="PsychENCODE_TWAS/" ### from psychencode
scores="scores/"$tissue

mkdir -p $scores 
mkdir -p $scores/ensgIDs


##############################################################################
### 1. Download the PsychENCODE TWAS weights of Gandal et al. 2018, and get list of genes with TWAS weights
mkdir -p PsychENCODE_TWAS
cd PsychENCODE_TWAS
wget http://resource.psychencode.org/Datasets/Derived/PEC_TWAS_weights.tar.gz
tar -zxvf PEC_TWAS_weights.tar.gz
printf '%s\n' ENSG00000* | sed 's/.wgt.RDat//g' > ensgID.txt
cd ../


##############################################################################
### 2. Make score files for each transcript. Here, just for those on chromosome 21, per the ENSG Biomart gene lists
grep -Ff PsychENCODE_TWAS/ensgID.txt ensg.ids.hg37.txt | awk '$6==21 {print $1}' | xargs -i -P $ncore sh -c "Rscript make_score.R PsychENCODE_TWAS/{}.wgt.RDat > scores/'$tissue'/{}.score"


##############################################################################
### 3. Get the unique positions to be retained from the score files for each tissue
### Get only the unique chrom:positions that are retained in the TWAS score files (files generated from
cut -f -1 $scores/*.score | sort | uniq > $scores/$tissue.chrpos.unique.txt ## Done once, do not need to do again



##############################################################################
### 4. Download 1000 Genomes reference data to use. Here, we'll just be using a single chromosome (21) from the hg19 build, and convert it to plink2 format while extracting EUR group individuals only.
### Build hg19 can be downloaded from http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/
### You will also need a list of the 1KG individuals in the EUR continental group for the plink2 command below.
wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr21.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz
mkdir 1kg
mv ALL.chr21.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz 1kg
wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/integrated_call_samples_v3.20200731.ALL.ped
mv integrated_call_samples_v3.20200731.ALL.ped 1kg/
grep 'CEU\|TSI\|GBR\|FIN\|IBS' 1kg/integrated_call_samples_v3.20200731.ALL.ped | cut -f -2 > 1kg/1000g_individuals.EUR.txt
plink2 --vcf 1kg/ALL.chr21.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz \
       --chr 21 \
       --double-id \
       --keep 1kg/1000g_individuals.EUR.txt \
       --make-pgen \
       --out 1kg/eur.21 \
       --maf 0.01

### Because the TWAS weights files have chrom:pos for the variant IDs, we create a new pvar file in that format:
mv 1kg/eur.21.pvar 1kg/eur.21.original.pvar
awk -F'\t' '{ if(/#/) {print $0} else {print $1,$2,$1":"$2,$4,$5,$6,$7,$8} } ' 1kg/eur.21.original.pvar > 1kg/eur.21.pvar

### Then extract only those positions we want, and do some basic qc on them:
plink2 --pfile 1kg/eur.21 \
       --maf 0.0001 \
       --geno 0.01 \
       --mind 0.01 \
       --extract $scores/$tissue.chrpos.unique.txt \
       --make-pfile \
       --freq \
       --out 1kg/eur.21.keep

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
