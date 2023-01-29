program modif
 
USE netcdf
 
IMPLICIT NONE
 
INTEGER :: fidTin, fidTclim, fidTobs, fidTout, fidSin, fidSclim, fidSobs, fidSout, status,    &
&          dimID_nbounds, mnbounds, dimID_time, dimID_z, dimID_y, dimID_x, dimID_time_out_T,  &
&          dimID_z_out_T, dimID_y_out_T, dimID_x_out_T, mtime, mz, my, mx, time_ID, ktout,    &
&          thetao_ID, x_ID, y_ID, z_ID, x_out_T_ID, y_out_T_ID, z_out_T_ID, ll, kt,           &
&          Tcor_ID, Scor_ID, tmp_ID, time_out_T_ID, time_out_S_ID, fidTFavg, fidTFrms,        &
&          ki, kj, kz, thetao_out_ID, x_out_TFrms_ID, y_out_TFrms_ID, z_out_TFrms_ID,         &
&          dimID_time_out_S, dimID_z_out_S, dimID_y_out_S, dimID_x_out_S, so_out_ID,          &
&          dimID_time_out_TFavg, dimID_z_out_TFavg, dimID_y_out_TFavg, dimID_x_out_TFavg,     &
&          dimID_time_out_TFrms, dimID_z_out_TFrms, dimID_y_out_TFrms, dimID_x_out_TFrms,     &
&          x_out_S_ID, y_out_S_ID, z_out_S_ID, z_bnds_ID, so_ID,                              &
&          x_out_TFavg_ID, y_out_TFavg_ID, z_out_TFavg_ID, TFavg_out_ID, TFrms_out_ID,        &
&          time_out_TFavg_ID, time_out_TFrms_ID, dimID_nbounds_out_T, dimID_nbounds_out_S,    &
&          dimID_nbounds_out_TFavg, dimID_nbounds_out_TFrms, z_bnds_out_T_ID, z_bnds_out_S_ID,&
&          z_bnds_out_TFavg_ID, z_bnds_out_TFrms_ID
 
CHARACTER(LEN=150) :: file_in_Tobs, file_in_Sobs, file_in_Tclim, file_in_Sclim, file_in_T,   &
&                     file_out_T, file_in_S, file_out_S, file_out_TFavg, file_out_TFrms
 
REAL*4,ALLOCATABLE,DIMENSION(:) :: x, y, z
 
REAL*4,ALLOCATABLE,DIMENSION(:,:) :: z_bnds

REAL*8,ALLOCATABLE,DIMENSION(:) :: time
 
REAL*4,ALLOCATABLE,DIMENSION(:,:,:) :: tmp, Tcor, Scor

REAL*4,ALLOCATABLE,DIMENSION(:,:,:,:) :: thetao, so

REAL*8,DIMENSION(1) :: time_out

REAL*4 :: aa, lbd1, lbd2, lbd3

!---------------------------------------

file_in_Tobs  = '/data/njourdain/DATA_ISMIP6/obs_temperature_1995-2017_8km_x_60m.nc'
file_in_Sobs  = '/data/njourdain/DATA_ISMIP6/obs_salinity_1995-2017_8km_x_60m.nc'

file_in_Tclim  = '/data/njourdain/DATA_PROTECT/<model>/thetao_Clim_<model>_<scenar>_<member>_199501_201412.nc'
file_in_Sclim  = '/data/njourdain/DATA_PROTECT/<model>/so_Clim_<model>_<scenar>_<member>_199501_201412.nc'
 
file_in_T  = '/scratchu/njourdain/CMIP6_ON_ISMIP6_GRID/EXTRAPOLATED/thetao_Omon_<model>_<scenar>_<member>_<date1>_<date2>_<alpha>.nc'
file_in_S  = '/scratchu/njourdain/CMIP6_ON_ISMIP6_GRID/EXTRAPOLATED/so_Omon_<model>_<scenar>_<member>_<date1>_<date2>_<alpha>.nc'

file_out_T = '/data/njourdain/DATA_PROTECT/<model>/thetao_Oyr_<model>_<scenar>_<member>_<date1>_<date2>_<alpha>.nc'
file_out_S = '/data/njourdain/DATA_PROTECT/<model>/so_Oyr_<model>_<scenar>_<member>_<date1>_<date2>_<alpha>.nc'
file_out_TFavg = '/data/njourdain/DATA_PROTECT/<model>/TFavg_Oyr_<model>_<scenar>_<member>_<date1>_<date2>_<alpha>.nc'
file_out_TFrms = '/data/njourdain/DATA_PROTECT/<model>/TFrms_Oyr_<model>_<scenar>_<member>_<date1>_<date2>_<alpha>.nc'

! Freezing temperature (Asay-Davis et al., 2016) :
lbd1 = -0.0573 ! degC/psu
lbd2 = 0.0832  ! degC
lbd3 = -7.53e-8*1028*9.81 ! degC/m (per meeter of depth, with depth > 0)

!---------------------------------------
! Read observed temperature climatology
 
write(*,*) 'Reading ', TRIM(file_in_Tobs)
 
status = NF90_OPEN(TRIM(file_in_Tobs),0,fidTobs); call erreur(status,.TRUE.,"read obs temp climato")
 
status = NF90_INQ_DIMID(fidTobs,"nbounds",dimID_nbounds); call erreur(status,.TRUE.,"inq_dimID_nbounds")
status = NF90_INQ_DIMID(fidTobs,"z",dimID_z); call erreur(status,.TRUE.,"inq_dimID_z")
status = NF90_INQ_DIMID(fidTobs,"y",dimID_y); call erreur(status,.TRUE.,"inq_dimID_y")
status = NF90_INQ_DIMID(fidTobs,"x",dimID_x); call erreur(status,.TRUE.,"inq_dimID_x")
 
status = NF90_INQUIRE_DIMENSION(fidTobs,dimID_nbounds,len=mnbounds); call erreur(status,.TRUE.,"inq_dim_nbounds")
status = NF90_INQUIRE_DIMENSION(fidTobs,dimID_z,len=mz); call erreur(status,.TRUE.,"inq_dim_z")
status = NF90_INQUIRE_DIMENSION(fidTobs,dimID_y,len=my); call erreur(status,.TRUE.,"inq_dim_y")
status = NF90_INQUIRE_DIMENSION(fidTobs,dimID_x,len=mx); call erreur(status,.TRUE.,"inq_dim_x")
  
ALLOCATE(  x(mx), y(my), z(mz) ) 
ALLOCATE(  z_bnds(mnbounds,mz)  ) 
ALLOCATE(  Tcor(mx,my,mz)  ) 
ALLOCATE(  Scor(mx,my,mz)  ) 
ALLOCATE(  tmp(mx,my,mz)  ) 
 
!status = NF90_INQ_VARID(fidTobs,"z_bnds",z_bnds_ID); call erreur(status,.TRUE.,"inq_z_bnds_ID")
status = NF90_INQ_VARID(fidTobs,"z",z_ID); call erreur(status,.TRUE.,"inq_z_ID")
status = NF90_INQ_VARID(fidTobs,"temperature",Tcor_ID); call erreur(status,.TRUE.,"inq_temperature_ID")
status = NF90_INQ_VARID(fidTobs,"y",y_ID); call erreur(status,.TRUE.,"inq_y_ID")
status = NF90_INQ_VARID(fidTobs,"x",x_ID); call erreur(status,.TRUE.,"inq_x_ID")
 
!status = NF90_GET_VAR(fidTobs,z_bnds_ID,z_bnds); call erreur(status,.TRUE.,"getvar_z_bnds")
status = NF90_GET_VAR(fidTobs,z_ID,z); call erreur(status,.TRUE.,"getvar_z")
status = NF90_GET_VAR(fidTobs,Tcor_ID,Tcor); call erreur(status,.TRUE.,"getvar_temperature")
status = NF90_GET_VAR(fidTobs,y_ID,y); call erreur(status,.TRUE.,"getvar_y")
status = NF90_GET_VAR(fidTobs,x_ID,x); call erreur(status,.TRUE.,"getvar_x")
 
status = NF90_CLOSE(fidTobs); call erreur(status,.TRUE.,"close_file")

z_bnds(1,:) = z(:) - 30.00000000
z_bnds(2,:) = z(:) + 30.00000000

!---------------------------------------
! Read observed salinity climatology
 
write(*,*) 'Reading ', TRIM(file_in_Sobs)
status = NF90_OPEN(TRIM(file_in_Sobs),0,fidSobs); call erreur(status,.TRUE.,"read obs sal climato")
status = NF90_INQ_VARID(fidSobs,"salinity",Scor_ID); call erreur(status,.TRUE.,"inq_salinity_ID")
status = NF90_GET_VAR(fidSobs,Scor_ID,Scor); call erreur(status,.TRUE.,"getvar_salinity")
status = NF90_CLOSE(fidSobs); call erreur(status,.TRUE.,"close_file")

!-----------------------------------------------------
! Read CMIP6 temperature climatology over 1995-2014 :
 
write(*,*) 'Reading ', TRIM(file_in_Tclim)
status = NF90_OPEN(TRIM(file_in_Tclim),0,fidTclim); call erreur(status,.TRUE.,"read thetao climatology")
status = NF90_INQ_VARID(fidTclim,"thetao",tmp_ID); call erreur(status,.TRUE.,"inq_clim_thetao_ID")
status = NF90_GET_VAR(fidTclim,tmp_ID,tmp); call erreur(status,.TRUE.,"getvar_clim_thetao")
status = NF90_CLOSE(fidTclim); call erreur(status,.TRUE.,"close_file_Tclim")

Tcor(:,:,:) = Tcor(:,:,:) - tmp(:,:,:)

!-----------------------------------------------------
! Read CMIP6 salinity climatology over 1995-2014 :

write(*,*) 'Reading ', TRIM(file_in_Sclim)
status = NF90_OPEN(TRIM(file_in_Sclim),0,fidSclim); call erreur(status,.TRUE.,"read so climatology")
status = NF90_INQ_VARID(fidSclim,"so",tmp_ID); call erreur(status,.TRUE.,"inq_clim_so_ID")
status = NF90_GET_VAR(fidSclim,tmp_ID,tmp); call erreur(status,.TRUE.,"getvar_clim_so")
status = NF90_CLOSE(fidSclim); call erreur(status,.TRUE.,"close_file_Sclim")

Scor(:,:,:) = Scor(:,:,:) - tmp(:,:,:)

!---------------------------------------
! Read netcdf input temperature file :
 
write(*,*) 'Reading ', TRIM(file_in_T)
 
status = NF90_OPEN(TRIM(file_in_T),0,fidTin); call erreur(status,.TRUE.,"read thetao")
 
status = NF90_INQ_DIMID(fidTin,"time",dimID_time); call erreur(status,.TRUE.,"inq_dimID_time")
 
status = NF90_INQUIRE_DIMENSION(fidTin,dimID_time,len=mtime); call erreur(status,.TRUE.,"inq_dim_time")
  
ALLOCATE(  time(mtime)  ) 
ALLOCATE(  thetao(mx,my,mz,12)  ) 
ALLOCATE(  so(mx,my,mz,12)  ) 
 
status = NF90_INQ_VARID(fidTin,"time",time_ID); call erreur(status,.TRUE.,"inq_time_ID")
status = NF90_INQ_VARID(fidTin,"thetao",thetao_ID); call erreur(status,.TRUE.,"inq_thetao_ID")

status = NF90_GET_VAR(fidTin,time_ID,time); call erreur(status,.TRUE.,"getvar_time")
 
!---------------------------------------
! Read netcdf input salinity file :
 
write(*,*) 'Reading ', TRIM(file_in_S)
status = NF90_OPEN(TRIM(file_in_S),0,fidSin); call erreur(status,.TRUE.,"read so")
status = NF90_INQ_VARID(fidSin,"so",so_ID); call erreur(status,.TRUE.,"inq_so_ID")
 
!---------------------------------------------------------------------------------------------------
! Writing four output netcdf files (thetao, so, TFavg, TFrms):
 
write(*,*) 'Creating ', TRIM(file_out_T)
status = NF90_CREATE(TRIM(file_out_T),NF90_NOCLOBBER,fidTout); call erreur(status,.TRUE.,'create file1')
write(*,*) 'Creating ', TRIM(file_out_S)
status = NF90_CREATE(TRIM(file_out_S),NF90_NOCLOBBER,fidSout); call erreur(status,.TRUE.,'create file2')
write(*,*) 'Creating ', TRIM(file_out_TFavg)
status = NF90_CREATE(TRIM(file_out_TFavg),NF90_NOCLOBBER,fidTFavg); call erreur(status,.TRUE.,'create file3')
write(*,*) 'Creating ', TRIM(file_out_TFrms)
status = NF90_CREATE(TRIM(file_out_TFrms),NF90_NOCLOBBER,fidTFrms); call erreur(status,.TRUE.,'create file4')

!--

status = NF90_DEF_DIM(fidTout,"time",NF90_UNLIMITED,dimID_time_out_T); call erreur(status,.TRUE.,"def_dimID_time")
status = NF90_DEF_DIM(fidTout,"nbounds",mnbounds,dimID_nbounds_out_T); call erreur(status,.TRUE.,"def_dimID_nbounds")
status = NF90_DEF_DIM(fidTout,"z",mz,dimID_z_out_T); call erreur(status,.TRUE.,"def_dimID_z")
status = NF90_DEF_DIM(fidTout,"y",my,dimID_y_out_T); call erreur(status,.TRUE.,"def_dimID_y")
status = NF90_DEF_DIM(fidTout,"x",mx,dimID_x_out_T); call erreur(status,.TRUE.,"def_dimID_x")

status = NF90_DEF_DIM(fidSout,"time",NF90_UNLIMITED,dimID_time_out_S); call erreur(status,.TRUE.,"def_dimID_time")
status = NF90_DEF_DIM(fidSout,"nbounds",mnbounds,dimID_nbounds_out_S); call erreur(status,.TRUE.,"def_dimID_nbounds")
status = NF90_DEF_DIM(fidSout,"z",mz,dimID_z_out_S); call erreur(status,.TRUE.,"def_dimID_z")
status = NF90_DEF_DIM(fidSout,"y",my,dimID_y_out_S); call erreur(status,.TRUE.,"def_dimID_y")
status = NF90_DEF_DIM(fidSout,"x",mx,dimID_x_out_S); call erreur(status,.TRUE.,"def_dimID_x")

status = NF90_DEF_DIM(fidTFavg,"time",NF90_UNLIMITED,dimID_time_out_TFavg); call erreur(status,.TRUE.,"def_dimID_time")
status = NF90_DEF_DIM(fidTFavg,"nbounds",mnbounds,dimID_nbounds_out_TFavg); call erreur(status,.TRUE.,"def_dimID_nbounds")
status = NF90_DEF_DIM(fidTFavg,"z",mz,dimID_z_out_TFavg); call erreur(status,.TRUE.,"def_dimID_z")
status = NF90_DEF_DIM(fidTFavg,"y",my,dimID_y_out_TFavg); call erreur(status,.TRUE.,"def_dimID_y")
status = NF90_DEF_DIM(fidTFavg,"x",mx,dimID_x_out_TFavg); call erreur(status,.TRUE.,"def_dimID_x")

status = NF90_DEF_DIM(fidTFrms,"time",NF90_UNLIMITED,dimID_time_out_TFrms); call erreur(status,.TRUE.,"def_dimID_time")
status = NF90_DEF_DIM(fidTFrms,"nbounds",mnbounds,dimID_nbounds_out_TFrms); call erreur(status,.TRUE.,"def_dimID_nbounds")
status = NF90_DEF_DIM(fidTFrms,"z",mz,dimID_z_out_TFrms); call erreur(status,.TRUE.,"def_dimID_z")
status = NF90_DEF_DIM(fidTFrms,"y",my,dimID_y_out_TFrms); call erreur(status,.TRUE.,"def_dimID_y")
status = NF90_DEF_DIM(fidTFrms,"x",mx,dimID_x_out_TFrms); call erreur(status,.TRUE.,"def_dimID_x")

!--

status = NF90_DEF_VAR(fidTout,"time",NF90_DOUBLE,(/dimID_time_out_T/),time_out_T_ID)
call erreur(status,.TRUE.,"def_var_time_ID1")
status = NF90_DEF_VAR(fidTout,"z_bnds",NF90_FLOAT,(/dimID_nbounds_out_T,dimID_z_out_T/),z_bnds_out_T_ID)
call erreur(status,.TRUE.,"def_var_z_bnds_ID1")
status = NF90_DEF_VAR(fidTout,"x",NF90_FLOAT,(/dimID_x_out_T/),x_out_T_ID); call erreur(status,.TRUE.,"def_var_x_ID1")
status = NF90_DEF_VAR(fidTout,"y",NF90_FLOAT,(/dimID_y_out_T/),y_out_T_ID); call erreur(status,.TRUE.,"def_var_y_ID1")
status = NF90_DEF_VAR(fidTout,"z",NF90_FLOAT,(/dimID_z_out_T/),z_out_T_ID); call erreur(status,.TRUE.,"def_var_z_ID1")

status = NF90_DEF_VAR(fidSout,"time",NF90_DOUBLE,(/dimID_time_out_S/),time_out_S_ID)
call erreur(status,.TRUE.,"def_var_time_ID2")
status = NF90_DEF_VAR(fidSout,"z_bnds",NF90_FLOAT,(/dimID_nbounds_out_S,dimID_z_out_S/),z_bnds_out_S_ID)
call erreur(status,.TRUE.,"def_var_z_bnds_ID2")
status = NF90_DEF_VAR(fidSout,"x",NF90_FLOAT,(/dimID_x_out_S/),x_out_S_ID); call erreur(status,.TRUE.,"def_var_x_ID2")
status = NF90_DEF_VAR(fidSout,"y",NF90_FLOAT,(/dimID_y_out_S/),y_out_S_ID); call erreur(status,.TRUE.,"def_var_y_ID2")
status = NF90_DEF_VAR(fidSout,"z",NF90_FLOAT,(/dimID_z_out_S/),z_out_S_ID); call erreur(status,.TRUE.,"def_var_z_ID2")

status = NF90_DEF_VAR(fidTFavg,"time",NF90_DOUBLE,(/dimID_time_out_TFavg/),time_out_TFavg_ID)
call erreur(status,.TRUE.,"def_var_time_ID3")
status = NF90_DEF_VAR(fidTFavg,"z_bnds",NF90_FLOAT,(/dimID_nbounds_out_TFavg,dimID_z_out_TFavg/),z_bnds_out_TFavg_ID)
call erreur(status,.TRUE.,"def_var_z_bnds_ID3")
status = NF90_DEF_VAR(fidTFavg,"x",NF90_FLOAT,(/dimID_x_out_TFavg/),x_out_TFavg_ID); call erreur(status,.TRUE.,"def_var_x_ID3")
status = NF90_DEF_VAR(fidTFavg,"y",NF90_FLOAT,(/dimID_y_out_TFavg/),y_out_TFavg_ID); call erreur(status,.TRUE.,"def_var_y_ID3")
status = NF90_DEF_VAR(fidTFavg,"z",NF90_FLOAT,(/dimID_z_out_TFavg/),z_out_TFavg_ID); call erreur(status,.TRUE.,"def_var_z_ID3")

status = NF90_DEF_VAR(fidTFrms,"time",NF90_DOUBLE,(/dimID_time_out_TFrms/),time_out_TFrms_ID)
call erreur(status,.TRUE.,"def_var_time_ID4")
status = NF90_DEF_VAR(fidTFrms,"z_bnds",NF90_FLOAT,(/dimID_nbounds_out_TFrms,dimID_z_out_TFrms/),z_bnds_out_TFrms_ID)
call erreur(status,.TRUE.,"def_var_z_bnds_ID4")
status = NF90_DEF_VAR(fidTFrms,"x",NF90_FLOAT,(/dimID_x_out_TFrms/),x_out_TFrms_ID); call erreur(status,.TRUE.,"def_var_x_ID4")
status = NF90_DEF_VAR(fidTFrms,"y",NF90_FLOAT,(/dimID_y_out_TFrms/),y_out_TFrms_ID); call erreur(status,.TRUE.,"def_var_y_ID4")
status = NF90_DEF_VAR(fidTFrms,"z",NF90_FLOAT,(/dimID_z_out_TFrms/),z_out_TFrms_ID); call erreur(status,.TRUE.,"def_var_z_ID4")

status = NF90_DEF_VAR(fidTout,"thetao",NF90_FLOAT,(/dimID_x_out_T,dimID_y_out_T,dimID_z_out_T,dimID_time_out_T/),thetao_out_ID)
call erreur(status,.TRUE.,"def_var_thetao_ID")
status = NF90_DEF_VAR(fidSout,"so",NF90_FLOAT,(/dimID_x_out_S,dimID_y_out_S,dimID_z_out_S,dimID_time_out_S/),so_out_ID)
call erreur(status,.TRUE.,"def_var_so_ID")
status = NF90_DEF_VAR(fidTFavg,"TF",NF90_FLOAT,(/dimID_x_out_TFavg,dimID_y_out_TFavg,dimID_z_out_TFavg,dimID_time_out_TFavg/),TFavg_out_ID)
call erreur(status,.TRUE.,"def_var_TFavg_ID")
status = NF90_DEF_VAR(fidTFrms,"TF",NF90_FLOAT,(/dimID_x_out_TFrms,dimID_y_out_TFrms,dimID_z_out_TFrms,dimID_time_out_TFrms/),TFrms_out_ID)
call erreur(status,.TRUE.,"def_var_TFrms_ID")

!--

status = NF90_PUT_ATT(fidTout,x_out_T_ID,"units","m"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidTout,x_out_T_ID,"long_name","x coordinate"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidTout,y_out_T_ID,"units","m"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidTout,y_out_T_ID,"long_name","y coordinate"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidTout,z_out_T_ID,"units","m"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTout,z_out_T_ID,"bounds","z_bnds"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTout,z_out_T_ID,"long_name","depth"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTout,z_out_T_ID,"positive","up"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTout,time_out_T_ID,"standard_name","time"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidTout,time_out_T_ID,"units","days since 1850-01-01"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidTout,time_out_T_ID,"calendar","proleptic_gregorian"); call erreur(status,.TRUE.,"put_att_time_ID")

status = NF90_PUT_ATT(fidSout,x_out_S_ID,"units","m"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidSout,x_out_S_ID,"long_name","x coordinate"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidSout,y_out_S_ID,"units","m"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidSout,y_out_S_ID,"long_name","y coordinate"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidSout,z_out_S_ID,"units","m"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidSout,z_out_S_ID,"bounds","z_bnds"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidSout,z_out_S_ID,"long_name","depth"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidSout,z_out_S_ID,"positive","up"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidSout,time_out_S_ID,"standard_name","time"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidSout,time_out_S_ID,"units","days since 1850-01-01"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidSout,time_out_S_ID,"calendar","proleptic_gregorian"); call erreur(status,.TRUE.,"put_att_time_ID")

status = NF90_PUT_ATT(fidTFavg,x_out_TFavg_ID,"units","m"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidTFavg,x_out_TFavg_ID,"long_name","x coordinate"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidTFavg,y_out_TFavg_ID,"units","m"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidTFavg,y_out_TFavg_ID,"long_name","y coordinate"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidTFavg,z_out_TFavg_ID,"units","m"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTFavg,z_out_TFavg_ID,"bounds","z_bnds"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTFavg,z_out_TFavg_ID,"long_name","depth"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTFavg,z_out_TFavg_ID,"positive","up"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTFavg,time_out_TFavg_ID,"standard_name","time"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidTFavg,time_out_TFavg_ID,"units","days since 1850-01-01"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidTFavg,time_out_TFavg_ID,"calendar","proleptic_gregorian"); call erreur(status,.TRUE.,"put_att_time_ID")

status = NF90_PUT_ATT(fidTFrms,x_out_TFrms_ID,"units","m"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidTFrms,x_out_TFrms_ID,"long_name","x coordinate"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidTFrms,y_out_TFrms_ID,"units","m"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidTFrms,y_out_TFrms_ID,"long_name","y coordinate"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidTFrms,z_out_TFrms_ID,"units","m"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTFrms,z_out_TFrms_ID,"bounds","z_bnds"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTFrms,z_out_TFrms_ID,"long_name","depth"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTFrms,z_out_TFrms_ID,"positive","up"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTFrms,time_out_TFrms_ID,"standard_name","time"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidTFrms,time_out_TFrms_ID,"units","days since 1850-01-01"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidTFrms,time_out_TFrms_ID,"calendar","proleptic_gregorian"); call erreur(status,.TRUE.,"put_att_time_ID")

!--

status = NF90_PUT_ATT(fidTout,thetao_out_ID,"units","degC"); call erreur(status,.TRUE.,"put_att_thetao_ID")
status = NF90_PUT_ATT(fidTout,thetao_out_ID,"long_name","Sea Water Potential Temperature (corrected)"); call erreur(status,.TRUE.,"put_att_thetao_ID")
status = NF90_PUT_ATT(fidTout,thetao_out_ID,"standard_name","sea_water_potential_temperature"); call erreur(status,.TRUE.,"put_att_thetao_ID")

status = NF90_PUT_ATT(fidSout,so_out_ID,"units","1.e-3"); call erreur(status,.TRUE.,"put_att_so_ID")
status = NF90_PUT_ATT(fidSout,so_out_ID,"long_name","Sea Water Salinity (corrected)"); call erreur(status,.TRUE.,"put_att_so_ID")
status = NF90_PUT_ATT(fidSout,so_out_ID,"standard_name","sea_water_salinity"); call erreur(status,.TRUE.,"put_att_so_ID")

status = NF90_PUT_ATT(fidTFavg,TFavg_out_ID,"units","degC"); call erreur(status,.TRUE.,"put_att_TFavg_ID")
status = NF90_PUT_ATT(fidTFavg,TFavg_out_ID,"long_name","Thermal Forcing (corrected annual mean)"); call erreur(status,.TRUE.,"put_att_TFavg_ID")

status = NF90_PUT_ATT(fidTFrms,TFrms_out_ID,"units","degC"); call erreur(status,.TRUE.,"put_att_TFrms_ID")
status = NF90_PUT_ATT(fidTFrms,TFrms_out_ID,"long_name","Thermal Forcing (annual RMS, corrected)"); call erreur(status,.TRUE.,"put_att_TFrms_ID")

!--

status = NF90_PUT_ATT(fidTout,NF90_GLOBAL,"history","Created by Nico Jourdain (IGE-CNRS) from the CMIP6 data"); call erreur(status,.TRUE.,"put_att_GLO1")
status = NF90_PUT_ATT(fidTout,NF90_GLOBAL,"tools","https://github.com/nicojourdain/CMIP6_data_to_ISMIP6_grid"); call erreur(status,.TRUE.,"put_att_GLO2")
status = NF90_PUT_ATT(fidTout,NF90_GLOBAL,"project","EU-H2020-PROTECT"); call erreur(status,.TRUE.,"put_att_GLO3")

status = NF90_PUT_ATT(fidSout,NF90_GLOBAL,"history","Created by Nico Jourdain (IGE-CNRS) from the CMIP6 data"); call erreur(status,.TRUE.,"put_att_GLO1")
status = NF90_PUT_ATT(fidSout,NF90_GLOBAL,"tools","https://github.com/nicojourdain/CMIP6_data_to_ISMIP6_grid"); call erreur(status,.TRUE.,"put_att_GLO2")
status = NF90_PUT_ATT(fidSout,NF90_GLOBAL,"project","EU-H2020-PROTECT"); call erreur(status,.TRUE.,"put_att_GLO3")
 
status = NF90_PUT_ATT(fidTFavg,NF90_GLOBAL,"history","Created by Nico Jourdain (IGE-CNRS) from the CMIP6 data"); call erreur(status,.TRUE.,"put_att_GLO1")
status = NF90_PUT_ATT(fidTFavg,NF90_GLOBAL,"tools","https://github.com/nicojourdain/CMIP6_data_to_ISMIP6_grid"); call erreur(status,.TRUE.,"put_att_GLO2")
status = NF90_PUT_ATT(fidTFavg,NF90_GLOBAL,"project","EU-H2020-PROTECT"); call erreur(status,.TRUE.,"put_att_GLO3")
 
status = NF90_PUT_ATT(fidTFrms,NF90_GLOBAL,"history","Created by Nico Jourdain (IGE-CNRS) from the CMIP6 data"); call erreur(status,.TRUE.,"put_att_GLO1")
status = NF90_PUT_ATT(fidTFrms,NF90_GLOBAL,"tools","https://github.com/nicojourdain/CMIP6_data_to_ISMIP6_grid"); call erreur(status,.TRUE.,"put_att_GLO2")
status = NF90_PUT_ATT(fidTFrms,NF90_GLOBAL,"project","EU-H2020-PROTECT"); call erreur(status,.TRUE.,"put_att_GLO3")

!--

status = NF90_ENDDEF(fidTout); call erreur(status,.TRUE.,"fin_definition") 
status = NF90_ENDDEF(fidSout); call erreur(status,.TRUE.,"fin_definition") 
status = NF90_ENDDEF(fidTFavg); call erreur(status,.TRUE.,"fin_definition") 
status = NF90_ENDDEF(fidTFrms); call erreur(status,.TRUE.,"fin_definition") 
 
!--

status = NF90_PUT_VAR(fidTout,x_out_T_ID,x); call erreur(status,.TRUE.,"var_x_ID")
status = NF90_PUT_VAR(fidTout,y_out_T_ID,y); call erreur(status,.TRUE.,"var_y_ID")
status = NF90_PUT_VAR(fidTout,z_out_T_ID,z); call erreur(status,.TRUE.,"var_z_ID")
status = NF90_PUT_VAR(fidTout,z_bnds_out_T_ID,z_bnds); call erreur(status,.TRUE.,"var_z_ID")

status = NF90_PUT_VAR(fidSout,x_out_S_ID,x); call erreur(status,.TRUE.,"var_x_ID")
status = NF90_PUT_VAR(fidSout,y_out_S_ID,y); call erreur(status,.TRUE.,"var_y_ID")
status = NF90_PUT_VAR(fidSout,z_out_S_ID,z); call erreur(status,.TRUE.,"var_z_ID")
status = NF90_PUT_VAR(fidSout,z_bnds_out_S_ID,z_bnds); call erreur(status,.TRUE.,"var_z_ID")

status = NF90_PUT_VAR(fidTFavg,x_out_TFavg_ID,x); call erreur(status,.TRUE.,"var_x_ID")
status = NF90_PUT_VAR(fidTFavg,y_out_TFavg_ID,y); call erreur(status,.TRUE.,"var_y_ID")
status = NF90_PUT_VAR(fidTFavg,z_out_TFavg_ID,z); call erreur(status,.TRUE.,"var_z_ID")
status = NF90_PUT_VAR(fidTFavg,z_bnds_out_TFavg_ID,z_bnds); call erreur(status,.TRUE.,"var_z_ID")

status = NF90_PUT_VAR(fidTFrms,x_out_TFrms_ID,x); call erreur(status,.TRUE.,"var_x_ID")
status = NF90_PUT_VAR(fidTFrms,y_out_TFrms_ID,y); call erreur(status,.TRUE.,"var_y_ID")
status = NF90_PUT_VAR(fidTFrms,z_out_TFrms_ID,z); call erreur(status,.TRUE.,"var_z_ID")
status = NF90_PUT_VAR(fidTFrms,z_bnds_out_TFrms_ID,z_bnds); call erreur(status,.TRUE.,"var_z_ID")

!---------------------------------------
! LOOP OVER ALL TIME STEPS :

ktout=0

DO kt=1,mtime,12
 
  ktout=ktout+1

  ! Read T, S
  status = NF90_GET_VAR(fidTin,thetao_ID,thetao,start=(/1,1,1,kt/),count=(/mx,my,mz,12/)); call erreur(status,.TRUE.,"getvar_thetao")
  status = NF90_GET_VAR(fidSin,so_ID,so,start=(/1,1,1,kt/),count=(/mx,my,mz,12/)); call erreur(status,.TRUE.,"getvar_so")

  time_out(1) = SUM(time(kt:kt+11))/12.

  ! Annual Mean Temperature (not allowing lower than thermal forcing)
  tmp = SUM(thetao,4)/12.+Tcor
  tmp(:,:,:) = 0.e0
  do ki=1,mx
  do kj=1,my
    do kz=1,mz
      do ll=1,12
        tmp(ki,kj,kz) = tmp(ki,kj,kz) &
        &               + max( thetao(ki,kj,kz,ll) + Tcor(ki,kj,kz) , lbd1 * ( so(ki,kj,kz,ll) + Scor(ki,kj,kz) ) + lbd2 + lbd3*(-z(kz)) )
      enddo
    enddo
  enddo
  enddo
  tmp(:,:,:) = tmp(:,:,:) / 12.
  status = NF90_PUT_VAR(fidTout,time_out_T_ID,time_out,start=(/ktout/),count=(/1/)); call erreur(status,.TRUE.,"var_time1_ID")
  status = NF90_PUT_VAR(fidTout,thetao_out_ID,tmp,start=(/1,1,1,ktout/),count=(/mx,my,mz,1/)); call erreur(status,.TRUE.,"var_thetao_ID")

  ! Annual Mean Salinity
  tmp = SUM(so,4)/12.+Scor
  status = NF90_PUT_VAR(fidSout,time_out_S_ID,time_out,start=(/ktout/),count=(/1/)); call erreur(status,.TRUE.,"var_time2_ID")
  status = NF90_PUT_VAR(fidSout,so_out_ID,tmp,start=(/1,1,1,ktout/),count=(/mx,my,mz,1/)); call erreur(status,.TRUE.,"var_thetao_ID")

  ! Annual Mean Thermal Forcing ( T - Tf )
  tmp(:,:,:) = 0.e0
  do ki=1,mx
  do kj=1,my
    do kz=1,mz
      do ll=1,12
        tmp(ki,kj,kz) = tmp(ki,kj,kz) &
        &               + max( 0.e0 , thetao(ki,kj,kz,ll) + Tcor(ki,kj,kz) - ( lbd1 * ( so(ki,kj,kz,ll) + Scor(ki,kj,kz) ) + lbd2 + lbd3*(-z(kz)) ) )
      enddo    
    enddo
  enddo
  enddo
  tmp(:,:,:) = tmp(:,:,:) / 12.
  status = NF90_PUT_VAR(fidTFavg,time_out_TFavg_ID,time_out,start=(/ktout/),count=(/1/)); call erreur(status,.TRUE.,"var_time3_ID")
  status = NF90_PUT_VAR(fidTFavg,TFavg_out_ID,tmp,start=(/1,1,1,ktout/),count=(/mx,my,mz,1/)); call erreur(status,.TRUE.,"var_TFavg_ID")

  ! Annual RMS Thermal Forcing
  tmp(:,:,:) = 0.e0
  do ki=1,mx
  do kj=1,my
    do kz=1,mz
      aa=0.e0
      do ll=1,12
        aa = aa + ( max( 0.e0 , &
        &                thetao(ki,kj,kz,ll) + Tcor(ki,kj,kz) - ( lbd1 * ( so(ki,kj,kz,ll) + Scor(ki,kj,kz) ) + lbd2 + lbd3*(-z(kz)) ) ) )**2
      enddo
      tmp(ki,kj,kz) = sqrt(aa/12.) 
    enddo
  enddo
  enddo
  status = NF90_PUT_VAR(fidTFrms,time_out_TFrms_ID,time_out,start=(/ktout/),count=(/1/)); call erreur(status,.TRUE.,"var_time4_ID")
  status = NF90_PUT_VAR(fidTFrms,TFrms_out_ID,tmp,start=(/1,1,1,ktout/),count=(/mx,my,mz,1/)); call erreur(status,.TRUE.,"var_TFrms_ID")

ENDDO ! kt=1,mtime

!---------------------------------------

status = NF90_CLOSE(fidTin); call erreur(status,.TRUE.,"close fidTin")
status = NF90_CLOSE(fidSin); call erreur(status,.TRUE.,"close fidSin")
status = NF90_CLOSE(fidTout); call erreur(status,.TRUE.,"close fidTout")
status = NF90_CLOSE(fidSout); call erreur(status,.TRUE.,"close fidSout")
status = NF90_CLOSE(fidTFavg); call erreur(status,.TRUE.,"close fidTFavg")
status = NF90_CLOSE(fidTFrms); call erreur(status,.TRUE.,"close fidTFrms")

end program modif


!========================================================================================
SUBROUTINE erreur(iret, lstop, chaine)
  ! pour les messages d'erreur
  USE netcdf
  INTEGER, INTENT(in)                     :: iret
  LOGICAL, INTENT(in)                     :: lstop
  CHARACTER(LEN=*), INTENT(in)            :: chaine
  !
  CHARACTER(LEN=80)                       :: message
  !
  IF ( iret .NE. 0 ) THEN
    WRITE(*,*) 'ROUTINE: ', TRIM(chaine)
    WRITE(*,*) 'ERREUR: ', iret
    message=NF90_STRERROR(iret)
    WRITE(*,*) 'CA VEUT DIRE:',TRIM(message)
    IF ( lstop ) STOP
  ENDIF
  !
END SUBROUTINE erreur
