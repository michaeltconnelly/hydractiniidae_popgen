#!/bin/bash
#./bash/bwa_hydractinia_wrapper.sh
# purpose: alignment to Hydractinia reference genome

# create variable for source and target directories
prodir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen"
data_dir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen/data/reads"

# making a list of sample names
set=$1 # ex. midatlantic
samples=$(cat ${prodir}/data/${set}_samples.txt)

#lets me know which files are being processed
echo "These are the samples to be trimmed:"
echo $samples

#loop to automate generation of scripts to direct sequence file trimming
for sample in $samples
do \
echo "Preparing script for ${sample}"

# create job file
JOBFILE="${prodir}/jobs/bwa_hydractinia_${sample}.job"
touch $JOBFILE

# input SLURM commands
echo "#!/bin/bash
#SBATCH --mem=24g
#SBATCH --cpus-per-task=8
#SBATCH --gres=lscratch:24
#SBATCH --time=10-00:00:00
#SBATCH --job-name ${sample}_bwa_hydractinia
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80" > $JOBFILE

# import modules
echo "module load bwa samtools" >> $JOBFILE

# job script - bwa alignment of trimmed reads
echo "bwa mem ${prodir}/data/genomes/GCF_029227915.1_HSymV2.1_genomic.fna \
${prodir}/data/trimmed/${sample}_R1_PE_trimmed.fastq.gz \
${prodir}/data/trimmed/${sample}_R2_PE_trimmed.fastq.gz \
> ${prodir}/outputs/alignments/${sample}.sam" >> $JOBFILE

# QC read alignment rates of sam files
echo "samtools flagstat ${prodir}/outputs/alignments/${sample}.sam > ${prodir}/outputs/QCs/flagstats/${sample}_flagstat.txt" >> $JOBFILE

# submit job
sbatch $JOBFILE
done
