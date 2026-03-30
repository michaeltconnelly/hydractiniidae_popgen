#!/bin/bash
#./bash/spades_parents_wrapper.sh
# purpose: SPAdes assembly for Podocoryna parental reads

# create variable for source and target directories
prodir="/data/NHGRIBaxevanis/connellym2/projects/hydractiniidae_popgen"
data_dir="/data/NHGRIBaxevanis/podo_data_sharing/podo_parent_illumina"

# making a list of sample names
samples="Male_HLCJWBCX2_18309568 Female_HLCVJBCX2_18828953"

#lets me know which files are being processed
echo "These are the samples to be assembled:"
echo $samples

#loop to automate generation of scripts
for sample in $samples
do \
sample_abbv=$(echo $sample | cut -f 1 -d "_")
echo "Preparing script for ${sample_abbv} parent"

# create job file
JOBFILE="${prodir}/jobs/spades_parent_${sample_abbv}.job"
touch $JOBFILE

# input SLURM commands
echo "#!/bin/bash
#SBATCH --mem=720g
#SBATCH --cpus-per-task=2
#SBATCH --time=10-00:00:00
#SBATCH --job-name ${sample_abbv}_parent_spades
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80" > $JOBFILE

# import modules
echo "module load spades" >> $JOBFILE

# job script - spades assembly
echo "spades.py \
-o ${prodir}/outputs/spades/${sample_abbv}_parent \
--pe1-1 ${data_dir}/${sample}_R1_val_1.fq \
--pe1-2 ${data_dir}/${sample}_R2_val_2.fq \
-m 720 -t 2" >> $JOBFILE

# submit job
sbatch $JOBFILE
done

#for i in */*contigs.fasta; do new_name=$(ls $i | sed 's/\//_/g'); echo $i $new_name; cp $i contigs/${new_name};  done
#for i in *.fasta; do echo $i | cut -f 1,2 -d _; grep ">" $i | wc -l; done | paste - - > contigs_summary.txt
