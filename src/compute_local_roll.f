c      implicit none
c      real (kind=8) ra_ref, dec_ref, v2_ref, v3_ref, pa_v3, roll_ref,
c     &     source
c      ra_REF=146.8773091666667d0
c      dec_REF =63.2478083333333d0
c      pa_v3 = 0.0
c      v2_ref =-121.154684d0
c      v3_ref =-525.4781410000001d0
c      call compute_local_roll( pa_v3, ra_ref, dec_ref, v2_ref,
c     &     v3_ref, roll_ref)
c      source = 359.9335734123501d0
c      print *,'here :', roll_ref
c      print *,'JWST :', source
c      print *,'diff :', source-roll_ref
c      stop
c      end
!---------------------------------------------------------------------
!     https://github.com/spacetelescope/jwst/blob/master/jwst/lib/set_telescope_pointing.py
!     (compute_local_roll)
      subroutine compute_local_roll( pa_v3, ra_ref, dec_ref, v2_ref,
     &     v3_ref, roll_ref)
      implicit none
      real (kind=8) :: v2_ref, v3_ref, ra_ref, dec_ref, pa_v3, roll_ref
      real (kind=8) :: v2_rad, v3_rad, ra_rad, dec_rad, pa_rad, roll_rad
      real (kind=8) :: qq
      real (kind=8) :: matrix1, xx, yy
      real (kind=8) cosra, sinra, cosdec, sindec, cosv2, sinv2, cosv3,
     &     sinv3, cospa, sinpa
      dimension matrix1(3,3)
!
      qq = dacos(-1.0d0)/180.0d0
!
      v2_rad  = v2_ref*qq/3600.d0
      v3_rad  = v3_ref*qq/3600.d0
      ra_rad  = ra_ref*qq
      dec_rad = dec_ref*qq
      pa_rad  = pa_v3*qq
!
      cosra   = dcos(ra_rad)
      sinra   = dsin(ra_rad)
      cosdec  = dcos(dec_rad)
      sindec  = dsin(dec_rad)
      cospa   = dcos(pa_rad)
      sinpa   = dsin(pa_rad)
      cosv2   = dcos(v2_rad)
      sinv2   = dsin(v2_rad)
      cosv3   = dcos(v3_rad)
      sinv3   = dsin(v3_rad)
!     
      matrix1(1,1) =  cosra*cosdec
      matrix1(1,2) = -sinra*cospa + cosra*sindec*sinpa
      matrix1(1,3) = -sinra*sinpa - cosra*sindec*cospa
!
      matrix1(2,1) =  sinra*cosdec
      matrix1(2,2) =  cosra*cospa + sinra*sindec*sinpa
      matrix1(2,3) =  cosra*sinpa - sinra*sindec*cospa
!
      matrix1(3,1) =  sindec
      matrix1(3,2) = -cosdec * sinpa
      matrix1(3,3) =  cosdec * cospa
!
!     roll_angle_from_matrix
!
      xx =-(matrix1(3,1)*cosv2 + matrix1(3,2)*sinv2) * sinv3 +
     &      matrix1(3,3)*cosv3
      yy =(matrix1(1,1)*matrix1(2,3) - matrix1(2,1)*matrix1(1,3))*cosv2
     &   +(matrix1(1,2)*matrix1(2,3) - matrix1(2,2)*matrix1(1,3))*sinv2
     
      roll_rad = datan2(yy,xx)
      roll_ref = roll_rad/qq
      if(roll_ref .lt. 0.0d0) roll_ref = roll_ref + 360.d0
      return
      end
      
