#!/bin/bash
#./bash/sharkmer_process_blastwrapper.sh
# purpose: create wrapper scripts to process sharkmer output

# create variable for source and target directories
prodir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen"
sharkdir="${prodir}/outputs/sharkmer"

# making a list of sample names
set=$1 # ex. midatlantic
samples=$(cat ${prodir}/data/${set}_samples.txt)

# select marker and set length 
marker=$2 # ex. "miglietta_16S cnidaria_16S cnidaria_CO1 cnidaria_18S cnidaria_28S cnidaria_ITS cnidaria_ITS-v2 cnidaria_EF1A cnidaria_28S-v2"
min_length=$3 # 600, 500, 600,
max_length=$4 # 750

# load module(s)
module load seqkit

#automate generation of scripts
echo "Summarizing sharkmer results for $marker barcode"

mkdir ${sharkdir}/all_processed/${marker}

# Combine all samples into one file and 
cat ${sharkdir}/*/*${marker}.fasta > ${sharkdir}/all_processed/${marker}/sharkmer_${set}_${marker}_all.fasta

# Summarize sharkmer output for each sample
grep ">" ${sharkdir}/all_processed/${marker}/sharkmer_${set}_${marker}_all.fasta | cut -f 1,2,4,6,11,13,15,17 -d " " | sed 's/ /_/' | sed 's/ /_p/' | sed 's/ /_/' | sed '1iseq mean median min max' | sed 's/ /\t/g' > ${sharkdir}/all_processed/${marker}/sharkmer_${set}_${marker}_fasta_summary.txt

# Change headers
cat ${sharkdir}/all_processed/${marker}/sharkmer_${set}_${marker}_all.fasta | sed 's/ /_/' | sed 's/ product /_p/' | sed 's/ length /_/' | sed 's/kmer.*$//' > ${sharkdir}/all_processed/${marker}/sharkmer_${set}_${marker}_clean.fasta

# Filter to minimum and maximum length
seqkit seq -M $max_length -m $min_length ${sharkdir}/all_processed/${marker}/sharkmer_${set}_${marker}_clean.fasta > ${sharkdir}/all_processed/${marker}/sharkmer_${set}_${marker}_${min_length}.fasta

# create job file
echo "Preparing script to get top BLAST hit for $marker barcode"
JOBFILE="${prodir}/jobs/sharkmer_process_${marker}.job"
touch $JOBFILE

# input SLURM commands
echo "#!/bin/bash
#SBATCH --mem=80g
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --job-name sharkmer_process_${marker}
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80" > $JOBFILE

echo "module load blast" >> $JOBFILE

# Obtain best BLAST hit for each barcode 
echo "blastn -query ${sharkdir}/all_processed/${marker}/sharkmer_${set}_${marker}_${min_length}.fasta \
-db /fdb/blastdb/nt \
-evalue 0.01 \
-max_target_seqs 5 \
-num_threads 4 \
-outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore sscinames stitle' > ${sharkdir}/all_processed/${marker}/sharkmer_${set}_${marker}_${min_length}_top_blastn_hit.txt" >> $JOBFILE

# submit job
sbatch -D ${prodir}/outputs/sharkmer $JOBFILE