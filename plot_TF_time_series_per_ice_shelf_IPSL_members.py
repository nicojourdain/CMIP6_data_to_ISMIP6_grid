import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import glob

fig, axs = plt.subplots(nrows=2,ncols=2,figsize=(21.0,14.0))
axs = axs.ravel()

bm = xr.open_dataset('/data/njourdain/DATA_ISMIP6/BedMachineAntarctica_2020-07-15_v02_8km.nc')

dirTF='/data/njourdain/DATA_PROTECT/TF_on_ice_draft'

var='TFavg'

model = 'IPSL-CM6A-LR'

member = [ 'r1i1p1f1'      , 'r3i1p1f1'  , 'r4i1p1f1' , 'r5i1p1f1' , 'r6i1p1f1' , 'r7i1p1f1' , 'r8i1p1f1' , 'r9i1p1f1' , 'r10i1p1f1'  , 'r11i1p1f1', 'r15i1p1f1', 'r20i1p1f1', 'r25i1p1f1', 'r26i1p1f1'  ]
colors = [ 'cornflowerblue', 'darkblue'  , 'yellow'   , 'brown'    ,  'cyan'    ,  'magenta' , 'chartreuse' ,   'green'  ,    'red'   , 'orange'   , 'lightpink', 'olive'    , 'gold'     , 'lavender'   ]

isf  = ['(a) Ross Ice Shelf', '(b) Ronne-Filchner' , '(c) Thwaites-PIG' , '(d) Totten-Moscow']
imin = [         304        ,          189         ,         169        ,          649       ]
imax = [         435        ,          320         ,         195        ,          672       ]
jmin = [         199        ,          389         ,         319        ,          201       ]
jmax = [         350        ,          530         ,         350        ,          265       ]

for kisf in np.arange(len(imax)):
      
   aa = bm.mask.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf])).sum(dim=["x","y"]).values

   for kmemb in np.arange(np.shape(member)[0]):

      print(isf[kisf],member[kmemb])
   
      list_histo = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model+'_historical_'+member[kmemb]+'_*12.nc')) 
      
      if len(list_histo):
         print(list_histo)
         hi = xr.open_mfdataset(list_histo,decode_times=False)
         tmp_histo = hi.TF.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf])) * bm.mask.isel(x=slice(imin[kisf],imax[kisf]),y=slice(jmin[kisf],jmax[kisf]))
         hi_year0 = 1850
         hi_years = np.arange(hi_year0,hi_year0+hi.time.shape[0],1)
         TF_histo = tmp_histo.sum(dim=["x","y"]) / aa
         axs[kisf].plot(hi_years,TF_histo.values,color=colors[kmemb],linewidth=1.5,label='historical')
      
      if kisf==0:
         if kmemb < 7:
           axs[kisf].plot([1875,1900],[5.5-kmemb*0.5,5.5-kmemb*0.5],color=colors[kmemb],linewidth=1.5)
           axs[kisf].text(1905,5.5-kmemb*0.5,member[kmemb],fontsize=16,va='center')
         else:
           axs[kisf].plot([1975,2000],[5.5-(kmemb-7)*0.5,5.5-(kmemb-7)*0.5],color=colors[kmemb],linewidth=1.5)
           axs[kisf].text(2005,5.5-(kmemb-7)*0.5,member[kmemb],fontsize=16,va='center')
   
   axs[kisf].set_title(isf[kisf],fontsize=20,fontweight='bold')
   axs[kisf].set_ylabel('Thermal Forcing (°C)',fontsize=16)
   axs[kisf].set_xlim([1850,2060])
   #axs[kisf].set_ylim([0,3.5])
   axs[kisf].tick_params(axis='both', which='both', labelsize=14)

figname='TF_timeseries_IPSL_members.pdf'

fig.savefig(figname)
