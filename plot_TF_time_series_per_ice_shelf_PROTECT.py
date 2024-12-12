import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import glob

fig, axs = plt.subplots(nrows=2,ncols=2,figsize=(21.0,14.0))
axs = axs.ravel()

bm = xr.open_dataset('/data/njourdain/DATA_ISMIP6/BedMachineAntarctica_2020-07-15_v02_8km.nc')

dirTF='/data/njourdain/DATA_PROTECT/TF_on_ice_draft'

var='TFrms'

model  = [ 'IPSL-CM6A-LR', 'IPSL-CM6A-LR'   , 'UKESM1-0-LL', 'UKESM1-0-LL', 'CESM2-WACCM', 'CESM2-WACCM', 'ACCESS-CM2', 'ACCESS-CM2' ]
member = [ 'r1i1p1f1'    , 'r1i1p1f1'       , 'r4i1p1f2'   , 'r4i1p1f2'   , 'r1i1p1f1'   , 'r1i1p1f1'   , 'r1i1p1f1'  , 'r1i1p1f1'   ]
scenar = [ 'ssp585'      , 'ssp126'         , 'ssp585'     , 'ssp126'     , 'ssp585'     , 'ssp126'     , 'ssp585'    , 'ssp126'     ]
colors = [ 'mediumblue'  , 'cornflowerblue' , 'red'        , 'gold'       , 'purple'     , 'violet'     , 'darkgreen' , 'limegreen'  ]

isf  = ['(a) Ross Ice Shelf', '(b) Ronne-Filchner' , '(c) Thwaites-PIG' , '(d) Totten-Moscow']
imin = [         304        ,          189         ,         169        ,          649       ]
imax = [         435        ,          320         ,         195        ,          672       ]
jmin = [         199        ,          389         ,         319        ,          201       ]
jmax = [         350        ,          530         ,         350        ,          265       ]

for kisf in np.arange(len(imax)):
      
   aa = bm.mask.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf])).sum(dim=["x","y"]).values

   for kmod in np.arange(np.shape(model)[0]):

      print(isf[kisf],model[kmod])
   
      if ( scenar[kmod] == 'ssp585' ):
        list_his = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model[kmod]+'_historical_'+member[kmod]+'_*12.nc')) 
        hi = xr.open_mfdataset(list_his,decode_times=False)
        tmp_histo = hi.TF.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf])) * bm.mask.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf]))
        hi_year0 = 1850
        hi_years = np.arange(hi_year0,hi_year0+hi.time.shape[0],1)
        TF_histo = tmp_histo.sum(dim=["x","y"]) / aa
        axs[kisf].plot(hi_years,TF_histo.values,color=colors[kmod],linewidth=1.5)

      list_ssp = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model[kmod]+'_'+scenar[kmod]+'_'+member[kmod]+'_*12.nc')) 
      ssp = xr.open_mfdataset(list_ssp,decode_times=False)
      tmp_sp585 = ssp.TF.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf])) * bm.mask.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf]))
      ssp_year0 = 2015
      ssp_years = np.arange(ssp_year0,ssp_year0+ssp.time.shape[0],1)
      TF_sp585 = tmp_sp585.sum(dim=["x","y"]) / aa
      axs[kisf].plot(ssp_years,TF_sp585.values,color=colors[kmod],linewidth=1.5,label=model[kmod]+' ('+scenar[kmod]+')')

   axs[kisf].set_title(isf[kisf],fontsize=20,fontweight='bold')
   axs[kisf].set_ylabel('Thermal Forcing (°C)',fontsize=16)
   axs[kisf].set_xlim([1980,2200])
   axs[kisf].tick_params(axis='both', which='both', labelsize=14)

axs[0].legend(loc='upper left',fontsize=14)

figname='TF_timeseries_all_models_PROTECT.pdf'

fig.savefig(figname)
