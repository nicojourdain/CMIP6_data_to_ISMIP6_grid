import numpy as np
import xarray as xr
import glob
from ll2xy import ll2xy
from scipy import interpolate
import time

#=================================================================
def vertical_interp(original_depth,interpolated_depth):
   """ Find upper and lower bound indices for simple vertical 1d interpolation
   """
   if ( original_depth[1] < original_depth[0] ):
     ll_kupward = True
   else:
     ll_kupward = False
   nn = np.size(interpolated_depth)
   kinf=np.zeros(nn,dtype='int')
   ksup=np.zeros(nn,dtype='int')
   for k in np.arange(nn):
      knear = np.argmin( np.abs( original_depth - interpolated_depth[k] ) )
      if (original_depth[knear] > interpolated_depth[k]):
        ksup[k] = knear
        if ll_kupward:
          kinf[k] = np.min([ np.size(original_depth)-1, knear+1 ])
        else:
          kinf[k] = np.max([ 0, knear-1 ])
      else:
        kinf[k] = knear
        if ll_kupward:
          ksup[k] = np.max([ 0, knear-1 ])
        else:
          ksup[k] = np.min([ np.size(original_depth)-1, knear+1 ])
   return (kinf,ksup)


#=================================================================
def to_stereo(ismip_grid_file,cmip_file_list,file_out='test.nc',\
              var_name='thetao',lon_name='longitude',lat_name='latitude',lev_name='lev'):

   start=time.time()

   # ISMIP grid data :

   grd=xr.open_dataset(ismip_grid_file)

   mxyst = grd.x.size * grd.y.size
   xst_2d,yst_2d = np.meshgrid(grd.x.values,grd.y.values,indexing='xy')
   xst_2d_1d = np.reshape(xst_2d,mxyst)
   yst_2d_1d = np.reshape(yst_2d,mxyst)

   # CMIP data :

   cmip=xr.open_mfdataset(cmip_file_list)

   latmax=-59.0   # only read CMIP file south of that
   depmax=2200.0  # only read CMIP file above this depth

   var_cmip=eval("cmip."+var_name+".where((cmip."+lat_name+"<latmax)&(cmip."+lev_name+"<depmax),drop=True)")
   mt_cmip,mz_cmip,my_cmip,mx_cmip = var_cmip.shape
   mxy_cmip = mx_cmip*my_cmip
   print('CMIP File Size : ',mx_cmip,my_cmip,mz_cmip,mt_cmip)

   lon_cmip=eval("cmip."+lon_name+".where((cmip."+lat_name+"<latmax),drop=True)")
   lat_cmip=eval("cmip."+lat_name+".where((cmip."+lat_name+"<latmax),drop=True)")
   lev_cmip=eval("cmip."+lev_name+".where((cmip."+lev_name+"<depmax),drop=True).values")

   #print(var_cmip.shape,lon_cmip.shape)

   x_cmip, y_cmip = ll2xy(lat_cmip, lon_cmip, sgn=-1)

   x_cmip_1d = np.reshape( x_cmip.values, mxy_cmip)
   y_cmip_1d = np.reshape( y_cmip.values, mxy_cmip)

   # Interpolation :

   ismip_depth = np.arange(30.,1830.,60.)
   kinf,ksup = vertical_interp(lev_cmip,ismip_depth)
   #for kzis in np.arange(ismip_depth.size):
   #  print(ismip_depth[kzis],lev_cmip[ksup[kzis]],lev_cmip[kinf[kzis]])

   #var_out = np.zeros((mt_cmip, ismip_depth.size, grd.y.size, grd.x.size))*np.nan
   #tmp = var_cmip.values.reshape((mt_cmip, mz_cmip, mxy_cmip))

   count=-1
   alphabet='abcdefghijklmnopqrstuvwxyz'
   for ks in np.arange(0,mt_cmip,120): # slices of 10-year maximum

       count=count+1

       new_file_out = file_out.replace('.nc','_'+alphabet[count]+'.nc')

       var_out = np.zeros((np.arange(ks,min([mt_cmip,ks+120])).size, ismip_depth.size, grd.y.size, grd.x.size))*np.nan
       tmp = var_cmip.isel(time=slice(ks,min([mt_cmip,ks+120]))).values.reshape(np.arange(ks,min([mt_cmip,ks+120])).size, mz_cmip, mxy_cmip)
       var_tmp = np.zeros((mz_cmip, grd.y.size, grd.x.size))*np.nan
   
       for kt in np.arange(np.arange(ks,min([mt_cmip,ks+120])).size):

           for kz in np.arange(mz_cmip):
    
               # horizontal interpolation
    
               var_cmip_1d = tmp[kt,kz,:]
    
               var_st_1d = interpolate.griddata( (x_cmip_1d,y_cmip_1d), var_cmip_1d, (xst_2d_1d,yst_2d_1d), \
                                                 method='linear', fill_value=np.nan )
    
               var_tmp[kz,:,:] = np.reshape( var_st_1d, (grd.y.size,grd.x.size) )
    
           # vertical interpolation :
    
           for kzis in np.arange(ismip_depth.size):
    
               var_out[kt,kzis,:,:] = (   var_tmp[kinf[kzis],:,:] * (ismip_depth[kzis]-lev_cmip[ksup[kzis]])   \
                                        + var_tmp[ksup[kzis],:,:] * (lev_cmip[kinf[kzis]]-ismip_depth[kzis]) ) \
                                      / (lev_cmip[kinf[kzis]]-lev_cmip[ksup[kzis]])
    
       # save netcdf file :
       
       outds= xr.Dataset(
          {
          var_name:        (["time", "z", "y", "x"], np.float32(var_out)),
          },
          coords={
          "x": np.float32(grd.x.values),
          "y": np.float32(grd.y.values),
          "z": np.float32(ismip_depth*(-1)),
          "time": cmip.time.isel(time=slice(ks,min([mt_cmip,ks+120]))).values
          },
       )
    
       outds.x.encoding['_FillValue'] = None
       outds.x.attrs['units'] = 'm'
       outds.x.attrs['long_name'] = 'x coordinate'
        
       outds.y.encoding['_FillValue'] = None
       outds.y.attrs['units'] = 'm'
       outds.y.attrs['long_name'] = 'y coordinate'
        
       outds.z.encoding['_FillValue'] = None
       outds.z.attrs['units'] = 'm'
       outds.z.attrs['long_name'] = 'depth'
       outds.z.attrs['positive'] = 'up'
        
       outds.time.encoding['units'] = 'days since 1850-01-01'
       outds.time.encoding['_FillValue'] = None
       outds.time.attrs['standard_name'] = 'time'
       
       # global attributes :
       outds.attrs['history'] = 'interpolated by Nicolas Jourdain (IGE, Grenoble, FR)' 
       outds.attrs['project'] = 'EU-H2020-PROTECT'
        
       print('Creating ',new_file_out)
       outds.to_netcdf(new_file_out,mode='w',unlimited_dims="time")


#=================================================================

