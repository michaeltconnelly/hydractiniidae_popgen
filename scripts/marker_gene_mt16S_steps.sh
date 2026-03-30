#!/bin/bash

prodir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen"
mtdir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen/data/marker_genes/mt16S"
cd $mtdir

# concatenate fasta files
cat Podocoryna_americana_mt_genome_16S_rRNA.fasta Hydractinia_echinata_mt_genome_16S_rRNA_mt.fasta Hydractinia_symbiolongicarpus_mt_genome_16S_rRNA.fasta Miglietta_Atlantic_Select_GenBank_16S_seqs.fasta Miglietta_Hydractinia_GM_GenBank_16S_seqs.fasta Cairns_Stylaster_GenBank_16S_seqs.fasta > Genbank_16S_seqs.fasta

# perform multiple sequence alignment
module load mafft
mafft --maxiterate 1000 --localpair Genbank_16S_seqs.fasta > Genbank_16S_seqs_aligned.fasta

# automatically trim alignment 
clipkit Genbank_16S_seqs_aligned.fasta -m smart-gap -o Genbank_16S_seqs_aligned_clipkit.fasta

# perform maximum likelihood analysis
module load iqtree
iqtree2 -s Genbank_16S_seqs_aligned_clipkit.fasta -o EU645322.1,EU645315.1,EU645311.1,EU645305.1,EU645303.1 -m TEST -B 1000 -alrt 1000 --prefix iqtree/Genbank_16S_seqs_aligned_clipkit 