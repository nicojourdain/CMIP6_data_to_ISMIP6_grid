import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import glob

fig, axs = plt.subplots(nrows=3,ncols=1,figsize=(20.0,25.0))
axs = axs.ravel()

bm = xr.open_dataset('/data/njourdain/DATA_ISMIP6/BedMachineAntarctica_2020-07-15_v02_8km.nc')

dirTF='/data/njourdain/DATA_PROTECT/TF_on_ice_draft'

var='TFrms'

model  = [ 'IPSL-CM6A-LR', 'UKESM1-0-LL', 'MPI-ESM1-2-HR' ]

#isf  = ['(a) Ross Ice Shelf', '(b) Ronne-Filchner' , '(c) Thwaites-PIG' , '(d) Totten-Moscow']
#imin = [         304        ,          189         ,         169        ,          649       ]
#imax = [         435        ,          320         ,         195        ,          672       ]
#jmin = [         199        ,          389         ,         319        ,          201       ]
#jmax = [         350        ,          530         ,         350        ,          265       ]
# Thwaites-PIG :
imin = 169
imax = 195
jmin = 319
jmax = 350

aa = bm.mask.isel(x=slice(imin,imax),y=slice(jmin,jmax)).sum(dim=["x","y"]).values

col= [ 'cornflowerblue', 'orange', 'firebrick', 'limegreen', 'darkmagenta' ]

for kmod in np.arange(np.shape(model)[0]):

     print(model[kmod])

     list_piC = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model[kmod]+'_piControl_*12.nc'))
     pi = xr.open_mfdataset(list_piC,decode_times=False)
     tmp_piC = pi.TF.isel(x=slice(imin,imax),y=slice(jmin,jmax)) * bm.mask.isel(x=slice(imin,imax),y=slice(jmin,jmax))
     pi_year0 = 0
     pi_years = np.arange(pi_year0,pi_year0+pi.time.shape[0],1)
     TF_piC = tmp_piC.sum(dim=["x","y"]) / aa
     axs[kmod].plot(pi_years,TF_piC.values,color='k',linewidth=2.5)

     if ( model[kmod] == 'IPSL-CM6A-LR' ):
        member = [ 'r1i1p1f1', 'r3i1p1f1', 'r6i1p1f1', 'r11i1p1f1', 'r25i1p1f1' ]
        hi_year0 = np.array([ 1910, 1930, 2030, 2230, 2370]) - 1850
        al='(a)'
     elif ( model[kmod] == 'UKESM1-0-LL' ):
        member = [ 'r1i1p1f2', 'r2i1p1f2', 'r4i1p1f2', 'r8i1p1f2' ]
        hi_year0 = np.array([ 2250, 2165, 1960, 2395 ]) - 1860
        al='(b)'
     elif ( model[kmod] == 'MPI-ESM1-2-HR' ):
        member = [ 'r1i1p1f1', 'r2i1p1f1' ]
        hi_year0 = np.array([ 1850, 1900 ]) - 1850
        al='(c)'

     for kmem in np.arange(np.shape(member)[0]):

        print('   ',member[kmem])

        list_his = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model[kmod]+'_historical_'+member[kmem]+'_*12.nc')) 
        hi = xr.open_mfdataset(list_his,decode_times=False)
        tmp_histo = hi.TF.isel(x=slice(imin,imax),y=slice(jmin,jmax)) * bm.mask.isel(x=slice(imin,imax),y=slice(jmin,jmax))
        hi_years = np.arange(hi_year0[kmem],hi_year0[kmem]+hi.time.shape[0],1)
        TF_histo = tmp_histo.sum(dim=["x","y"]) / aa
        axs[kmod].plot(hi_years,TF_histo.values,color=col[kmem],linewidth=1.5)
        print(TF_histo[145:165].mean().values)

        list_ssp = sorted(glob.glob(dirTF+'/'+var+'_ISdraft_Oyr_'+model[kmod]+'_ssp245_'+member[kmem]+'_201501_210012.nc')) 
        ssp = xr.open_mfdataset(list_ssp,decode_times=False)
        tmp_sp245 = ssp.TF.isel(x=slice(imin,imax),y=slice(jmin,jmax)) * bm.mask.isel(x=slice(imin,imax),y=slice(jmin,jmax))
        ssp_years = np.arange(hi_year0[kmem]+2015-1850,hi_year0[kmem]+2015-1850+ssp.time.shape[0],1)
        TF_sp245 = tmp_sp245.sum(dim=["x","y"]) / aa
        axs[kmod].plot(ssp_years,TF_sp245.values,color=col[kmem],linewidth=1.5,linestyle=':')

     axs[kmod].plot([0,800],[1.33,1.33],'--','k',linewidth=0.75)
     axs[kmod].set_title(al+' '+model[kmod],fontsize=20,fontweight='bold')
     axs[kmod].set_ylabel('Thermal Forcing (°C)',fontsize=16)
     axs[kmod].set_xlim([0,800])
     axs[kmod].tick_params(axis='both', which='both', labelsize=14)

figname='TF_timeseries_piControl_members.pdf'

fig.savefig(figname)
