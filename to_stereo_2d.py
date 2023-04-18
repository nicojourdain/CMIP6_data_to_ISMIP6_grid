import numpy as np
import xarray as xr
import dask
import glob
from ll2xy import ll2xy
from ll2xyb import ll2xyb
from scipy import interpolate
import time
import os

#=================================================================
def to_stereo_2d(ismip_grid_file,cmip_file_list,file_out='test.nc',\
                 var_name='tas',lon_name='longitude',lat_name='latitude'):

   start=time.time()

   dask.config.set({"array.slicing.split_large_chunks": True})

   # ISMIP grid data :

   grd=xr.open_dataset(ismip_grid_file)

   mxyst = grd.x.size * grd.y.size
   xst_2d,yst_2d = ll2xy(grd.lat, grd.lon, sgn=-1)
   xst_2d_1d = np.reshape(xst_2d.values,mxyst)
   yst_2d_1d = np.reshape(yst_2d.values,mxyst)

   # CMIP data :

   cmip=xr.open_mfdataset(cmip_file_list)

   latmax=-59.0   # only read CMIP file south of that

   var_cmip=eval("cmip."+var_name+".where((cmip."+lat_name+"<latmax),drop=True)")
   mt_cmip,my_cmip,mx_cmip = var_cmip.shape
   mxy_cmip = mx_cmip*my_cmip
   print('CMIP File Size : ',mx_cmip,my_cmip,mt_cmip)

  # 2d lon lat :
   print(np.shape(eval("cmip."+lon_name+".values")))
   lon_cmip,lat_cmip = eval("np.meshgrid(cmip."+lon_name+".values,cmip."+lat_name+".where((cmip."+lat_name+"<latmax),drop=True).values,indexing='xy')")
   print(np.shape(lon_cmip))
   print(np.shape(lat_cmip))

   x_cmip, y_cmip = ll2xyb(np.reshape(lat_cmip, mxy_cmip), np.reshape(lon_cmip, mxy_cmip), sgn=-1)

   x_cmip_1d = np.reshape( x_cmip, mxy_cmip)
   y_cmip_1d = np.reshape( y_cmip, mxy_cmip)

   # Interpolation :

   count=-1
   alphabet='abcdefghijklmnopqrstuvwxyz'
   for ks in np.arange(0,mt_cmip,120): # slices of 10-year maximum

       count=count+1

       new_file_out = file_out.replace('.nc','_'+alphabet[count]+'.nc')

       if os.path.exists(new_file_out) :

           print('already there : ',new_file_out)

       else:

           var_out = np.zeros((np.arange(ks,min([mt_cmip,ks+120])).size, grd.y.size, grd.x.size))*np.nan
           tmp = var_cmip.isel(time=slice(ks,min([mt_cmip,ks+120]))).values.reshape(np.arange(ks,min([mt_cmip,ks+120])).size, mxy_cmip)
           var_tmp = np.zeros((grd.y.size, grd.x.size))*np.nan
       
           for kt in np.arange(np.arange(ks,min([mt_cmip,ks+120])).size):
    
                # horizontal interpolation
        
                var_cmip_1d = tmp[kt,:]
        
                var_st_1d = interpolate.griddata( (x_cmip_1d,y_cmip_1d), var_cmip_1d, (xst_2d_1d,yst_2d_1d), \
                                                     method='linear', fill_value=np.nan )
        
                var_out[kt,:,:] = np.reshape( var_st_1d, (grd.y.size,grd.x.size) )
        
        
           # save netcdf file :
           
           outds= xr.Dataset(
              {
              var_name:        (["time", "y", "x"], np.float32(var_out)),
              },
              coords={
              "x": np.float32(grd.x.values),
              "y": np.float32(grd.y.values),
              "time": cmip.time.isel(time=slice(ks,min([mt_cmip,ks+120]))).values
              },
           )
        
           outds.x.encoding['_FillValue'] = None
           outds.x.attrs['units'] = 'm'
           outds.x.attrs['long_name'] = 'x coordinate'
            
           outds.y.encoding['_FillValue'] = None
           outds.y.attrs['units'] = 'm'
           outds.y.attrs['long_name'] = 'y coordinate'
            
           outds.time.encoding['units'] = 'days since 1850-01-01'
           outds.time.encoding['_FillValue'] = None
           outds.time.attrs['standard_name'] = 'time'
           
           # global attributes :
           outds.attrs['history'] = 'interpolated by Nicolas Jourdain (IGE, Grenoble, FR)' 
           outds.attrs['project'] = 'EU-H2020-PROTECT'
            
           print('Creating ',new_file_out)
           outds.to_netcdf(new_file_out,mode='w',unlimited_dims="time")


#=================================================================

