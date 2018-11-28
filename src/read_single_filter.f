c
c-----------------------------------------------------------------------
c
      subroutine read_single_filter(tempfile, filter_index, verbose)
c
      implicit none
c
c     are all of these really needed ? One can use the actual
c     throughput curves:
c
      double precision effective_wl_nircam, width_nircam, 
     *     system_transmission
      double precision filters, filtpars
c
      integer nnn, mmm, lll, npar, nfilters, i, nf,l, ll, len, nf_used,
     &     verbose, filter_index
c
      character filterid*20, tempfile*(*)
c
      parameter (nnn=25000,mmm=200,lll=1000,npar=30, nfilters = 54)
c
c     filter parameters, average responses from filters, and qe and mirror
c     averaged over filter.
c
      dimension effective_wl_nircam(nfilters), width_nircam(nfilters), 
     *     system_transmission(nfilters)
c
      dimension filters(2,nnn, mmm),filtpars(mmm,npar), filterid(mmm)
      common /filter/filters, filtpars, filterid
c     
      common /throughput/effective_wl_nircam, width_nircam,
     *     system_transmission
c
c     read filter parameters
      nf = filter_index
      print 280, tempfile
 280  format(a120)
      open(3,file= tempfile)
      read(3,290) len, filterid(nf)
 290  format(i6,1x,a20)
c      print 290,  len, filterid(nf)
      read(3,300,err=301) (filtpars(nf,l),l=1, 29)
 300  format(10(1x,e23.16))
      go to 302
 301  print 300,  (filtpars(nf,l),l=1, 29)
         
c     These are the parameters saved for filters. These are all included:
c     1. telescope reflectivity
c     2. dichroic reflectance/throughput
c     3. filter throughput (which combines 2 filters for filters on pupil Wheel)
c     4. NIRCam optics throughput
c     5. detector QE
c      filtpars(nf,1)  = wl(1)
c      filtpars(nf,2)  = wl(lll)
c      filtpars(nf,3)  = vega0   ! zero-point relative to vega (zmag)
c      filtpars(nf,4)  = ab0     ! AB zero-point 
c      filtpars(nf,5)  = st_mag_zp
c      filtpars(nf,6)  = flambda_zp ! flambda corresponding to mag=0.0
c      filtpars(nf,7)  = fnu_zp ! F_nu in Jy for mag = 0.
c      filtpars(nf,8)  = effective ! effective wavelength (Bessell & Murphy)
c      filtpars(nf,9)  = effective_nu
c      filtpars(nf,10) = pivot        ! pivot wavelength
c      filtpars(nf,11) = nominal   ! nominal WL according to GHR
c      filtpars(nf,12) = nominal_reach ! nominal WL according to Reach
c      filtpars(nf,13) = mean photon wavelength  (Bessell & Murphy)
c      filtpars(nf,14) = lambda_iso ! isophotal wavelength (Bessell & Murphy)
c      filtpars(nf,15) = lambda_iso ! isophotal wavelength (Rieke)
c      filtpars(nf,16) = response ! system response (filter+mirror+qe+op)
c      filtpars(nf,17) = fwhm
c      filtpars(nf,18) = bandwidth ! integral of normalised response
c      filtpars(nf,19) = half_power_l ! half-power wavelength (blue)
c      filtpars(nf,20) = half_power_r ! half-power wavelength (red)
c      filtpars(nf,21) = filter equivalent width (synphot)
c      filtpars(nf,22) = filter retangular width (synphot)
c      filtpars(nf,23) = efficiency (qtlam in synphot)
c      filtpars(nf,24) = equivalent monochromatic flux (emflx in synphot)
c      filtpars(nf,25) = photflam (1 photon/s) (uresp in synphot)
c      filtpars(nf,26) = mirror_area
c      filtpars(nf,27) = Vega magnitude of source with 1 photon/s
c      filtpars(nf,28) = AB magnitude of source with 1 photon/s 
c      filtpars(nf,29) = ST magnitude of source with 1 photon/s 
c          
 302  continue
      effective_wl_nircam(nf) = filtpars(i, 8)
      width_nircam(nf)        = filtpars(i,18)
      system_transmission(nf) = filtpars(i,16)
      if(verbose.gt.1) then
         print 310, filterid(nf),filtpars(i, 8),
     &        filtpars(i, 18), filtpars(i,16)
 310     format(a20,3(3x,f10.6),' read_filter_parameters')
      end if
c     
c     read wavelength and sensitivity curve
c     
      do ll =1 , len
         read(3,300) filters(1, ll,nf), filters(2,ll,nf)
      end do
      close(3)
      return
      end
