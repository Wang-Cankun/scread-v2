setwd("/fs/scratch/PCON0022/ad/input/fst/label")
source("/fs/scratch/PCON0022/ad/new_code/functions.R")
options(future.globals.maxSize = 8000 * 1024^2)
suppressPackageStartupMessages(library(httr))
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
suppressPackageStartupMessages(library(igraph))
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(Polychrome))

signatures  <-
  preprocess.signatures('/fs/scratch/PCON0022/ad/new_code/custom_marker.csv')
cell_type_name <-
  c(
    'Astrocytes',
    'Endothelial cells',
    'Excitatory neurons',
    'Inhibitory neurons',
    'Microglia',
    'Oligodendrocytes',
    'Oligodendrocyte precursor cells',
    'Pericytes'
  )
names(signatures) <- cell_type_name

custom_color <-
  as.character(palette36.colors(36)[-2])[1:12]

labels <- list.files(pattern = "*_cell_label_project.txt")
ids <- sapply(str_split(labels, "_"), function(x) {x[1]})


i = ids[6]
ari <- vector()
for (i in ids) {
  this_v1_label <- read_tsv(paste0(i, "_cell_label_v2.txt"))
  this_v2_label <- read_tsv(paste0(i, "_cell_label_project.txt"))
  
  this_label <- this_v1_label %>%
    left_join(this_v2_label, by="cell_name")
  this_label[is.na(this_label)] <- "NA"
  
  this_ari <-
    igraph::compare(as.factor(this_label$label.y),
                    as.factor(this_label$label.x),
                    method = "adjusted.rand")
  ari <- c(ari, this_ari)
}


##### Boxplot
library(ggpubr)
ggboxplot(ari, add = "jitter") 


#ids[which(ari<0.1)]
#ids[which(ari<0.2 & ari > 0.1)]

#ids[which(ari<0.6 & ari > 0.3)]


this_id <- "AD00201"
i <- ids[which(ids == this_id)]
### Compare umap
obj <- readRDS(paste0("/fs/scratch/PCON0022/ad/input/fst/rds/", this_id ,".rds"))
this_v1_label <- read_tsv(paste0(i, "_cell_label_v2.txt"))
this_v2_label <- read_tsv(paste0(i, "_cell_label_project.txt"))

this_label <- this_v1_label %>%
  left_join(this_v2_label, by="cell_name")
this_label[is.na(this_label)] <- "NA"
this_label <- as.data.frame(this_label)
rownames(this_label) <- this_label$cell_name
this_label <- this_label[colnames(obj), ]

level1 <- as.factor(as.character(obj$predicted.id))
Idents(obj) <- level1

p1 <- DimPlot(obj, reduction = "umap", cols = custom_color)

obj <- AddMetaData(obj, this_label$label.x, col.name = "v1")
level2 <- as.factor(as.character(obj$v1))
Idents(obj) <- level2

p2 <- DimPlot(obj, reduction = "umap", cols = custom_color)


p2 + p1

FeaturePlot(obj, features = c("Cx3cr1","Tyrobp"))

