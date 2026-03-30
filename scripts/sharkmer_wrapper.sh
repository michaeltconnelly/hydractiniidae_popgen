#!/bin/bash
#./bash/sharkmer_wrapper.sh
# purpose: create wrapper scripts to recover mitochondrial barcodes

# create variable for source and target directories
prodir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen"
data_dir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen/data/reads"

# making a list of sample names
set=$1 # ex. midatlantic
samples=$(cat ${prodir}/data/${set}_samples.txt)

#lets me know which files are being processed
echo "These are the samples for sharkmer:"
echo $samples

#loop to automate generation of scripts
for sample in $samples
do \
echo "Preparing script for ${sample}"

# create job file
JOBFILE="${prodir}/jobs/sharkmer_${sample}.job"
touch $JOBFILE

# input SLURM commands
echo "#!/bin/bash
#SBATCH --mem=80g
#SBATCH --cpus-per-task=2
#SBATCH --time=12:00:00
#SBATCH --job-name ${sample}_sharkmer
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80" > $JOBFILE

# job script - sharkmer
# PCR primers - use primer sequence from Miglietta et al. 2009, cnidaria primer panel (16S, CO1, 18S, ITSfull)

echo "gunzip ${prodir}/data/trimmed/${sample}_R1_PE_trimmed.fastq.gz
gunzip ${prodir}/data/trimmed/${sample}_R2_PE_trimmed.fastq.gz" >> $JOBFILE

# add Linder et al. 2008 EF1a primers
echo "/home/connellym2/programs/sharkmer/sharkmer/target/release/sharkmer \
 --max-reads 2000000 -k 25 -s ${sample} -o ${prodir}/outputs/sharkmer/${sample}/ \
 --pcr "forward=ACGGAATGAACTCAAATCATGT,reverse=TCGACTGTTTACCAAAAACATA,max-length=1000,name=miglietta_16S" \
 --pcr cnidaria \
 ${prodir}/data/trimmed/${sample}_R1_PE_trimmed.fastq ${prodir}/data/trimmed/${sample}_R2_PE_trimmed.fastq" >> $JOBFILE

echo "gzip ${prodir}/data/trimmed/${sample}_R1_PE_trimmed.fastq
gzip ${prodir}/data/trimmed/${sample}_R2_PE_trimmed.fastq" >> $JOBFILE

# submit job
sbatch -D ${prodir}/outputs/sharkmer $JOBFILE
done
