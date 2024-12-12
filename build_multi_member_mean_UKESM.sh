#!/bin/bash
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mem=16000
#SBATCH --threads-per-core=1
#SBATCH -J build_multi_member_mean
#SBATCH -e build_multi_member_mean.e%j
#SBATCH -o build_multi_member_mean.o%j
#SBATCH --time=47:59:00
ulimit -s unlimited

ifort -c $NC_INC build_multimember_mean_thetao_UKESM.f90 
ifort -o build_multimember_mean_thetao build_multimember_mean_thetao_UKESM.o $NC_LIB
./build_multimember_mean_thetao
rm -f build_multimember_mean_thetao build_multimember_mean_thetao_UKESM.o

ifort -c $NC_INC build_multimember_mean_so_UKESM.f90
ifort -o build_multimember_mean_so build_multimember_mean_so_UKESM.o $NC_LIB
./build_multimember_mean_so
rm -f build_multimember_mean_so build_multimember_mean_so_UKESM.o
