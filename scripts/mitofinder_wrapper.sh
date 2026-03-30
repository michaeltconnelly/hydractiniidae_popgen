#!/bin/bash
#./bash/mitofinder_wrapper.sh
# purpose: create wrapper scripts to recover mitochondrial genome

# create variable for source and target directories
prodir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen"
data_dir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen/data/reads"

# making a list of sample names
set=$1 # ex. midatlantic
samples=$(cat ${prodir}/data/${set}_samples.txt)

#lets me know which files are being processed
echo "These are the samples for mitofinder:"
echo $samples

#loop to automate generation of scripts to direct sequence file trimming
for sample in $samples
do \
echo "Preparing script for ${sample}"

# create job file
JOBFILE="${prodir}/jobs/mitofinder_${sample}.job"
touch $JOBFILE

# input SLURM commands
echo "#!/bin/bash
#SBATCH --mem=24g
#SBATCH --cpus-per-task=16
#SBATCH --gres=lscratch:8
#SBATCH --time=3-00:00:00
#SBATCH --job-name ${sample}_mitofinder
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80" > $JOBFILE

# import modules
# conda activate mitofinder

# job script - mitofinder
# reference - use custom-generated Hydractinia genbank file
# seqret -sequence HSymV2.0.MT.fasta -feature -fformat gff -fopenfile HSymV2.0.MT.gff -osformat genbank -osname HSymV2.0.MT.gb
echo "mitofinder \
-j ${sample} \
-o 4 \
-p 16 \
-r ${prodir}/data/mt_genome/HSymV2/HSymV2.0.MT.gb \
-1 ${prodir}/data/trimmed/${sample}_R1_PE_trimmed.fastq.gz \
-2 ${prodir}/data/trimmed/${sample}_R2_PE_trimmed.fastq.gz \
--max-contig 1 --adjust-direction" >> $JOBFILE

# submit job
sbatch -D ${prodir}/outputs/mitofinder $JOBFILE
done
