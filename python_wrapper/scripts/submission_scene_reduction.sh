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
#SBATCH -J 'reduction_scene'
### output and error logs
#SBATCH -o reduction_scene_%a.out
#SBATCH -e reduction_scene_%a.err
### mail
#SBATCH --mail-type=END
#SBATCH --mail-user=sandro.tacchella@cfa.harvard.edu
source activate pro
srun -n 1 python /n/eisenstein_lab/Users/stacchella/img_simulator/guitarra/python_wrapper/scripts/reduction_scene.py \
--idx_pointing="${SLURM_ARRAY_TASK_ID}" \
<<<<<<< HEAD
--num_cores=1000 \
=======
--num_cores=800 \
>>>>>>> 4741ed3ba867a87cfa05fa8e76d9d9a12b7b9d34
--path_raw_data="/n/eisenstein_lab/Users/stacchella/img_simulator/make_scene/raw_data/" \
--environ="cluster" \

