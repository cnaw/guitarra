c
c     create the clonned 1-D image from 2-D templates
      subroutine prepare_clone_s(filename, kk, level, nx, ny,
     &     x_scale, y_scale, sca_scale, one_d, nxny, npts,
     &     magnitude, nfilters, verbose)
c      
      implicit none
      integer ii, jj, kk, ll, nx_zgal, ny_zgal, nfilters,verbose
c     
c     images
c
      character filename*(*)
      double precision two_d, one_d
!
      real cube, template, temp
      integer int_cube, naxes, level, ntemplates, bitpix, extnum
      integer npts, nxny,  mmm, nnn,nnrc, ooo
      integer nx, ny, nz
c     
c     WCS
c
      character cunit1*40, cunit2*40, cunit3*40, radesys*8,
     *     ctype1*40,ctype2*40, ctype3*40
      double precision crpix1, crval1,
     &     crpix2, crval2, crpix3, crval3,
     &     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3, equinox
c
      parameter(mmm=512, nnn =2048, ooo=11, nnrc=10)
c
      dimension cube(nnn,nnn, ooo), int_cube(nnn,nnn, ooo)
      dimension template(nnn,nnn),temp(nnn,nnn)
      dimension two_d(nnn,nnn), one_d(nxny)
c
      character filter*6, source*120, nrc_name*6
      integer nf, number, indx, last
      double precision wl_filter, magnitude, zp, redshift
      double precision ra, dec, zz,  mz, scale_0, scale_z, mag,
     &     nrc_zp, nrc, sca_scale, x_scale, y_scale
      dimension filter(ooo), wl_filter(ooo), zp(ooo),
     &     source(ooo), nrc(nnrc), nrc_name(nnrc), nrc_zp(nnrc),
     &    magnitude(nfilters)

      data nrc/0.7046d0,0.9025d0, 1.1543d0, 1.5007d0, 1.9886d0,
     &     2.7618d0, 3.3621d0, 3.5684d0, 4.0822d0, 4.4040d0/
      data nrc_name/'F070W','F090W','F115W','F150W','F200W',
     &     'F277W','F335M','F356W','F410M','F444W'/
      data nrc_zp/27.033d0, 27.453d0, 27.568d0, 27.814d0, 27.997d0,
     &     27.880d0, 27.058d0, 28.007d0, 27.185d0, 28.065d0/
!
      call read_template_image(filename, bitpix,
     &     cube, int_cube,
     &     nnn, nnn, ooo, nx, ny, nz, redshift ,mag, number,
     &     radesys, equinox,
     &     ctype1, cunit1, crpix1, crval1,
     &     ctype2, cunit2, crpix2, crval2,
     &     ctype3, cunit3, crpix3, crval3, 
     &     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3,
     &     filter, wl_filter, magnitude, zp, source, nf,
     &     verbose)
      if(verbose .gt.0) 
     & print *,'prepare_clone_s : nx, ny, nz, level',nx, ny, nz, level
      if(bitpix.eq.32 .or.bitpix.eq.16) then
         do jj = 1, ny
            do ii = 1, nx
               if(int_cube(ii,jj,level) .lt.0) then
                  two_d(ii,jj) = 0
               else
                  two_d(ii,jj) = int_cube(ii,jj,level)
               end if
            end do
         end do
      endif
      if(bitpix.eq.-32 .or.bitpix.eq.-64) then
         do jj = 1, ny
            do ii = 1, nx
               if(cube(ii,jj,level) .lt.0) then
                  two_d(ii,jj) = 0
               else
                  two_d(ii,jj) = cube(ii,jj,level)
               end if
            end do
         end do
      end if
      x_scale = dsqrt(cd1_1*cd1_1+cd1_2*cd1_2)
      y_scale = dsqrt(cd2_1*cd2_1+cd2_2*cd2_2)
      scale_0 = (x_scale+y_scale)/2.d0
      if(kk.le.5) then
         sca_scale = 0.031d0
      else
         sca_scale = 0.063d0
      end if
      scale_z = sca_scale
      ra      = crval1
      dec     = crval2
      zz      = redshift
      nx_zgal = nx
      ny_zgal = ny
      extnum   = 0
      call integration(two_d, nnn, nx_zgal, ny_zgal, 
     *     one_d, nxny, npts, verbose)
      return
      end
      

