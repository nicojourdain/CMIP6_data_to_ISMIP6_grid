program modif
 
USE netcdf
 
IMPLICIT NONE
 
INTEGER :: fidTin, fidTclim, fidTobs, fidTout, fidSin, fidSclim, fidSobs, fidSout, status, &
&          dimID_nbounds, mnbounds, dimID_time, dimID_z, dimID_y, dimID_x, dimID_time_out, &
&          dimID_z_out, dimID_y_out, dimID_x_out, mtime, mz, my, mx, time_ID, time_out_ID, &
&          thetao_ID, x_ID, y_ID, z_ID, thetao_out_ID, x_out_ID, y_out_ID, z_out_ID,       &
&          Tcor_ID, Scor_ID
 
CHARACTER(LEN=150) :: file_in_Tobs, file_in_Sobs, file_in_T, file_out_T, file_in_S, file_out_S, file_out_TF
 
REAL*4,ALLOCATABLE,DIMENSION(:) :: x, y, z
 
REAL*4,ALLOCATABLE,DIMENSION(:,:) :: z_bnds

REAL*8,ALLOCATABLE,DIMENSION(:) :: time
 
REAL*4,ALLOCATABLE,DIMENSION(:,:,:) :: tmp, Tcor, Scor, thetao, so

!---------------------------------------

file_in_Tobs  = '/data/njourdain/DATA_ISMIP6/obs_temperature_1995-2017_8km_x_60m.nc'
file_in_Sobs  = '/data/njourdain/DATA_ISMIP6/obs_salinity_1995-2017_8km_x_60m.nc'

file_in_T  = '/scratchu/njourdain/CMIP6_ON_ISMIP6_GRID/EXTRAPOLATED/thetao_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_195001_201412_e.nc'
file_in_S  = '/scratchu/njourdain/CMIP6_ON_ISMIP6_GRID/EXTRAPOLATED/so_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_195001_201412_e.nc'

file_out_T = 'thetao_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_195001_201412_e.nc'
file_out_S = 'so_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_195001_201412_e.nc'

!---------------------------------------
! Read observed temperature climatology
 
write(*,*) 'Reading ', TRIM(file_in_Tobs)
 
status = NF90_OPEN(TRIM(file_in_Tobs),0,fidTobs); call erreur(status,.TRUE.,"read")
 
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
 
status = NF90_INQ_VARID(fidTobs,"z_bnds",z_bnds_ID); call erreur(status,.TRUE.,"inq_z_bnds_ID")
status = NF90_INQ_VARID(fidTobs,"z",z_ID); call erreur(status,.TRUE.,"inq_z_ID")
status = NF90_INQ_VARID(fidTobs,"temperature",Tcor_ID); call erreur(status,.TRUE.,"inq_temperature_ID")
status = NF90_INQ_VARID(fidTobs,"y",y_ID); call erreur(status,.TRUE.,"inq_y_ID")
status = NF90_INQ_VARID(fidTobs,"x",x_ID); call erreur(status,.TRUE.,"inq_x_ID")
 
status = NF90_GET_VAR(fidTobs,z_bnds_ID,z_bnds); call erreur(status,.TRUE.,"getvar_z_bnds")
status = NF90_GET_VAR(fidTobs,z_ID,z); call erreur(status,.TRUE.,"getvar_z")
status = NF90_GET_VAR(fidTobs,Tcor_ID,Tcor); call erreur(status,.TRUE.,"getvar_temperature")
status = NF90_GET_VAR(fidTobs,y_ID,y); call erreur(status,.TRUE.,"getvar_y")
status = NF90_GET_VAR(fidTobs,x_ID,x); call erreur(status,.TRUE.,"getvar_x")
 
status = NF90_CLOSE(fidTobs); call erreur(status,.TRUE.,"close_file")

!---------------------------------------
! Read observed salinity climatology
 
write(*,*) 'Reading ', TRIM(file_in_Sobs)
status = NF90_OPEN(TRIM(file_in_Sobs),0,fidSobs); call erreur(status,.TRUE.,"read")
status = NF90_INQ_VARID(fidSobs,"salinity",Scor_ID); call erreur(status,.TRUE.,"inq_salinity_ID")
status = NF90_GET_VAR(fidSobs,Scor_ID,Scor); call erreur(status,.TRUE.,"getvar_salinity")
status = NF90_CLOSE(fidSobs); call erreur(status,.TRUE.,"close_file")

!---------------------------------------
! Read netcdf input temperature file :
 
write(*,*) 'Reading ', TRIM(file_in_T)
 
status = NF90_OPEN(TRIM(file_in_T),0,fidTin); call erreur(status,.TRUE.,"read thetao")
 
status = NF90_INQ_DIMID(fidTin,"time",dimID_time); call erreur(status,.TRUE.,"inq_dimID_time")
status = NF90_INQ_DIMID(fidTin,"z",dimID_z); call erreur(status,.TRUE.,"inq_dimID_z")
status = NF90_INQ_DIMID(fidTin,"y",dimID_y); call erreur(status,.TRUE.,"inq_dimID_y")
status = NF90_INQ_DIMID(fidTin,"x",dimID_x); call erreur(status,.TRUE.,"inq_dimID_x")
 
status = NF90_INQUIRE_DIMENSION(fidTin,dimID_time,len=mtime); call erreur(status,.TRUE.,"inq_dim_time")
status = NF90_INQUIRE_DIMENSION(fidTin,dimID_z,len=mz); call erreur(status,.TRUE.,"inq_dim_z")
status = NF90_INQUIRE_DIMENSION(fidTin,dimID_y,len=my); call erreur(status,.TRUE.,"inq_dim_y")
status = NF90_INQUIRE_DIMENSION(fidTin,dimID_x,len=mx); call erreur(status,.TRUE.,"inq_dim_x")
  
ALLOCATE(  time(mtime)  ) 
ALLOCATE(  thetao(mx,my,mz,mtime)  ) 
ALLOCATE(  x(mx)  ) 
ALLOCATE(  y(my)  ) 
ALLOCATE(  z(mz)  ) 
 
status = NF90_INQ_VARID(fidTin,"time",time_ID); call erreur(status,.TRUE.,"inq_time_ID")
status = NF90_INQ_VARID(fidTin,"thetao",thetao_ID); call erreur(status,.TRUE.,"inq_thetao_ID")
status = NF90_INQ_VARID(fidTin,"x",x_ID); call erreur(status,.TRUE.,"inq_x_ID")
status = NF90_INQ_VARID(fidTin,"y",y_ID); call erreur(status,.TRUE.,"inq_y_ID")
status = NF90_INQ_VARID(fidTin,"z",z_ID); call erreur(status,.TRUE.,"inq_z_ID")
 
status = NF90_GET_VAR(fidTin,time_ID,time); call erreur(status,.TRUE.,"getvar_time")
status = NF90_GET_VAR(fidTin,thetao_ID,thetao); call erreur(status,.TRUE.,"getvar_thetao")
status = NF90_GET_VAR(fidTin,x_ID,x); call erreur(status,.TRUE.,"getvar_x")
status = NF90_GET_VAR(fidTin,y_ID,y); call erreur(status,.TRUE.,"getvar_y")
status = NF90_GET_VAR(fidTin,z_ID,z); call erreur(status,.TRUE.,"getvar_z")
 
status = NF90_CLOSE(fidTin); call erreur(status,.TRUE.,"close_file")
 
!---------------------------------------
! Read netcdf input salinity file :
 
write(*,*) 'Reading ', TRIM(file_in_S)
 
status = NF90_OPEN(TRIM(file_in_S),0,fidSin); call erreur(status,.TRUE.,"read so")
 
ALLOCATE(  so(mx,my,mz,mtime)  ) 
 
status = NF90_INQ_VARID(fidSin,"so",so_ID); call erreur(status,.TRUE.,"inq_so_ID")
 
status = NF90_GET_VAR(fidSin,so_ID,so); call erreur(status,.TRUE.,"getvar_so")
 
status = NF90_CLOSE(fidSin); call erreur(status,.TRUE.,"close_file")
 
!---------------------------------------
! Modification of the variables :
 
 
!---------------------------------------
! Writing new netcdf file :
 
write(*,*) 'Creating ', TRIM(file_out_T)
 
status = NF90_CREATE(TRIM(file_out_T),NF90_NOCLOBBER,fidTout); call erreur(status,.TRUE.,'create')
 
status = NF90_DEF_DIM(fidTout,"time",NF90_UNLIMITED,dimID_time_out); call erreur(status,.TRUE.,"def_dimID_time")
status = NF90_DEF_DIM(fidTout,"z",mz,dimID_z_out); call erreur(status,.TRUE.,"def_dimID_z")
status = NF90_DEF_DIM(fidTout,"y",my,dimID_y_out); call erreur(status,.TRUE.,"def_dimID_y")
status = NF90_DEF_DIM(fidTout,"x",mx,dimID_x_out); call erreur(status,.TRUE.,"def_dimID_x")
  
status = NF90_DEF_VAR(fidTout,"time",NF90_DOUBLE,(/dimID_time_out/),time_out_ID); call erreur(status,.TRUE.,"def_var_time_ID")
status = NF90_DEF_VAR(fidTout,"x",NF90_FLOAT,(/dimID_x_out/),x_out_ID); call erreur(status,.TRUE.,"def_var_x_ID")
status = NF90_DEF_VAR(fidTout,"y",NF90_FLOAT,(/dimID_y_out/),y_out_ID); call erreur(status,.TRUE.,"def_var_y_ID")
status = NF90_DEF_VAR(fidTout,"z",NF90_FLOAT,(/dimID_z_out/),z_out_ID); call erreur(status,.TRUE.,"def_var_z_ID")
status = NF90_DEF_VAR(fidTout,"thetao",NF90_FLOAT,(/dimID_x_out,dimID_y_out,dimID_z_out,dimID_time_out/),thetao_out_ID)
call erreur(status,.TRUE.,"def_var_thetao_ID")
 
status = NF90_PUT_ATT(fidTout,x_out_ID,"units","m"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidTout,x_out_ID,"long_name","x coordinate"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidTout,y_out_ID,"units","m"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidTout,y_out_ID,"long_name","y coordinate"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidTout,z_out_ID,"units","m"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTout,z_out_ID,"long_name","depth"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTout,z_out_ID,"positive","up"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidTout,time_out_ID,"standard_name","time"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidTout,time_out_ID,"units","days since 1850-01-01"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidTout,time_out_ID,"calendar","proleptic_gregorian"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidTout,thetao_out_ID,"units","degC"); call erreur(status,.TRUE.,"put_att_thetao_ID")
status = NF90_PUT_ATT(fidTout,thetao_out_ID,"long_name","Sea Water Potential Temperature"); call erreur(status,.TRUE.,"put_att_thetao_ID")
status = NF90_PUT_ATT(fidTout,thetao_out_ID,"standard_name","sea_water_potential_temperature"); call erreur(status,.TRUE.,"put_att_thetao_ID")

status = NF90_PUT_ATT(fidTout,NF90_GLOBAL,"history","Created by Nico Jourdain (IGE-CNRS) from the CMIP6 data"); call erreur(status,.TRUE.,"put_att_GLO1")
status = NF90_PUT_ATT(fidTout,NF90_GLOBAL,"tools","https://github.com/nicojourdain/CMIP6_data_to_ISMIP6_grid"); call erreur(status,.TRUE.,"put_att_GLO2")
status = NF90_PUT_ATT(fidTout,NF90_GLOBAL,"project","EU-H2020-PROTECT"); call erreur(status,.TRUE.,"put_att_GLO3")
 
status = NF90_ENDDEF(fidTout); call erreur(status,.TRUE.,"fin_definition") 
 
status = NF90_PUT_VAR(fidTout,time_out_ID,time); call erreur(status,.TRUE.,"var_time_ID")
status = NF90_PUT_VAR(fidTout,thetao_out_ID,thetao); call erreur(status,.TRUE.,"var_thetao_ID")
status = NF90_PUT_VAR(fidTout,x_out_ID,x); call erreur(status,.TRUE.,"var_x_ID")
status = NF90_PUT_VAR(fidTout,y_out_ID,y); call erreur(status,.TRUE.,"var_y_ID")
status = NF90_PUT_VAR(fidTout,z_out_ID,z); call erreur(status,.TRUE.,"var_z_ID")
 
status = NF90_CLOSE(fidTout); call erreur(status,.TRUE.,"final")

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
