program modif
 
USE netcdf
 
IMPLICIT NONE
 
INTEGER :: fidA, status, dimID_x, dimID_y, dimID_z, dimID_time, mx, my, mz, mtime, &
&          time_ID, z_ID, y_ID, x_ID, var_ID, fidM, fidB, fidT, basinNumber_ID,    &
&          mask_ID, bed_ID, thickness_ID, surface_ID

CHARACTER(LEN=15) :: varnam

CHARACTER(LEN=150) :: file_in, file_out, file_basin, file_topo
 
REAL*4,ALLOCATABLE,DIMENSION(:) :: z, y, x
 
REAL*8,ALLOCATABLE,DIMENSION(:) :: time
 
INTEGER*8,ALLOCATABLE,DIMENSION(:,:) :: basinNumber

REAL*4,ALLOCATABLE,DIMENSION(:,:) :: mask, bed, thickness, surface

REAL*4,ALLOCATABLE,DIMENSION(:,:,:,:) :: var
 
!----------------------------------------------------------------

file_in  = '/data/njourdain/CMIP6_ON_ISMIP6_GRID/so_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_195001_201412_e.nc'
file_out = '/data/njourdain/CMIP6_ON_ISMIP6_GRID/EXTRAPOLATED/so_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_195001_201412_e.nc'
file_basin = '/data/njourdain/DATA_ISMIP6/imbie2_basin_numbers_8km_v2.nc' 
file_topo  = '/data/njourdain/DATA_ISMIP6/BedMachineAntarctica_2020-07-15_v02_8km.nc'

varnam = 'thetao'

!----------------------------------------------------------------
! Read CMIP6 data (previously interpolated to the ISMIP6 grid) :
 
write(*,*) 'Reading ', TRIM(file_in)
 
status = NF90_OPEN(TRIM(file_in),0,fidA); call erreur(status,.TRUE.,"read")
 
status = NF90_INQ_DIMID(fidA,"x",dimID_x); call erreur(status,.TRUE.,"inq_dimID_x")
status = NF90_INQ_DIMID(fidA,"y",dimID_y); call erreur(status,.TRUE.,"inq_dimID_y")
status = NF90_INQ_DIMID(fidA,"z",dimID_z); call erreur(status,.TRUE.,"inq_dimID_z")
status = NF90_INQ_DIMID(fidA,"time",dimID_time); call erreur(status,.TRUE.,"inq_dimID_time")
 
status = NF90_INQUIRE_DIMENSION(fidA,dimID_x,len=mx); call erreur(status,.TRUE.,"inq_dim_x")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_y,len=my); call erreur(status,.TRUE.,"inq_dim_y")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_z,len=mz); call erreur(status,.TRUE.,"inq_dim_z")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_time,len=mtime); call erreur(status,.TRUE.,"inq_dim_time")
  
ALLOCATE(  time(mtime)  ) 
ALLOCATE(  z(mz)  ) 
ALLOCATE(  y(my)  ) 
ALLOCATE(  x(mx)  ) 
ALLOCATE(  var(mx,my,mz,mtime)  ) 
 
status = NF90_INQ_VARID(fidA,"time",time_ID); call erreur(status,.TRUE.,"inq_time_ID")
status = NF90_INQ_VARID(fidA,"z",z_ID); call erreur(status,.TRUE.,"inq_z_ID")
status = NF90_INQ_VARID(fidA,"y",y_ID); call erreur(status,.TRUE.,"inq_y_ID")
status = NF90_INQ_VARID(fidA,"x",x_ID); call erreur(status,.TRUE.,"inq_x_ID")
status = NF90_INQ_VARID(fidA,TRIM(varnam),var_ID); call erreur(status,.TRUE.,"inq_var_ID")
 
status = NF90_GET_VAR(fidA,time_ID,time); call erreur(status,.TRUE.,"getvar_time")
status = NF90_GET_VAR(fidA,z_ID,z); call erreur(status,.TRUE.,"getvar_z")
status = NF90_GET_VAR(fidA,y_ID,y); call erreur(status,.TRUE.,"getvar_y")
status = NF90_GET_VAR(fidA,x_ID,x); call erreur(status,.TRUE.,"getvar_x")
status = NF90_GET_VAR(fidA,var_ID,var); call erreur(status,.TRUE.,"getvar_var")
 
status = NF90_CLOSE(fidA); call erreur(status,.TRUE.,"close_file")
 
!----------------------------------------------------------------
! Reading IMBIE2 basins :
 
write(*,*) 'Reading ', TRIM(file_basin)
 
status = NF90_OPEN(TRIM(file_basin),0,fidB); call erreur(status,.TRUE.,"read")
 
ALLOCATE(  basinNumber(mx,my)  ) 
 
status = NF90_INQ_VARID(fidB,"basinNumber",basinNumber_ID); call erreur(status,.TRUE.,"inq_basinNumber_ID")
 
status = NF90_GET_VAR(fidB,basinNumber_ID,basinNumber); call erreur(status,.TRUE.,"getvar_basinNumber")
 
status = NF90_CLOSE(fidB); call erreur(status,.TRUE.,"close_file")


!----------------------------------------------------------------
! Read ice shelf mask and bed topographie
 
write(*,*) 'Reading ', TRIM(file_topo)
 
status = NF90_OPEN(TRIM(file_topo),0,fidT); call erreur(status,.TRUE.,"read")
 
ALLOCATE(  mask(mx,my)  ) 
ALLOCATE(  bed(mx,my)  ) 
ALLOCATE(  thickness(mx,my)  ) 
ALLOCATE(  surface(mx,my)  ) 
 
status = NF90_INQ_VARID(fidT,"mask",mask_ID); call erreur(status,.TRUE.,"inq_mask_ID")
status = NF90_INQ_VARID(fidT,"bed",bed_ID); call erreur(status,.TRUE.,"inq_bed_ID")
status = NF90_INQ_VARID(fidT,"thickness",thickness_ID); call erreur(status,.TRUE.,"inq_thickness_ID")
status = NF90_INQ_VARID(fidT,"surface",surface_ID); call erreur(status,.TRUE.,"inq_surface_ID")
 
status = NF90_GET_VAR(fidT,mask_ID,mask); call erreur(status,.TRUE.,"getvar_mask")
status = NF90_GET_VAR(fidT,bed_ID,bed); call erreur(status,.TRUE.,"getvar_bed")
status = NF90_GET_VAR(fidT,thickness_ID,thickness); call erreur(status,.TRUE.,"getvar_thickness")
status = NF90_GET_VAR(fidT,surface_ID,surface); call erreur(status,.TRUE.,"getvar_surface")
 
status = NF90_CLOSE(fidT); call erreur(status,.TRUE.,"close_file")

!---------------------------------------
! Extrapolation
 
 
!-------------------------------------------------------------
! Writing new netcdf file with extrapolated data:
 
write(*,*) 'Creating ', TRIM(file_out)
 
status = NF90_CREATE(TRIM(file_out),NF90_NOCLOBBER,fidM); call erreur(status,.TRUE.,'create')
 
status = NF90_DEF_DIM(fidM,"x",mx,dimID_x); call erreur(status,.TRUE.,"def_dimID_x")
status = NF90_DEF_DIM(fidM,"y",my,dimID_y); call erreur(status,.TRUE.,"def_dimID_y")
status = NF90_DEF_DIM(fidM,"z",mz,dimID_z); call erreur(status,.TRUE.,"def_dimID_z")
status = NF90_DEF_DIM(fidM,"time",NF90_UNLIMITED,dimID_time); call erreur(status,.TRUE.,"def_dimID_time")
  
status = NF90_DEF_VAR(fidM,"time",NF90_DOUBLE,(/dimID_time/),time_ID); call erreur(status,.TRUE.,"def_var_time_ID")
status = NF90_DEF_VAR(fidM,"z",NF90_FLOAT,(/dimID_z/),z_ID); call erreur(status,.TRUE.,"def_var_z_ID")
status = NF90_DEF_VAR(fidM,"y",NF90_FLOAT,(/dimID_y/),y_ID); call erreur(status,.TRUE.,"def_var_y_ID")
status = NF90_DEF_VAR(fidM,"x",NF90_FLOAT,(/dimID_x/),x_ID); call erreur(status,.TRUE.,"def_var_x_ID")
status = NF90_DEF_VAR(fidM,TRIM(varnam),NF90_FLOAT,(/dimID_x,dimID_y,dimID_z,dimID_time/),var_ID); call erreur(status,.TRUE.,"def_var_var_ID")
 
status = NF90_PUT_ATT(fidM,time_ID,"calendar","proleptic_gregorian"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidM,time_ID,"units","days since 1850-01-01"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidM,time_ID,"standard_name","time"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidM,z_ID,"positive","up"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidM,z_ID,"long_name","depth"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidM,z_ID,"units","m"); call erreur(status,.TRUE.,"put_att_z_ID")
status = NF90_PUT_ATT(fidM,y_ID,"long_name","y coordinate"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidM,y_ID,"units","m"); call erreur(status,.TRUE.,"put_att_y_ID")
status = NF90_PUT_ATT(fidM,x_ID,"long_name","x coordinate"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidM,x_ID,"units","m"); call erreur(status,.TRUE.,"put_att_x_ID")
status = NF90_PUT_ATT(fidM,var_ID,"_FillValue",NaN); call erreur(status,.TRUE.,"put_att_var_ID")
 
status = NF90_PUT_ATT(fidM,NF90_GLOBAL,"project","EU-H2020-PROTECT"); call erreur(status,.TRUE.,"att_GLO1")
status = NF90_PUT_ATT(fidM,NF90_GLOBAL,"history","Created by N. Jourdain (IGE,CNRS)"); call erreur(status,.TRUE.,"att_GLO2")
status = NF90_PUT_ATT(fidM,NF90_GLOBAL,"method","see https://github.com/nicojourdain/CMIP6_data_to_ISMIP6_grid"); call erreur(status,.TRUE.,"att_GLO3")
 
status = NF90_ENDDEF(fidM); call erreur(status,.TRUE.,"fin_definition") 
 
status = NF90_PUT_VAR(fidM,time_ID,time); call erreur(status,.TRUE.,"var_time_ID")
status = NF90_PUT_VAR(fidM,z_ID,z); call erreur(status,.TRUE.,"var_z_ID")
status = NF90_PUT_VAR(fidM,y_ID,y); call erreur(status,.TRUE.,"var_y_ID")
status = NF90_PUT_VAR(fidM,x_ID,x); call erreur(status,.TRUE.,"var_x_ID")
status = NF90_PUT_VAR(fidM,var_ID,var); call erreur(status,.TRUE.,"var_var_ID")
 
status = NF90_CLOSE(fidM); call erreur(status,.TRUE.,"final")

end program modif


!=====================================================================================
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
