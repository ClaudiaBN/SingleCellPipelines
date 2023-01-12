#BiocManager::install("Rsubread")
library(Rsubread)

samples<-list.files(path = "/gpfs/data/genomic-imprinting/Claudia/embryos/srnaseq_data/alignments", pattern ="sorted.bam",             
                    full.names = TRUE)
featurecounts_gtf<-featureCounts(files=samples,
                                 annot.ext="/gpfs/data/genomic-imprinting/Claudia/embryos/annotation/Homo_sapiens.GRCh38.107.gtf",
                                 isGTFAnnotationFile=TRUE,GTF.featureType="gene",GTF.attrType="gene_id",isPairedEnd=FALSE)

gene_length_gtf<-as.data.frame(featurecounts_gtf$annotation$Length)
counts_gtf<-as.data.frame(featurecounts_gtf$counts)
saveRDS(counts_gtf, file = "/gpfs/data/genomic-imprinting/Claudia/embryos/srnaseq_data/srnaseq_analysis/counts.rds")
saveRDS(gene_length_gtf, file = "/gpfs/data/genomic-imprinting/Claudia/embryos/srnaseq_data/srnaseq_analysis/gene_length.rds")
