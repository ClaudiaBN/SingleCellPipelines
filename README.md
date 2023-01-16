# SingleCellPipelines
## Description
Source code for the implementation of scMethyl-seq and scRNA-seq pipelines in a CLUSTER using SLURM.
## Prerequisites
The following programs need to be installed (This pipeline was run using the shown version):
<ol>
<li>Trimgalore (v0.6.5)</li>
<li>Bismark (v0.22.3)</li>
<li>Bowtie2 (v2.3.5.1)</li>
 <li>Samtools (v1.11)</li>
 <li>HISAT2 (v2.1.0)</li>
 <li>R (v4.0.0)</li>
 <li>Miniconda3</li>
</ol>

### scMethyl-SEQ pipeline
Input .fastq.gz files have to be gathered together in a directory. The script scell_methylseq_pipeline.sub has to be run from that directory. 
#### 1. Quality assessment and adapter trimming
Read quality was assessed using software FASTQC and trimgalore.
#### 2. Alignment, duplication removal and methylation extraction
These 3 steps were performed using the Bisulfite Read Mapper and Methylation Caller Bismark. Alignment to the reference genome (hg38) was performed in single-end mode to increase the mapping efficiency.
Methylation call files were processed so methylation states were binarised: methylation < 0.1 was set to 0 (unmethylated cytosine), methylation > 0.1 and < 0.9 was set to 0.5 (equivalent to allelic methylation) and methylation > 0.9 was set to 1 (methylated cytosine).
#### 3. Generating summary table
Quality, alignment and methylation metrics were gathered in a table for analysis/filtering.
#### 4. Mapping coverage files to different genomic features
Binarised methylation calls (.cov files generated with bismark) were mapped to the following features using coordinates from the hg38 human genome:

CpG islands (available from UCSC). 
Gene promoter regions in CpG islands (available from UCSC): promoters were classified according to CpG island density (high meidum and low), following the criteria described by Xie et al. (https://pubmed.ncbi.nlm.nih.gov/23664764/).
Enhancers class I and class II (see Alvaro Rada-Iglesias et al., https://www.nature.com/articles/nature09692).
Solo WCGW CpGs (see Zhou et al., https://zwdzwd.github.io/pmd)
LINE, SINE and LTR repeats (available from UCSC browser, using RepeatMasker).

#### Annotation files


### scRNA-SEQ pipeline
#### 1. Quality assessment and adapter trimming
Read quality was assessed using software FASTQC and trimgalore.
#### 2. Alignment
Alignment was performed using HISAT2.
#### 3. Generating summary table
Quality and alignment were gathered in a table for analysis/filtering.
#### 4. Extract read counts for each gene
Counts were obtained from the sorted .bam files using the R package (see bam_get_counts.R).




