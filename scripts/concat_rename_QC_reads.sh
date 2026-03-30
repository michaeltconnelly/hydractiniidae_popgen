#!/bin/bash
#./bash/concat_rename_QC_reads.sh
# purpose: concatenate, rename, and QC fastq files by sample (parent directory)

# create variable for source and target directories
origin_dir="/data/NHGRIBaxevanis/podo_data_sharing/Hydractinia_PopGen_reads"
prodir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen"
data_dir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen/data/reads"

# create variable list of sample names
samples=$(cat ${prodir}/data/samples.txt)

# loop to submit separate jobs for each sample read concatenation
for sample in $samples
do echo $sample
# create job file
JOBFILE="${prodir}/jobs/concat_QC_${sample}.job"
touch $JOBFILE
# input SLURM commands
echo "#!/bin/bash
#SBATCH --mem=100g
#SBATCH --cpus-per-task=2
#SBATCH --gres=lscratch:10
#SBATCH --time=5-00:00:00
#SBATCH --job-name ${sample}_concat_QC
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80" >> $JOBFILE

# import modules
echo "module load fastqc" >> $JOBFILE

# job script - concatenate, rename fastq files
echo "zcat ${origin_dir}/${sample}/*_R1_001.fastq.gz > ${data_dir}/${sample}_R1.fastq" >> $JOBFILE
echo "gzip ${data_dir}/${sample}_R1.fastq" >> $JOBFILE
echo "zcat ${origin_dir}/${sample}/*_R2_001.fastq.gz > ${data_dir}/${sample}_R2.fastq" >> $JOBFILE
echo "gzip ${data_dir}/${sample}_R2.fastq" >> $JOBFILE

# QC fastq files
echo "fastqc ${data_dir}/${sample}_*.fastq.gz --threads 2 -o ${prodir}/outputs/QCs/fastqcs/" >> $JOBFILE

# submit job
sbatch $JOBFILE
done