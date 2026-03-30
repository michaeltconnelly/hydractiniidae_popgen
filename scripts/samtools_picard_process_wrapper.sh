#!/bin/bash
#./bash/samtools_picard_process_wrapper.sh
# purpose: flagstat, sort, index, and convert alignments to bam files with samtools, add read groups and mark duplicates with picard

# create variable for source and target directories
prodir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen"
data_dir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen/data/reads"

# making a list of sample names
set=$1 # ex. midatlantic
samples=$(cat ${prodir}/data/${set}_samples.txt)

#lets me know which files are being processed
echo "These are the samples to be processed:"
echo $samples

#loop to automate generation of scripts to direct file processing
for sample in $samples
do \
echo "Preparing script for ${sample}"

# create job file
JOBFILE="${prodir}/jobs/samtools_picard_${sample}.job"
touch $JOBFILE

# input SLURM commands
echo "#!/bin/bash
#SBATCH --mem=24g
#SBATCH --cpus-per-task=8
#SBATCH --gres=lscratch:8
#SBATCH --time=3-04:00:00
#SBATCH --job-name ${sample}_samtools_picard
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80" >> $JOBFILE

# import modules
echo "module load samtools" >> $JOBFILE
echo "module load picard" >> $JOBFILE

# job script - samtools flagstat
echo "samtools flagstat ${prodir}/outputs/alignments/${sample}.sam > ${prodir}/outputs/QCs/flagstats/${sample}_flagstat.txt" >> $JOBFILE

# job script - samtools bam conversion, sort, index
echo "samtools view -b ${prodir}/outputs/alignments/${sample}.sam \
-o ${prodir}/outputs/alignments/${sample}.bam -@ 8" >> $JOBFILE
# cleanup
echo "rm ${prodir}/outputs/alignments/${sample}.sam" >> $JOBFILE

echo "samtools sort ${prodir}/outputs/alignments/${sample}.bam -@ 8 \
-o ${prodir}/outputs/alignments/${sample}.sorted.bam" >> $JOBFILE
# cleanup
echo "rm ${prodir}/outputs/alignments/${sample}.bam" >> $JOBFILE

echo "samtools index -b ${prodir}/outputs/alignments/${sample}.sorted.bam" >> $JOBFILE

# job script - picard add read groups 
echo "java -jar /usr/local/apps/picard/3.3.0/picard.jar \
AddOrReplaceReadGroups \
INPUT=${prodir}/outputs/alignments/${sample}.sorted.bam \
OUTPUT=${prodir}/outputs/alignments/${sample}.sorted.rg.bam \
RGID=id \
RGLB=library \
RGPL=illumina \
RGPU=unit1 \
RGSM=${sample}" >> $JOBFILE
# cleanup
echo "rm ${prodir}/outputs/alignments/${sample}.sorted.bam" >> $JOBFILE

# job script - picard mark duplicates
echo "java -jar /usr/local/apps/picard/3.3.0/picard.jar \
MarkDuplicates \
INPUT=${prodir}/outputs/alignments/${sample}.sorted.rg.bam \
OUTPUT=${prodir}/outputs/alignments/${sample}.sorted.md.rg.bam \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=SILENT \
METRICS_FILE=${prodir}/outputs/QCs/dups/${sample}_marked_dup_metrics.txt" >> $JOBFILE
# cleanup
echo "rm ${prodir}/outputs/alignments/${sample}.sorted.rg.bam" >> $JOBFILE

# submit job
sbatch $JOBFILE
done
