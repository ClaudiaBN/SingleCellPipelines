#install.packages("data.table")
#install.packages("stringr")
library(data.table)
library(stringr)

#TRIMMING REPORTS
#paired end data but treating it as single end**
files_tr <- list.files(path="/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/reports", pattern="*trimming_report.txt", full.names=TRUE, recursive=FALSE)
names<-data.frame(files_tr)
input_tr<-lapply(files_tr, read.delim, header=TRUE, stringsAsFactors=FALSE)
l1 <-lapply(input_tr, function(x) {
  removed_reads<-sub("Sequences removed because they became shorter than the length cutoff of 50 bp:", "",tail(x, n=1))
  total_reads<-sub("Total reads processed:","",x[22,])
  reads_with_adapters<-sub("Reads with adapters:","",x[23,])
  names<-sub("Input filename:", "",x[2,])
  i<-data.frame(Samples=names,Total_reads=total_reads, Reads_with_adapters=reads_with_adapters,Filtered_reads=removed_reads)
  i
})
tr_metrics<-rbindlist(l1,fill=TRUE)
##FASTQC REPORTS
files_fqc <- list.files(path="/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/reports", pattern="*summary.txt", full.names=TRUE, recursive=FALSE)
names<-as.data.frame(files_fqc)
input_fqc<-lapply(files_fqc, read.delim, header=TRUE, stringsAsFactors=FALSE)
l2 <- lapply(input_fqc, function(x) {
  i<-data.frame(Samples=x[1:10,3],Description=x[1:10,2],Values=x[1:10,1])
  print(i)
  i<-dcast(i, Samples~ Description)
  i
})

fqc_metrics<-rbindlist(l2,fill=TRUE)

###ALIGNMENT REPORTS
files_a <- list.files(path="/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/reports", pattern="*SE_report.txt", full.names=TRUE, recursive=FALSE)
input_a<-lapply(files_a, read.delim, header=TRUE, stringsAsFactors=FALSE)
l3 <- lapply(input_a, function(x) {
  sample<-sub(".fq.gz..version..v0.22.3.", "",colnames(x))
  sample<-sub("Bismark.report.for..", "",sample)
  i<-data.frame(Samples=sample,Total_sequences=x[6,],Uniquely_mapped_reads=x[8,],Mapping_efficiency=x[10,],C_methylated_in_CpG_context=x[51,],C_methylated_in_CHG_context=x[53,],
                C_methylated_in_CHH_context=x[55,],C_methylated_in_unknown_CN_CHN_context=x[57,])
  i
})

alignment_metrics<-rbindlist(l3)

##DUPLICATION REPORTS 
files_d <- list.files(path="/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/reports", pattern="*deduplication_report.txt", full.names=TRUE, recursive=FALSE)
input_d<-lapply(files_d, read.delim, header=TRUE, stringsAsFactors=FALSE)
l4 <- lapply(input_d, function(x) {
  sample<-sub("_bismark_bt2.bam.", "",colnames(x[1]))
  sample<-sub("Total.number.of.alignments.analysed.in.", "",sample)
  dup<-stringr::str_extract(string = x[1,],pattern = "(?<=\\().*(?=\\))")
  i<-data.frame(Samples=sample,duplication=dup[2])
  i
})
duplication_metrics<-rbindlist(l4)
##METHYLATION REPORTS
files_m <- list.files(path="/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/reports", pattern="*splitting_report.txt", full.names=TRUE, recursive=FALSE)
input_m<-lapply(files_m, read.delim, header=TRUE, stringsAsFactors=FALSE)
l5 <- lapply(input_m, function(x) {
  sample<-sub("_bismark_bt2.deduplicated.bam.", "",colnames(x[1]))
  dup<-stringr::str_extract(string = x[1,],pattern = "(?<=\\().*(?=\\))")
  i<-data.frame(Samples=sample,C_methylated_in_CpG_context_dedup=x[24,],C_methylated_in_CHG_context_dedup=x[26,],
                C_methylated_in_CHH_context_dedup=x[28,])
  i
})
methylation_metrics<-rbindlist(l5)
##Generate final table
general_metrics<-cbind(fqc_metrics,alignment_metrics[,2:8],duplication_metrics[,2],methylation_metrics[,2:4])
general_metrics$Reads_with_adapters <- sub("\\(.*", "", tr_metrics$Reads_with_adapters)
general_metrics$Filtered_reads <- sub("\\(.*", "", tr_metrics$Filtered_reads)
general_metrics$condition = str_extract(general_metrics$Samples, "BL|CL2|CL3|O|Sperm")
general_metrics<-lapply(general_metrics, gsub, pattern='%', replacement='')  ##remove the % symbol
general_metrics<-as.data.frame(general_metrics)
write.csv(general_metrics,"/gpfs/data/genomic-imprinting/Claudia/embryos/smethyl_seq/scmethylseq_analysis/all_scmethylseq_metrics.csv")
