import numpy as np
import glob
from to_stereo_2d import to_stereo_2d

# PROTECT RCM grid :
f1='/data/njourdain/DATA_PROTECT/TAS/RCM_ice_regrid_04000m.nc'

# CMIP data path :
cmip_dir='/bdd/CMIP6'

# output dir :
out_dir='/scratchu/njourdain/CMIP6_ON_ISMIP6_GRID'

#model_list = ['MPI-ESM1-2-HR','UKESM1-0-LL','IPSL-CM6A-LR','CESM2','CNRM-CM6-1','NorESM2-MM','CESM2-WACCM','MRI-ESM2-0','ACCESS-CM2','CanESM5','GISS-E2-1-H','ACCESS-ESM1-5','CNRM-ESM2-1','GFDL-CM4','GFDL-ESM4']
model_list = ['CNRM-CM6-1']
#scenar_list = ['historical','ssp126','ssp245','ssp585','piControl']
scenar_list = ['ssp585']
#var_list=['tas','pr','evspsbl','mrro','mrros']
var_list=['pr','evspsbl']

for model in model_list:

    namlon='longitude'
    namlat='latitude'
    member='r1i1p1f1'
    grd='gr'
    if ( model[0:4] == 'MPI-' ):  
        institute='MPI-M'
        namlon='lon'
        namlat='lat'
        grd='gn'
    elif ( model[0:5] == 'UKESM' ):  
        institute='MOHC'
        member='r1i1p1f2'
        namlon='lon'
        namlat='lat'
        grd='gn'
    elif ( model[0:4] == 'IPSL' ):
        institute='IPSL'
        namlon='lon'
        namlat='lat'
        member='r1i1p1f1'
    elif ( model[0:4] == 'CESM' ):
        institute='NCAR'
        namlon='lon'
        namlat='lat'
        #member='r11i1p1f1' # for CESM2
        member='r1i1p1f1' # for CESM2-WACCM
        grd='gn'
    elif ( model[0:4] == 'CNRM' ):
        institute='CNRM-CERFACS'
        namlon='lon'
        namlat='lat'
        member='r1i1p1f2'
    elif ( model[0:7] == 'NorESM2' ):
        institute='NCC'
        namlon='lon'
        namlat='lat'
        grd='gn'
    elif ( model[0:4] == 'MRI-' ):
        institute='MRI'
        namlon='lon'
        namlat='lat'
        grd='gn'
    elif ( model[0:10] == 'ACCESS-CM2' ):
        institute='CSIRO-ARCCSS'
        namlon='lon'
        namlat='lat'
        grd='gn'
    elif ( model[0:13] == 'ACCESS-ESM1-5' ):
        institute='CSIRO'
        namlon='lon'
        namlat='lat'
        grd='gn'
    elif ( model[0:7] == 'CanESM5' ):
        institute='CCCma'
        namlon='lon'
        namlat='lat'
        grd='gn'
    elif ( model[0:9] == 'GISS-E2-1' ):
        institute='NASA-GISS'
        namlon='lon'
        namlat='lat'
        member='r1i1p1f2'
        grd='gn'
        ll2d=False
    elif ( model[0:4] == 'GFDL' ):
        institute='NOAA-GFDL'
        namlon='lon'
        namlat='lat'
    else:
        institute='NOT_PROVIDED'

    print(' ')
    print('===== ',model,' ',institute,' ',member,' =====')

    for scenar in scenar_list:

        print(' ')
        print('########## ',scenar,' ##########')

        for var in var_list:

            print(' ')
            print('---------- ',var,' ----------')
           
            if ( scenar[0:3] == 'ssp' ):
                var_dir='/scratchu/njourdain/RAW_CMIP6'
                #var_dir=cmip_dir+'/ScenarioMIP/'+institute+'/'+model+'/'+scenar+'/'+member+'/Amon/'+var+'/'+grd+'/latest'
            elif ( scenar[0:3] == 'rcp' ):
                var_dir='/scratchu/njourdain/RAW_CMIP6'
            else:
                var_dir=cmip_dir+'/CMIP/'+institute+'/'+model+'/'+scenar+'/'+member+'/Amon/'+var+'/'+grd+'/latest'
                #var_dir='/scratchu/njourdain/RAW_CMIP6'
            print(var_dir)

            for period in np.arange(100,300,1):

                file_list= sorted(glob.glob(var_dir+'/'+var+'_Amon_'+model+'_'+scenar+'_'+member+'_'+grd+'_'\
                                           +period.astype(str)+'*.nc'))

                if ( len(file_list) ): # file_list not empty
    
                    print(file_list)
    
                    first_date=file_list[0][-16:-10]
                    last_date=file_list[-1][-9:-3]
    
                    out_file=out_dir+'/'+var+'_Amon_'+model+'_'+scenar+'_'+member+'_'+first_date+'_'+last_date+'.nc'

                    to_stereo_2d(ismip_grid_file=f1,cmip_file_list=file_list,file_out=out_file,var_name=var,\
                                 lon_name=namlon,lat_name=namlat)

print('[oK]')
