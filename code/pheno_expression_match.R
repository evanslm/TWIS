### Script to merge pheno & expression data into a single file

args = commandArgs(trailingOnly=TRUE)

phenotype <- args[1]
residualized <- args[2]

cat ("########################\n")
cat ("command-line arguments:\n")
print (args)
cat ("########################\n")

#############################################################################
############   1. Read in phenotype data. These only include the rel<0.05 individuals for the phenotype  ############
load(paste0("phenos/",phenotype,".residualized.RDat"),verbose=T)
cat("read in the phenotype\n")
dim(dresid) 


#############################################################################
###########   2. Gene gene names for all genes:
genesID<-read.table(paste0(residualized,"/genelist.txt"),header=F)
ng<-nrow(genesID)
cat("done reading in the gene names\n")
print(ng)



#############################################################################
###########   3. Get individuals with BOTH phenotype and expression data:
g1<-as.character(genesID[1,1])
load(paste0(residualized,"/",g1,"_predicted_residuals.RDat"),verbose=T)
pd<-merge(dresid,d)
pd<-data.frame(pd[,c(1:3)])  ### NOTE THAT THIS HAS THE PHENOTYPE IN THE 3nd COL, in order of the expression data
ids<-geall[,1:2] ### Matrix of IDs, only to use to quickly merge so as to order the retained individuals in next step (4) below
print("done identifying individuals with both pheno and expression data")
print (nrow(geall))
rm(dresid) ## To save space
rm(d)

#############################################################################
###########   4. Reading in gene expression data and merge with phenotype
printn=100

for(tt in 1:ng){  
   
    g1<-as.character(genesID[tt,1])
    
    tryCatch({
        load(paste0(residualized,"/",g1,"_predicted_residuals.RDat"))
        id.exp<-merge(ids,d,sort=F) ### To cut out only the individuals retained in step 3, order in the same way as in step 3
    },error=function(e){cat("ERROR : gene ",tt,", ",conditionMessage(e), "\n")})
    if(!all(geall[,2]==id.exp[,2])){
        cat(paste0("ID Order does not match. gene: ",g1,", index: ",tt))
        quit()
    }
    pd<-cbind(pd,as.numeric(d[,3])) ### to be sure it's numeric
    colnames(pd)[ncol(pd)]<-g1
    
    if(tt %% printn==0){
        print(paste0("Done loading gene ",tt, " of ",ng))
    }
}

if(!ncol(pd)==(nrow(genesID)+3)){
    print ("different numbers of genes for genesID & geall:")
    print (c(nrow(genesID),ncol(geall)))
    quit(save="no")
}



#############################################################################
###########   5. Write out merged file:
save(pd,file=paste0("phenos/",phenotype,".pheno_expression_merged.RDat"))  ### third column of output is the phenotype, all data merged

cat("Nindiv=",nrow(pd),"Ngenes=",nrow(pd)-3,"\n")
