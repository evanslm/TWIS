### Script to residualize imputed gene expression

library(RcppArmadillo)
library(optparse)


option_list = list(
  make_option("--pred_scores", action="store", default=NA, type='character',
              help="location of predicted expression missing"),
  make_option("--resid_out", action="store", default=NA, type='character',
              help="location of residualized expression is missing"),
  make_option("--covar", action="store", default=NA, type='character',
              help="covariate file missing"),
  make_option("--verbose", action="store", default=FALSE, type='character',
              help="print out for each gene") 
 )

  

opt = parse_args(OptionParser(option_list=option_list))

cat("predicted expression in: ", opt$pred_scores,"\n")
cat("writing residualized expression in: ", opt$resid_out,"\n")
cat("covariate file: ", opt$covar,"\n")



## opt=list(
##     covar="SIMULATE",
##     pred_scores="predicted/",
##     resid_out="residualized/",
## )



# Get list of genes with predicted expression
genelist<-as.vector(read.table(paste0(opt$pred_scores,"/predicted.genelist.txt"),header=F)[,1])

                
# Read in covariates: column names FID,IID,c1,c2...
if(opt$covar=="SIMULATE"){  ### If no covariates, and simulation desired, just simulate some values for the individuals
    covs<-read.table(paste0(opt$pred_scores,"/",as.character(genelist[1]),".pred.sscore"),header=F)
    covs<-covs[,1:2]
    colnames(covs)<-c("FID","IID")
    set.seed(10)
    covs$cov1<-rnorm(nrow(covs))
    covs$cov2<-rnorm(nrow(covs))
    covariates<-colnames(covs)[3:ncol(covs)]
} else if(!is.na(opt$covar)){
    covs<-read.table(opt$covar,header=T)
    covariates<-colnames(covs)[3:ncol(covs)]
} else{
    cat("no covariates to residualize on\n")
    quit("no")
}



# Residualize each gene in turn
for(gg in 1:length(genelist)){
    gene<-as.character(genelist[gg])
    if(opt$verbose) print(paste0("Beginning residualizing gene expression of gene ",gg," ",gene))    

    g<-read.table(paste0(opt$pred_scores,"/",gene,".pred.sscore"),header=F)
    g<-g[,c(1:2,5)]
    colnames(g)<-c("FID","IID","SCORE1_AVG")

    gc<-na.omit(merge(g,covs))
        
    f<-as.formula(paste("SCORE1_AVG",paste(covariates,collapse="+"),sep="~"))
    fit<-fastLm(f,data=gc)  ### regressing the locus genotype on all the covariate PCs


    ## Get the residuals from the above regression, standardize them to N(0,1)
    FID<-as.character(gc$FID)
    IID<-as.character(gc$IID)
    resids<-as.numeric(scale(residuals(fit)))
    d<-cbind(as.character(FID),as.character(IID),resids)
    colnames(d)<-c("FID","IID",gene)
    save(d,file=paste0(opt$resid_out,"/",gene,"_predicted_residuals.RDat"))
    if(opt$verbose) cat(paste0("Completed gene ",gg,": ",gene,"\n"))    
}


cat(c("\nResidualized expression of ",length(genelist)," genes written to:", opt$resid_out,"\n"))
