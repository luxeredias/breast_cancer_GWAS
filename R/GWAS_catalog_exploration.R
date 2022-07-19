library(dplyr)
library(tidyverse)
library(data.table)

#Download GWAS Catalog
GWAS_catalog_v1.02 <- fread("https://www.ebi.ac.uk/gwas/api/search/downloads/alternative")

GWAS_cat_brca <- GWAS_catalog_v1.02 %>%
  filter(grepl("breast",MAPPED_TRAIT) |
           grepl("breast",`DISEASE/TRAIT`))

traits <- GWAS_cat_brca %>%
  select(`DISEASE/TRAIT`,MAPPED_TRAIT) %>%
  filter(!duplicated(.))

GWAS_cat_breast_carcinoma <- GWAS_catalog_v1.02 %>%
  filter(MAPPED_TRAIT=="breast carcinoma")

#Number of studies = 58
length(unique(GWAS_cat_breast_carcinoma$PUBMEDID))

#Number of unique SNPs
length(unique(GWAS_cat_breast_carcinoma$`STRONGEST SNP-RISK ALLELE`))

multi_study_SNPs <- as.data.frame(table(GWAS_cat_breast_carcinoma$`STRONGEST SNP-RISK ALLELE`))

multi_study_SNPs <- multi_study_SNPs %>%
  arrange(desc(Freq)) %>%
  rename(SNP=1,studies=2) %>%
  filter(studies >= 3)

selected_SNPs <- multi_study_SNPs$SNP

GWAS_cat_selected_SNPs <- GWAS_cat_breast_carcinoma %>%
  filter(`STRONGEST SNP-RISK ALLELE` %in% as.character(multi_study_SNPs$SNP))

#Number of studies of top multi study SNPs
length(unique(GWAS_cat_selected_SNPs$PUBMEDID))

SNPs_per_study <- as.data.frame(table(GWAS_cat_selected_SNPs$PUBMEDID))

SNPs_per_study_unique <- GWAS_cat_selected_SNPs %>%
  filter(!duplicated(paste0(PUBMEDID,`STRONGEST SNP-RISK ALLELE`)))

SNPs_per_study_2 <- as.data.frame(table(SNPs_per_study_unique$PUBMEDID)) %>%
  rename(PUBMEDID=1,SNPs=2)

write.csv(SNPs_per_study_2,file = "data/SNPs_per_study.csv",
          row.names = F)

write.csv(SNPs_per_study_unique,file = "data/GWAS_catalog_top_BRCA_SNPs_and_studies.csv",
          row.names = F)

#O que faremos com esses dados?
#
# - focar nos top 5 SNPs presentes em mais artigos (rs10069690-T,rs4784227-T,rs13387042-A,rs4973768-T,rs10941679-G)
# - ler os artigos onde os SNPs foram associados:
#   - verificar se há sobreposição de amostras
#   - anotar o tamanho das amostras (N casos, N controles)
#   - anotar ancestralidade das populações
#   - anotar plataforma de genotipagem
#   - anotar tipo de estimativa do tamanho de efeito: beta ou OR
#   
#   
# - Fazer meta análise dos estudos selecionados