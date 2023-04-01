import numpy as np
import glob
from to_stereo import to_stereo

# ISMIP6 grid :
f1='/data/njourdain/DATA_ISMIP6/imbie2_basin_numbers_8km_v2.nc'

# CMIP data path :
cmip_dir='/bdd/CMIP6'

# output dir :
out_dir='/scratchu/njourdain/CMIP6_ON_ISMIP6_GRID'

#model_list = ['MPI-ESM1-2-HR','UKESM1-0-LL','IPSL-CM6A-LR','CESM2','CNRM-CM6-1','NorESM2-MM','CESM2-WACCM','MRI-ESM2-0','ACCESS-CM2','CanESM5','GISS-E2-1-H']
model_list = ['GISS-E2-1-H']
#scenar_list = ['historical','ssp126','ssp245','ssp585','piControl']
scenar_list = ['historical']
#var_list=['thetao','so']
var_list=['thetao','so']

for model in model_list:

    namlon='longitude'
    namlat='latitude'
    namlev='lev'
    member='r1i1p1f1'
    grd='gn'
    ll2d=True # 2d lon lat
    if ( model[0:4] == 'MPI-' ):  
        institute='MPI-M'
    elif ( model[0:5] == 'UKESM' ):  
        institute='MOHC'
        #member='r4i1p1f2'
        member='r1i1p1f2'
    elif ( model[0:4] == 'IPSL' ):
        institute='IPSL'
        namlon='nav_lon'
        namlat='nav_lat'
        namlev='olevel'
        #member='r1i1p1f1'
        #member='r3i1p1f1'
        member='r25i1p1f1'
    elif ( model[0:4] == 'CESM' ):
        institute='NCAR'
        namlon='lon'
        namlat='lat'
        #member='r11i1p1f1' # for CESM2
        member='r1i1p1f1' # for CESM2-WACCM
    elif ( model[0:4] == 'CNRM' ):
        institute='CNRM-CERFACS'
        namlon='lon'
        namlat='lat'
        member='r1i1p1f2'
    elif ( model[0:7] == 'NorESM2' ):
        institute='NCC'
        grd='gr'
    elif ( model[0:4] == 'MRI-' ):
        institute='MRI'
    elif ( model[0:10] == 'ACCESS-CM2' ):
        institute='CSIRO-ARCCSS'
    elif ( model[0:7] == 'CanESM5' ):
        institute='CCCma'
    elif ( model[0:9] == 'GISS-E2-1' ):
        institute='NASA-GISS'
        namlon='lon'
        namlat='lat'
        member='r1i1p1f2'
        grd='gr'
        ll2d=False
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
                var_dir=cmip_dir+'/ScenarioMIP/'+institute+'/'+model+'/'+scenar+'/'+member+'/Omon/'+var+'/'+grd+'/latest'
            else:
                var_dir=cmip_dir+'/CMIP/'+institute+'/'+model+'/'+scenar+'/'+member+'/Omon/'+var+'/'+grd+'/latest'

            # grouping by minimum 10-year periods :

            for period in np.arange(100,300,1):

                file_list= sorted(glob.glob(var_dir+'/'+var+'_Omon_'+model+'_'+scenar+'_'+member+'_'+grd+'_'\
                                           +period.astype(str)+'*.nc'))

                if ( len(file_list) ): # file_list not empty
    
                    print(file_list)
    
                    first_date=file_list[0][-16:-10]
                    last_date=file_list[-1][-9:-3]
    
                    out_file=out_dir+'/'+var+'_Omon_'+model+'_'+scenar+'_'+member+'_'+first_date+'_'+last_date+'.nc'

                    to_stereo(ismip_grid_file=f1,cmip_file_list=file_list,file_out=out_file,var_name=var,\
                              lon_name=namlon,lat_name=namlat,lev_name=namlev,lonlat2d=ll2d)

print('[oK]')
