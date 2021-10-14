# Goal
# This document aims to filter out control-like cells in disease stage dataset 
#
# Notes:
#
# Why use Harmony for integration? 
# 1. Fast and best performances among 14 tools: A benchmark of batch-effect correction methods for single-cell RNA sequencing data
# 2. Seurat cannot handle 500k+ cells.
#
# Why use PCA+PCA for label transfering?
# 1. PCA results are better: https://docs.google.com/spreadsheets/d/1IJBT95FGIXBP05bNOUlFtKlM95aWaVUStCE9EpZ0rgA/edit
# 2. Seurat recommendation: FindTransferAnchors: We recommend using PCA when reference and query datasets are from scRNA-seq
# https://www.rdocumentation.org/packages/Seurat/versions/3.1.4/topics/FindTransferAnchors
# 3. PCA is much faster since it is already calculated.


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
suppressPackageStartupMessages(library(clusterProfiler))
suppressPackageStartupMessages(library(org.Mm.eg.db))


# Do not use multi threads, at least not working in OSC clusters
#plan("multiprocess", workers = 16)
#plan()


args <- commandArgs(TRUE)
wd <- args[1] # working directory
ref_filename <- args[2] # rds seurat object
tar_filename <- args[3] # raw filename

load_test_data <- function(){
  # This function is used for testing
  rm(list = ls(all = TRUE))
  #setwd("C:/Users/flyku/Desktop/script")
  wd <- "/fs/scratch/PCON0022/ad/input/fst"
  ref_filename <- "AD00101"
  tar_filename <- "AD00201"
}

setwd(wd)
source("/fs/scratch/PCON0022/ad/new_code/functions.R")

####### Load raw files
ref_obj <- read_rds(paste0("./rds/",ref_filename,".rds"))

tar_obj <- read_rds(paste0("./rds/",tar_filename,".rds"))

tar_obj <- FindVariableFeatures(tar_obj, selection.method = "vst", nfeatures = 2000)
tar_obj.gene <- rownames(tar_obj)
tar_obj <- ScaleData(tar_obj, features = tar_obj.gene)
tar_obj <- RunPCA(tar_obj, features = VariableFeatures(object = tar_obj))
#tar_obj <- RunLSI(tar_obj, n = 50, scale.max = NULL, verbose = TRUE)
tar_obj <- RunUMAP(tar_obj, reduction = "pca", dims = 1:25)

#gc()
## FindTransferAnchors: We recommend using PCA when reference and query datasets are from scRNA-seq
transfer.anchors <- FindTransferAnchors(reference = ref_obj, query = tar_obj, features = VariableFeatures(object = ref_obj), reduction = "pcaproject",verbose = TRUE)

if(nrow(transfer.anchors@anchors) > 30) {
  celltype.predictions <- TransferData(anchorset = transfer.anchors, refdata = ref_obj$predicted.id, weight.reduction = tar_obj[["pca"]],l2.norm = FALSE,dims = 1:25, k.weight = 30)
} else{
  celltype.predictions <- TransferData(anchorset = transfer.anchors, refdata = ref_obj$predicted.id, weight.reduction = tar_obj[["pca"]],l2.norm = FALSE,dims = 1:25, k.weight = (nrow(transfer.anchors@anchors)-1))
}

#celltype.predictions <- as.factor(tar_obj$orig.ident)
#levels(celltype.predictions) <- 'Excitatory neurons'
#tar_obj <- AddMetaData(tar_obj, metadata = celltype.predictions, col.name = 'predicted.id')

tar_obj <- AddMetaData(tar_obj, metadata = celltype.predictions)

####### Visualize LSI predicted cell types (works for Mathy's data)
#Idents(tar_obj) <- tar_obj$cell_type
#p1 <- Plot.cluster2D(tar_obj, reduction.method = "umap",pt_size = 0.2,txt = "Provided cell type")
#
#Idents(tar_obj) <- tar_obj$predicted.id
#p2 <- Plot.cluster2D(tar_obj, reduction.method = "umap",pt_size = 0.2,txt = "Predicted cell type")
#library(igraph)
#igraph::compare(as.factor(tar_obj$cell_type),as.factor(tar_obj$predicted.id),method="adjusted.rand")
#plot_grid(p1,p2)

Idents(ref_obj) <- ref_obj$predicted.id
p1 <- Plot.cluster2D(ref_obj, reduction.method = "umap",pt_size = 0.4,txt = "Control cell type")

Idents(tar_obj) <- tar_obj$predicted.id
p2 <- Plot.cluster2D(tar_obj, reduction.method = "umap",pt_size = 0.4,txt = "Disease cell type")

png(paste("./png/",tar_filename,"_project_umap.png",sep = ""),width=4000, height=2000,res=300)
plot_grid(p1,p2)
dev.off()

Idents(tar_obj) <- tar_obj$predicted.id
saveRDS(tar_obj, paste0("rds/", tar_filename,"_project.rds"))

exp_data <- GetAssayData(object = tar_obj,slot = "counts")

#write.table(data.frame("Gene"=rownames(exp_data),exp_data,check.names = F),paste("expr/", tar_filename,"_expr.txt",sep = ""), row.names = F,sep="\t",quote=FALSE)

cell_info <- tar_obj$predicted.id
cell_label <- cbind(colnames(tar_obj),as.character(cell_info))
colnames(cell_label) <- c("cell_name","label")
cell_label <- cell_label[order(cell_label[,1]),]
write.table(cell_label,paste("label/", tar_filename,"_cell_label_project.txt",sep = ""),quote = F,row.names = F,sep = "\t")





###
#saveRDS(tar_obj, paste0("rds/", tar_filename,"_project.rds"))
#tar_obj1 <- read_rds(paste0("./rds/AD00201.rds"))
#tar_obj <- read_rds(paste0("./rds/AD00201_project.rds"))
#
#custom_color <-
#  as.character(palette36.colors(36)[-2])[1:12]
#
#level1 <- as.factor(as.character(tar_obj$predicted.id))
#Idents(tar_obj) <- level1
#
#p1 <- DimPlot(tar_obj, reduction = "umap", cols = custom_color)
#
#level2 <- as.factor(as.character(tar_obj1$predicted.id))
#Idents(tar_obj1) <- level2
#
#p2 <- DimPlot(tar_obj1, reduction = "umap", cols = custom_color)
#
#
#this_ari <-
#  igraph::compare(level1,
#                  level2,
#                  method = "adjusted.rand")
