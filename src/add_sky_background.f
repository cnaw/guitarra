c     Add sky background (e-)
c
c     cnaw 2015-01-27; 2016-06-06
c
c     Steward Observatory, University of Arizona
c 
      subroutine add_sky_background (rate_d, subarray,
     *     colcornr, rowcornr, naxis1, naxis2, integration_time,
     *     noiseless, verbose)

      implicit none
      double precision intensity, background, rate_d, rate_adu, 
     *     gain_l, integration_time, rate_e, zbqlnor
c
      real image, gain_image
c
      integer zbqlpoi
      integer colcornr, rowcornr, naxis1, naxis2 
      integer nnn, istart, iend, jstart, jend, i, j, k, l, n_image_x,
     *     n_image_y, filter_index, verbose
c
      logical noiseless
c
      character subarray*(*)
c
      parameter (nnn=2048)
c
      dimension image(nnn,nnn)
      dimension gain_image(nnn,nnn)
c
      common /image_/ image
      common /gain_/ gain_image
c
      if(verbose.gt.1) then
         print *,'add_sky_background : e-/sec = ', rate_d
         print *,'add_sky_background : per frame = ', 
     &        rate_d*integration_time
      end if
      
      if(subarray .eq. 'FULL') then
         istart = 5
         iend   = naxis1 - 4
         jstart = 5
         jend   = naxis2 - 4
      else
         istart = colcornr
         iend   = colcornr + naxis1 - 1
         jstart = rowcornr
         jend   = rowcornr + naxis2 - 1
      end if
c      print *, subarray
c      print *,'add_background:',istart, iend, jstart,jend
      do j = jstart, jend
c         if(subarray .eq. 'FULL') then
c            l = j
c         else
c            l = j + rowcornr-1
c         end if
         do i = istart, iend
c            if(subarray .eq. 'FULL') then
c               k = i
c            else
c               k = i + colcornr-1
c            end if
c     
            rate_e      = rate_d * integration_time ! [e-/s] * [s]
            if(rate_e .lt. 0.d0) then
               print *, 'add_sky_background: rate_e ', rate_e,
     &              rate_d, integration_time
            end if
            if(noiseless .eqv. .TRUE.) then
               intensity = rate_e
            else
               intensity  = zbqlpoi(rate_e)
            end if
            image(i,j) = image(i,j) + intensity
         end do
      end do
      return
      end
