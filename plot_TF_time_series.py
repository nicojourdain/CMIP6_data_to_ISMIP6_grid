import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import glob
import dask

dask.config.set(**{'array.slicing.split_large_chunks': True})

#== ice shelf draft ==

bm = xr.open_dataset('/data/njourdain/DATA_ISMIP6/BedMachineAntarctica_2020-07-15_v02_8km.nc')
Zdraft = bm.surface - bm.thickness

#== TF ==

var='TFrms'

model='MPI-ESM1-2-HR'
member='r1i1p1f1'
path='/data/njourdain/DATA_PROTECT/'

list_histo = sorted(glob.glob(path+'/'+model+'/'+var+'_Oyr_'+model+'_historical_'+member+'_*[0-9].nc')) 
list_pictl = sorted(glob.glob(path+'/'+model+'/'+var+'_Oyr_'+model+'_piControl_'+member+'_*[0-9].nc')) 

print(list_histo)
print(list_pictl)

hi = xr.open_mfdataset(list_histo)
pi = xr.open_mfdataset(list_pictl)

tmp_histo = hi.TF.interp(z=Zdraft,method="linear").isel(time=slice(0,5)) * bm.mask
tmp_pictl = pi.TF.interp(z=Zdraft,method="linear").isel(time=slice(0,5)) * bm.mask

print(tmp_histo)

aa = bm.mask.sum(dim=["x","y"]).values
TF_histo = tmp_histo.sum(dim=["x","y"]) / aa
TF_pictl = tmp_pictl.sum(dim=["x","y"]) / aa

print(TF_histo)
print(TF_pictl)

#==================

fig, ax = plt.subplots()

ax.plot(TF_histo)
ax.plot(pi.time[0:5].values,TF_pictl.values)

fig.savefig('TF_timeseries.pdf')
