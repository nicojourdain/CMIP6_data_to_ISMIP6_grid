program modif
 
USE netcdf
 
IMPLICIT NONE
 
INTEGER :: fidA, status, dimID_time, dimID_olevel, dimID_nvertex, dimID_y, dimID_x, dimID_axis_nbounds, mtime, &
&          molevel, mnvertex, my, mx, maxis_nbounds, time_bounds_ID, time_ID, thetao_ID, olevel_bounds_ID,     &
&          olevel_ID, bounds_nav_lat_ID, bounds_nav_lon_ID, nav_lon_ID, nav_lat_ID, fidM, kmem, Nmemb,&
&          Nmembers, thetao_mean_ID, kt
 
CHARACTER(LEN=150) :: file_in, file_out

CHARACTER(LEN=13) :: period
 
REAL*4,ALLOCATABLE,DIMENSION(:) :: olevel
 
REAL*8,ALLOCATABLE,DIMENSION(:) :: time
 
REAL*4,ALLOCATABLE,DIMENSION(:,:) :: olevel_bounds, nav_lon, nav_lat
 
REAL*8,ALLOCATABLE,DIMENSION(:,:) :: time_bounds
 
REAL*4,ALLOCATABLE,DIMENSION(:,:,:) :: bounds_nav_lat, bounds_nav_lon, thetao, thetao_mean
 
!==================================================================

period = '185001-189912'

Nmembers=19

!==================================================================

write(file_out,222) TRIM(period)
222 FORMAT('/scratchu/njourdain/MULTI_MEMBER_MEAN/thetao_Omon_UKESM1-0-LL_historical_r0i1p1f2_gn_',a,'.nc')

!==================================================================
! Read dimensions and variables common to all members:

kmem=1
write(file_in,101) kmem, kmem, TRIM(period)
101 FORMAT('/bdd/CMIP6/CMIP/MOHC/UKESM1-0-LL/historical/r',i1,'i1p1f2/Omon/thetao/gn/latest/thetao_Omon_UKESM1-0-LL_historical_r',i1,'i1p1f2_gn_',a,'.nc')
501 FORMAT('/bdd/CMIP6/CMIP/MOHC/UKESM1-0-LL/historical/r',i1,'i1p1f3/Omon/thetao/gn/latest/thetao_Omon_UKESM1-0-LL_historical_r',i1,'i1p1f3_gn_',a,'.nc')
102 FORMAT('/bdd/CMIP6/CMIP/MOHC/UKESM1-0-LL/historical/r',i2,'i1p1f2/Omon/thetao/gn/latest/thetao_Omon_UKESM1-0-LL_historical_r',i2,'i1p1f2_gn_',a,'.nc')

write(*,*) 'Reading ', TRIM(file_in)
status = NF90_OPEN(TRIM(file_in),0,fidA); call erreur(status,.TRUE.,"read")
 
status = NF90_INQ_DIMID(fidA,"time",dimID_time); call erreur(status,.TRUE.,"inq_dimID_time")
status = NF90_INQ_DIMID(fidA,"lev",dimID_olevel); call erreur(status,.TRUE.,"inq_dimID_olevel")
status = NF90_INQ_DIMID(fidA,"vertices",dimID_nvertex); call erreur(status,.TRUE.,"inq_dimID_nvertex")
status = NF90_INQ_DIMID(fidA,"j",dimID_y); call erreur(status,.TRUE.,"inq_dimID_y")
status = NF90_INQ_DIMID(fidA,"i",dimID_x); call erreur(status,.TRUE.,"inq_dimID_x")
status = NF90_INQ_DIMID(fidA,"bnds",dimID_axis_nbounds); call erreur(status,.TRUE.,"inq_dimID_axis_nbounds")
 
status = NF90_INQUIRE_DIMENSION(fidA,dimID_time,len=mtime); call erreur(status,.TRUE.,"inq_dim_time")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_olevel,len=molevel); call erreur(status,.TRUE.,"inq_dim_olevel")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_nvertex,len=mnvertex); call erreur(status,.TRUE.,"inq_dim_nvertex")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_y,len=my); call erreur(status,.TRUE.,"inq_dim_y")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_x,len=mx); call erreur(status,.TRUE.,"inq_dim_x")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_axis_nbounds,len=maxis_nbounds); call erreur(status,.TRUE.,"inq_dim_axis_nbounds")

ALLOCATE(  time_bounds(maxis_nbounds,mtime)  )
ALLOCATE(  time(mtime)  )
ALLOCATE(  thetao(mx,my,molevel)  )
ALLOCATE(  thetao_mean(mx,my,molevel)  )
ALLOCATE(  olevel_bounds(maxis_nbounds,molevel)  )
ALLOCATE(  olevel(molevel)  )
ALLOCATE(  bounds_nav_lat(mnvertex,mx,my)  )
ALLOCATE(  bounds_nav_lon(mnvertex,mx,my)  )
ALLOCATE(  nav_lon(mx,my)  )
ALLOCATE(  nav_lat(mx,my)  )

status = NF90_INQ_VARID(fidA,"time_bnds",time_bounds_ID); call erreur(status,.TRUE.,"inq_time_bounds_ID")
status = NF90_INQ_VARID(fidA,"time",time_ID); call erreur(status,.TRUE.,"inq_time_ID")
status = NF90_INQ_VARID(fidA,"lev_bnds",olevel_bounds_ID); call erreur(status,.TRUE.,"inq_olevel_bounds_ID")
status = NF90_INQ_VARID(fidA,"lev",olevel_ID); call erreur(status,.TRUE.,"inq_olevel_ID")
status = NF90_INQ_VARID(fidA,"vertices_latitude",bounds_nav_lat_ID); call erreur(status,.TRUE.,"inq_bounds_nav_lat_ID")
status = NF90_INQ_VARID(fidA,"vertices_longitude",bounds_nav_lon_ID); call erreur(status,.TRUE.,"inq_bounds_nav_lon_ID")
status = NF90_INQ_VARID(fidA,"longitude",nav_lon_ID); call erreur(status,.TRUE.,"inq_nav_lon_ID")
status = NF90_INQ_VARID(fidA,"latitude",nav_lat_ID); call erreur(status,.TRUE.,"inq_nav_lat_ID")
 
status = NF90_GET_VAR(fidA,time_bounds_ID,time_bounds); call erreur(status,.TRUE.,"getvar_time_bounds")
status = NF90_GET_VAR(fidA,time_ID,time); call erreur(status,.TRUE.,"getvar_time")
status = NF90_GET_VAR(fidA,olevel_bounds_ID,olevel_bounds); call erreur(status,.TRUE.,"getvar_olevel_bounds")
status = NF90_GET_VAR(fidA,olevel_ID,olevel); call erreur(status,.TRUE.,"getvar_olevel")
status = NF90_GET_VAR(fidA,bounds_nav_lat_ID,bounds_nav_lat); call erreur(status,.TRUE.,"getvar_bounds_nav_lat")
status = NF90_GET_VAR(fidA,bounds_nav_lon_ID,bounds_nav_lon); call erreur(status,.TRUE.,"getvar_bounds_nav_lon")
status = NF90_GET_VAR(fidA,nav_lon_ID,nav_lon); call erreur(status,.TRUE.,"getvar_nav_lon")
status = NF90_GET_VAR(fidA,nav_lat_ID,nav_lat); call erreur(status,.TRUE.,"getvar_nav_lat")

status = NF90_CLOSE(fidA); call erreur(status,.TRUE.,"close_file")

!==================================================================
! Create output files and write variables common to all members:

write(*,*) 'Creating ', TRIM(file_out)
 
status = NF90_CREATE(TRIM(file_out),NF90_NETCDF4,fidM); call erreur(status,.TRUE.,'create')
 
status = NF90_DEF_DIM(fidM,"time",NF90_UNLIMITED,dimID_time); call erreur(status,.TRUE.,"def_dimID_time")
status = NF90_DEF_DIM(fidM,"lev",molevel,dimID_olevel); call erreur(status,.TRUE.,"def_dimID_olevel")
status = NF90_DEF_DIM(fidM,"vertices",mnvertex,dimID_nvertex); call erreur(status,.TRUE.,"def_dimID_nvertex")
status = NF90_DEF_DIM(fidM,"j",my,dimID_y); call erreur(status,.TRUE.,"def_dimID_y")
status = NF90_DEF_DIM(fidM,"i",mx,dimID_x); call erreur(status,.TRUE.,"def_dimID_x")
status = NF90_DEF_DIM(fidM,"bnds",maxis_nbounds,dimID_axis_nbounds); call erreur(status,.TRUE.,"def_dimID_axis_nbounds")
  
status = NF90_DEF_VAR(fidM,"time_bnds",NF90_DOUBLE,(/dimID_axis_nbounds,dimID_time/),time_bounds_ID); call erreur(status,.TRUE.,"def_var_time_bounds_ID")
status = NF90_DEF_VAR(fidM,"time",NF90_DOUBLE,(/dimID_time/),time_ID); call erreur(status,.TRUE.,"def_var_time_ID")
status = NF90_DEF_VAR(fidM,"thetao",NF90_FLOAT,(/dimID_x,dimID_y,dimID_olevel,dimID_time/),thetao_mean_ID,deflate_level=1); call erreur(status,.TRUE.,"def_var_thetao_mean_ID")
status = NF90_DEF_VAR(fidM,"lev_bnds",NF90_FLOAT,(/dimID_axis_nbounds,dimID_olevel/),olevel_bounds_ID); call erreur(status,.TRUE.,"def_var_olevel_bounds_ID")
status = NF90_DEF_VAR(fidM,"lev",NF90_FLOAT,(/dimID_olevel/),olevel_ID); call erreur(status,.TRUE.,"def_var_olevel_ID")
status = NF90_DEF_VAR(fidM,"vertices_latitude",NF90_FLOAT,(/dimID_nvertex,dimID_x,dimID_y/),bounds_nav_lat_ID); call erreur(status,.TRUE.,"def_var_bounds_nav_lat_ID")
status = NF90_DEF_VAR(fidM,"vertices_longitude",NF90_FLOAT,(/dimID_nvertex,dimID_x,dimID_y/),bounds_nav_lon_ID); call erreur(status,.TRUE.,"def_var_bounds_nav_lon_ID")
status = NF90_DEF_VAR(fidM,"longitude",NF90_FLOAT,(/dimID_x,dimID_y/),nav_lon_ID); call erreur(status,.TRUE.,"def_var_nav_lon_ID")
status = NF90_DEF_VAR(fidM,"latitude",NF90_FLOAT,(/dimID_x,dimID_y/),nav_lat_ID); call erreur(status,.TRUE.,"def_var_nav_lat_ID")
 
status = NF90_PUT_ATT(fidM,thetao_mean_ID,"history","none"); call erreur(status,.TRUE.,"put_att_thetao_mean_ID")
status = NF90_PUT_ATT(fidM,thetao_mean_ID,"coordinates","latitude longitude"); call erreur(status,.TRUE.,"put_att_thetao_mean_ID")
status = NF90_PUT_ATT(fidM,thetao_mean_ID,"missing_value",1.e+20); call erreur(status,.TRUE.,"put_att_thetao_mean_ID")
status = NF90_PUT_ATT(fidM,thetao_mean_ID,"_FillValue",1.e+20); call erreur(status,.TRUE.,"put_att_thetao_mean_ID")
status = NF90_PUT_ATT(fidM,thetao_mean_ID,"units","degC"); call erreur(status,.TRUE.,"put_att_thetao_mean_ID")
status = NF90_PUT_ATT(fidM,thetao_mean_ID,"long_name","Sea Water Potential Temperature"); call erreur(status,.TRUE.,"put_att_thetao_mean_ID")
status = NF90_PUT_ATT(fidM,thetao_mean_ID,"standard_name","sea_water_potential_temperature"); call erreur(status,.TRUE.,"put_att_thetao_mean_ID")
status = NF90_PUT_ATT(fidM,time_ID,"bounds","time_bnds"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidM,time_ID,"time_origin","1850-01-01 00:00:00"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidM,time_ID,"units","days since 1850-01-01 00:00:00"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidM,time_ID,"calendar","360_day"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidM,time_ID,"long_name","time"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidM,time_ID,"standard_name","time"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidM,time_ID,"axis","T"); call erreur(status,.TRUE.,"put_att_time_ID")
status = NF90_PUT_ATT(fidM,olevel_bounds_ID,"units","m"); call erreur(status,.TRUE.,"put_att_olevel_bounds_ID")
status = NF90_PUT_ATT(fidM,olevel_ID,"bounds","lev_bnds"); call erreur(status,.TRUE.,"put_att_olevel_ID")
status = NF90_PUT_ATT(fidM,olevel_ID,"positive","down"); call erreur(status,.TRUE.,"put_att_olevel_ID")
status = NF90_PUT_ATT(fidM,olevel_ID,"units","m"); call erreur(status,.TRUE.,"put_att_olevel_ID")
status = NF90_PUT_ATT(fidM,olevel_ID,"long_name","ocean depth coordinate"); call erreur(status,.TRUE.,"put_att_olevel_ID")
status = NF90_PUT_ATT(fidM,olevel_ID,"standard_name","depth"); call erreur(status,.TRUE.,"put_att_olevel_ID")
status = NF90_PUT_ATT(fidM,nav_lon_ID,"bounds","vertices_longitude"); call erreur(status,.TRUE.,"put_att_nav_lon_ID")
status = NF90_PUT_ATT(fidM,nav_lon_ID,"units","degrees_east"); call erreur(status,.TRUE.,"put_att_nav_lon_ID")
status = NF90_PUT_ATT(fidM,nav_lon_ID,"long_name","longitude"); call erreur(status,.TRUE.,"put_att_nav_lon_ID")
status = NF90_PUT_ATT(fidM,nav_lon_ID,"standard_name","longitude"); call erreur(status,.TRUE.,"put_att_nav_lon_ID")
status = NF90_PUT_ATT(fidM,nav_lat_ID,"bounds","vertices_longitude"); call erreur(status,.TRUE.,"put_att_nav_lat_ID")
status = NF90_PUT_ATT(fidM,nav_lat_ID,"units","degrees_north"); call erreur(status,.TRUE.,"put_att_nav_lat_ID")
status = NF90_PUT_ATT(fidM,nav_lat_ID,"long_name","latitude"); call erreur(status,.TRUE.,"put_att_nav_lat_ID")
status = NF90_PUT_ATT(fidM,nav_lat_ID,"standard_name","latitude"); call erreur(status,.TRUE.,"put_att_nav_lat_ID")
 
status = NF90_PUT_ATT(fidM,NF90_GLOBAL,"history","Created using build_multimember_mean_thetao_UKESM.f90")
status = NF90_PUT_ATT(fidM,NF90_GLOBAL,"content","Multi-member mean")
status = NF90_PUT_ATT(fidM,NF90_GLOBAL,"number_of_members",Nmemb)
call erreur(status,.TRUE.,"put_att_GLOBAL_ID")
 
status = NF90_ENDDEF(fidM); call erreur(status,.TRUE.,"fin_definition") 
 
status = NF90_PUT_VAR(fidM,time_bounds_ID,time_bounds); call erreur(status,.TRUE.,"var_time_bounds_ID")
status = NF90_PUT_VAR(fidM,time_ID,time); call erreur(status,.TRUE.,"var_time_ID")
status = NF90_PUT_VAR(fidM,olevel_bounds_ID,olevel_bounds); call erreur(status,.TRUE.,"var_olevel_bounds_ID")
status = NF90_PUT_VAR(fidM,olevel_ID,olevel); call erreur(status,.TRUE.,"var_olevel_ID")
status = NF90_PUT_VAR(fidM,bounds_nav_lat_ID,bounds_nav_lat); call erreur(status,.TRUE.,"var_bounds_nav_lat_ID")
status = NF90_PUT_VAR(fidM,bounds_nav_lon_ID,bounds_nav_lon); call erreur(status,.TRUE.,"var_bounds_nav_lon_ID")
status = NF90_PUT_VAR(fidM,nav_lon_ID,nav_lon); call erreur(status,.TRUE.,"var_nav_lon_ID")
status = NF90_PUT_VAR(fidM,nav_lat_ID,nav_lat); call erreur(status,.TRUE.,"var_nav_lat_ID")
 
!==================================================================

DO kt=1,mtime

  write(*,*) kt

  thetao_mean(:,:,:) = 0.e0
  Nmemb=0

  do kmem=1,Nmembers
   if ( kmem .le. 12 .or. kmem .ge. 16 ) then ! UKESM

    if ( kmem .lt. 10 ) then
      if ( kmem .ge. 5 .and. kmem .le. 7 ) then
        write(file_in,501) kmem, kmem, TRIM(period)
      else
        write(file_in,101) kmem, kmem, TRIM(period)
      endif
    else 
      write(file_in,102) kmem, kmem, TRIM(period)
    endif

    status = NF90_OPEN(TRIM(file_in),0,fidA)
    if ( status .ne. 0 ) then
      write(*,*) 'ERROR with file ', file_in
      call erreur(status,.TRUE.,"read_file")
    endif
    status = NF90_INQ_VARID(fidA,"thetao",thetao_ID); call erreur(status,.TRUE.,"inq_thetao_ID")
    status = NF90_GET_VAR(fidA,thetao_ID,thetao,start=(/1,1,1,kt/),count=(/mx,my,molevel,1/)); call erreur(status,.TRUE.,"getvar_thetao")
    status = NF90_CLOSE(fidA); call erreur(status,.TRUE.,"close_file")


    thetao_mean(:,:,:) = thetao_mean(:,:,:) + thetao(:,:,:)

    Nmemb = Nmemb + 1

   endif
  enddo

  thetao_mean(:,:,:) = thetao_mean(:,:,:) / Nmemb
  
  status = NF90_PUT_VAR(fidM,thetao_mean_ID,thetao_mean,start=(/1,1,1,kt/),count=(/mx,my,molevel,1/))
  call erreur(status,.TRUE.,"var_thetao_mean_ID")

ENDDO

status = NF90_CLOSE(fidM); call erreur(status,.TRUE.,"final")
 
end program modif


!====================================================================
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
