install.packages("data.table")
library(data.table)
library(stringr)

###TRIMMING REPORTS
files_tr <- list.files(path="/gpfs/data/genomic-imprinting/Claudia/embryos/srnaseq_data/reports", pattern="*trimming_report.txt", full.names=TRUE, recursive=FALSE)
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

#FASTQC REPORTS
files_fqc <- list.files(path="/gpfs/data/genomic-imprinting/Claudia/embryos/srnaseq_data/reports", pattern="*summary.txt", full.names=TRUE, recursive=FALSE)
names<-as.data.frame(files_fqc)
input_fc<-lapply(files_fqc, read.delim, header=TRUE, stringsAsFactors=FALSE)
l2 <- lapply(input_fc, function(x) {
  i<-data.frame(Samples=x[1:10,3],Description=x[1:10,2],Values=x[1:10,1])
  i<-dcast(i, Samples~ Description)
  i
})
fqc_metrics<-rbindlist(l2)

#ALIGNMENT REPORTS
files_a <- list.files(path="/gpfs/data/genomic-imprinting/Claudia/embryos/srnaseq_data/reports", pattern="*hisat.report.txt", full.names=TRUE, recursive=FALSE)
names<-as.data.frame(files_a)
input_a<-lapply(files_a, read.delim, header=TRUE, stringsAsFactors=FALSE)
l3 <-lapply(input_a, function(x) {
  print(x)
  ar<-sub("overall alignment rate", "",x[5,])
  reads<-sub(".reads..of.these.", "",colnames(x))
  i<-data.frame(Alignment_rate=ar,Total_reads=reads)
  i
})
alignment_metrics<-rbindlist(l3)

##Generate final table
general_metrics<-cbind(fqc_metrics,alignment_metrics)
general_metrics$Reads_with_adapters <- sub("\\(.*", "", tr_metrics$Reads_with_adapters)
general_metrics$Filtered_reads <- sub("\\(.*", "", tr_metrics$Filtered_reads)
general_metrics$condition = str_extract(general_metrics$Samples, "BL|CL2|CL3|O|Sperm")
general_metrics<- lapply(general_metrics, gsub, pattern='X', replacement='')
general_metrics<-lapply(general_metrics, gsub, pattern='%', replacement='')  ##remove the % symbol
general_metrics<-as.data.frame(general_metrics)
write.csv(general_metrics,"/gpfs/data/genomic-imprinting/Claudia/embryos/srnaseq_data/srnaseq_analysis/all_srnaseq_metrics.csv")