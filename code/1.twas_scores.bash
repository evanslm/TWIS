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

