#!/bin/bash
#SBATCH --ntasks=1
###SBATCH --mem=128000
#SBATCH --mem=156000
#SBATCH --threads-per-core=1
#SBATCH -J interpolate_CMIP
#SBATCH -e interpolate_CMIP.e%j
#SBATCH -o interpolate_CMIP.o%j
#SBATCH --time=47:59:00
ulimit -s unlimited

date
srun python all_files_to_stereo.py 
date
