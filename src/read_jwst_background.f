c
c     read the file with background calculated by the STScI task jwst-backgrounds:
c                                                                          RA        DEC    filter_wl
c     jwst_backgrounds --day 355 --background_file goods_s_2019_12_21.txt 53.1496 -27.78895 3.56
      subroutine read_jwst_background(filename, indx, pixel,
     &     mirror_area, events)
      implicit none
      double precision filters, filtpars
      double precision resp, wll, tbkg, mjy
      double precision pi, scale, hplanck, pixel_area,
     *     cee, wavelength, bzzz, wl_cm, e_photon, photons,
     *     photon_flux, eflux_total, dwl, hh, pixel_sr,
     *     arc_sec_per_radian, mirror_area,electron_flux,
     *     pixel, wl, flux, events
      integer ii, nfilters, mode, npar, nf, verbose,
     *     i, k, indx, ll, lll, mmm, nnn, npts
c
      character filename*(*), junk*30, filterid*20
c
      parameter (nnn=25000,mmm=200,lll=1000)
      parameter(nfilters=54, npar=30)
c
      dimension filters(2,nnn,mmm),filtpars(mmm,npar), filterid(mmm)
      dimension wl(lll), flux(lll)
      common /filter/filters, filtpars, filterid
c
c     constants
c
      cee     = 2.99792458d10       ! cm/s
      hplanck = 6.62606957d-27      ! erg s 
c
      pi  = dacos(-1.00d0)
      arc_sec_per_radian = 180.d0 * 3600.d0/pi 
      pixel_sr = (pixel/arc_sec_per_radian)**2
c
c     read background file calculated by jwst-background
c     header
      open(1,file=filename)
      do i = 1, 11
         read(1,10) junk
 10      format(a30)
c         print 10, junk
      end do
c
c     spectrum
c
      npts = 0
      do i = 1, 1000
         read(1,*, end=1000) wll, tbkg
         npts = npts + 1
         wl(npts) = wll
         flux(npts) = tbkg
         photons = 1.d13*tbkg*wll/(cee*hplanck)
c         if(wll .eq.3.5) print *, wll, tbkg,photons
      end do
 1000 close(1)
c
c     rebin background spectrum  and calculate the convolution with filter
c
      photon_flux = 0.d0
      do i = 1, lll
         hh = 1.0d0
         if(i.eq.1 .or. i.eq.lll) hh = 0.5d0
         wavelength  =  filters(1, i, indx)
         resp        =  filters(2, i, indx) 
c         print *, 'wavelength ', wavelength
         call linear_interpolation(npts, wl, flux, wavelength,
     *           mjy)
         bzzz        = mjy * 1.0d-17 ! Mjy/sr --> erg/(s cm**2 Hz sr)
         wl_cm       = wavelength * 1.0d-04
         bzzz        = bzzz * cee/(wl_cm*wl_cm) ! [erg/(cm**2 sec cm sr)]
         e_photon    = hplanck *cee/wl_cm ! [ erg]
         photons     = bzzz/e_photon ! [photons/(cm**2 sec cm sr)]
         photon_flux = photon_flux + photons * resp * hh
c         print *,wavelength, mjy, bzzz,photons, e_photon
      end do
c
c     this will be the total number of photo-electrons integrated
c     over the filter band pass per pixel, taking into account 
c     the instrumental efficiency and telescope area
c
      dwl = filters(1, 2, indx) -filters(1, 1, indx)
      electron_flux = photon_flux * dwl * 1.d-04 
      eflux_total   = electron_flux * mirror_area
      eflux_total   = eflux_total/arc_sec_per_radian**2
c
c     number of background electrons per pixel per second
c
c      print *,  electron_flux, pixel_sr, mirror_area
      events  = electron_flux * pixel_sr * mirror_area
      print *,'read_jwst_background: events/sec ', events
c
      return
      end

