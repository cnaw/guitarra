#!/bin/bash
### Name of the job
### Requested number of cores
#SBATCH -n 1
### Requested number of nodes
#SBATCH -N 1
### Requested computing time in minutes
#SBATCH -t 10080
### Partition or queue name
#SBATCH -p conroy,itc_cluster,hernquist
### memory per cpu, in MB
#SBATCH --mem-per-cpu=4000
### Job name
#SBATCH -J 'reduction_GS_scene'
### output and error logs
#SBATCH -o reduction_GS_scene_%a.out
#SBATCH -e reduction_GS_scene_%a.err
### mail
#SBATCH --mail-type=END
#SBATCH --mail-user=sandro.tacchella@cfa.harvard.edu
source activate pro
srun -n 1 python PATH/reduction_GS_scene.py \
--idx_pointing="${SLURM_ARRAY_TASK_ID}" \
