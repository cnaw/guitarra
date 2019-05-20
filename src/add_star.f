      subroutine add_star(xg, yg, mag, abmag, integration_time,
     &     noiseless, psf_add, ipc_add, verbose)
c
c     Add a single stars to an image.
c     2018-06-13
c     
      implicit none
      double precision xg, yg, mag, abmag,integration_time
      double precision intensity, total_per_cycle, stellar_photons,
     *     x_sca, y_sca, xx, yy, xhit, yhit, x_osim, y_osim
      double precision photon_flux_from_uresp, zbqlnor
c
      real gain_image
c
      integer expected, zbqlpoi
      integer colcornr, rowcornr, naxis1, naxis2, filter_index
      integer verbose, sca_id, nnn, max_stars, nfilters, ix, iy,
     *     i, j, nstars, ixmin, ixmax, iymin, iymax, seed, invert,
     *     in_field
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
      if(noiseless .eqv. .true.) then
         expected = total_per_cycle 
      else
         expected = zbqlpoi(total_per_cycle)
      end if
c      
      if(verbose.gt.0) then
         print 10, xg, yg, mag, stellar_photons,
     *        integration_time, total_per_cycle, expected
 10      format('add_star ', 2(1x,f9.3), 1x,f9.3, 
     *        3(2x,f12.2),2x,i10)
      end if
c
      if(expected .gt.0 ) then
         do j = 1, expected
            if(psf_add .eqv. .true.) 
     &           call psf_convolve(seed, xhit, yhit)
c     
            ix = idnint(xg - xhit)
            iy = idnint(yg - yhit)
c     
c     add this photo-electron
c     
            if(ix.gt.ixmin .and.ix.lt.ixmax .and. 
     *           iy.gt.iymin .and. iy .lt.ixmax) then
               intensity = 1.d0
c     if(subarray(1:4) .ne.'FULL') then
c                  ix = ix - colcornr
c                  iy = iy - rowcornr
c               end if
               call add_ipc(ix, iy, intensity, ipc_add)
c     PRINT *, 'ADD IPC ', IX, IY
            end if
         end do
      end if
      return
      end
