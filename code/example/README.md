### Example files


This directory contains files useful for running the example TWIS and E-TWIS analyses. It contains gene information in `cortex.PEC.prediction_gene_model_info.txt`, including gene ID, chromosome and position, the meta-analyzed results of low vs. high number of cigarettes per day `cpdL10H20_cortex.PEC.meta.txt`, useful for the E-TWIS analyses, as well as example gene sets. 


The example gene sets are of 20 genes each, drawn randomly from either the genes on chromosome 21 that were actually included in the example TWIS example, or alternatively, all other chromosomes in the genome. These were generated using the commands below, as a way to demonstrate the E-TWIS approach.



`cut -d ',' -f -1 ../cpdL10H20_cortex.PEC.chr21.csv | tr '_' '\n' | sort | uniq| perl -MList::Util -e 'print List::Util::shuffle <>' | head -20`

`perl -MList::Util -e 'print List::Util::shuffle <>' ../ensg.ids.hg37.txt | awk '$6!=21' | cut -f -1 | head -20`
