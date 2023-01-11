# SingleCellPipelines
## Description
Source code for the implementation of scMethyl-seq and scRNA-seq pipelines.
### Methylation pipeline steps
#### 1. Quality assessment and adapter trimming
Read quality is assessed using software FASTQC and trimgalore.
#### 2. Alignment, duplication removal and metrhylation extraction
These 3 steps were performed using Bismark. Alignment to the reference genome (see Annotations) was performed in single-end mode to increase the mapping efficiency.
Methylation call files were processed so methylation states were binarized: methylation < 0.1 was set to 0 (unmethylated cytosine), methylation > 0.1 and < 0.9 was set to 0.5 (equivalent to allelic methylation) and methylation > 0.9 was set to 1 (methylated cytosine).
#### 3. Generating summary table
Quality, alignment and methylation metrics were gathered in a table for analysis/filtering.




