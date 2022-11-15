# Transcriptome Wide Interaction Study
**Code and scripts to run TWIS**

The method and steps are described in https://doi.org/10.1101/2022.08.16.504187


### Organization

1. `code/` contains all the scripts to perform TWIS and E-TWIS
2. `figure_data/` contains all the data and scripts to recreate the data from the publication

The code here includes bash and R scripts used to perform a TWIS and E-TWIS analysis. It is organized by each step in the process, not as a unified single program. It is set up to perform an example analysis using publicly available 1000 Genomes data, and publicly released TWAS weights.

Some of the steps are performed in pieces, where the analysis is split into some number of chunks, and each chunk or piece is run on a separate compute node. The research computing facility at CU Boulder, where I work, uses SLURM as its scheduler, and SBATCH commands are included, but you can modify any and all of the code to match your own system.
