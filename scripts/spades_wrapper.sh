#!/bin/bash
#./bash/spades_wrapper.sh
# purpose: SPAdes assembly

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
JOBFILE="${prodir}/jobs/spades_${sample}.job"
touch $JOBFILE

# input SLURM commands
echo "#!/bin/bash
#SBATCH --mem=384g
#SBATCH --cpus-per-task=8
#SBATCH --time=10-00:00:00
#SBATCH --job-name ${sample}_spades
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80" > $JOBFILE

# import modules
echo "module load spades" >> $JOBFILE

# job script - SPAdes assembly
# NOTE: make sure SE reads are concatenated during trim job
echo "spades.py \
-o ${prodir}/outputs/spades/${sample} \
--pe1-1 ${prodir}/data/trimmed/${sample}_R1_PE_trimmed.fastq.gz \
--pe1-2 ${prodir}/data/trimmed/${sample}_R2_PE_trimmed.fastq.gz \
--pe1-s ${prodir}/data/trimmed/${sample}_SE_concat.fastq.gz -m 384 -t 8" >> $JOBFILE

# submit job
sbatch $JOBFILE
done

#for i in */*contigs.fasta; do new_name=$(ls $i | sed 's/\//_/g'); echo $i $new_name; cp $i contigs/${new_name};  done
#for i in *.fasta; do echo $i | cut -f 1,2 -d _; grep ">" $i | wc -l; done | paste - - > contigs_summary.txt
