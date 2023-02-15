#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mem=32000
#SBATCH --threads-per-core=1
#SBATCH -J extrapolate
#SBATCH -e extrapolate.e%j
#SBATCH -o extrapolate.o%j
#SBATCH --time=47:59:00

## TAKES ~47h FOR 100 YEARS

ulimit -s unlimited

date

INPUTDIR='/scratchu/njourdain/CMIP6_ON_ISMIP6_GRID'
OUTPUTDIR='/scratchu/njourdain/CMIP6_ON_ISMIP6_GRID/EXTRAPOLATED'

#for file in ${INPUTDIR}/*_Omon_*_*_r*_*.nc
for file in ${INPUTDIR}/*_Omon_CNRM-CM6-1_historical_r1i1p1f2_*
#for file in ${INPUTDIR}/*_Omon_MPI-ESM1-2-HR_piControl_r1i1p1f1_21*
#for file in ${INPUTDIR}/*_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_195001_201412_[e-g].nc
do

VAR=`basename $file | cut -d '_' -f1`

# Horizontal extrapolation :
rm -f tmp_hor tmp_hor.o tmp_hor.nc
sed -e "s#<file_in>#${file}#g ; s#<var_name>#${VAR}#g" extrapolate_everywhere_horizontally.f90 > tmp_hor.f90
ifort -c $NC_INC tmp_hor.f90
ifort -o tmp_hor tmp_hor.o $NC_LIB
srun ./tmp_hor
if [ ! -f tmp_hor.nc ]; then
   echo "~!@#%^&* ERROR IN HORIZONTAL INTERPOLATION FOR FILE :"
   echo  "        $file"
   exit
else
   rm -f tmp_hor tmp_hor.o tmp_hor.f90
fi
date

FILEOUT="${OUTPUTDIR}/`basename $file`"

# Vertical extrapolation
rm -f tmp_ver tmp_ver.o ${FILEOUT}
sed -e "s#<file_out>#${FILEOUT}#g ; s#<var_name>#${VAR}#g" extrapolate_remaining_vertically.f90 > tmp_ver.f90
ifort -c $NC_INC tmp_ver.f90
ifort -o tmp_ver tmp_ver.o $NC_LIB
srun ./tmp_ver
if [ ! -f ${FILEOUT} ]; then
   echo "~!@#%^&* ERROR IN VERTICAL INTERPOLATION FOR FILE :"
   echo  "        ${FILEOUT}"
   echo  "        HAS NOT BEEN CREATED !! >>>>>>>>>> STOP !"
   exit
else
   rm -f tmp_ver tmp_ver.o tmp_ver.f90 tmp_hor.nc
fi
date


done
