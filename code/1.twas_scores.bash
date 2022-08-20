#!/bin/bash

#### This script creates the score files from the TWAS weights, required to make expression predictions
#### Uses the FUSION-supplied R script to create the scores
#### Currently uses the sCCA cross-tissue weights from FUSION documentation website preprint
#### Gets the gene IDs split by chromosome for later parallelization across chromosomes


tissue="cortex.PEC"
weight_loc="PsychENCODE_TWAS"
scores="scores/"$tissue


mkdir -p $scores
mkdir -p $scores/ensgIDs


##############################################################################
### 1. Download pre-computed GTEx cross-tissue (sCCA) expression prediction models & unzip, and download the FUSION make_scores.R script from the fusion github site (https://github.com/gusevlab/fusion_twas)
wget http://gusevlab.org/projects/fusion/weights/sCCA_weights_v8_2.zip
unzip sCCA_weights_v8_2.zip

