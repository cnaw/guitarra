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
#SBATCH --mem-per-cpu=250000
### Job name
#SBATCH -J 'mosaic_scene'
### output and error logs
#SBATCH -o mosaic_scene_%a.out
#SBATCH -e mosaic_scene_%a.err
### mail
#SBATCH --mail-type=END
#SBATCH --mail-user=sandro.tacchella@cfa.harvard.edu
source activate pro
srun -n 1 python /n/eisenstein_lab/Users/stacchella/img_simulator/guitarra/python_wrapper/scripts/mosaic_scene.py \
--filter="F444W" \
--path_raw_data="/n/eisenstein_lab/Users/stacchella/img_simulator/make_scene/raw_data/" \
