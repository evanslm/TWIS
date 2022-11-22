### R script to perform E-TWIS analysis of gene sets
### INCLUDING BOTH CORRELATION AND PHYSICAL DISTANCE THRESHOLDS

library(data.table)
library(RcppArmadillo)
library(optparse)


option_list = list(
  make_option("--input", action="store", default=NA, type='character',
              help="the input file with meta-analyzed TWIS statistics, in csv format"),
  make_option("--rthreshold", action="store", default=0.05, type='numeric',
              help="Threshold for pairwise correlation of predicted expression for removing from analysis"),
  make_option("--dist.thresh", action="store", default=1e6, type='numeric',
              help="bp threshold between gene midpoints beyond which to keep in analyses when on the same chromosome"),
  make_option("--genesets", action="store", default=NA, type='character',
              help="the list of genesets, each a file with one column of ENSG gene IDs")
)
opt = parse_args(OptionParser(option_list=option_list))

genesetnames<-read.table(opt$genesets,header=F)

gID<-read.table('ensg.ids.hg37.txt',sep="\t",header=T)
gID$pos.med<-apply(cbind(gID$Gene.start..bp.,gID$Gene.end..bp.),1,median)
gID1<-gID[,c(1,6,7)];colnames(gID1)<-c("ID1","CHR1","pos1")
gID2<-gID1;colnames(gID2)<-c("ID2","CHR2","pos2")


## Output header
test<-paste("GeneSetName","GeneSetSize","GeneSetSizeInTWIS","GeneSetPairsInTWIS","GeneSetPairsinTWIS_thresh","Chisq","Chisq_p","Chisq_thresh","Chisq_thresh_p","\n",sep=" ")
cat(test)


## All genes in the genome with expression data. allg is a list of gene names
allg<-read.table("predicted/predicted.genelist.txt",header=F)

## All gene-gene interaction results for trait/tissue (here just on chromosome 21):
d<-fread(opt$input,sep=",",header=T)

ids<-do.call(rbind,strsplit(d$MARKER,'_')) # Split the marker name into the pair of genes

d<-cbind(ids,d)
colnames(d)[c(1:2)]<-c("ID1","ID2")

for(gg in 1:nrow(genesetnames)){
    ## The target gene set:
    gsname<-genesetnames[gg,1]
    gs<-read.table(gsname,header=F)
    ng.set<-nrow(gs)
    gset<-gs[which(gs[,1]%in%allg[,1]),]
    ng<-length(gset) ## The number of genes that are actually in the TWAS gxg dataset, which may not include all for various reasons

    ## Only run when the number of genes in the TWIS dataset are >=10
    if(ng>=10){
        ## Estimate network connectivity of the target gene set (using the "all" meta-analyzed Z-scores):
        gs.pairs<-which(d$ID1%in%gs$V1 & d$ID2%in%gs$V1)
        d.gs.pairs<-d[gs.pairs,]
        d.gs.pairs<-merge(d.gs.pairs,gID1,keep.x=T,by="ID1")
        d.gs.pairs<-merge(d.gs.pairs,gID2,keep.x=T,by="ID2")
        d.gs.pairs$bpdist<-abs(d.gs.pairs$pos1-d.gs.pairs$pos2)
        
        ## pairs that pass correlation and distance cutoffs
        gs.pairs.thresh<-which(d.gs.pairs$PairwiseExpressionCorrelation<=opt$rthreshold & d.gs.pairs$PairwiseExpressionCorrelation>=-opt$rthreshold & (d.gs.pairs$CHR1!=d.gs.pairs$CHR2 | d.gs.pairs$bpdist>=opt$dist.thresh))

        ## sum(Z^2) for all pairs:
        Z2sum<-sum((d.gs.pairs$Z_all)^2)
        Z2p<-pchisq(Z2sum,length(gs.pairs),lower.tail=F)

        ## sum(Z^2) only for pairs that pass cutoffs:
        Z2sumr<-sum((d.gs.pairs$Z_all[gs.pairs.thresh])^2)
        Z2pr<-pchisq(Z2sumr,length(gs.pairs.thresh),lower.tail=F)

        ## Write out the results
        test<-paste(gsname,ng.set,ng,length(gs.pairs),length(gs.pairs.thresh),Z2sum,Z2p,Z2sumr,Z2pr,sep=" ")
        cat(test,"\n")
    } else{
        message(paste0(gsname,'has only ', ng,' genes in the TWIS dataset'))
    }
}


