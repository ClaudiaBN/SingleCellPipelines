# SingleCellPipelines
## Description
Source code for the implementation of scMethyl-seq and scRNA-seq pipelines.
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
#### 1. Quality assessment and adapter trimming
Read quality is assessed using software FASTQC and trimgalore.
#### 2. Alignment, duplication removal and methylation extraction
These 3 steps were performed using the Bisulfite Read Mapper and Methylation Caller Bismark. Alignment to the reference genome (see Annotations) was performed in single-end mode to increase the mapping efficiency.
Methylation call files were processed so methylation states were binarized: methylation < 0.1 was set to 0 (unmethylated cytosine), methylation > 0.1 and < 0.9 was set to 0.5 (equivalent to allelic methylation) and methylation > 0.9 was set to 1 (methylated cytosine).
#### 3. Generating summary table
Quality, alignment and methylation metrics were gathered in a table for analysis/filtering.
#### 4. Input files

### scRNA-SEQ pipeline
#### 1. Quality assessment and adapter trimming
Read quality is assessed using software FASTQC and trimgalore.
#### 2. Alignment
Alignment is performed using HISAT2.
#### 3. Generating summary table
Quality and alignment were gathered in a table for analysis/filtering.




