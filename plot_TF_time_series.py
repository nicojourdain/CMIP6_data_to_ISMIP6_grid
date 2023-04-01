import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import glob

bm = xr.open_dataset('/data/njourdain/DATA_ISMIP6/BedMachineAntarctica_2020-07-15_v02_8km.nc')
aa = bm.mask.sum(dim=["x","y"]).values

dirTF='/data/njourdain/DATA_PROTECT/TF_on_ice_draft'

var='TFrms'

#model='IPSL-CM6A-LR' ; member='r1i1p1f1'
#model='CNRM-CM6-1' ; member='r1i1p1f2'
#model='CESM2' ; member='r11i1p1f1'
model='UKESM1-LL' ; member='r4i1p1f2'

list_pictl = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model+'_piControl_'+member+'_*12.nc')) 
list_histo = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model+'_historical_'+member+'_*12.nc')) 
list_sp126 = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model+'_ssp126_'+member+'_*12.nc')) 
list_sp245 = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model+'_ssp245_'+member+'_*12.nc')) 
list_sp585 = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model+'_ssp585_'+member+'_*12.nc')) 

fig, ax = plt.subplots()

if len(list_pictl):
   pi = xr.open_mfdataset(list_pictl,decode_times=False)
   tmp_pictl = pi.TF * bm.mask
   TF_pictl = tmp_pictl.sum(dim=["x","y"]) / aa
   pi_year0 = 1850
   pi_years = np.arange(pi_year0,pi_year0+pi.time.sizes,1)
   ax.plot(pi_years,TF_pictl.values,color='gray',linewidth=1.0,label='piControl')

if len(list_histo):
   hi = xr.open_mfdataset(list_histo,decode_times=False)
   tmp_histo = hi.TF * bm.mask
   hi_year0 = 1850
   hi_years = np.arange(hi_year0,hi_year0+hi.time.shape[0],1)
   TF_histo = tmp_histo.sum(dim=["x","y"]) / aa
   ax.plot(hi_years,TF_histo.values,color='cornflowerblue',linewidth=1.0,label='historical')

if len(list_sp126):
   s1 = xr.open_mfdataset(list_sp126,decode_times=False)
   tmp_sp126 = s1.TF * bm.mask
   s1_year0 = 2015
   s1_years = np.arange(s1_year0,s1_year0+s1.time.shape[0],1)
   TF_sp126 = tmp_sp126.sum(dim=["x","y"]) / aa
   ax.plot(s1_years,TF_sp126.values,color='sandybrown',linewidth=1.0,label='ssp126')

if len(list_sp245):
   s2 = xr.open_mfdataset(list_sp245,decode_times=False)
   tmp_sp245 = s2.TF * bm.mask
   s2_year0 = 2015
   s2_years = np.arange(s2_year0,s2_year0+s2.time.shape[0],1)
   TF_sp245 = tmp_sp245.sum(dim=["x","y"]) / aa
   ax.plot(s2_years,TF_sp245.values,color='orangered',linewidth=1.0,label='ssp245')

if len(list_sp585):
   s5 = xr.open_mfdataset(list_sp585,decode_times=False)
   tmp_sp585 = s5.TF * bm.mask
   s5_year0 = 2015
   s5_years = np.arange(s5_year0,s5_year0+s5.time.shape[0],1)
   TF_sp585 = tmp_sp585.sum(dim=["x","y"]) / aa
   ax.plot(s5_years,TF_sp585.values,color='firebrick',linewidth=1.0,label='ssp585')

ax.set_title(model)
ax.set_ylabel('Thermal Forcing (°C)')
ax.legend(loc='upper left')

figname='TF_timeseries_'+model+'.pdf'

fig.savefig(figname)
