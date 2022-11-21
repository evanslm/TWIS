####   Script to run TWIS analyses
## To run interactively, use the opt list below
## opt=list(
##     phenotype="SIMULATE",
##     residualized="residualized/",
##     results="results/",
##     ncore=6,
##     part=1,
##     nparts=100,
## )



library(data.table)
library(optparse)
library(Matrix)
library(RcppArmadillo)
library(foreach)
library(iterators)
library(doMC)

option_list = list(
  make_option("--phenotype", action="store", default=NA, type='character',
              help="phenotype missing"),
  make_option("--residualized", action="store", default=NA, type='character',
              help="residualized expression directory missing"),
  make_option("--results", action="store", default="results/", type='character',
              help="results directory missing"),
  make_option("--ncore", action="store", default=1, type='numeric',
              help="number of threads to use"),  
  make_option("--part", action="store", default=NA, type='numeric',
              help="part number missing"),  
  make_option("--nparts", action="store", default=100, type='numeric',
              help="total number of analysis parts missing")
 )
opt = parse_args(OptionParser(option_list=option_list))

registerDoMC(cores=opt$ncore)


#############################################################################
############   1. Load in phenotype & expression data.
cat("Loading all pheno & expression data:\n")
load(paste0("phenos/",opt$phenotype,".pheno_expression_merged.RDat"),verbose=T)  ### object is 'pd'
cat("All pheno & expression data loaded in memory, dimensions:\n")
cat(paste0("Sample size N=",nrow(pd),"\n"))

#############################################################################
###########   2. Gene gene names for running pairwise comparisons:
genesID<-read.table(paste0(opt$residualized,"/genelist.txt"),header=F)
n<-nrow(genesID)

#############################################################################
###########   3. set up pairwise gene interaction tests FOR THIS PART ONLY, INDEXED BY GENE NUMBER:
g_pairs<-NULL
a<-1:n
n.total.tests<-choose(n,2)  ### Total number of tests to run for full genome
ntests<-round(n.total.tests/opt$nparts)  ### number of tests within this part

startg<-(opt$part-1)*ntests+1
endg<-opt$part*ntests
if(opt$part==opt$nparts) endg<-n.total.tests

for(i in startg:endg){	
	m=n*(n-1)/2  #same as choose (n+1,2)
	y=m-i
	d<-1+floor( ( (8*y+1)^.5 - 1) / 2)
	k=n-d
	g_pairs<-rbind(g_pairs, c(a[k], a[i+k+d*(d+1)/2 - m]))
}
cat("done with creating the pairs, indexed by gene number\n")
dim(g_pairs)


#############################################################################
###########   4.  Run interaction tests:
printn<-100  ### Step to print out progress to stdout

date()
U<-foreach(tt=1:opt$ncore,.combine=rbind)%dopar%{
    tstart<-(tt-1)*floor(nrow(g_pairs)/opt$ncore)+1
    tend<-tt*floor(nrow(g_pairs)/opt$ncore)
    if(tt==opt$ncore) tend<-nrow(g_pairs)
    R<-NULL

    for(ii in tstart:tend){
        ii1<-g_pairs[ii,1]
        ii2<-g_pairs[ii,2]
        g1<-as.character(genesID[ii1,1])
        g2<-as.character(genesID[ii2,1])
        
        variables<-c(g1,g2,paste0(g1,"*",g2))
        f<-as.formula(paste(opt$phenotype,paste(variables,collapse="+"),sep="~"))
        fit<-fastLm(f,data=pd)          
        
        ## ## to test rank of model matrix, M:
        ## M<-pd[,variables[1:2]];M$inx<-M[,1]*M[,2]
        ## if(rankMatrix(M)!=3) cat("Matrix not full rank, treat with caution:", variables,"\n")
        
        cs<-cbind(c(g1,g2,paste0(g1,"X",g2)),g1, g2, coef(summary(fit))[2:4,])
        R<-rbind(R,cs)
        ## if(ii %% printn==0){
        ##     print(paste0("Chunk ", part,"_",tt,", Completed pair number ",ii))
        ## }
        
    }
    (R)
}
cat("done running TWIS\n")
cat("output: ",dim(U),"\n")

#############################################################################
###########   5. Write out the results
#save(U,file=paste0(opt$results,opt$phenotype,".",opt$nparts,".",opt$part,".RDat"))
write.table(U, paste0(opt$results,opt$phenotype,".",opt$nparts,".",opt$part,".txt"), quote = F, col.names = T, row.names = F, sep = "\t")

print(paste0("completed part ", opt$part," of ",opt$nparts))

