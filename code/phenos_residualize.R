### Script to residualize phenotypes

args = commandArgs(trailingOnly=TRUE)
phenotype=args[1]
covariate<-args[2]
simpheno<-args[3]


           
# Read in phenotype: column names FID,IID,phenotypename
if(phenotype=="SIMULATE"){  ### If no phenotype, and simulation desired, just simulate some values for the individuals
    pheno<-read.table("1kg/eur.21.keep.psam",header=F)
    pheno<-pheno[,1:2]
    colnames(pheno)<-c("FID","IID")
    set.seed(32) ## To match the github results
    if(simpheno=="norm") pheno$random.pheno<-rnorm(nrow(pheno))
    if(simpheno=="binom") pheno$random.pheno<-rbinom(nrow(pheno),1,0.5)
    p<-colnames(pheno)[3]
} else{
    pheno<-read.table(phenotype,header=T)
    p<-colnames(pheno)[3]
} 


                
# Read in covariates: column names FID,IID,c1,c2...
if(covariate=="SIMULATE"){  ### If no covariates, and simulation desired, just simulate some values for the individuals
    covs<-read.table("1kg/eur.21.keep.psam",header=F)
    covs<-covs[,1:2]
    colnames(covs)<-c("FID","IID")
    set.seed(10) ## To match the github results
    covs$cov1<-rnorm(nrow(covs))
    covs$cov2<-rnorm(nrow(covs))
    covariates<-colnames(covs)[3:ncol(covs)]
} else {
    covs<-read.table(opt$covar,header=T)
    covariates<-colnames(covs)[3:ncol(covs)]
}


# Residualize the phenotypes on covariates:
d<-merge(pheno,covs)

f<-as.formula(paste(p,paste(covariates,collapse="+"),sep="~"))

if(all(sort(unique(as.numeric(as.matrix(d)[,p])))==c(0,1))){ ### If it's a binomially distributed trait
    fitlog<-glm(f,data=d,family='binomial')
    logfitted<-cbind(d[,1:2],residuals(fitlog))
    colnames(logfitted)<-c("FID","IID",phenotype)
    write.table(logfitted,paste0("phenos/",phenotype,".residualized.txt"),col.names=T,row.names=F,quote=F,sep="\t")

}else{ ### if it's a continuous trait
    fit<-lm(f,data=d)
    dresid<-d[,1:2]
    dresid$resids<-residuals(fit) ### Get the residuals from the above regression
    colnames(dresid)[1:3]<-c("FID","IID",phenotype)
    write.table(dresid,paste0("phenos/",phenotype,".residualized.txt"),col.names=T,row.names=F,quote=F,sep="\t")
}


