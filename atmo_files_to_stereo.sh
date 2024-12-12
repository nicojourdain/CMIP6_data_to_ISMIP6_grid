#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mem=48000
#SBATCH --threads-per-core=1
#SBATCH -J atmo_to_stereo
#SBATCH -e atmo_to_stereo.e%j
#SBATCH -o atmo_to_stereo.o%j
#SBATCH --time=47:59:00
ulimit -s unlimited

date
srun python atmo_files_to_stereo.py
date
