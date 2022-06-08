c
c----------------------------------------------------------------------
c
c     Add cosmic rays using Observed ACS hit statistics or simulated
c     hits by M. Robberto
c
c     cnaw 2015-01-27, 2021-10-06
c
c     Steward Observatory, University of Arizona
      subroutine add_modelled_cosmic_rays(cr_mode,
     *     subarray,  colcornr, rowcornr, naxis1, naxis2, 
     *     integration_time, ipc_add, read_number, verbose)
c
      implicit  none
      double precision rate, cr_hit, fz, ymax, cr_adu
      double precision zbqlu01, seed
      double precision integration_time
c                    
      real cr_matrix, cr_flux, cr_accum, gain_image, mev
      double precision accum, flux
      integer init, over_sampling_rate
c
      integer  nnn, ncr, len, number_of_events, ix, iy,
     *     i, j, k, l, m, level, n_cr_levels, cr_mode, istart, iend,
     *     jstart, jend, l_full, m_full,
     *     verbose, ion, read_number
      integer  colcornr, rowcornr, naxis1, naxis2
      integer  zbqlpoi
      logical ipc_add
c      logical subarray
      character subarray*8
c     
      parameter (nnn=2048,ncr=21)
      parameter (len= 1000)
c      
      dimension cr_matrix(ncr,ncr,10000),cr_flux(10000),cr_accum(10000),
     &     ion(10000), mev(10000)
c
      dimension accum(10000), flux(10000)
      dimension gain_image(nnn,nnn)
      common /gain_/ gain_image
      common /cr_list/ cr_matrix, cr_flux,cr_accum, n_cr_levels,
     &      ion, mev
c
      save accum, flux, init
c
      data init/1/
c
c     Add cosmic rays to images. The procedure following M. Robberto
c     for NIRCam is slightly different from that derived from ACS 
c     events. For NIRCam, one first determines the number of events
c     and then randomly sample CR_MATRIX for the energy level.
c     In the case of using ACS as input model, one searches
c     the accumulated list  to find number of expected hits and
c     then find the energy level.
c
      if(subarray .eq. 'FULL') then
         istart = 5
         iend   = naxis1 - 4
         jstart = 5
         jend   = naxis2 - 4
      else
         istart = colcornr
         iend   = istart + naxis1 -1
         jstart = rowcornr
         jend   = jstart + naxis2 -1
      end if
c     
      if(cr_mode.ge.1) then
c
c     cr_flux is measured in events/cm**2/sec; assuming an area
c     of 18 microns/pixel and 2040 x 2040 pixels this transforms
c     to 13.48358 cm**2
c
         rate = cr_flux(cr_mode) * integration_time * 13.48358d0
         number_of_events = zbqlpoi(rate)
         if(verbose.gt.1) then
            print *, 'add_modelled_cosmic_rays ', 
     &           cr_mode, number_of_events,cr_flux(cr_mode),
     &        integration_time, rate
c            stop
         end if
         do k = 1, number_of_events
c     
c     chose a random level in the cr_matrix. Each of these will 
c     correspond to a given element (H=0, He=1, C=2, N=3, O=4, Fe=5)
c     and total energy level (in Mev)
c     
            level  = idnint(zbqlu01(seed) * 10000)
            if(level.gt.10000 .or. level.eq.0) then
               level  = idnint(zbqlu01(seed) * 10000)
            end if
c     
c     Position of hit is random, but has to be contained within the
c     IR-sensitive region
c     
            ix     = istart +  idnint(zbqlu01(seed) * iend)
            iy     = jstart +  idnint(zbqlu01(seed) * jend)
c     
c     there seem to be no events further than 2 pixels from the centre
c     
            do j = 9, 13
               m = iy +(j- 11)
               if(m.ge.jstart .and.m.le.jend) then
                  do i = 9, 13
                     l  = ix +(i- 11)
                     if(l.ge.istart .and.l.le.iend) then
                        cr_hit = cr_matrix(i, j, level)
                        if(cr_hit.ne.0.0d0) then 
                           call add_ipc(l, m, cr_hit,
     &                          naxis1, naxis2, ipc_add)
                           cr_adu = cr_hit/gain_image(l,m)
c                           print 100, read_number, l, m, cr_hit,
c     &                          ion(level), mev(level)
                           write(9, 100) read_number, l, m, cr_hit,
     &                           cr_adu, mev(level),ion(level)
                        end if
                     end if
                  end do
               end if
            end do
 100        format(i4, 2(1x,i4), 3(1x,e14.6),2x,i2)
         end do
c         read(*,'(A)')
      else
c
c     find the expected number of events - ymax will be the total
c     number of expected CR hits 
c
         if(init.eq.1) then
            cr_accum(1) = 0.d0
            do i = 2, n_cr_levels
c
c     cr_accum comes in events per sec per cm**2
c     13.48358 is the area of an SCA
c
               accum(i) = dble(cr_accum(i)) * 13.48358d0
               flux(i)  = dble(cr_flux(i))
            end do
            init = 0
         end if
         ymax =  accum(n_cr_levels)
         rate = ymax * integration_time
         number_of_events = zbqlpoi(rate)
         if(verbose.gt.1) then
            print *, 'add_modelled_cosmic_rays ', number_of_events
            print *, 'add_modelled_cosmic_rays ',cr_mode,
     *           integration_time,number_of_events, rate
         end if
       do k = 1, number_of_events
c     
c      Find energy level
c     
            fz    = zbqlu01(seed) * ymax
            call linear_interpolation(n_cr_levels, accum,
     *           flux, fz,  cr_hit)
c     
c     Position of hit is random, but has to be contained within the
c     IR-sensitive region
c     
            ix     = istart +  idnint(zbqlu01(seed) * iend)
            iy     = jstart +  idnint(zbqlu01(seed) * jend)
            call add_ipc(ix, iy, cr_hit,naxis1, naxis2,ipc_add)
c            print *, ix, iy, fz, cr_hit, dlog10(cr_hit)
c            pause
         end do
      end if
      return
      end
c
