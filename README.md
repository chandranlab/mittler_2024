# Workflows
---
## Published in Mittler et al.
### A. Analysis of CRISPR/Cas9 screen

#### Hardware, operating systen, software
- Mac (arm64)
- Mac OS v14.6.1 (Sonoma)
- Terminal v2.14
- GNU bash v3.2.57(1)-release (arm64-apple-darwin23)
- mageck v0.5.9.5 (available [here](https://sourceforge.net/p/mageck/wiki/Home/))
  
#### Data acquisition
A genome-scale CRISPR/Cas9 cell-survival screen for tick-borne encephalitis virus (TBEV) dependency factors was performed as described in Mittler et al.

A549 cells transduced with a lentiviral pool encoding the [Gecko-v2 CRISPR/Cas9-based gene inactivation library](https://www.addgene.org/pooled-library/zhang-human-gecko-v2/) were either left untreated or exposed to TBEV. The surviving cells were expanded and their genomic DNA was isolated. Experiments were performed in biological duplicate to yield 4 samples (control-rep1, TBEV-rep1, control-rep2, TBEV-rep2). 

Amplicons containing single-guide RNA (sgRNA) sequences were prepared from the genomic gDNA and ligated to Illumina adapters. Libraries were pooled and sequenced on the Illumina NextSeq 500 (2x150 bp, paired-end mode). FASTQ files were demultiplexed and processed to remove technical adapter sequences.

#### Input data files
1. control-rep1_R1.fastq
2. control-rep1_R2.fastq
3. tbev-rep1_R1.fastq
4. tbev-rep1_R2.fastq
5. control-rep2_R1.fastq
6. control-rep2_R2.fastq
7. tbev-rep2_R1.fastq
8. tbev-rep2_R2.fastq

rep = replicate, 
R1 = P7 read, 
R2 = P5 read

#### Read structure
<img width="1256" alt="Screenshot 2024-10-27 at 9 27 45 AM" src="https://github.com/user-attachments/assets/a3114525-5088-4117-8189-991ae055bf35">

#### Reorienting reads with `pooled_CRISPR_screen_Gecko_v2_reorient.sh`
Because adapter ligation is orientation-independent, the R1 and R2 read files for each sample are expected to contain ~50% of the 'forward' reads of interest (containing the sgRNA sequence). 

The bash script `pooled_CRISPR_screen_Gecko_v2_reorient.sh` extracts reads from the R1 and R2 FASTQ files that are in the desired forward orientation and compiles them into a new `_reoriented_R1.fastq` file. Reverse reads only contain sgRNA scaffold and lentiviral framework sequences and are discarded.

#### Running `mageck count`

See [mageck count](https://sourceforge.net/p/mageck/wiki/usage/#count) for documentation. 

Launch mageck count from Terminal command line to determine sgRNA readcounts in each fileset as follows:

`mageck count -l Human_GeCKOv2_Library_combine.csv --fastq control_rep1_reoriented_R1.fastq control_rep2_reoriented_R1.fastq TBEV_rep1_reoriented_R1.fastq TBEV_rep2_reoriented_R1.fastq --norm-method median -n tbev_screen --unmapped-to-file --sample-label control1,control2,tbev1,tbev2`

Library file containing Gecko-v2 sgRNA sequences is available [here](https://github.com/chandranlab/mittler_2024/blob/main/Human_GeCKOv2_Library_combine.csv).

Output file `tbev_screen.count.txt` containing sgRNA readcounts for each sample is used as input for `mageck test`.

#### Running `mageck test`
See [mageck test](https://sourceforge.net/p/mageck/wiki/usage/#test) for documentation. 

Launch mageck test from Terminal to rank sgRNAs and genes based on the read count table provided:

`mageck test -k tbev_screen.count.txt -t 2,3 -c 0,1 -n TBEV --norm-method median --pdf-report`

The gene-specific positive selection score in output file `TBEV.gene_summary.txt` was used to identify gene hits (see the manuscript).

#### Demo dataset

A sample dataset for testing the bash script (gzipped FASTQ R1 and R2 files containing 2,500 reads) can be downloaded [here](https://github.com/chandranlab/mittler_2024/tree/main/demo_fastq_files).

A raw CRISPR/Cas9 screen dataset from [Kulsuptrakul et al.](https://doi.org/10.1016/j.celrep.2021.108859) was used for testing the mageck subcommands and is available for download on [EBI ArrayExpress](https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-MTAB-8646). 

---

### B. CellProfiler analysis of immunofluorescence microscopy images

#### Hardware, operating systen, software
- Mac (arm64)
- Mac OS v14.6.1 (Sonoma)
- CellProfiler v4.2.6 (available [here](https://cellprofiler.org/))

#### Data acquisition
Experiments to detect and measure TBEV attachment and internalization into A549 cells was performed, cells were fluorescently labeled for plasma membrane glycans (wheat germ aggluttinin (WGA)), TBEV glycoprotein E, and nuclei. 

Cells were visualized by confocal microscopy, and fields containing cells were captured in three fluorescent channels: WGA - red, E - green, nuclei - blue. 

See Mittler et al. for details.

#### CellProfiler analysis

See the [Cellprofiler website](https://cellprofiler.org/) for documentation.

The custom CellProfiler pipeline used in this study is available [here](https://github.com/chandranlab/mittler_2024/blob/main/cell_fluorescent_puncta_count.cpproj).

A sample image (Nikon nd2 format) containing the three fluorescent channels above is available [here](https://github.com/chandranlab/mittler_2024/blob/main/sample_image.nd2).

Cells were segmented according to nuclei (primary objects) and WGA (secondary objects).

Cell-associated fluorescent E puncta were segmented as primary objects, enumerated, and assigned as child objects to Cells.



