      subroutine add_star(xg, yg, mag, abmag, integration_time,
     &     noiseless, psf_add, ipc_add, distortion,
     *     psf_scale, over_sampling_rate, naxis1, naxis2, 
     *     sca, precise,
     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &     det_sci_yangle, det_sci_parity,
     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     *     verbose)
c
c     Add a single stars to an image.
c     2018-06-13
c     2020-05-12
c     
      implicit none
      double precision xg, yg, mag, abmag,integration_time
      double precision intensity, total_per_cycle, stellar_photons,
     *     x_sca, y_sca, xx, yy, xhit, yhit, x_osim, y_osim
      double precision v2, v3, xdet, ydet
      double precision psf_scale
      double precision photon_flux_from_uresp, zbqlnor
c
      real gain_image
c
      integer distortion, over_sampling_rate, sca, precise
      integer expected, zbqlpoi
      integer colcornr, rowcornr, naxis1, naxis2, filter_index
      integer verbose, sca_id, nnn, max_stars, nfilters, ix, iy,
     *     i, j, nstars, ixmin, ixmax, iymin, iymax, seed, invert,
     *     in_field
c     
      integer ideal_to_sci_degree, v_idl_parity,
     &     sci_to_ideal_degree, det_sci_parity
      double precision 
     &     x_det_ref, y_det_ref,
     &     x_sci_ref, y_sci_ref,
     &     sci_to_ideal_x, sci_to_ideal_y,
     &     ideal_to_sci_x, ideal_to_sci_y,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang,
     &     det_sci_yangle,
     &     v2_ref, v3_ref
      dimension 
     &     sci_to_ideal_x(6,6), sci_to_ideal_y(6,6), 
     &     ideal_to_sci_x(6,6), ideal_to_sci_y(6,6)
c
      character subarray*8
      logical noiseless, psf_add, ipc_add
c
      parameter (max_stars=10000,nnn=2048,nfilters=54)
c
      dimension gain_image(nnn,nnn)
c
      if (verbose .ge.1) then
         print *,'enter add_star'
      end if
      ixmin = 5
      ixmax = 2044
      iymin = 5
      iymax = 2044
c
c     if(subarray(1:4) .eq.'FULL') then
c         ixmin = 5
c         ixmax = naxis1- 4
c         iymin = 5
c         iymax = naxis2 - 4
c      else
c         ixmin = colcornr
c         ixmax = ixmin + naxis1
c         iymin = rowcornr
c         iymax = iymin + naxis2
c      end if
c
      xhit     = 0.0d0
      xhit     = 0.0d0
      in_field = 0
c     
      stellar_photons = photon_flux_from_uresp(mag, abmag)
c     
c     Find expected number of photo-electrons
c     
      total_per_cycle = stellar_photons * integration_time
c     
c     for noiseless
c     
c      if(noiseless .eqv. .true.) then
         expected = total_per_cycle 
c      else
c         expected = zbqlpoi(total_per_cycle)
c      end if
c      
      if(verbose.gt.0) then
c         if(idnint(xg).eq.672 .and.idnint(yg).eq.1216) then
         print 10, xg, yg, mag, stellar_photons,
     *        integration_time, total_per_cycle, expected
 10      format('add_star ', 2(1x,f9.3), 1x,f9.3, 
     *        3(2x,f12.2),2x,i10)
      end if
c
      if(expected .gt.0 ) then
         if(distortion.eq.0) then
            do j = 1, expected
               if(psf_add .eqv. .true.) 
     &              call psf_convolve(seed, xhit, yhit)
c     
               ix = idnint(xg - xhit)
               iy = idnint(yg - yhit)
c     
c     add this photo-electron
c     
               if(ix.gt.ixmin .and.ix.lt.ixmax .and. 
     *              iy.gt.iymin .and. iy .lt.ixmax) then
                  intensity = 1.d0
                  call add_ipc(ix, iy, intensity,naxis1, naxis2, 
     &                 ipc_add)
c     PRINT *, 'ADD IPC ', IX, IY
               end if
            end do
c
c     adding focal plane distortion
c     calculate v2, v3 
c
         else
            do j = 1, expected
               call psf_convolve(seed, xhit, yhit)
c     detector coordinates for this photon (arc sec)
               v2 = xg + xhit * psf_scale
               v3 = yg + yhit * psf_scale
c            print *,'add_star: xg, yg,v2, v3, xhit, yhit, psf_scale ',
c     &              xg, yg, v2, v3, xhit, yhit, psf_scale
               call v2v3_to_det(
     &              x_det_ref, y_det_ref,
     &              x_sci_ref, y_sci_ref,
     &              sci_to_ideal_x,sci_to_ideal_y, sci_to_ideal_degree,
     &              ideal_to_sci_x,ideal_to_sci_y,ideal_to_sci_degree,
     &              v3_sci_x_angle,v3_sci_y_angle,
     &              v3_idl_yang, v_idl_parity,
     &              det_sci_yangle,
     &              v2_ref, v3_ref,
     &              v2, v3, xdet, ydet,
     &              precise,verbose)
               ix = idnint(xdet)
               iy = idnint(ydet)
               if(ix.gt.ixmin .and.ix.lt.ixmax .and. 
     *              iy.gt.iymin .and. iy .lt.ixmax) then
                  intensity = 1.d0
                  call add_ipc(ix, iy, intensity,naxis1, naxis2, 
     &                 ipc_add)
               endif
            end do
         endif
      end if
      return
      end
