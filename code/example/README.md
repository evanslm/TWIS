### Example files


This directory contains files useful for running the example TWIS and E-TWIS analyses. It contains gene information in `cortex.PEC.prediction_gene_model_info.txt`, including gene ID, chromosome and position. 

For the E-TWIS analysis, we suggest downloading the summary statistics from our manuscript via [dryad](https://doi.org/10.5061/dryad.866t1g1tw). The example scripts to run E-TWIS will use the meta-analyzed CPD results. The specific file used in the E-TWIS scripts (2.15GB) can be downloaded using `wget`, unzipped, and moved to your `example/` directory using:

```
wget -O example/cpdL10H20_cortex.PEC.meta.txt.gz https://datadryad.org/stash/downloads/file_stream/1971644
gunzip example/cpdL10H20_cortex.PEC.meta.txt.gz
```

The example gene sets are of 20 genes each, drawn randomly from either the genes on chromosome 21 that were actually included in the example TWIS example, or alternatively, genes specifically expressed in certain cell types, found in the [Protein Atlas](https://www.proteinatlas.org/). 
