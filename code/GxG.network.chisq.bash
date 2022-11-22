#!/bin/bash
#SBATCH -J gxg.network
#SBATCH -N 1-1
#SBATCH --ntasks=2
#SBATCH --qos=blanca-ibg
#SBATCH --constraint=skylake
#SBATCH --time=72:00:00
#SBATCH --mem=85000
#SBATCH -o GeneSets.chisq.%A.outerr


date
hostname

module load R/4.0.4
export OMP_NUM_THREADS=1



cut -d ',' -f -1 *csv | tr '_' '\n' | sort | uniq| perl -MList::Util -e 'print List::Util::shuffle <>' | head -20 > genesets/test.chr21.geneset.txt
perl -MList::Util -e 'print List::Util::shuffle <>' ensg.ids.hg37.txt | awk '$6!=21' | cut -f -1 | head -20 > genesets/test.otherchromosomes.geneset.txt

echo 'test.chr21.geneset.txt' > genesets/test.genesets.txt
echo 'test.otherchromosomes.geneset.txt' >> genesets/test.genesets.txt

### When meta-analyzed multiple datasets:
Rscript GxG.network.chisq.allsets2.R \
	--input example/cpdL10H20_cortex.PEC.chr21.csv \
	--geneset example/test.genesets.txt \
	> cpdL10H20.cortex.PEC.e_twis.txt 2> cpdL10H20.cortex.PEC.e_twis.err
