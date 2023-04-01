import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import glob

fig, axs = plt.subplots(nrows=2,ncols=2,figsize=(21.0,14.0))
axs = axs.ravel()

bm = xr.open_dataset('/data/njourdain/DATA_ISMIP6/BedMachineAntarctica_2020-07-15_v02_8km.nc')

dirTF='/data/njourdain/DATA_PROTECT/TF_on_ice_draft'

var='TFrms'

model  = [ 'IPSL-CM6A-LR'  , 'CNRM-CM6-1', 'CESM2'     , 'UKESM1-0-LL', 'MRI-ESM2-0', 'CESM2-WACCM' , 'MPI-ESM1-2-HR' , 'ACCESS-CM2' ]
member = ['r1i1p1f1'       , 'r1i1p1f2'  , 'r11i1p1f1' , 'r4i1p1f2'   , 'r1i1p1f1'  ,  'r1i1p1f1'   ,   'r1i1p1f1'    ,  'r1i1p1f1'  ]
colors = ['cornflowerblue' , 'darkblue'  , 'orange'    , 'brown'      ,  'cyan'     ,   'magenta'   ,   'chartreuse'  ,    'green'   ]

isf  = ['(a) Ross Ice Shelf', '(b) Ronne-Filchner' , '(c) Thwaites-PIG' , '(d) Totten-Moscow']
imin = [         304        ,          189         ,         169        ,          649       ]
imax = [         435        ,          320         ,         195        ,          672       ]
jmin = [         199        ,          389         ,         319        ,          201       ]
jmax = [         350        ,          530         ,         350        ,          265       ]

for kisf in np.arange(len(imax)):
      
   aa = bm.mask.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf])).sum(dim=["x","y"]).values

   for kmod in np.arange(np.shape(model)[0]):

      print(isf[kisf],model[kmod])
   
      list_histo = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model[kmod]+'_historical_'+member[kmod]+'_*12.nc')) 
      list_sp126 = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model[kmod]+'_ssp126_'+member[kmod]+'_*12.nc')) 
      list_sp585 = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model[kmod]+'_ssp585_'+member[kmod]+'_*12.nc')) 
      
      if len(list_histo):
         hi = xr.open_mfdataset(list_histo,decode_times=False)
         tmp_histo = hi.TF.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf])) * bm.mask.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf]))
         hi_year0 = 1850
         hi_years = np.arange(hi_year0,hi_year0+hi.time.shape[0],1)
         TF_histo = tmp_histo.sum(dim=["x","y"]) / aa
         axs[kisf].plot(hi_years,TF_histo.values,color=colors[kmod],linewidth=1.5,label='historical')
      
#      if len(list_sp126):
#         s1 = xr.open_mfdataset(list_sp126,decode_times=False)
#         tmp_sp126 = s1.TF.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf])) * bm.mask.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf]))
#         s1_year0 = 2015
#         s1_years = np.arange(s1_year0,s1_year0+s1.time.shape[0],1)
#         TF_sp126 = tmp_sp126.sum(dim=["x","y"]) / aa
#         axs[kisf].plot(s1_years,TF_sp126.values,color=colors[kmod],linestyle='--',linewidth=1.5,label='ssp126')
      
      if len(list_sp585):
         s5 = xr.open_mfdataset(list_sp585,decode_times=False)
         tmp_sp585 = s5.TF.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf])) * bm.mask.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf]))
         s5_year0 = 2015
         s5_years = np.arange(s5_year0,s5_year0+s5.time.shape[0],1)
         TF_sp585 = tmp_sp585.sum(dim=["x","y"]) / aa
         axs[kisf].plot(s5_years,TF_sp585.values,color=colors[kmod],linewidth=1.5,label='ssp585')

      if kisf==0:
         axs[kisf].plot([1875,1900],[6.5-kmod*0.5,6.5-kmod*0.5],color=colors[kmod],linewidth=1.5)
         #axs[kisf].plot([1875,1900],[3.0-kmod*0.3,3.0-kmod*0.3],color=colors[kmod],linewidth=1.5)
         axs[kisf].text(1910,6.5-kmod*0.5,model[kmod],fontsize=16,va='center')
         #axs[kisf].text(1910,3.0-kmod*0.3,model[kmod],fontsize=16,va='center')
   
   axs[kisf].set_title(isf[kisf],fontsize=20,fontweight='bold')
   axs[kisf].set_ylabel('Thermal Forcing (°C)',fontsize=16)
   axs[kisf].set_xlim([1850,2300])
   #axs[kisf].set_ylim([0,3.5])
   axs[kisf].tick_params(axis='both', which='both', labelsize=14)

figname='TF_timeseries_all_models.pdf'

fig.savefig(figname)
