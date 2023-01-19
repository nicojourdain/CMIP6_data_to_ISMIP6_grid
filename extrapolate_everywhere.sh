#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mem=32000
#SBATCH --threads-per-core=1
#SBATCH -J extrapolate
#SBATCH -e extrapolate.e%j
#SBATCH -o extrapolate.o%j
#SBATCH --time=00:59:00
ulimit -s unlimited

date

rm -f extrapolate_everywhere.o
#ifort -g -traceback -check all -c $NC_INC extrapolate_everywhere.f90
ifort -c $NC_INC extrapolate_everywhere.f90
#ifort -g -traceback -check -o extrapolate extrapolate_everywhere.o $NC_LIB
ifort -o extrapolate extrapolate_everywhere.o $NC_LIB

srun ./extrapolate

date
