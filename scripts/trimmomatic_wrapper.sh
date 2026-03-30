#!/bin/bash
#./bash/trimmomatic_wrapper.sh
# purpose: create wrapper scripts for read trimming using trimmomatic

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
JOBFILE="${prodir}/jobs/trim_${sample}.job"
touch $JOBFILE

# input SLURM commands
echo "#!/bin/bash
#SBATCH --mem=100g
#SBATCH --cpus-per-task=16
#SBATCH --gres=lscratch:24
#SBATCH --time=5-00:00:00
#SBATCH --job-name ${sample}_trim
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80" >> $JOBFILE

# import modules
echo "module load trimmomatic fastqc" >> $JOBFILE

# job script - trim fastq files
echo "java -jar /usr/local/apps/trimmomatic/0.39/trimmomatic-0.39.jar \
PE -phred33 \
${prodir}/data/reads/${sample}_R1.fastq.gz \
${prodir}/data/reads/${sample}_R2.fastq.gz \
${prodir}/data/trimmed/${sample}_R1_PE_trimmed.fastq.gz \
${prodir}/data/trimmed/${sample}_R1_SE_trimmed.fastq.gz \
${prodir}/data/trimmed/${sample}_R2_PE_trimmed.fastq.gz \
${prodir}/data/trimmed/${sample}_R2_SE_trimmed.fastq.gz \
ILLUMINACLIP:/usr/local/apps/trimmomatic/0.39/adapters/TruSeq3-PE.fa:2:30:10 \
LEADING:3 TRAILING:3 \
CROP:150 \
SLIDINGWINDOW:4:15 \
MINLEN:36" >> $JOBFILE

# QC trimmed PE fastq files
echo "fastqc ${prodir}/data/trimmed/${sample}_*PE*.fastq.gz --threads 2 -o ${prodir}/outputs/QCs/trimqcs/" >> $JOBFILE

# concatenate SE reads for SPAdes
echo "cat ${prodir}/data/trimmed/${sample}_R1_SE_trimmed.fastq.gz ${prodir}/data/trimmed/${sample}_R2_SE_trimmed.fastq.gz > ${prodir}/data/trimmed/${sample}_SE_concat.fastq.gz" >> $JOBFILE

# submit job
sbatch $JOBFILE
done
