#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mem=16000
#SBATCH --threads-per-core=1
#SBATCH -J extract_TF
#SBATCH -e extract_TF.e%j
#SBATCH -o extract_TF.o%j
#SBATCH --time=01:59:00
ulimit -s unlimited

date

INPUTDIR='/scratchu/njourdain/CMIP6_ON_ISMIP6_GRID/EXTRAPOLATED'
OUTPUTDIR='/data/njourdain/DATA_PROTECT'
# loop on a list of **thetao files** (assuming that corresponding so files exist) :
for file in ${INPUTDIR}/thetao_Omon_NorESM2-MM_ssp585_r1i1p1f1_*
do

MODEL=`basename $file | cut -d '_' -f3`
SCENAR=`basename $file | cut -d '_' -f4`
MEMBER=`basename $file | cut -d '_' -f5`
DATE1=`basename $file | cut -d '_' -f6`
DATE2=`basename $file | cut -d '_' -f7`
ALPHA=`basename $file | cut -d '_' -f8 | sed -e "s/.nc//g"`

if [ ! -f ${INPUTDIR}/so_Omon_${MODEL}_${SCENAR}_${MEMBER}_${DATE1}_${DATE2}_${ALPHA}.nc ]; then
  echo '~!@#$%^&*()- ERROR : you need both thetao and so files !!!!'
  echo "                     ${MODEL} ${SCENAR} ${MEMBER} ${DATE1} ${DATE2} ${ALPHA}"
  echo '   >>>>> STOP !'
  exit
fi

rm -f xtr xtr.o
sed -e "s#<model>#${MODEL}#g ; s#<scenar>#${SCENAR}#g ; s#<member>#${MEMBER}#g ; s#<date1>#${DATE1}#g ; s#<date2>#${DATE2}#g ; s#<alpha>#${ALPHA}#g" extract_yearly_values_and_TF.f90 > xtr.f90
ifort -c $NC_INC xtr.f90
ifort -o xtr xtr.o $NC_LIB
srun ./xtr

file_in_T=${INPUTDIR}/thetao_Omon_${MODEL}_${SCENAR}_${MEMBER}_${DATE1}_${DATE2}_${ALPHA}.nc
file_in_S=${INPUTDIR}/so_Omon_${MODEL}_${SCENAR}_${MEMBER}_${DATE1}_${DATE2}_${ALPHA}.nc
file_ori_T=${INPUTDIR}/../thetao_Omon_${MODEL}_${SCENAR}_${MEMBER}_${DATE1}_${DATE2}_${ALPHA}.nc
file_ori_S=${INPUTDIR}/../so_Omon_${MODEL}_${SCENAR}_${MEMBER}_${DATE1}_${DATE2}_${ALPHA}.nc

if [ -f $OUTPUTDIR/$MODEL/thetao_Oyr_${MODEL}_${SCENAR}_${MEMBER}_${DATE1}_${DATE2}_${ALPHA}.nc ] && [ -f $OUTPUTDIR/$MODEL/so_Oyr_${MODEL}_${SCENAR}_${MEMBER}_${DATE1}_${DATE2}_${ALPHA}.nc ] && [ -f $OUTPUTDIR/$MODEL/TFrms_Oyr_${MODEL}_${SCENAR}_${MEMBER}_${DATE1}_${DATE2}_${ALPHA}.nc ] && [ -f $OUTPUTDIR/$MODEL/TFavg_Oyr_${MODEL}_${SCENAR}_${MEMBER}_${DATE1}_${DATE2}_${ALPHA}.nc ]; then
  echo '[successful]'
  rm -f xtr xtr.o xtr.f90
  echo '-> cleaning files from the previous steps'
  rm -f $file_in_T $file_in_S $file_ori_T $file_ori_S
else
  echo "~!@#$%^&*() ERROR : $OUTPUTDIR/$MODEL/TFrms_Oyr_${MODEL}_${SCENAR}_${MEMBER}_${DATE1}_${DATE2}_${ALPHA}.nc"
  echo "                    has not been created  >>>>>>>>>>> STOP !!"
  exit
fi

date

done
echo '[oK]'
