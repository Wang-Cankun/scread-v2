# Goal
# This document aims to run Seurat analysis workflow, and export tables in scREAD database format.


options(future.globals.maxSize = 8000 * 1024^2)
suppressPackageStartupMessages(library(fst))
suppressPackageStartupMessages(library(Seurat))
suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(Polychrome))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(harmony))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(future))

## Do not use it, not working in OSC clusters
## Set multi-thread for Seurat
#plan("multiprocess", workers = 16)
#plan()

args <- commandArgs(TRUE)
wd <- args[1] # working directory
a_data_id <- args[2] # raw user filename
b_data_id <- args[3] # raw user filename

load_test_data <- function(){
  rm(list = ls(all = TRUE))
  #setwd("C:/Users/flyku/Desktop/ad/new/")
  wd <- "/fs/scratch/PAS1475/ad/input/rds_old"
  #B is usually disease object, A is healthy object
  a_data_id <- "AD00901"
  b_data_id <- "AD00802"
  
  # control, early age, female on the left side, A column
  # disease, late age, male groups are on the right side, B column
}

#source("C:/Users/flyku/Desktop/ad/code/functions.R")

setwd(wd)
a_expr_file <- paste0(a_data_id,".rds")
b_expr_file <- paste0(b_data_id,".rds")

####### Load raw files
a.obj <- readRDS(a_expr_file)
#b.obj <- readRDS(b_expr_file)

a.obj <- NormalizeData(a.obj)
#b.obj <- NormalizeData(b.obj)

##Tmp save
Idents(a.obj) <- a.obj$predicted.id
saveRDS(a.obj, paste0("../",a_data_id,".rds"))
a_data <- GetAssayData(object = a.obj,slot = "counts")
write.table(data.frame("Gene"=rownames(a_data),a_data,check.names = F),paste("../",a_data_id,"_expr.txt",sep = ""), row.names = F,sep="\t",quote=FALSE)

