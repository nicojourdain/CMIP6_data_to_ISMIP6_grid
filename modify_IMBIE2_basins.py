import numpy as np
import xarray as xr

file_in='/data/njourdain/DATA_ISMIP6/imbie2_basin_numbers_8km.nc'
file_out='/data/njourdain/DATA_ISMIP6/imbie2_basin_numbers_8km_v2.nc'

ds=xr.open_dataset(file_in)

def calc_line(x1,y1,x2,y2):
    slope = (y2-y1)/(x2-x1)
    intercept = y2 - slope*x2
    return slope,intercept

# Extend ocean part of the Filchner-Ronne basin (no. 14) :
sW1, iW1 = calc_line(-1460000.,780000.,-1285000.,1400000.)
sW2, iW2 = calc_line(-1285000.,1400000.,-720000.,1050000.)
basinNumber_tmp=ds.basinNumber.where( ~(  (ds.x>-1460000.) & (ds.x<-720000.) \
                                        & (ds.y>780000.)   & (ds.y<1400000.) \
                                        & (ds.y<=sW1*ds.x+iW1) & (ds.y<=sW2*ds.x+iW2) ), 14 )

# Extend ocean part of the Amery basin (no. 2) :
sA1, iA1 = calc_line(2300000.,610000.,2600000.,700000.)
sA2, iA2 = calc_line(2300000.,820000.,2600000.,700000.)
basinNumber_new=basinNumber_tmp.where( ~(  (ds.x>2120000.) & (ds.x<2600000.) \
                                         & (ds.y>610000.)  & (ds.y<820000.) \
                                         & (ds.y>=sA1*ds.x+iA1) & (ds.y<=sA2*ds.x+iA2) ), 2 )

# Create new netcdf file :
outds= xr.Dataset(
   {
   "basinNumber": (["y", "x"], basinNumber_new.values),
   },
   coords={
     "x": ds.x.values,
     "y": ds.y.values,
          },
)

outds.x.encoding['_FillValue'] = None
outds.x.attrs['units'] = 'm'
outds.x.attrs['long_name'] = 'x coordinate'

outds.y.encoding['_FillValue'] = None
outds.y.attrs['units'] = 'm'
outds.y.attrs['long_name'] = 'y coordinate'

outds.attrs['history'] = 'IMBIE2 bassins used in ISMIP6 and modified by Nicolas Jourdain (IGE, Grenoble, FR)'

print('Creating ',file_out)
outds.to_netcdf(file_out)
