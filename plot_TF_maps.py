import numpy as np
import xarray as xr
import matplotlib.pyplot as plt

#== ice shelf draft ==

bm = xr.open_dataset('/data/njourdain/DATA_ISMIP6/BedMachineAntarctica_2020-07-15_v02_8km.nc')
Zdraft = bm.surface - bm.thickness

#== TF ==

ds = xr.open_dataset('/data/njourdain/DATA_PROTECT/MPI-ESM1-2-HR/TFrms_Oyr_MPI-ESM1-2-HR_historical_r1i1p1f1_185001_194912.nc')

TFdraft = ds.TF.isel(time=0).interp(z=Zdraft,method="linear")
plt.pcolormesh(TFdraft)
plt.colorbar()
plt.show()
