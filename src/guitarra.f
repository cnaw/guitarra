      implicit none
c
c===========================================================================
c
c     Keywords from 
c     https://mast.stsci.edu/portal/Mashup/clients/jwkeywords/index.html
c     list as of 2018-02-07 (version JWSTDP-2018_1-180207)
c
c     NIRCam Imaging
c     standard and basic parameters
c
      logical simple, extend, dataprob, targcoopp, zerofram
      integer bitpix, naxis, naxis1, naxis2, naxis3, naxis4, pcount,
     &     gcount
      integer bzero, hdn
      double precision bscale
      character date*30, origin*20, timesys*10, filename*68, 
     &     filetype*30, sdp_ver*20, xtension*20
c
c     coordinate system
c
      character radesys*10
c
c     programmatic information
c
      character title*150, pi_name*183, category*4, subcat*10, 
     &     scicat*10
      integer cont_id
c
c     observation identifiers
c
c
c     observation identifiers
c
      character date_obs*10, time_obs*15, date_end*10, time_end*15,
     &     obs_id*26, visit_id*11, observtn*9, visit*11, obslabel*40,
     &     visitgrp*2, seq_id*1, act_id*1, exposure_request*5, 
     &     template*50, eng_qual*8, exposure*7, program_id*7
      logical bkgdtarg
c
c     Visit information
c
      character visitype*30,vststart*20, visitsta*15
      integer nexposur
      logical intarget, targoopp
c
c     Target information
c
      double precision targ_ra, targ_dec, targura, targudec, 
     &     mu_ra, mu_dec, mu_epoch, prop_ra, prop_dec
      character targprop*31, targname*31, targtype*7
c
c     instrument-related
c
      character instrume*7,detector*12,module*6, channel*6, 
     &     object*20, filter_id*8, coronmsk*20
      logical pilin
c
c     exposure parameters
c
      double precision expstart, expmid, expend, tsample,
     &     tframe, tgroup, effinttm, effexpt, duration
      integer pntg_seq, expcount, nints, ngroups, nframes, groupgap,
     &     nsamples, nrststrt,NRESETS, sca_num, drpfrms1,drpfrms3
      character expripar*20, exp_type*30, readpatt*15
      logical tsovisit
c
c     subarray parameters
c
      integer substrt1,substrt2, subsize1,subsize2, fastaxis, slowaxis
c
c     NIRCam dither pattern parameters
c
      double precision xoffset, yoffset
      integer patt_num, numdthpt,subpxnum, subpxpns
      character  read_patt*10
c
c     JWST Ephemeris
c
      double precision eph_time, jwst_x, jwst_y, jwst_z, jwst_dx,
     &     jwst_dy, jwst_dz
      character refframe*10, eph_type*10
c
c     aperture information
c
      double precision pa_aper
      character apername*20, pps_aper*40
c
c     velocity aberration information
c
      double precision dva_ra, dva_dec, va_scale
c
c     Time information
c
      double precision bartdelt,bstrtime, bendtime, bmidtime,
     &     helidelt, hstrtime, hendtime, hmidtime
c
c     photometry information
c
      double precision photmjsr, photuja2, pixar_sr, pixar_a2

c
c     Spacecraft pointing information
c
      double precision pa_v3, v2_ref, v3_ref, ra_v1, dec_v1
c
c     WCS parameters
c
      integer wcsaxes, vparity 
      double precision crpix1, crpix2, crpix3,
     &     crval1, crval2, crval3, cdelt1, cdelt2,cdelt3,
     &     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2,
     &     ra_ref, dec_ref, roll_ref,
     &     v3i_yang, wavstart, wavend, sporder

      character ctype1*10, ctype2*10, ctype3*10,
     &     cunit1*40, cunit2*40, cunit3*40,
     &     s_region*100
c
c==========================================================================
c
c     other keywords; some need to be kept so reduction with DHAS
c     can be carried out.
c
      double precision pi, q, arc_sec_per_radian, cee, hplanck
      integer job
      integer status
c
c     catalogue-related
c
      double precision ra_stars, dec_stars, mag_stars, counts
      double precision ra_galaxies, dec_galaxies, 
     *     z, magnitude, nsersic, ellipticity,
     *     re, theta, flux_ratio
      integer max_stars, max_objects, nsub, ncomponents, nstars, ngal,
     *     catalogue_filters_used
      character clone_path*180, star_catalogue*180, galaxy_catalogue*180
c
c     these need to be checked because may not be needed,
c     but are kept for compatibility
c
      double precision x_sci_ref, y_sci_ref, x_sci_scale, y_sci_scale
      double precision xc, yc, x0, y0, osim_scale, ra_sca, dec_sca,
     &     x_osim, y_osim, x_sca, y_sca
      double precision flam_to_mjy_per_sr,flam_to_ujy, pixel, scale
c
c     background
c
      double precision zodiacal_scale_factor, events
      integer bkg_mode
      character zodifile*180
c
c     detector.
c
      integer colcornr, rowcornr
      double precision decay_rate, time_since_previous,voltage_offset,
     &     ktc, gain,  read_noise, dark_mean, dark_sigma
      double precision  dark_mean_cv3, dark_sigma_cv3, gain_cv3,
     &     read_noise_cv3
      integer max_order, order ! refers to linearity
      double precision linearity_gain,  lincut, well_fact
c
c     dither related
c
      double precision primary_dither, dither_arc_sec, subpixel_dither
      integer number_primary, number_subpixel
      integer iunit, nx, ny, nz, nframe, nnn, nskip, max_groups,
     &     naxes, sca_id
      integer   primary_position, primary_total, subpixel_position,
     &     subpixel_total 
      double precision ra0, dec0, new_ra, new_dec, dx, dy, pa_degrees
      integer idither, indx, icat_f
c
c     Exposure 
c     
      double precision bias_value, readnoise, background, exptime,
     &     integration_time, effective_integration, temp_time
      double precision total_time, flux, uresp, wl_cm,e_photon
      character full_date*25, full_time_end*25
c      wcs-related (but not used by STScI pipeline)
      double precision equinox,  cd1_1, cd1_2, cd2_1, cd2_2, cd3_3
      double precision sec, jday, mjd, ut, ut_end
      integer ih, im, year, month, day
c
c     filter-related
c
      double precision mirror_area
      double precision wavelength, bandwidth, system_transmission, bkg
      double precision filters, filtpars
      double precision photplam, photflam, f_nu, stmag, abmag
      integer nfilter_wl, nbands, npar, nfilters, use_filter,
     &     filter_in_cat, nf_used, nf, filter_index, cat_filter
      character filterid*20, temp*20, filter_path*180
c
c     image-related
c
      real base_image, accum, image, latent_image, gain_image,
     &     dark_image, well_depth, linearity, bias, scratch
      integer image_4d, zero_frames, max_nint, nint_level
      integer ii, jj, ll
c
      integer verbose, skip, dhas, i, j, k, seed, n_image_x, n_image_y
      integer (kind=4) int_image, plane,fpixels, lpixels, group, nullval
      character noise_name*180,latent_file*180
      character cube_name*180, test_name*180
c
c     PSF-related
c
      double precision integrated_psf
      integer nxny, nxy, over_sampling_rate, n_psf_x, n_psf_y, npsf
      logical psf_add
      character psf_file*180
c     
c     environment 
c
      character guitarra_aux*100
c
c     input parameters
c
      logical noiseless
      integer include_bg, include_cr,  include_dark, include_ktc, 
     *     include_latents, include_non_linear, include_readnoise, 
     *     include_reference, include_1_over_f, brain_dead_test
      logical ipc_add
      integer cr_mode
      integer include_stars, include_galaxies, include_cloned_galaxies
      integer old_style
      character subarray*15,
     &     primary*16, subpixel*16, comment*40
c
c     define lengths
c
      parameter (nfilter_wl = 25000, nbands=200, npar=30,nfilters=54)
      parameter(nnn=2048, max_nint=1, max_order=7)
      parameter (nxny=2048*2048)
c      parameter (nxny=3072*3072)
c      parameter (nxny=6144*6144)
      parameter(max_stars=10000)
      parameter(max_objects = 50000, nsub = 4)
c
c     SCA parameters
c
      dimension dark_mean_cv3(10), dark_sigma_cv3(10), gain_cv3(10),
     *     read_noise_cv3(10), voltage_offset(10), ktc(10)
      dimension dark_mean(10), dark_sigma(10), gain(10),
     *     read_noise(10)
c     
c     images
c
      dimension base_image(nnn,nnn)
      dimension accum(nnn,nnn), image(nnn,nnn), latent_image(nnn,nnn)
      dimension gain_image(nnn,nnn), dark_image(nnn,nnn,2),
     *     well_depth(nnn,nnn), linearity(nnn,nnn,max_order),
     &     bias(nnn,nnn), scratch(nnn,nnn)
      dimension image_4d(nnn,nnn,20,max_nint), naxes(4),
     &     zero_frames(nnn,nnn,max_nint), plane(nnn,nnn)
      dimension int_image(nnn, nnn,20), fpixels(4), lpixels(4) 
c
c     filter parameters, average responses from filters
c
      dimension bkg(nfilters),cat_filter(nfilters)
c
      dimension filters(2, nfilter_wl, nbands), filtpars(nbands,npar), 
     *     filterid(nbands)
      dimension psf_file(nfilters), integrated_psf(nxny)
c
c     dithers
c
c
c     catalogues
c
c      dimension cr_matrix(ncr,ncr,10000),cr_flux(10000),cr_accum(10000)
      dimension ra_stars(max_stars), dec_stars(max_stars),
     *     mag_stars(max_stars ,nfilters), counts(max_stars)
      dimension ra_galaxies(max_objects), dec_galaxies(max_objects), 
     *     z(max_objects),
     *     magnitude(max_objects,nfilters), ncomponents(max_objects),
     *     nsersic(max_objects, nsub), ellipticity(max_objects, nsub),
     *     re(max_objects, nsub), theta(max_objects, nsub), 
     *     flux_ratio(max_objects, nsub),
     *     clone_path(max_objects)
c
      double precision
     *     xshift, yshift, xmag, ymag, xrot, yrot,
     *     oxshift, oyshift, oxmag, oymag, oxrot, oyrot
 
      dimension xshift(10), yshift(10), xmag(10), ymag(10), xrot(10),
     *     yrot(10)
      dimension oxshift(10), oyshift(10), oxmag(10), oymag(10),
     *     oxrot(10), oyrot(10)
c
c     images
c
c
      common /four_d/ image_4d, zero_frames
      common /gain_/ gain_image
      common /base/ base_image
      common /latent/ latent_image
      common /images/ accum, image, n_image_x, n_image_y
      common /scratch_/ scratch
      common /well_d/ well_depth, bias, linearity,
     *     linearity_gain,  lincut, well_fact, order
c
      common /wcs/ equinox, 
     *     crpix1, crpix2,      ! crpix3,
     *     crval1, crval2,      !crval3,
     *     cdelt1, cdelt2,      !cdelt3,
     *     cd1_1, cd1_2, cd2_1, cd2_2,! cd3_3,
     *     pc1_1, pc1_2, pc2_1, pc2_2 !, pc3_1, pc3_2
c
      common /parameters/ gain_cv3,
     *     decay_rate, time_since_previous, read_noise, 
     *     dark_mean, dark_sigma, ktc, voltage_offset 
c
      common /filter/filters, filtpars, filterid
c
      common /galaxy/ra_galaxies, dec_galaxies, z, magnitude, 
     *     nsersic, ellipticity, re, theta, flux_ratio, ncomponents

      common /psf/ integrated_psf,n_psf_x, n_psf_y, 
     *     nxy, over_sampling_rate

       data osim_scale/60.d0/
c       data osim_scale/1.59879d0/
       common /transform/ xshift, yshift, xmag, ymag, xrot, yrot
       common /otransform/ oxshift, oyshift, oxmag, oymag, oxrot, oyrot
c
c     ISIM CV3 values in e-/sec from K. Misselt
c      
      data dark_mean_cv3 /0.001d0, 0.003d0, 0.003d0, 0.003d0, 0.033d0,
     *     0.002d0, 0.001d0, 0.001d0, 0.001d0, 0.040d0/
      
      data dark_sigma_cv3/0.002d0, 0.005d0, 0.003d0, 0.002d0, 0.006d0,
     *     0.002d0, 0.002d0, 0.003d0, 0.004d0, 0.004d0/
c     e-
      data read_noise_cv3/11.3d0, 10.5d0, 10.2d0, 10.3d0, 8.9d0,
     *     11.5d0, 12.7d0, 11.3d0, 12.0d0, 10.5d0/
c     Gains  in e-/ADU
c     These come from Jarron L and are derived from ISIMCV3 measurements
c     2018-06-07
c
      data gain/2.07d0, 2.010d0, 2.16d0, 2.01d0, 1.83d0,
     *     2.00d0, 2.42d0, 1.93d0, 2.30d0, 1.85d0/
      do i = 1, 10
         gain_cv3(i) = 1.d0
c         gain_cv3(i) = gain(i)
      end do
c
c     voltage offsets in ADU from Jarron Leisenring
c
      voltage_offset(1)  =  5900.d0
      voltage_offset(2)  =  5400.d0
      voltage_offset(3)  =  6400.d0
      voltage_offset(4)  =  6150.d0
      voltage_offset(5)  = 11650.d0
      voltage_offset(6)  =  7300.d0
      voltage_offset(7)  =  7500.d0
      voltage_offset(8)  =  6700.d0
      voltage_offset(9)  =  7500.d0
      voltage_offset(10) = 11500.d0
c
c     kTC in ADU (also from Jarron L)
c
      ktc(1) =  18.5d0 
      ktc(2) =  15.9d0 
      ktc(3) =  15.2d0 
      ktc(4) =  16.9d0 
      ktc(5) =  20.0d0
      ktc(6) =  19.2d0
      ktc(7) =  16.1d0
      ktc(8) =  19.1d0
      ktc(9) =  19.0d0
      ktc(10) = 20.0d0
c
c     constants
c
      pi     = dacos(-1.0d0)
      q      = pi/180.d0
      arc_sec_per_radian = 3600.d0*180.d0/pi
      hplanck = 6.62606957d-27  ! erg s 
      cee     = 2.99792458d10   ! cm/s
c
c     PSF oversampling rate
c
      over_sampling_rate = 8
c
c     mirror area from JDOX
c
      mirror_area = 25.4d0 * 1.0D4 
      wcsaxes = 2
      job       = 1000
      dhas      = 1
      old_style = 1
      noiseless = .false.
c      noiseless = .true.
      psf_add   = .true.
      ipc_add   = .true.
c
c     these are input by the user via the perl script
c
      include_ktc        = 1
      include_bg         = 1
      include_cr         = 1
      include_dark       = 0
      include_latents    = 0
      include_readnoise  = 1
      include_non_linear = 1 
c
      if(dhas.eq.1) then
c
c     This insures that bitpix will be 16 and bzero=32K, bscale = 1
c     for unsigned integers
c
         bitpix = 20
      else
         bitpix =  8
      end if
c
      eng_qual  = 'Imaginary'
c
      obs_id      = 'MockFields'
      obslabel    = 'Mock'
      program_id  = '1180'
      object      = 'A Really Cool Field'
      equinox    = 2000.d0
c
      primary_position = 1
      primary_total    = 2
      subpixel  = 'SMALL'
      subpixel_position = 1
      subpixel_total    = 2
c
c=======================================================================
c     
c         
c     Cosmic rays
c     cr_mode:
c     0         -  Use ACS observed counts for rate and energy levels
c     1         -  Use M. Robberto models for quiet Sun
c     2         -  Use M. Robberto models for active Sun
c     3         -  Use M. Robberto models for solar flare
c
c=======================================================================
c
c     Instrument related parameters
c
      do i = 1, 10
         ktc(i)            = ktc(i)*gain(i) ! ADU --> e-
         voltage_offset(i) = voltage_offset(i) * gain(i) ! ADU --> e-
         dark_mean(i)      = dark_mean_cv3(i)
         dark_sigma(i)     = dark_sigma_cv3(i)
         gain(i)           = gain_cv3(i)
         read_noise(i)     = read_noise_cv3(i)
      end do
c     
c     Latents:
c     decay rate comes Marcia Rieke's report for the EIDP OSIM SCAs
c     page 5-4: "latent images drop to < 1 % of the saturating signal
c     after the reset cycle finishes (e.g., by 31.8sec)"
c     If 1% is used: decay_time = 6.9053 s or
c     
      decay_rate      = 0.144817d0
c
c     Chad quotes 0.1% after 60 seconds. This corresponds to
c      decay_rate      = 0.11513d0
c     The value quoted in the report is
c      decay_rate      = 1.d0/55.12d0
c
c     WFC3 has  a latent decay rate of dark = 2.212 * 0.931**time + 0.446
c     this is the same as 2.212 * exp(time * ln(0.931)) + 0.446 
c     or                  2.212 * exp(-0.07150 * time) + 0.446
c                         2.212 * exp(-time/13.9868) + 0.446
c      decay_rate      = dlog(0.931d0)
c
c     reset time (time between end of exposure and start of next)
c     is about 31.8 s (M. Rieke EIDP_OSIM.pdf)
c
      time_since_previous = 31.8d0
c
c=======================================================================
c
c     these are fed through an input file (or by hand) :
c     guitarra < /home/cnaw/desfalque/params_F200W_489_001.input
c
      read(5,9,err=90) cube_name
 90   print 9, cube_name
      read(5,9,err=91) noise_name
 91   print 9,noise_name
      read(5,*) ra0
      read(5,*) dec0
c
c     SCA to use
c
      read(5,*) sca_id
c
c     catalogues
c
      read(5,9) star_catalogue
 9    format(a180)
      read(5,9) galaxy_catalogue
c
c     number of filters contained in source catalogues
c
      read(5, *) filter_in_cat 
c
c     filter to use from the list in the source catalogue.
c     This will be an index
c
      read(5,*) use_filter
c     
      read(5,9) filter_path
      print 9, filter_path
c
c     read number of PSF files to use
c
      read(5,*) npsf
      do i = 1, npsf
         read(5,9) psf_file(i)
         print 9, psf_file(i)
      end do
c     
c
c     name of file containing background SED for observation date
c
      read(5,9) zodifile
      print 9, zodifile
      read(5,*) verbose
 10   format(i12)
c      print *, 'verbose = ', verbose
      print *, 'verbose = ',verbose
      read(*,*) noiseless
      read(*,*) brain_dead_test
      print *, 'brain_dead_test     ', brain_dead_test
c
c     aperture
      read(5,11,err= 16) apername
 11   format(a20)
 16   print *, 'apername  = ', apername
 15   format(a20) 
c
      read(5,11) readpatt
      print *, 'readout pattern ', readpatt
      read(5,10) ngroups
      print *, 'ngroups ', ngroups
c
c     sub-array related data
c
      read(5, 17) subarray
 17   format(a15)
      print 18, subarray
 18   format(' subarray is ',a15)
      read(5,10)  substrt1
      print *, 'substrt1 ', substrt1
      read(5,10)  substrt2
      print *, 'substrt2 ', substrt2

      read(5,10) subsize1
      print *, 'subsize1 ', subsize1
      read(5,10) subsize2
      print *, 'subsize2 ', subsize2
c
      colcornr = substrt1
      rowcornr = substrt2
      naxis1   = subsize1
      naxis2   = subsize2
c
      read(5,*) pa_degrees
      print *, 'PA ', pa_degrees
c
c     noise to include
c
      read(5,10) include_ktc
      print *,'include_ktc                   ', include_ktc
      read(5,10) include_dark
      print *,'include_dark                  ', include_dark
      read(5,10) include_readnoise
      print *,'include_readnoise             ', include_readnoise
      read(5,10) include_reference
      print *,'include_reference             ', include_reference
      read(5,10) include_non_linear
      print *,'include_non_linear            ', include_non_linear
      read(5,10) include_latents
      print *,'include_latents               ', include_latents
      read(5,10) include_1_over_f
      print *,'include_1_over_f              ', include_1_over_f
      read(5,10) include_cr
      print *,'include_cr                    ', include_cr
      read(5,10) cr_mode
      print *,'cr_mode                       ', cr_mode
      read(5,10) include_bg 
      print *,'include_bg                    ', include_bg
      read(5,10) include_galaxies
      print *,'include_galaxies              ',include_galaxies
      read(5,10) include_cloned_galaxies
      print *,'include_cloned_galaxies       ',include_cloned_galaxies
 40   format(a80)
 50   format(a30,2x,a80)
c      read(*, 10) filter_in_cat
c      print *,'number of filters in catalogue', filter_in_cat
c      read(5,10) icat_f
c      print *,'filter index in catalogue     ', icat_f
c      read(5,10) indx
c      print *,'filter index in filter list   ', indx
c      read(5,*) filter_id
c      print *,'filter_id                     ',filter_id
      read(5,40) primary
      read(5,*) primary_position
      read(5,*) primary_total
      read(5,*) subpixel_position
      read(5,*) subpixel_total
c
c     number of integrations at the same position
c
      read(5,*,end=60) nints
      go to 70
 60   nints = 1
 70   continue
c
c     print some confirmation values
c
      idither = subpixel_position
      print *,' filter_in_cat' , use_filter 
c      print *, idither, ra0, dec0, new_ra, new_dec, dx,
c     *     dy, sca_id, indx, icat_f
      print *, ' idither, ra0, sca_id, indx, icat_f ',
     &     idither, ra0, sca_id, use_filter, icat_f
c
      scale               =   0.0317d0
      if(sca_id .eq. 485 .or. sca_id .eq.490) then
         scale = 0.0648d0
      end if

c^&&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&^&
c      readpatt = 'RAPID'
c      ngroups  = 10
c      groupgap = 0
c
c=======================================================================
c
c     read filter parameters
c
      call read_single_filter(filter_path, use_filter, verbose)
c     
c     read list of fits filenames of point-spread-function
c
      call getenv('GUITARRA_AUX',guitarra_aux)
c      call read_psf_list(psf_file,guitarra_aux)
c      do i = 1, 27 
c         print 1111, psf_file(i)
c 1111    format(a180)
c      end do
c      stop
c
c=======================================================================
c
      j                   = use_filter
      temp                = filterid(j)
      filter_id           = temp(8:12)
c      filter_id           = temp(1:5)
      wavelength          = filtpars(j,8) ! effective_wl_nircam(j)
      bandwidth           = filtpars(j,18) ! width_nircam(j)
      system_transmission = filtpars(j,16) 
      photplam            = filtpars(j,10)
      uresp               = filtpars(j,25)
      photplam            = filtpars(j,10) ! pivot wavelength
      photflam            = filtpars(j,27)
      abmag               = filtpars(j,28)
      stmag               = filtpars(j,29)
c      filter_index        = j
      print *,'filter_index ', j, wavelength, bandwidth, uresp, 
     &     photflam, abmag
c      stop
c
      readnoise           = read_noise_cv3(sca_id-480)
      print *,'readnoise ', readnoise
c
c     these need to be calculated from the APERTURE position
c     and PA (e.g, from B.Hilberts python script)
c
      targ_ra   = ra0           ! These come from the input file
      targ_dec  = dec0          ! 
      targura   = 1.0d-8
      targudec  = 1.0d-8
      mu_ra     = 0.0d0
      mu_dec    = 0.0d0
      mu_epoch  = 2000.d0
      prop_ra   = 0.0d0
      prop_dec  = 0.0d0
      pa_v3     = pa_degrees    ! This comes from read_parameters
c      ra_ref    = ra0           ! RA of SCA centre
c      dec_ref   = dec0          ! DEC of SCA centre
      roll_ref = pa_degrees     ! how does this relate to PA_V3 ?

c     Angle from V3 axis to Ideal Y axis (degrees)
      v3i_yang = -0.08954d0     ! Is is a constant??
c     
c     use appropriate column of object catalogue
c
c      icat_f              = cat_filter(indx)
c     
c     use appropriate filters for SW/LW
c     
      if(photplam .gt. 2.5d0) then
         pixel = 0.0648d0
      else
         pixel = 0.0317d0
      end if
c     
c     read zodiacal background
c
      call read_jwst_background(zodifile, use_filter, pixel,
     &     mirror_area, background)
c
      if(scale.eq.0.0317d0.and.wavelength.gt.2.4d0) go to 999
      if(scale.eq.0.0648d0.and.wavelength.lt.2.4d0) go to 999
c     
      print 92, sca_id, use_filter, filter_id, scale, wavelength,
     &     psf_file(1)
 92   format('main:       sca',2x,i3,' filter ',i4,2x,a5,
     &     ' scale',2x,f6.4,' wavelength ',f7.4,
     &     /,a180)
      PRINT *,'PA_DEGREES ', PA_DEGREES, 'PAUSE'
c      stop
c     
c====================================================================      
c
c     If this is a noiseless simulation set
c     noise values accordingly
c
      i          = sca_id - 480
      if(noiseless .eqv. .true.) then
         readnoise  = 0.0d0
         ipc_add    = .false.
         psf_add    = .true.    ! for now
         psf_add    = .false.    ! for now
         ktc(i)            = 0.0d0
         voltage_offset(i) = 0.0d0
         dark_mean(i)      = 0.0d0
         dark_sigma(i)     = 0.0d0
      end if
c
c====================================================================      
c
c     NIRCam total number of points in primary dither pattern: 1-25, 27, 36, 45 
      NUMDTHPT  =  primary_total
c     Total number of points in subpixel dither pattern (1-64)
      SUBPXPNS  =  subpixel_total
      nresets   = 1
c
c     This is the SIAF position for the NIRCAALL aperture
c
      xc        = -0.00529d0
      yc        = -8.209855d0
c
c     full array
c
      nx        = 2048
      ny        = 2048
c
c     number of groups
c
      nz        = ngroups
c 
c      if(dhas.eq.1) then
c         nints = 1
c      else
c         nints = 1
c      end if
c
c=======================================================================
c
c     load table with transformations between OSIM coordinates
c     and SCA coordinates
c
c     read parameters that will be used for the WCS header
c     ra_sca, dec_sca are read from the catalogue file for now
c
      print *,' verbose ', verbose
c      if(old_style.eq.1) then 
      call load_osim_transforms(verbose)
c      i = 10
c      print *, xshift(i), yshift(i), xmag(i), ymag(i),
c     *     xrot(i), yrot(i)
c      print *, oxshift(i), oyshift(i), oxmag(i), oymag(i),
c     *     oxrot(i), oyrot(i)
c      else
c         call read_sca_wcs(sca_id, 
c     &        x_sci_ref, y_sci_ref, x_sci_scale, y_sci_scale,
c     &        v2_ref, v3_ref, vparity, v3i_yang)
c         call wcs_keywords_new(sca_id, ra_sca, dec_sca, 
c     &        x_sci_ref, y_sci_ref, x_sci_scale, y_sci_scale,
c     &        v3i_yang, pa_degrees, 2)
c      end if
c
c
c======================================================================
c     Official FITS keywords 
c
c     Instrument configuration information
c
      title      = 'NIRCam mocks'
      pi_name    = 'Me'
      category   = 'GO'
      subcat     = 'NIRCAM'
      scicat     = 'Extragalac'
c
c     visit information
c
      visitype   = 'GENERIC'
c
c     target information
c
      targprop   = 'what is this ?'
c
c     instrument configuration
c
      instrume   = 'NIRCAM  '
      if(sca_id .gt. 485) then
         module     = 'B'
      else
         module     = 'A'
      end if
      if(sca_id.eq.485 .or.sca_id.eq.490) then
         channel    = 'LONG  '
         if(sca_id .eq. 485) detector   = 'NRCALONG    '
         if(sca_id .eq. 490) detector   = 'NRCBLONG    '
      else
         channel    = 'SHORT '
      end if
c
      coronmsk   = 'NONE'
      pilin      = .false.
c
c     Subarray parameters
c
      subarray  = 'FULL    '
      substrt1  =      1
      substrt2  =      1
      subsize1  =   2048
      subsize2  =   2048
      fastaxis  =      1
      slowaxis  =      1
c
      naxis1    = subsize1
      naxis2    = subsize2
c
c     telemetry problem ?
c
      dataprob  = .false.
c
c---------------------------------------------------------------------
c
c     Prepare some keywords related to dither pattern,
c     readout pattern and time
c
      call get_date_time(date_obs, time_obs)
      read(date_obs, 130) year, month, day
 130  format(i4,1x,i2,1x,i2)
      write(full_date,110) date_obs, time_obs
 110  format(a10,'T',a12)
      read(time_obs,120) ih, im, sec
 120  format(i2,1x,i2,1x,f6.3)
      print *, 'date_obs'
      print  125, date_obs
      print *, 'time_obs'
      print  125, time_obs
 125  format(a40)
c     
c     calculate UT and other parameters
c
      call julian_day(year, month, day, ut, jday, mjd)
      ut = ih + im/60.d0 + sec/3600.d0
c
c     find what this means in terms of frames, groups, gaps
c
      call set_params(readpatt, nframes, groupgap, max_groups)
      nskip = groupgap
c     
c     integration time per read (is a function of the array size)
c     
      integration_time = (10.73676d0*dble(subsize1)/2048.d0)
c     Time between start of successive frames in units of seconds.
      integration_time = integration_time *(dble(subsize2)/2048.d0)
      tframe = integration_time
c     nsamples   Number of A/D samples per pixel
      nsamples   =  1
c     Delta time between samples in units of microsec
      tsample    = 10.d0
      integration_time = (10.73676d0*dble(subsize1)/2048.d0)
      integration_time = integration_time *(dble(subsize2)/2048.d0)
      tframe = integration_time
c     time between start of successive groups
      tgroup = (nframes + groupgap) * tframe
c     Effective integration time
      effective_integration = (ngroups-1)*tgroup
      effinttm  = effective_integration
c     effective exposure time
      exptime = total_time(nframes, groupgap, ngroups, 1, tframe)
      exptime = exptime * nints
      effexpt = exptime
      duration = exptime
c
      if(verbose.ge.2) print *,' exptime',
     &     exptime
c     
c
c     These increment as exposures are taken
c     (should be an input parameter)
c     
c     Position number in primary pattern
      patt_num  =  1
c     Subpixel sampling pattern number
      SUBPXNUM  =  idither
c
c     The following require calculating somewhere
c     x offset from pattern starting position (arc sec)
c     (presume it varies according to dither...)
      xoffset   =  0.0d0
c     y offset from pattern starting position  (arc sec)
      yoffset   =  0.d0
c
c     JWST Ephemeris information
c     jwst_xyz are the positions, jwst_dxyz are the velocities
c
      refframe = 'EME2000'
      eph_type = 'PREDICTED'
      eph_time = mjd
      jwst_x   =  0.d0
      jwst_y   =  0.d0
      jwst_z   =  0.d0
      jwst_dx  =  0.d0
      jwst_dy  =  0.d0
      jwst_dz  =  0.d0
c
c     coordinate system
c
      radesys  = 'ICRS'
c
c     exposure parameters
c
      exposure  = '1234567'
c     pointing sequence number
      pntg_seq  = idither
c     running count of exposures in visit
      expcount  = idither
c
c     prime or parallel exposure (should come from script
c     reading APT output
c
      expripar ='PARALLEL_COORDINATED'
      expripar ='PRIME'
c     Timer Series Observation visit indicator
      tsovisit = .false.
c     UTC exposure start time
      expstart = mjd + ut/24.d0
c     UTC at mid-exposure
      expmid   = expstart + exptime/(2.d0*3600.d0*24.d0)
c     UTC at end of exposure
      expend   = expstart + exptime/(3600.d0*24.d0)
      ut_end = ut + exptime/3600.d0
      call ut_to_date_time(year, month, day, ut_end, 
     &     date_end, time_end, full_time_end)
c     Type of data in the exposure
      exp_type  = 'NRC_IMAGE'

c     Sensor Chip Assembly number (Possible values are 1-18)
      sca_num = sca_id - 480
c     Number of resets at start of exposure
      nrststrt = 1
c     Number of resets that separate integrations within an exposure
      NRESETS =  0
c     Number of frames dropped prior to first integration
      DRPFRMS1 = 0
c     Number of frames dropped prior to between integrations
      DRPFRMS3 = 0
c
c     NIRCam dither pattern parameters
c
c     Aperture information
c
      pa_aper  = pa_degrees
      pps_aper = apername
c
c     Time information
c
c     Barycentric time correction
      bartdelt = 0.0d0
c     Solar System Barycentric exposure start time in Modified Julian Date forma
      bstrtime = expstart
c     Solar System Barycentric exposure end time in Modified Julian Date format
      bendtime = expend
c     Solar System Barycentric exposure mid time in Modified Julian Date format
      bmidtime = expmid
c     Calculated Heliocentric time correction from UTC in units of seconds.
      helidelt = 0.d0
c     Heliocentric exposure start time in Modified Julian Date format
      hstrtime  = expstart
c     Heliocentric exposure end time in Modified Julian Date format
      hendtime  = expend
c     Heliocentric exposure mid time in Modified Julian Date format
      hmidtime  = expmid
c     
c     photometry information
c
c     Flux density (MJy/steradian) producing 1 cps
c     for photflam is erg/(s cm**2 A), photplam in cm
c     
c     Nominal pixel area in steradians
      pixar_sr  = (pixel/arc_sec_per_radian)**2
c     Nominal pixel area in arcsec^2
      pixar_a2  = pixel*pixel
c
c     for uresp in erg/(cm**2 sec A) and phoplam in microns:
c
      wl_cm     = photplam*1.d-04
      f_nu      = 1.0d23*uresp * 1.d08 * wl_cm*wl_cm/cee
c     Flux density in MJy/sr
      photmjsr  = (f_nu/1.0d06) *mirror_area/pixar_sr
c     Flux density (uJy/arcsec2) producing 1 cps
      photuja2 = (f_nu*1.d06) * mirror_area/pixar_a2
      print *,'guitarra: photflam,photplam, uresp, photmjsr , photuja2',
     &     photflam,photplam, uresp, photmjsr , photuja2
c
c=======================================================================
c
c     Things that depend on variables defined above
c
c     these are really simplified - each field and orientation
c     has its own values for the image scale
c
c     if(sca_id .eq. 485 .or. sca_id .eq.490) then
c        scale = 0.0648d0
c     else
c        scale = 0.0317d0
c     end if
c
c     parameters used when saving fits files and images
c
      status = 0 
      bscale = 1
      bzero  = 32768
      bzero  = 0
c
c     spectroscopic parameters
c
c     Lower bound of the default wavelength range
      wavstart = 0.0d0
c     Upper bound of the default wavelength range 
      wavend   = 0.0d0
c     Default spectral order
      sporder  = 0.d0
c
c     set parameters so image is compatible with the DHAS
c
      if(dhas.eq. 1) then
         bitpix    = 20
         naxis     =  3
         naxes(1)  = naxis1
         naxes(2)  = naxis2
         naxes(3)  = ngroups
         zerofram  = .false.
      else
         bitpix    = 16
         naxis     =  4
         naxes(1)  = naxis1
         naxes(2)  = naxis2
         naxes(3)  = ngroups
         naxes(4)  = nints
         zerofram  = .true.
      end if
c
c--------------------------------------------------------------------------
c
c     WCS parameters
c
c     to take distortions into account need to include the SIP keywords. 
c     For now assume all is plane.
c
      wcsaxes = 2
c
c     Spacecraft pointing information
c     (v2, v3) reference position. This is only true for full NIRCam:
c
      v2_ref  = xc * 60.d0
      v3_ref  = yc * 60.d0
c
      pa_v3   = pa_degrees
      ra_v1   = targ_ra
      dec_v1  = targ_dec
c     Right Ascension of the reference point (deg) 
      ra_ref  =  targ_ra
c     Declination of the reference point (deg) 
      dec_ref =  targ_dec
c     Telescope roll angle of V3 North over East at the ref. point (deg) 
      roll_ref = pa_v3
c
c     Parity (sense) of aperture settings (1, -1)
c     seems to be a fixed parameter from the inspection of
c     files provided by Bryan Hilbert
c
      vparity  = -1
c     Angle from V3 axis to Ideal y axis (deg)
      v3i_yang = 0.0d0
c
      crpix3 =    1.d0
c
c     CRVAL3 needs to be verified
c
      crval3 =    tgroup
      cdelt3 =    tgroup
c
c     This step calculates the equatorial coordinates of the SCA 
c     centre, at the same time setting the WCS keywords
c
      x_sca = 1024.5d0
      y_sca = 1024.5d0
c
      call wcs_keywords(sca_id, x_sca, y_sca, xc, yc, osim_scale,
     *     ra0, dec0,  pa_degrees,verbose)
      call osim_coords_from_sca(sca_id, x_sca, y_sca, x_osim, y_osim)
      call sca_to_ra_dec(sca_id, 
     *     ra0, dec0,
     *     ra_sca, dec_sca, pa_degrees, 
     *     xc, yc, osim_scale, x_sca, y_sca)
c      print *,'crval1, crval2, crval3',crval1, crval2, crval3
c      print *,'crval1, crval2, crval3',crval1, crval2, crval3
c      print *,'cd1_1, cd1_2, cd2_1, cd2_2',cd1_1, cd1_2, cd2_1, cd2_2
c
c     From Karl Misselt 2018-02-23:
c     PCi_j are the equivalent of CDi_j where CDi_j include pixel scale and
c     the PCi_j do not (both include the rotation).
c     cdi_i = cdelt_i * pci_j
c      pc1_1    = cd1_1 /(osim_scale/3600.d0)  
c      pc1_2    = cd1_2 /(osim_scale/3600.d0)  
c      pc2_1    = cd2_1 /(osim_scale/3600.d0)  
c      pc2_2    = cd2_2 /(osim_scale/3600.d0)  
      cdelt1   = scale/3600.d0
      cdelt2   = scale/3600.d0
      pc1_1    = cd1_1 / cdelt1
      pc1_2    = cd1_2 / cdelt1
      pc2_1    = cd2_1 / cdelt2
      pc2_2    = cd2_2 / cdelt2
c
c**************************************************************************
c
c     Read source catalogues 
c
c**************************************************************************
      open(7,file = 'fake_objects.reg')
      open(9,file = 'fake_objects_rd.reg')
      open(8,file = 'fake_objects.cat')
c
      if(verbose.gt.0) print *,'read catalogues'
c      if(include_stars.gt.0) then 
c         x0 = 0.0d0
c         y0 = 0.0d0
c         print 9327, subarray
c 9327    format(a8)
c         call read_star_catalogue(star_catalogue, nfilters, 
c     &     subarray, colcornr, rowcornr, naxis1, naxis2,
c     &     ra_ref, dec_ref, pa_degrees, x0, y0, osim_scale,
c     &     sca_id, old_style, verbose)
c         if(verbose.ge.2) print *,'read star catalogue', nstars
c      end if
c
c      if(include_galaxies .eq. 1 .and. ngal .gt. 0) then 
c
      call read_fake_mag_cat(galaxy_catalogue, cat_filter, 
     &     filter_in_cat, catalogue_filters_used, ngal)
      print *,'filters in cat,catalogue_filters_used, use_filter,ngal', 
     &     filter_in_cat,catalogue_filters_used, use_filter, ngal

c     end if
      if(verbose.ge.2) then
         do i = 1, 10,2
            print * ,ra_galaxies(i), dec_galaxies(i),
     &           magnitude(i,use_filter)
            
         end do
      end if
c
c=======================================================================
c
c     Start simulation
c
c=======================================================================
c
c     Initialise the random number generator
c     set seed to zero if the system clock will be used to seed
c     the random numbers. For repeatability set to 1
c
      seed = 0
      call zbqlini(seed)
c
c=======================================================================
c
c     Latent file
c
      write(latent_file, 1120) filter_id, iabs(sca_id)
 1120 format('latent_',a5,'_',i3.3,'.fits')
      print *,'latent file will be ', latent_file
c
c=======================================================================
c     
c     open fits file, write header
c
c=======================================================================
c
c     Open the fits data hyper-cube
c
      simple = .true.
      extend = .true.
      if(dhas.ne.1 .or.nints.gt.1) then

c     This creates a new IMAGE and places the current counter
c     there.
c     
         call data_model_fits(iunit,cube_name, verbose)
c         call ftghdn(iunit, hdn)
c         print *,'header number is:', hdn
c     
c     write basic keywords
c     
         bitpix   = 8
         naxis    = 0
         status   = 0
c
         call ftphpr(iunit,simple, bitpix, naxis, naxes, 
     &        0,1,extend,status)
         if (status .gt. 0) then
            print *, 'simple,bitpix,naxis'
            call printerror(status)
         end if
         status = 0
c     
c     create new empty HDU
c
         call ftcrhd(iunit,status)
         if (status .gt. 0) then
            call printerror(status)
            if(verbose.ge.1) print *, 'ftcrhd: ',status
         end if
         bitpix    = 16
         naxis     = 4
         naxes(1)  = naxis1
         naxes(2)  = naxis2
         naxes(3)  = ngroups
         naxes(4)  = nints
       else
         if(verbose.gt.0) 
     &        print *,'going to call data_model_fits ', cube_name
         call data_model_fits(iunit, cube_name, verbose)
         if(verbose .gt.0) then
            print *,'exited data_model_fits'
            print *, latent_file
            print *,'header number is ', hdn
            print *,'going to call jwst_keywords : ', cube_name
         end if
      endif
c
c=======================================================================
c     
c     write header information in first extension
c
      call jwst_keywords
     *     (iunit, nx, ny, 
     *     bitpix, naxis, naxes, pcount, gcount, cube_name,
     *     title, pi_name, category, subcat, scicat, cont_id,
     *     full_date,
     *     date_obs, time_obs, date_end, time_end, obs_id,
     *     visit_id, program_id, observtn, visit, obslabel,
     *     visitgrp, seq_id, act_id, exposure, template,
     *     eng_qual, visitype, vststart, nexposur, intarget,
     *     targcoopp, targprop, targ_ra, targ_dec, 
     *     targura, targudec, mu_ra, mu_dec, mu_epoch,
     *     prop_ra, prop_dec, 
     *     instrume, module, channel, filter_id, coronmsk,
     *     pilin,
     *     pntg_seq, expcount, expripar, tsovisit, expstart,
     *     expmid, expend, readpatt, nints, ngroups, groupgap,
     *     tframe, tgroup, effinttm, exptime,nrststrt, nresets, 
     *     zerofram, sca_num, drpfrms1, drpfrms3,
     *     subarray, substrt1, substrt2, subsize1, subsize2,
     *     fastaxis, slowaxis, 
     &     primary, primary_position, primary_total,
     &     subpixel, subpixel_position, subpixel_total,
     *     xoffset, yoffset,
     *     jwst_x, jwst_y, jwst_z, jwst_dx, jwst_dy, jwst_dz,
     *     apername,  pa_aper, pps_aper,
     *     dva_ra,  dva_dec, va_scale,
     *     bartdelt, bstrtime, bendtime, bmidtime,
     *     helidelt, hstrtime, hendtime, hmidtime,
     *     photmjsr, photuja2, pixar_sr, pixar_a2,
     *     wcsaxes, 
     *     crpix1, crpix2, crpix3, crval1, crval2, crval3,
     *     cdelt1, cdelt2, cdelt3, cunit1, cunit2, cunit3,
     *     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2,
     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3, equinox,
     *     ra0, dec0, roll_ref, v2_ref, v3_ref, 
     *     vparity, v3i_yang,
     &     nframes, object, sca_id,
     &     photplam, photflam, stmag, abmag,
     &     naxis1, naxis2,
     &     noiseless,
     &     include_ktc, include_bg, include_cr, include_dark,
     &     include_latents, include_readnoise, include_non_linear,
     &     ktc(sca_id-480),voltage_offset(sca_id-480),
     &     readnoise, background, dhas, verbose)
c
c=======================================================================
c
c     get detector footprint
c
      do 500 nint_level = 1, nints
c         print *,'=========================='
         do im = 1, max_nint
            do k = 1, 20
               do j = 1, 2048
                  do i =1, 2048
                     image_4d(i,j,k,im) = 0
                  end do
               end do
            end do
         end do

         if(nints .gt.1) print *,' nint_level ', nint_level, 
     &        ' of ', nints
         call sca_footprint(sca_id, noiseless, naxis1, naxis2,
     &        include_ktc, include_latents,
     &        include_non_linear, brain_dead_test, include_1_over_f,
     &        latent_file, idither, verbose)

c     
c     write base image
c
c      print *,'write_2d : filename: ', cube_name
c      if(zerofram .eqv. .true.) then
c         print*, 'ftiimg 1',iunit, bitpix,naxis, naxes, status
c         call ftiimg(iunit, bitpix,naxis, naxes, status)
c         if (status .gt. 0) then
c            print *,'at ftiimg 1 for SCI'
c            call printerror(status)
c         end if
c         status = 0
c         call ftghdn(iunit, hdn)
c         print *,'header number is ', hdn
c         call write_2d(cube_name, base_image, nx, ny,
c     *        nframe, tframe, groupgap, tgroup, ngroups, nints,
c     *        object, targ_ra, targ_dec, equinox,
c     *        crpix1, crpix2, crval1, crval2, cdelt1,
c     *        cdelt2, cd1_1, cd1_2, cd2_1, cd2_2,
c     *        sca_id, module, filter_id, 
c     *        subarray, colcornr, rowcornr)
c      end if
c
c     Add up the ramp
c     
         call add_up_the_ramp(idither, ra0, dec0,
     *        pa_degrees,
     *        cube_name, noise_name,
     *        sca_id, module, brain_dead_test, 
     *        xc, yc, pa_v3, osim_scale,scale,
     *        include_ktc, include_dark, include_readnoise, 
     *        include_reference,
     *        include_1_over_f, include_latents, include_non_linear,
     *        include_cr, cr_mode, include_bg,
     *        include_stars, include_galaxies, nstars, ngal,
     *        bitpix, ngroups, nframes, nskip, tframe, tgroup, object,
     *        nints,
     *        subarray, colcornr, rowcornr, naxis1, naxis2,
     *        filter_id, wavelength, bandwidth, system_transmission,
     *        mirror_area, photplam, photflam, stmag, abmag,
     *        background, icat_f,use_filter, npsf, psf_file, 
     *        over_sampling_rate, noiseless, psf_add,
     *        ipc_add, verbose)
c
c     This ensures that bitpix will be 16 and bzero=32K, bscale = 1
c     for unsigned integers
c
         if(dhas.ne.1 .or.nints.gt.1) then
            if(nint_level .eq.1) then
               call ftghdn(iunit, hdn)
c               print *,'header number is ', hdn, naxis, naxes
               status = 0
c     
               comment = 'Scale data by '
               call ftpkyd(iunit,'BSCALE',bscale,-7,comment,status)
               if (status .gt. 0) then
                  print *,'BSCALE'
                  call printerror(status)
               end if
               status = 0
c     
               comment = ' BSCALE * image + BZERO'
               call ftpkyj(iunit,'BZERO',bzero,comment,status)
               if (status .gt. 0) then
                  print *,' BZERO'
                  call printerror(status)
               end if
               status = 0
c     
               comment = 'Extension name'
c               print *,'ftpkys ', iunit, status
               call ftpkys(iunit,'EXTNAME','SCI',comment,status)
               if (status .gt. 0) then
                  print *,'at EXTNAME'
                  call printerror(status)
               end if
            end if
            nullval    = 0
            fpixels(1) = 1
            lpixels(1) = naxes(1)
            fpixels(2) = 1
            lpixels(2) = naxes(2)
            fpixels(4) = nint_level
            lpixels(4) = nint_level
c
c     store this ramp; since ftpssj does 
c     "transfer a rectangular subset of the pixels in a 
c     FITS N-dimensional image"
c     copy each group
c
            do ll = 1, naxes(3)
               fpixels(3) = ll
               lpixels(3) = ll
               do jj = fpixels(2), lpixels(2)
                  do ii = fpixels(1), lpixels(1)
                     plane(ii,jj) = image_4d(ii,jj,ll,1)
c
c     if this step is not carried out, one will have an
c     image with zeros for all pixels beyond the first case
c
                     if(image_4d(ii,jj,ll,1) .gt. 32767)
     &                    plane(ii,jj) = 32767
                     if(image_4d(ii,jj,ll,1) .lt.-32766)
     &                    plane(ii,jj) = -32766
                  end do
               end do
c     
               group = 0
               call ftpssj(iunit, group, naxis, naxes, fpixels, lpixels,
     &              plane, status)
               if (status .gt. 0) then
                  print *,'at ftpssj'
                  call printerror(status)
               end if
               status = 0
            end do
c     
c     save first readout of each of the NINTS exposures in the
c     second extension as a data-cube
c
c         bitpix    = 20
c         naxis     =  3
c         naxes(1)  = naxis1
c         naxes(2)  = naxis2
c         naxes(3)  = nints
c         call ftiimg(iunit, bitpix,naxis, naxes, status)
c         if (status .gt. 0) then
c            print *,'at ftiimg for zeroframe'
c            call printerror(status)
c         end if
c         status = 0
c     
c         comment = 'Scale data by       '
c         call ftpkyj(iunit,'BSCALE',bscale,comment,status)
c         if (status .gt. 0) then
c            print *,'BSCALE'
c            call printerror(status)
c         end if
c         status = 0
cc     
c         comment = ' BSCALE * image + BZERO'
c         call ftpkyj(iunit,'BZERO',bzero,comment,status)
c         if (status .gt. 0) then
c            print *,'BZERO'
c            call printerror(status)
c         end if
c         status = 0
c     
c         comment = 'Extension name'
c         call ftpkys(iunit,'EXTNAME','ZEROFRAME',comment,status)
c         if (status .gt. 0) then
c            print *,'at EXTNAME'
c            call printerror(status)
c         end if
c         status = 0
cc
c         nullval    = 0
c         fpixels(1) = 1
c         fpixels(2) = 1
c         fpixels(3) = 1
c         lpixels(1) = nnn
c         lpixels(2) = nnn
c         lpixels(3) = nints
c         group = 1
c         call ftp3dj(iunit, group, nnn, nnn, naxes(1), naxes(2), 
c     &        naxes(3),zero_frames, status)

      else
c
c     Output for file format compatible with current DHAS
c
         nullval    = 0
         fpixels(1) = 1
         fpixels(2) = 1
         fpixels(3) = 1
         fpixels(4) = 1
         lpixels(1) = nnn
         lpixels(2) = nnn
         lpixels(3) = naxes(3)
         lpixels(4) = 1
         group = 1
         do k = 1, naxes(3)
            do j = 1, naxes(2)
               do i = 1, naxes(1)
                  int_image(i,j,k) = image_4d(i, j, k, 1)
               end do
c               if(mod(j,1000).eq.0) print *,j,k,image_4d(1000, j, k, 1)
            end do
         end do
c         call ftpssj(iunit, group, naxis, naxes, fpixels, lpixels,
c     &        image_4d, status)
c         call ftp3dj(iunit, group, nnn, nnn, naxes(1), naxes(2), 
c     &        naxes(3),image_4d(1,1,1,1), status)
         call ftp3dj(iunit, group, nnn, nnn, naxes(1), naxes(2), 
     &        naxes(3),int_image, status)
      end if
 200  continue
 500  continue
      call closefits(iunit)
      print *, 'Exposure complete! Output file is'
      print *, cube_name
      stop
      write(test_name,1100) filter_id,iabs(sca_id),idither
 1100 format('sim_',a5,'_',i3.3,'_',i3.3,'.fits')
c
      call write_2d(test_name, image, nx, ny,
     *     nframe, tframe, groupgap, tgroup, ngroups, nints,
     *     object, targ_ra, targ_dec, equinox,
     *     crpix1, crpix2, crval1, crval2, cdelt1,
     *     cdelt2, cd1_1, cd1_2, cd2_1, cd2_2,
     *     sca_id, module, filter_id, 
     *     subarray, colcornr, rowcornr)
 999  continue
      print *,'Please verify if '
      print *,'one is using a SW filter for a LW detector'
      print *,'or'
      print *,'one is using a LW filter for a SW detector'
      print *,'this will require fixing the preparation script'
      stop
      end
