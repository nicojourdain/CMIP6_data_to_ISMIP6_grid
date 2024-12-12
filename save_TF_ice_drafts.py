import numpy as np
import xarray as xr
import os
import glob

#== ice shelf draft ==

bm = xr.open_dataset('/data/njourdain/DATA_ISMIP6/BedMachineAntarctica_2020-07-15_v02_8km.nc')
Zdraft = bm.surface - bm.thickness

#== TF ==

pathin = '/data/njourdain/DATA_PROTECT'
pathout = '/data/njourdain/DATA_PROTECT/TF_on_ice_draft'

model_list = ['MPI-ESM1-2-HR','UKESM1-0-LL','IPSL-CM6A-LR','CESM2','CNRM-CM6-1','NorESM2-MM','CESM2-WACCM','MRI-ESM2-0','ACCESS-CM2','CanESM5','GISS-E2-1-H','ACCESS-ESM1-5','CNRM-ESM2-1','GFDL-CM4','GFDL-ESM4','NorESM2-MM']
scenar_list = ['historical','ssp126','ssp245','ssp370','ssp585','piControl']
var_list=['TFrms','TFavg']

for model in model_list:
  for scenar in scenar_list:
    for var in var_list:

      file_list = glob.glob(pathin+'/'+model+'/'+var+'_Oyr_'+model+'_'+scenar+'_*12.nc')

      for file_in in file_list:

        file_out = file_in.replace(var,var+'_ISdraft').replace(pathin,pathout).replace('/'+model+'/','/')
        print(file_out)

        check=os.path.exists(file_out)

        if check:

           print('File exists, nothing changed')

        else:

           ds = xr.open_dataset(file_in)

           TFdraft = ds.TF.interp(z=Zdraft,method="linear")

           TFdraft.drop_vars('z').to_netcdf(file_out,unlimited_dims="time")

           print('File created !')
