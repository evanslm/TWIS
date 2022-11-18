#!/bin/bash

#### This script creates the predicted expression files from the TWAS weights in the target sample

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

### setup
tissue="pfc"
scores="scores/"$tissue
study="1kg"
predicted="predicted/"$tissue"/"$study
mkdir -p $predicted


### Generate predicted expression for each gene for each individual. Here, just doing it for genes on chromosome 21
chr=21
pfile=1kg/eur."$chr".keep

grep -Ff PsychENCODE_TWAS/ensgID.txt ensg.ids.hg37.txt | awk '$6==21 {print $1}' | \
    xargs -i -P $ncore sh -c "plink2 --pfile '$pfile' --read-freq '$pfile'.afreq --score '$scores'/{}.score 1 2 4 --out '$predicted'/{}.pred"


### Get list of all genes with prediction. Using the genes with .sscore prediction files ensures all genes tested will have predictions:
### Done only once for each tissue/study combination
printf '%s\n' $predicted/*sscore | cut -d '/' -f 4 | cut -d '.' -f -1 > $predicted/predicted.genelist.$study.txt


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
