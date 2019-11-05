c     call acs_cosmic_rays
c     stop
c      end
c
      subroutine acs_cosmic_rays
c     
c     Read distribution of Cosmic rays as measured for ACS, which is
c     in Log(e-) of event versus the number of events per 1000 seconds per
c     WFC  (assumed as covering 202" x 202"). Since the file was
c     digitised from an STScI plot, it is heavily smoothed and then
c     converted into expected number of events per second per cm**2
c     Source : 
c     Riess, A.  2002, ISR-ACS-2002-07 "A First Look at Cosmic Rays on ACS"
c
c     The QE for ACS is ~ 75% if one would want to convert into equivalent
c     photon energy
c
c     cnaw 2015-01-26
c     Steward Observatory, University of Arizona
c     
      implicit none
      double precision intensity, rate, xx, yy, acs_area, sum
      real cr_matrix, cr_flux, cr_accum, mev
      integer i, len, n, n_smooth, ncr, n_cr_levels, ion
      character file*180
      character guitarra_aux*100
      parameter (len=1000)
      parameter(ncr = 21)
c
c     define arrays
c     
      dimension rate(len), intensity(len)
      dimension cr_matrix(ncr,ncr,10000),cr_flux(10000),cr_accum(10000),
     &     ion(10000), mev(10000)
c      
      common /cr_list/ cr_matrix, cr_flux, cr_accum, n_cr_levels, ion,
     &     mev

      call getenv('GUITARRA_AUX',guitarra_aux)
      file = guitarra_aux(1:len_trim(guitarra_aux))//'acs_better.cat'
c     
c     open file and read
c     
      open(1,file= file)
      do i = 1, 4
         read(1,*)
      end do
      n = 0 
      do i = 1, len
         read(1,*,end=100) xx, yy
         n = n + 1
         intensity(n) = xx      ! log(e-)
         rate(n)      = yy      ! number of events per 1000 sec over ACS
      end do
 100  close(1)
c     
c     Create a smoothed distribution of CRs
c
      n_smooth = 21
      call smooth(n, rate, rate, n_smooth, len)
c
c     Convert into events per second (of time) per cm**2 (to be consistent
c     with the M. Robberto models for NIRCam). ACS has 2 * 2048 * 4096 pixels
c     of 15 by 15 microns. Assume no distortions (which is false!)
c
      acs_area = (15.d0*15.d0)/1.d08 ! area of a pixel in cm**2
      acs_area = acs_area * (2.d0*2048.d0*4096.d0)
c     
      do i = 1, n
         xx = rate(i)
         rate(i)    = rate(i)/1000.d0 ! events per second
         rate(i)    = rate(i)/acs_area ! events per sec per cm**2
      end do
c     
      n_cr_levels = n
      sum  = 0.0d0
      do  i = 1, n
         cr_flux(i)         = 10.d0**intensity(i)
         sum                = sum + rate(i)
         cr_accum(i)        = sum
c         print *,rate(i),intensity(i),cr_accum(i), cr_flux(i)
      enddo
c
      return
      end
