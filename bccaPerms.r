# Loading the libs in case one doesn't have those
userlibpath <- '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/R'
#dir.create(userlibpath)
#install.packages(c('bitops','R.methodsS3','R.oo','rmatio','CCAGFA','glmnet','R.matlab','R.utils'),userlibpath,repos<-'http://mirrors.dotsrc.org/cran/')
suppressPackageStartupMessages(library(CCAGFA,lib.loc = userlibpath))
suppressPackageStartupMessages(library(glmnet,lib.loc = userlibpath))
suppressPackageStartupMessages(library(R.matlab,lib.loc = userlibpath))
suppressPackageStartupMessages(library(R.methodsS3,lib.loc = userlibpath))
suppressPackageStartupMessages(library(R.oo,lib.loc = userlibpath))
suppressPackageStartupMessages(library(R.utils,lib.loc = userlibpath))
suppressPackageStartupMessages(library(bitops,lib.loc = userlibpath))
suppressPackageStartupMessages(library(rmatio,lib.loc = userlibpath))
suppressPackageStartupMessages(library(oro.nifti,lib.loc = userlibpath))
# ----- parameters -----# 
#1 convthresh     0.6
#2 nruns          4                                                                           
#3 ntask          4                                                                           
#4 TR             2.5                                                                         
#5 K              50                                                                          
#6 downsamp       1                                                                           
#7 dsampfolder    "downsampled"
#8 dataroot       "/triton/becs/scratch/braindata/shared/TouchHyperScan"                      
#9 lambda         Numeric,7                                                                  
#10 token          "MOTOR"                                                                     
#11 sender         "SubjectA"                                                                  
#12 receiver       "SubjectO"
if (!interactive()){
  args <- commandArgs(T)
  stopifnot(length(args) == 3)
  cfgpath <- args[1]
  shuffle_group <- args[2]
  op <- args[3]
} else {
  cfgpath <- '/triton/becs/scratch/braindata/shared/GraspHyperScan/hyper/MOTOR/Sonya_Actor/Sonya_Observer/permcfg_cca.mat'
}
params <- readMat(cfgpath,header=FALSE)$cfg
cfg_frame = data.frame(params)[[1]] # hack to make it into key:value
# Unpack parameters
K <- as.numeric(cfg_frame$K)
cvs <- 1:as.numeric(cfg_frame$nruns)
dataroot <- as.character(cfg_frame$dataroot)
partoken <- as.character(cfg_frame$token)
clsdata <- as.character(cfg_frame$sender)
obsdata <- as.character(cfg_frame$receiver)
dsampfolder <- as.character(cfg_frame$dsampfolder)

## load data
dobs <- readMat(sprintf('%s/Tokens/%s/%s_4mm.mat',dataroot,partoken,obsdata))$dO
dcls <- readMat(sprintf('%s/Tokens/%s/%s_4mm.mat',dataroot,partoken,clsdata))$dO
labels_num <- readMat(sprintf('%s/%s/dL2.mat',dataroot,obsdata))$tosave
# assuming all five runs in datasets
n <- length(labels_num)
n_per_run <- n/as.numeric(cfg_frame$ntask)
ind_lab <- labels_num != 0
# make empty matrix
fullmaskprojection <- matrix(0,nrow = dim(dcls)[1],ncol = dim(dcls)[2])

## Data shuffling, shuffle datapoint order of observer to lose the match between actor and observer. 
temp = as.matrix(sample(1:n,size=n,replace=FALSE))
dobs=dobs[temp,]

for (cvi in cvs){
  cat(sprintf('CV round %d\n', cvi))
  train_sel <- rep(T, n)
  train_sel[(1:n_per_run)+(cvi-1)*n_per_run] <- F
  test_sel <- !train_sel
  # learn CCA mapping (using all time points, i.e., including labeless points, unless they have been dropped in prepare_data.m)
  cat('Fitting CCA\n')
  opts <- getDefaultOpts()
  opts$verbose <- 0
  ccafit <- GFAexperiment(list(dcls[train_sel & ind_lab,],dobs[train_sel & ind_lab,]), K, opts)
  cat('Predicting\n')
  # predict "clsdata"-space representation for predata using the CCA mapping
  fullmaskprojection[test_sel,] <- GFApred(c(0,1), list(0*dobs[test_sel & ind_lab,],dobs[test_sel & ind_lab,]), ccafit, sample=F)$Y[[1]]
}
writeMat(sprintf('%s/hyper/%s/%s/%s/perms_cca/dataPerm%i.mat',dataroot,partoken,clsdata,obsdata,as.numeric(op)),fullmaskprojection=fullmaskprojection)
####
####
# Call matlab, its tricky here
setwd('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools')
p1 <- 'matlab -nosplash -nodisplay -nojvm -nodesktop -r '
p2 <- sprintf("mvlaPermutation('%s',%i,'hyper_cca',%i)",cfgpath,as.numeric(shuffle_group),as.numeric(op))
syscall <- paste(p1,'"',p2,'"',sep="")
system(syscall)
####
####

















