
#This script maps genomic features to coverage files (.cov) generated by bismark aligner and methylation extractor and creates plots for visualisation.

#Reading the coverage files. The type of sample (sperm, blood, oocyte/O, day 2/CL2, day 3/CL3, blastocyst from inner cell mass 
#or trophectoderm/BL.ICM/BL.TE) should be specified at the beginning of their filename (e.g., O.12.gz.bismark.edited.cov)

#Get file paths
files_cov <- list.files(path="/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/alignments/methylation_files/CpG_methylation", pattern="*cov", full.names=TRUE, recursive=FALSE)
#Read the files
input_cov2<-lapply(files_cov, read.delim, header=FALSE, stringsAsFactors=FALSE,sep=" ")
#Get file names
samples<-data.frame(samples=list.files(path = "/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/alignments/methylation_files/CpG_methylation", pattern ="cov", 
                    full.names = FALSE))

##Read and edit Feature annotations

anno_cpgs <- read.delim("/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/annotation/cpgIslandExt_edited.txt",header = FALSE)
anno_sines <- read.delim("/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/annotation/repeats_hg.18_rmsk_SINE_edited.txt",header = FALSE)
anno_lines <- read.delim("/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/annotation/repeats_hg.18_rmsk_LINE_edited.txt",header = FALSE)
anno_ltrs <- read.delim("/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/annotation/repeats_hg.18_rmsk_LTR_edited.txt",header = FALSE)

anno_sines_df<-data.frame(start=anno_sines$V2,end=anno_sines$V3,chr=anno_sines$V1)
anno_sines_df<-data.table(anno_sines_df)

anno_lines_df<-data.frame(start=anno_lines$V2,end=anno_lines$V3,chr=anno_lines$V1)
anno_lines_df<-data.table(anno_lines_df)

anno_ltrs_df<-data.frame(start=anno_ltr$V2,end=anno_ltr$V3,chr=anno_ltr$V1)
anno_ltrs_df<-data.table(anno_ltr_df)

anno_cpgs_df<-data.frame(start=anno_cpgs$V2,end=anno_cpgs$V3,chr=anno_cpgs$V1)
anno_cpgs_df<-data.table(anno_cpgs_df)

##Mapping methylation in CpG context repeats (global)

res<-NULL
global<-lapply(input_cov, function(x) {
  x<-na.omit(x)
  sample<-data.frame(x$V1,x$V2,x$V7)
  names(sample)<-c("chr","pos","methylation")
  met<-sum(sample$methylation)
  per_met<-met*100/length(sample$methylation)
  res<-rbind(res,per_met)
  res
})
df_global<-data.frame(methylation_percentage=unlist(global),sample=samples$samples)
df_global$sample_type<-as.factor(str_extract(df_global$sample,"blood|sperm|O|CL2|CL3|ICM|TE"))
df_global$cell<-gsub(".gz.bismark.edited.cov","",df_global$sample)
df_global$embryo<-gsub(".a|.b|.c|.d|.e|.f|.g|.h|.i|.j|.k|.l|.m|.r","",df_global$cell)
df_global_ordered<-df_global
df_global_ordered<- left_join(data.frame(sample_type = c("sperm","O","CL2","CL3","ICM","TE","blood")),df_global_ordered,by = "sample_type")
df_global_ordered$embryo <- factor(df_global_ordered$embryo, levels = unique(df_global_ordered$embryo))

#Plot global methylation in CpG context

dir.create("/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/Plots")
pdf(file = "/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/Plots/global_methylation.pdf", width = 8, height = 4) 
ggplot(df_global_ordered, aes(x = embryo, y = methylation_percentage, color = sample_type)) +
  geom_point(size=2.5) + ylim(0,100)+theme_classic2()+ggtitle("Global Methylation in CpG context")+ylab("% Methylation")+
  stat_summary(geom = "pointrange", fun.data = mean_sdl, fun.args = list(mult = 1),colour = "black",size=0.2) +
  scale_color_manual(values=c("darkorchid3","seagreen4","brown3","gray70","chocolate2", "dodgerblue2","burlywood4"))
dev.off()

#Mapping methylation in CpG context to SINE repeats

res<-NULL
sines <- lapply(input_cov, function(x) {
  names(x)<-c("chr","position","position2","methylation_percentage","count_methylated","count_unmethylated","methylation_percentage_binarised")
  cov_df<-data.frame(pos=x$position,pos2=x$position2,chr=x$chr)
  cov_df<-data.table(cov_df)
  joined<-cov_df[anno_sines_df, on = .(chr==chr, pos >= start, pos <= end),allow.cartesian=TRUE]
  joined$methylation <-x$methylation_percentage_binarised[match(joined$pos2,x$position)]
  names(joined)<-c("start","pos","chr","end","methylation")
  joined_filtered<-na.omit(joined)
  per_met<-sum(joined_filtered$methylation)*100/length(joined_filtered$methylation)
  res<-rbind(res,per_met)
})
df_sines<-data.frame(methylation_percentage=unlist(sines),sample=samples$samples)
df_sines$sample_type<-as.factor(str_extract(df_sines$sample,"blood|sperm|O|CL2|CL3|ICM|TE"))
df_sines$cell<-sub(".gz.bismark.edited.cov","",df_sines$sample)
df_sines$embryo<-sub("\\.[^.]*[a-z]$", "", df_sines$cell)
df_sines_ordered<-df_sines
df_sines_ordered<- left_join(data.frame(sample_type = c("sperm","O","CL2","CL3","ICM","TE","blood")),df_sines_ordered,by = "sample_type")
df_sines_ordered$embryo <- factor(df_sines_ordered$embryo, levels = unique(df_sines_ordered$embryo))

#Plot methylation for SINE repeats in CpG context

pdf(file = "/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/Plots/sine_methylation.pdf", width = 8, height = 4)
ggplot(df_sines_ordered, aes(x = embryo, y = methylation_percentage, color = sample_type)) +
  geom_point(size=2.5) + ylim(0,100)+theme_classic2()+ggtitle("Methylation in SINE repeats in CpG context")+ylab("% Methylation")+
  stat_summary(geom = "pointrange", fun.data = mean_sdl, fun.args = list(mult = 1),colour = "black",size=0.2) +
  scale_color_manual(values=c("darkorchid3","seagreen4","brown3","gray70","chocolate2", "dodgerblue2","burlywood4"))
dev.off()

#Mapping methylation in CpG context to LINE repeats

res<-NULL
lines <- lapply(input_cov, function(x) {
  names(x)<-c("chr","position","position2","methylation_percentage","count_methylated","count_unmethylated","methylation_percentage_binarised")
  cov_df<-data.frame(pos=x$position,pos2=x$position2,chr=x$chr)
  cov_df<-data.table(cov_df)
  joined<-cov_df[anno_lines_df, on = .(chr==chr, pos >= start, pos <= end),allow.cartesian=TRUE]
  joined$methylation <-x$methylation_percentage_binarised[match(joined$pos2,x$position)]
  names(joined)<-c("start","pos","chr","end","methylation")
  joined_filtered<-na.omit(joined)
  per_met<-sum(joined_filtered$methylation)*100/length(joined_filtered$methylation)
  res<-rbind(res,per_met)
})
df_lines<-data.frame(methylation_percentage=unlist(lines),sample=samples$samples)
df_lines$sample_type<-as.factor(str_extract(df_lines$sample,"blood|sperm|O|CL2|CL3|ICM|TE"))
df_lines$cell<-sub(".gz.bismark.edited.cov","",df_lines$sample)
df_lines$embryo<-sub("\\.[^.]*[a-z]$", "", df_lines$cell)
df_lines_ordered<-df_lines
df_lines_ordered<- left_join(data.frame(sample_type = c("sperm","O","CL2","CL3","ICM","TE","blood")),df_lines_ordered,by = "sample_type")
df_lines_ordered$embryo <- factor(df_lines_ordered$embryo, levels = unique(df_lines_ordered$embryo))

#Plot methylation for LINE repeats in CpG context

pdf(file = "/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/Plots/line_methylation.pdf", width = 8, height = 4) 
ggplot(df_lines_ordered, aes(x = embryo, y = methylation_percentage, color = sample_type)) +
  geom_point(size=2.5) + ylim(0,100)+theme_classic2()+ggtitle("Methylation in LINE repeats")+ylab("% Methylation")+
  stat_summary(geom = "pointrange", fun.data = mean_sdl, fun.args = list(mult = 1),colour = "black",size=0.2) +
  scale_color_manual(values=c("darkorchid3","seagreen4","brown3","gray70","chocolate2", "dodgerblue2","burlywood4"))
dev.of()

#Mapping methylation in CpG context to LTR repeats

res<-NULL
ltrs <- lapply(input_cov, function(x) {
  names(x)<-c("chr","position","position2","methylation_percentage","count_methylated","count_unmethylated","methylation_percentage_binarised")
  cov_df<-data.frame(pos=x$position,pos2=x$position2,chr=x$chr)
  names(cov_df)<-c("pos","pos2","chr")
  cov_df<-data.table(cov_df)
  joined<-cov_df[anno_ltrs_df, on = .(chr==chr, pos >= start, pos <= end),allow.cartesian=TRUE]
  joined$methylation <-x$methylation_percentage_binarised[match(joined$pos2,x$position)]
  names(joined)<-c("start","pos","chr","end","methylation")
  joined_filtered<-na.omit(joined)
  per_met<-sum(joined_filtered$methylation)*100/length(joined_filtered$methylation)
  res<-rbind(res,per_met)
})
df_ltrs<-data.frame(methylation_percentage=unlist(ltrs),sample=samples$samples)
df_ltrs$sample_type<-as.factor(str_extract(df_ltrs$sample,"blood|sperm|O|CL2|CL3|ICM|TE"))
df_ltrs$cell<-sub(".gz.bismark.edited.cov","",df_ltrs$sample)
df_ltrs$embryo<-sub("\\.[^.]*[a-z]$", "", df_ltrs$cell)
df_ltrs_ordered<-df_ltrs
df_ltrs_ordered<- left_join(data.frame(sample_type = c("sperm","O","CL2","CL3","ICM","TE","blood")),df_ltrs_ordered,by = "sample_type")
df_ltrs_ordered$embryo <- factor(df_ltrs_ordered$embryo, levels = unique(df_ltrs_ordered$embryo))

#Plot methylation for LTR repeats in CpG context

pdf(file = "/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/Plots/ltr_methylation.pdf", width = 8, height = 4) 
ggplot(df_ltrs_ordered, aes(x = embryo, y = methylation_percentage, color = sample_type)) +
  geom_point(size=2.5) + ylim(0,100)+theme_classic2()+ggtitle("Methylation in LTR repeats")+ylab("% Methylation")+
  stat_summary(geom = "pointrange", fun.data = mean_sdl, fun.args = list(mult = 1),colour = "black",size=0.2) +
  scale_color_manual(values=c("darkorchid3","seagreen4","brown3","gray70","chocolate2", "dodgerblue2","burlywood4"))
dev.off()

#Design theme for plot aesthetics

theme_classic2 <- function(base_size = 12, base_family = ""){
  theme_bw(base_size = base_size, base_family = base_family) %+replace%
    theme(
      panel.grid.major = element_line(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.minor.y = element_blank(),
      plot.title = element_text(hjust = 0.5,face="bold"),
      axis.title.x=element_blank(),
      axis.ticks.x=element_blank(),
      axis.title.y=element_text(angle=90,hjust = 0.5,face="bold"),
      axis.text.x = element_blank(),
      legend.title=element_blank()
      #legend.position = "none"
    )
}
