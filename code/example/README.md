### Example files

This directory contains the meta-analyzed TWIS results (`cpdL10H20_cortex.PEC.chr21.csv`) reported in the original TWIS paper for binary-coded cigarettes per day (Low<=10 per day, high>20 per day), using imputed expression in the PFC. To reduce the size of the file, only pairs on chromosome 21 are contained here.

This directory also contains two example gene sets of 20 genes each, drawn randomly from either the genes on chromosome 21 that were actually included in the example TWIS example, or alternatively, all other chromosomes in the genome. These were generated using the commands below, as a way to demonstrate the E-TWIS approach.



`cut -d ',' -f -1 ../cpdL10H20_cortex.PEC.chr21.csv | tr '_' '\n' | sort | uniq| perl -MList::Util -e 'print List::Util::shuffle <>' | head -20 > test.chr21.geneset.txt`

`perl -MList::Util -e 'print List::Util::shuffle <>' ../ensg.ids.hg37.txt | awk '$6!=21' | cut -f -1 | head -20 > test.otherchromosomes.geneset.txt`

`echo 'example/test.chr21.geneset.txt' > test.genesets.txt`

`echo 'example/test.otherchromosomes.geneset.txt' >> test.genesets.txt`
