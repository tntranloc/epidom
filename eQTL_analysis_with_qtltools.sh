## check the manual yourself for general or post- processing https://qtltools.github.io/qtltools/
## my note mostly show steps that are not explicit or not shown in the qtltools manual

# I start with 
  # a normalised (DESeq2's median-to-ratio method) gene count matrix 
    # this must be saved as bed file
      # must be zipped and tabix
      bgzip myPhenotypes.bed && tabix -p bed phenotypes.bed.gz
      
    # Columns required are: 
      # "#CHR" (same chromosome name as vcf file) 
      # "start" = numeric
      # "end" = numeric !!! NOT the real "end" but must be  = start + 1
      # "exonid" = make custom exon ID if you don't have one, f.e. chr + start + end + strand = exonID
      # "geneid" = make sure it is consitent with geneid in the vcf  
      # "strand" = a + or - strand
      # "sampleid_1" # count value
      # "sampleid_2" # count value
      # "sampleid_n..." # count value
    
  # a variant calling file (VCF) 
    # a snp matrix generated by any variant calling tool, with proper header and sample name matching gene count matrix

######## PCA on data to extract covariates #########
QTLtools pca --bed myPhenotypes.bed --scale --center --out myPhenotypes
QTLtools pca --vcf genotypes.vcf.gz --scale --center --maf 0.05 --distance 50000 --out genotypes


### PCA output format is 
 id sample1 sample2 sample3 sample4
PC1 -0.02 0.14 0.16 -0.02
PC2 0.01 0.11 0.10 0.01
PC3 0.03 0.05 0.08 0.07
...

### Combine PCs from bed and vcf into one single covariate file, like rowbind, because they both share sample header

### USE pca_stats to see how much % is explained by how many PCs
# Try different PCs to see which one give the highest detected eQTL

### for example covariate file like this means you take 3 PCs each from bed and genotype PCA

 id sample1 sample2 sample3 sample4
myPhenotypes_1_1_svd_PC1  -0.02 0.14 0.16 -0.02
myPhenotypes_1_1_svd_PC2 0.01 0.11 0.10 0.01
myPhenotypes_1_1_svd_PC3 0.03 0.05 0.08 0.07
genotypes_1_1_svd_PC1  -0.02 0.14 0.16 -0.02
genotypes_1_1_svd_PC2 0.01 0.11 0.10 0.01
genotypes_1_1_svd_PC3 0.03 0.05 0.08 0.07

### try for example 10 PCs for bed and change number of PCs for vcf, find the best number of PCs for VCF
## then do the reverse to find best number of PCs for bed


######## cis eQTL permutation method #########
QTLtools cis --vcf genotypes.vcf.gz --bed myPhenotypes.bed.gz --cov covariates.txt.gz --permute 1000 --window 5000 --out permutations.txt
# consider any region less than 5kb is a cis, otherwise trans
# remember to give window values because the default of qtltools is a huge window

## Run in chunks and parallel on cluster
..
# merge all chunks 
cat permutations_*_20.txt | gzip -c > permutations_full.txt.gz

### sanity check, plotting, and filtering as shown in qtltools manual

### get permutation threshold for the next analysis 
Rscript ./script/runFDR_cis.R permutations_all.txt.gz 0.05 permutations_all


######## cis eQTL conditional method #########
QTLtools cis --vcf genotypes.vcf.gz --bed myPhenotypes.bed.gz --cov covariates.txt.gz --mapping permutations_all.thresholds.txt --chunk 12 16 --out conditional_12_16.txt



######### trans eQTL #########



############ PLOT classic eQTL position #########



