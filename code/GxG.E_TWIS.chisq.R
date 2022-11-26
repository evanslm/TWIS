### Resampling pairs of genes to match gene sets of interest to estimate a null distribution of connectivity
### Luke M. Evans
### Last updated: 2022/11/23

library(data.table)
library(RcppArmadillo)
library(foreach)
library(iterators)
library(doMC)
library(optparse)

ncore<-as.numeric(system("env | grep SLURM_NTASKS | cut -d '=' -f 2",intern=TRUE)) 
registerDoMC(cores=ncore)

option_list = list(
  make_option("--input", action="store", default=NA, type='character',
              help="the input file with meta-analyzed TWIS statistics, in csv format"),
  make_option("--output", action="store", default=format(Sys.time(), "E_TWIS.resampling.%Y_%b_%d_%X.txt"), type='character',
              help="output file name"),
  make_option("--rthreshold", action="store", default=0.05, type='numeric',
              help="Threshold for (absolute value) pairwise correlation of predicted expression for removing from analysis. Default=0.05."),
  make_option("--dist.thresh", action="store", default=1e6, type='numeric',
              help="bp threshold between gene midpoints beyond which to keep in analyses when on the same chromosome. Default=1e6."),
  make_option("--genesets", action="store", default=NA, type='character',
              help="the list of genesets, each a file with one column of ENSG gene IDs"),
  make_option("--nsamp", action="store", default=1000, type='numeric',
              help="The number of resampled replicates to perform. Default=1000."),
  make_option("--gene_info", action="store", default=NA, type='character',
              help="the list of genesets, each a file with one column of ENSG gene IDs")
)
opt = parse_args(OptionParser(option_list=option_list))


## Gene sets to test
genesetnames<-read.table(opt$genesets,header=F)
cat("Number of genesets to test:", nrow(genesetnames),"\n")

## All gene-gene interaction results for trait/tissue (here just on chromosome 21):
d<-fread(opt$input,header=T)
cat("Done reading in TWIS summary statistics\n")

##############################################################################################################
### get genes with expression data, including their size, number of SNPs in best-supported FUSION model, and position
gID<-read.table(opt$gene_info,header=T,sep="\t")
gID$length<-gID$endbp-gID$startbp+1
gID$pos<-apply(cbind(gID$endbp,gID$startbp),1,median)
gID<-gID[,c(1,6,7,11,12)] ## Keeping only the columns needed later


## Merge location and gene info with TWIS results, and get bp distance between pairs:
gIDtmp<-gID;colnames(gIDtmp)<-paste0(colnames(gID),"1")
d<-merge(d,gIDtmp,keep.x=T)


gIDtmp<-gID;colnames(gIDtmp)<-paste0(colnames(gID),"2")
d<-merge(d,gIDtmp,keep.x=T,by="ID2")

d$bpdist<-abs(d$pos1-d$pos2)

cat("dims of dataset:", dim(d),"\n")
cat("Done merging with location data\n")
cat("Starting gene set analyses\n")

##############################################################################################################
### Identify pairs that don't pass thresholds for distance and expression correlation, and remove those
gs.pairs.thresh<-which(d$ExpCorr<=opt$rthreshold & d$ExpCorr>=-opt$rthreshold & (d$CHR1!=d$CHR2 | d$bpdist>=opt$dist.thresh))
cat("dropped ", nrow(d)-length(gs.pairs.thresh), " pairs due to expression correlation or physical distance thresholds\n")
d<-d[gs.pairs.thresh,]
cat("remaining ", nrow(d), " pairs for E-TWIS analysis\n")

##############################################################################################################
### Testing within each gene set:
## for(gg in 1:length(genesetnames)){
## The target gene set:

## Output header
header<-c("GeneSetName","GeneSetSize","GeneSetSizeInTWIS","GeneSetPairsInTWIS","X2","X2_p","X2_mean","Nresamp_larger","Nresamp","resamp_p")
cat(header)


gg=1
U<-NULL
for(gg in 1:nrow(genesetnames)){

    ## Read in the geneset
    gsname<-genesetnames[gg,1]
    gs<-read.table(gsname,header=F)
    ng.set<-nrow(gs)
    gset<-gs[which(gs[,1]%in%gID$ID),]
    ng<-length(gset) ### The number of genes that are actually in the TWIS results

    if(ng>=10){
        gs.pairs<-which(d$ID1%in%gs$V1 & d$ID2%in%gs$V1)
        ngs.pairs<-length(gs.pairs)

        ## Calculate the X^2 for this gene set for comparison to the resampling below:
        Z2sum<-sum((d$Z[gs.pairs])^2)
        Z2p<-pchisq(Z2sum,ngs.pairs,lower.tail=F)
        meanZ2sum<-Z2sum/ngs.pairs
        
         
        ##Set up the resampling:
        ## The lengths & number of SNPs within each gene, tabulated. Note that with a larger number of genes, the bin sizes could be smaller:
        gset.sizes<-gID[which(gID$ID %in% gset),]
        glength.hist<-hist(gset.sizes$length,plot=FALSE)
        gnsnp.hist<-hist(gset.sizes$nsnp,plot=FALSE)
        
        ## Making the same breaks within the genset and finding all genes within each breakpoint for length & nsnps across the whole genome to sample from:
        gID$lengthbin<-NA
        for(bb in 1:length(glength.hist$breaks)){
            gID$lengthbin[which(gID$length>=glength.hist$breaks[bb])]<-bb
        }
        
        gID$nsnpbin<-NA
        for(bb in 1:length(gnsnp.hist$breaks)){
            gID$nsnpbin[which(gID$nsnp>=gnsnp.hist$breaks[bb])]<-bb
        }
        
        genesize.bins<-table(as.data.table(cbind(gID$lengthbin,gID$nsnpbin)))
        gset.size<-gID[which(gID$ID %in% gset),]
        gset.size.bins<-table(as.data.table(cbind(gset.size$lengthbin,gset.size$nsnpbin)))
        nl<-nrow(gset.size.bins)
        ns<-ncol(gset.size.bins)
        

        ## Estimate chisq of nsamp random sets of genes of the same size as the target set & matching the length & num SNPs (roughly):
        x2.null<-foreach(ii=1:opt$nsamp,.combine=rbind)%dopar%{

            ## Sample ng random genes in the same bins as the focal geneset genes
            gs.samp<-NULL
            for(l in 1:nl){
                for(s in 1:ns){
                    nmatch<-gset.size.bins[l,s]
                    if( nmatch > 0 ){
                        gbins.match<-which(gID$lengthbin==l & gID$nsnpbin==s)
                        if(length(gbins.match)>0) gs.samp<-c(gs.samp,sample(gbins.match,nmatch,replace=F))
                    }
                }
            }
              
            if(length(gs.samp)<ng) gs.samp<-c(gs.samp,sample(nrow(gID),ng-length(gs.samp),replace=F)) ### Adding more if there aren't enough

            gs.resamp<-which(d$ID1%in%gID$ID[gs.samp] & d$ID2%in%gID$ID[gs.samp])
            n.gp.tmp<-length(gs.resamp)
            x2.tmp<-sum(d$Z[gs.resamp]^2)/n.gp.tmp
        
            (c(x2.tmp,n.gp.tmp))
        }
        x2.null<-cbind(x2.null,pchisq(x2.null[,1]*x2.null[,2],x2.null[,2],lower.tail=F))
        ## print(summary(x2.null))
        ## length(which(pchisq(x2.null[,1]*x2.null[,2],x2.null[,2],lower.tail=F)<=0.05))
        gsname.short<-tail(strsplit(gsname,"/")[[1]],1)
        ## fwrite(x2.null,file=paste0(trait,"_",tissue,"_",gsname.short,"_GeneSets.nullresampling.txt"),quote=F,sep=" ",row.names=F,col.names=T)
      
        ## Calculate empirical p-value from resampling:
        x2.big<-length(which(x2.null[,1]>=meanZ2sum))
        n.complete<-nrow(x2.null)
        p.val<-x2.big/n.complete

        test<-c(gsname,ng.set,ng,ngs.pairs,Z2sum,Z2p,meanZ2sum,x2.big,n.complete,p.val)
        cat(test,"\n")
        U<-rbind(U,test)
        
    }
}

colnames(U)<-c("GeneSetName","GeneSetSize","GeneSetSizeInTWIS","GeneSetPairsInTWIS","X2","X2_p","X2_mean","Nresamp_larger","Nresamp","resamp_p")
write.table(U,file=opt$output,quote=F,sep=" ",row.names=F,col.names=T)


cat(date(),": Done with analysis, writing output\n")


