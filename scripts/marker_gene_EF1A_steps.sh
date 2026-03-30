#!/bin/bash

prodir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen"
mtdir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen/data/marker_genes/EF1A"
cd $mtdir

# concatenate fasta files
cat Podocoryna_genome_EF1A_seq.fasta Hydractinia_genomes_EF1A_seqs.fasta Miglietta_Select_GenBank_EF1A_seqs.fasta > Genbank_EF1A_seqs.fasta # Hydra_vulgaris_ef1a_seq.fasta

# perform multiple sequence alignment
module load mafft
mafft --maxiterate 1000 --localpair Genbank_EF1A_seqs.fasta > Genbank_EF1A_seqs_aligned.fasta

# automatically trim alignment 
clipkit Genbank_EF1A_seqs_aligned.fasta -m smart-gap -o Genbank_EF1A_seqs_aligned_clipkit.fasta

# perform maximum likelihood analysis
module load iqtree
iqtree2 -s Genbank_EF1A_seqs_aligned_clipkit.fasta -m TEST -B 1000 -alrt 1000 --prefix iqtree/Genbank_EF1A_seqs_aligned_clipkit # -o AB565079.1