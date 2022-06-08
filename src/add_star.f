c
c     Add a point source to a scene. Calculate the PSF in (ra, dec)
c     space when focal plane distortion is included
c     
      subroutine add_star(v2_arcsec, v3_arcsec,
     &     xg, yg, 
     &     subarray,colcornr, rowcornr,
     &     mag, abmag, integration_time,
     &     noiseless, psf_add, ipc_add,
     *     psf_scale, over_sampling_rate, naxis1, naxis2, 
     *     sca, distortion, precise,
     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &     det_sci_yangle, det_sci_parity,
     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     *     verbose)
c
c     Add a single stars to an image.
c     2018-06-13
c     2020-05-12, 2020-06-23, 2021-02-04, 2021-08-20
c     
      implicit none
      double precision xg, yg, mag, abmag,integration_time
      double precision intensity, total_per_cycle, stellar_photons,
     *     x_sca, y_sca, xx, yy, xhit, yhit, x_osim, y_osim
      double precision v2, v3, xdet, ydet,v2_arcsec, v3_arcsec
      double precision psf_scale
      double precision photon_flux_from_uresp, zbqlnor
c
      integer distortion, over_sampling_rate, sca, precise
      integer (kind=8)  expected
      integer zbqlpoi
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

      character subarray*(*)
      logical noiseless, psf_add, ipc_add
c
      parameter (max_stars=10000,nnn=2048,nfilters=54)
c
      if (verbose .ge.1) then
         print *,'enter add_star'
      end if
c     
c     Find expected number of photo-electrons
c     
      stellar_photons = photon_flux_from_uresp(mag, abmag)
      total_per_cycle = stellar_photons * integration_time
c     
c     for noiseless
c     
      if(noiseless .eqv. .true.) then
         expected = total_per_cycle 
      else
         if(total_per_cycle.gt.1.0d09) then
            expected = total_per_cycle
         else
            expected = zbqlpoi(total_per_cycle)
         end if
      end if
c
c     lets speed things up for really bright stars
c     
      intensity = 1.0d0
      if(expected .gt. 1.d09) then
         intensity = 100.0
         if(verbose.eq.1)
     &        print *,'add_star : mag, total_per_cycle, intensity',
     &        mag, total_per_cycle, intensity
         expected = zbqlpoi(total_per_cycle/intensity)
         print *,'add_star : mag, expected', mag, expected
      end if
c
ccccccccccccccccccccccccc
c
c     set image domain
c
      ixmin = 5
      ixmax = 2044
      iymin = 5
      iymax = 2044
c
      if(subarray(1:4) .eq.'FULL') then
         ixmin = 5
         ixmax = naxis1- 4
         iymin = 5
         iymax = naxis2 - 4
      else
         ixmin = colcornr
         ixmax = ixmin + naxis1 - 1
         iymin = rowcornr
         iymax = iymin + naxis2 - 1
      end if
c
ccccccccccccccccccccccccc
c
c     from here add photons
c
      xhit     = 0.0d0
      xhit     = 0.0d0
      in_field = 0
c     
      if(expected .gt.0 ) then
         if(distortion.eq.0 .or. distortion.eq.2) then
            do j = 1, expected
               if(psf_add .eqv. .true.) then
                  call psf_convolve(seed, xhit, yhit)
               else
                  xhit = 0.0d0
                  yhit = 0.0d0
               end if
c     
               ix = idnint(xg - xhit) !- colcornr 2021-03-19
               iy = idnint(yg - yhit) !- rowcornr 2021-03-19
c     
c     add this photo-electron
c
               if(ix.gt.ixmin .and.ix.lt.ixmax .and. 
     *              iy.gt.iymin .and. iy .lt.ixmax) then
                  call add_ipc(ix, iy, intensity,naxis1, naxis2, 
     &                 ipc_add)
               end if
            end do
         end if
c     
c     adding focal plane distortion
c     calculate v2, v3 
c
         if(distortion.eq.1) then
            do j = 1, expected
               if(psf_add.eqv. .true.) then
                  call psf_convolve(seed, xhit, yhit)
               else
                  xhit = 0.d0
                  yhit = 0.d0
               end if
c     detector (V2, V3) coordinates for this photon (arc sec)
               v2 = v2_arcsec + xhit * psf_scale
               v3 = v3_arcsec + yhit * psf_scale
               call v2v3_to_det(
     &              x_det_ref, y_det_ref,
     &              x_sci_ref, y_sci_ref,
     &              sci_to_ideal_x,sci_to_ideal_y, sci_to_ideal_degree,
     &              ideal_to_sci_x,ideal_to_sci_y,ideal_to_sci_degree,
     &              v3_sci_x_angle,v3_sci_y_angle,
     &              v3_idl_yang, v_idl_parity,
     &              det_sci_yangle, det_sci_parity,
     &              v2_ref, v3_ref,
     &              v2, v3, xx, yy,
     &              precise,verbose)
               ix = idnint(xx)
               iy = idnint(yy)
               if(ix.gt.ixmin .and.ix.lt.ixmax .and. 
     *              iy.gt.iymin .and. iy .lt.ixmax) then
                  call add_ipc(ix, iy, intensity,naxis1, naxis2, 
     &                 ipc_add)
c                  print *,'add_star : mag, expected',
c     &                 xg,yg,ix,iy,mag,expected,intensity
c                  print *,'add_star ', ix, iy, j
c                  if(verbose.gt.0) then
c                     print 10, xg, yg, xx, yy, mag, stellar_photons,
c     *                    integration_time, total_per_cycle, expected
c 10                  format('add_star ', 4(1x,f9.3), 1x,f9.3, 
c     *                    3(2x,f12.2),2x,i10)
c                  end if

               end if
            end do
         end if
      end if
      return
      end
