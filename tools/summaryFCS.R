rm(list = ls())#清除内存变量
gc()
library(readxl)
projectdir<-"/Users/leeco/rStudio/r2021_05_14_colQuantiles"
metadata_filename <- "PD-RAD_metadata.xlsx"
md <- read_excel(paste0(projectdir, "/", metadata_filename))
md
md$condition <- factor(md$condition, levels = c("B1", "BX", "BE"))
#=============================================================================
## Define colors for conditions
color_conditions <- c("#6A3D9A", "#FF7F00", "#00AA00")
names(color_conditions) <- levels(md$condition)
color_conditions
names(color_conditions)

#=============================================================================
panel_filename <- "PD-RAD_panel.xlsx"
panel <- read_excel(paste0(projectdir, "/", panel_filename))
data.frame(panel)
#=============================================================================
#原文章从网络下载zip，再通过unzip（）函数解压，然后读取
#此处我通过files参数指定需要读取的文件，通过path参数指定读取文件所在目录完成这个过程
library(flowCore)
md$file_name
fcs_raw <- read.flowSet(files = md$file_name, path = projectdir, transformation = FALSE, 
                        truncate_max_range = FALSE)
lapply(1:12, function(x) dim( exprs(fcs_raw[[x]]) ))

expr <- fsApply(fcs_raw, exprs)
f1 = matrix(data = NA, nrow = 12, ncol = 2, byrow = FALSE,dimnames = NULL)
f1[1,] <- dim(exprs(fcs_raw[[1]]))
f1[2,] <- dim(exprs(fcs_raw[[2]]))
f1[3,] <- dim(exprs(fcs_raw[[3]]))
f1[4,] <- dim(exprs(fcs_raw[[4]]))
f1[5,] <- dim(exprs(fcs_raw[[5]]))
f1[6,] <- dim(exprs(fcs_raw[[6]]))
f1[7,] <- dim(exprs(fcs_raw[[7]]))
f1[8,] <- dim(exprs(fcs_raw[[8]]))
f1[9,] <- dim(exprs(fcs_raw[[9]]))
f1[10,] <- dim(exprs(fcs_raw[[10]]))
f1[11,] <- dim(exprs(fcs_raw[[11]]))
f1[12,] <- dim(exprs(fcs_raw[[12]]))
colnames(f1) = c("row","col")
f1 = t(f1)
colnames(f1) = md$file_name
f1 = t(f1)
write.xlsx(x = f1, file = paste0(projectdir, "/colQuantiles", ".xlsx"),
           sheetName = "num", row.names = TRUE, col.names = TRUE,append=TRUE)
rng <- colQuantiles(expr, probs = c(0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.99))
write.xlsx(x = data.frame(panel$antigen, rng), file = paste0(projectdir, "/colQuantiles", ".xlsx"),
           sheetName = paste0("fcs", 0), row.names = TRUE, col.names = TRUE,append=TRUE)
lapply(1:12, function(i){
  rng <- colQuantiles(fcs_raw[[i]]@exprs, probs = c(0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.99))
  write.xlsx(x = data.frame(panel$antigen, rng), file = paste0(projectdir, "/colQuantiles", ".xlsx"),
             sheetName = paste0("fcs", i), row.names = TRUE, col.names = TRUE,append=TRUE)
})
