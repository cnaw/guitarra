      subroutine get_distortion(ra_dithered, dec_dithered, pa_degrees,
     &     indx, attitude_inv)
c
      implicit none
      double precision ra_dithered, dec_dithered, pa_degrees
      double precision nrcall_v2, nrcall_v3, nrc_v2_rad, nrc_v3_rad,
     &     ra_rad, dec_rad, pa_rad, attitude_dir, attitude_inv, q
      integer indx, i, j
      character guitarra_aux*100, v2v3_ref*180
      dimension nrc_v2_rad(10), nrc_v3_rad(10), attitude_dir(3,3),
     &     attitude_inv(3,3)
c      
      q   = dacos(-1.0d0)/180.d0
c
c     read V2, V3 coordinates of NIRCam and individual SCAs
c     using SIAF model 
c
      call getenv('GUITARRA_AUX',guitarra_aux)
      v2v3_ref = guitarra_aux(1:len_trim(guitarra_aux))//'v2v3_reference
     &_coords.dat'
      print 100, v2v3_ref
 100  format(a180)
      open(37,file=v2v3_ref)
      read(37,*)
      read(37,*) nrcall_v2, nrcall_v3
      nrcall_v2 = q * nrcall_v2/3600.d0
      nrcall_v3 = q * nrcall_v3/3600.d0
      do i = 1, 10
         read(37,*) nrc_v2_rad(i), nrc_v3_rad(i)
         nrc_v2_rad(i) = q*nrc_v2_rad(i)/3600.d0
         nrc_v3_rad(i) = q*nrc_v3_rad(i)/3600.d0
      end do
      close(37)
c
c     Build the attitude matrix corresponding to the origin of NIRCam.
c     First convert angles into radians
c     
      ra_rad  = ra_dithered * q
      dec_rad = dec_dithered * q
      pa_rad  = pa_degrees * q
      call attitude(nrcall_v2, nrcall_v3, ra_rad, dec_rad, pa_rad,
     *     attitude_dir)
c     
c     Find the corresponding (RA, DEC) for a given SCA, when given
c     the RA, DEC, and PA_V3 for a NIRCam pointing. 
c     
      print *,'get_distortion: indx', indx
      call rot_coords(attitude_dir, nrc_v2_rad(indx), nrc_v3_rad(indx),
     &      ra_rad, dec_rad)
      print *,'get_distortion: ra_rad, dec_rad', ra_rad, dec_rad
c     
c     Build the attitude matrix for this new position, which allows
c     calculating V2, V3 for the catalogue ra, dec of objects falling
c     within the SCA footprint
c     
      call attitude(nrc_v2_rad(indx), nrc_v3_rad(indx), 
     *     ra_rad, dec_rad, pa_rad, attitude_dir)
c     
c     The inverse attitude matrix is the one that will do the conversion
c     of (ra,dec) -> (v2, v3)
c     
      do j = 1, 3
         do i = 1, 3
            attitude_inv(j,i) = attitude_dir(i,j)
         end do
      end do
      return
      end
