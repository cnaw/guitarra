c
c======================================================================
c     version 5.0 2021-10-29; 2022-06-08
c
c     Keywords from 
c     https://mast.stsci.edu/portal/Mashup/clients/jwkeywords/index.html
c     list as of 2018-02-07 (version JWSTDP-2018_1-180207)
c
c
c     NIRCam Imaging
c     standard and basic parameters
c
      implicit none
!
      type guitarra_source
      character :: path*180, id*25
      integer :: number, ncomponents
      real (kind=8)  :: ra, dec, mag, zz, 
     &     re, ellipticity, flux_ratio, theta, nsersic
      end type guitarra_source
!     
      type clone_source
      character :: path*180, id*25
      integer :: number
      double precision :: ra, dec, mag(10), smag(18),zz, pa
      end type clone_source
!
      logical simple, extend, dataprob, zerofram
      integer bitpix, naxis, naxis1, naxis2, naxis3, naxis4, pcount,
     &     gcount
      character keyword*8, value*50
      integer hdn
      double precision bscale, bzero
      real version
      character date*30, origin*20, timesys*10, filename*180, 
     &     filetype*30, sdp_ver*20, xtension*20, extname*20
c
c     input file
c
      character parameter_file*180
c
c     CR history
c
      character cr_history*180
c
c     coordinate system
c
      character radesys*10
c
c     programmatic information
c
      character title*150, pi_name*183, category*4, subcat*10, 
     &     scicat*10
      integer cont_id, id
c
c     observation identifiers
c
      character date_obs*10, time_obs*12, date_end*10, time_end*12,
     &     obs_id*26, visit_id*11, observtn*3, visit*11, obslabel*40,
     &     visitgrp*2, seq_id*1, act_id*2, exposure_request*5, 
     &     template*50, 
     &     eng_qual*8, exposure*7, patttype*15, program_id*5,
     &     subpixel_dither_type*20, primary_dither_string*15
      
      logical bkgdtarg

c     Visit information
c
      character visitype*30,vststart*20, visitsta*15
      integer nexposur
      logical intarget, targoopp
c
c     Target information
c
      double precision targ_ra, targ_dec, targura, targudec, 
     &     mu_ra, mu_dec, prop_ra, prop_dec
      character mu_epoch*6
      character targprop*31, targname*31, targtype*7
c
c     instrument-related
c
      character instrume*7,detector*12,module*6, channel*6, 
     &     object*26, filter_id*8, coronmsk*20, pupil*7
      logical pilin
c
c     exposure parameters
c
      double precision expstart, expmid, expend, tsample,
     &     tframe, tgroup, effinttm, effexptm, duration
      integer pntg_seq, expcount, nints, ngroups, nframes, groupgap,
     &     nsamples, nrststrt,NRESETS, sca_num, drpfrms1,drpfrms3
      character expripar*20, exp_type*30, readout_pattern*15
      logical tsovisit
c
c     subarray parameters
c
      integer substrt1,substrt2, subsize1,subsize2, fastaxis, slowaxis
      integer columns, rows, gaps
c     
c     NIRCam dither pattern parameters
c
      double precision xoffset, yoffset, v2_dither, v3_dither

      integer patt_num, numdthpt,subpxnum, subpxpns
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
      character apername*27, pps_aper*27, aperture*27
c
c     velocity aberration information
c
      double precision dva_ra, dva_dec, va_scale
c
c     Time information
c
      double precision sec, jday, mjd, ut, ut_end,mjd_utc, bjd_tbd,
     &     mirage_exptime
      double precision bartdelt,bstrtime, bendtime, bmidtime,
     &     helidelt, hstrtime, hendtime, hmidtime
      character date_time_start*30, date_time_end*30
      dimension date_time_start(200), date_time_end(200),
     &     group_end_time(200), mjd_utc(3,200), bjd_tbd(3,200)
c     
c     photometry information
c
      double precision photmjsr, photuja2, pixar_sr, pixar_a2

c
c     Spacecraft pointing information
c
      double precision pa_v3, ra_v1, dec_v1, ra_rad, dec_rad, pa_rad,
     &     v2_rad, v3_rad
c
c     WCS parameters
c
      integer wcsaxes
      double precision crpix1, crpix2, crpix3,
     &     crval1, crval2, crval3, cdelt1, cdelt2,cdelt3,
     &     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2,
     &     pc1_1_dms, pc1_2_dms, pc2_1_dms, pc2_2_dms,
     &     ra_ref, dec_ref, roll_ref,
     &     wavstart, wavend, sporder,
     &     crpix1_subarray, crpix2_subarray
      logical dms
      integer iop_cd_pc
c
c      wcs-related (but not used by STScI pipeline)
c
      double precision equinox,  cd1_1, cd1_2, cd2_1, cd2_2, cd3_3
      double precision cor1_1, cor1_2, cor2_1, cor2_2
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     SIAF parameters 
      character siaf_version*13
      integer ideal_to_sci_degree, v_idl_parity,
     &     sci_to_ideal_degree, det_sci_parity
      double precision 
     &     x_det_ref, y_det_ref,
     &     x_sci_ref, y_sci_ref,
     &     x_sci_size, y_sci_size,
     &     sci_to_ideal_x, sci_to_ideal_y,
     &     ideal_to_sci_x, ideal_to_sci_y,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang,
     &     det_sci_yangle,
     &     v2_ref, v3_ref,
     &     nrcall_v3idlyangle, nrcall_v2, nrcall_v3
      double precision attitude_dir, attitude_inv, attitude_nrc,
     &     aa, bb, ap, bp, det_sign
      integer a_order, b_order, ap_order, bp_order

      character ctype1*15, ctype2*15, ctype3*15,
     &     cunit1*40, cunit2*40, cunit3*40,
     &     s_region*100

      dimension 
     &     sci_to_ideal_x(6,6), sci_to_ideal_y(6,6), 
     &     ideal_to_sci_x(6,6), ideal_to_sci_y(6,6)
      dimension attitude_dir(3,3),attitude_inv(3,3), attitude_nrc(3,3),
     &     aa(9,9), bb(9,9), ap(9,9), bp(9,9)
      dimension columns(200), rows(200), gaps(200)
c     
c==========================================================================
c
c     other keywords; some need to be kept so reduction with DHAS
c     can be carried out.
c
      double precision pi, q, arc_sec_per_radian, cee, hplanck
      integer job
      integer status, nhdu, hdunum, hdutype
c
c     catalogue-related
c
      double precision ra_stars, dec_stars, mag_stars, counts
      double precision ra_galaxies, dec_galaxies, 
     *     z, magnitude, nsersic, ellipticity,
     *     re, theta, flux_ratio
      double precision two_n
      integer max_stars, max_objects, nsub, ncomponents, nstars, ngal,
     *     nclone, catalogue_filters_used, hst_level
      character clone_cat*180, clone_match*180, star_catalogue*180,
     *     galaxy_catalogue*180
c
c     these need to be checked because may not be needed,
c     but are kept for compatibility
c
      double precision x_sci_scale, y_sci_scale
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
     &     ktc, gain,  read_noise, dark_mean, dark_sigma, voltage_sigma
      double precision  dark_mean_cv3, dark_sigma_cv3, gain_cv3,
     &     read_noise_cv3
      integer max_order, order ! refers to linearity
      double precision linearity_gain,  lincut, well_fact
      double precision ipc
c
c     dither related
c
      double precision primary_dither, dither_arc_sec, subpixel_dither
      integer number_primary, number_subpixel
      integer iunit, nx, ny, nz, nframe, nnn, nskip, max_groups,
     &     naxes, sca_id, n_outputs
      integer tute_unit, extnum, write_tute, tute_naxis, tute_naxes
      integer   primary_position, primary_total, subpixel_position
      double precision ra0, dec0, new_ra, new_dec, dx, dy, pa_degrees
      integer idither, indx, icat_f
c
c     Exposure 
c     
      double precision bias_value, readnoise, background, exptime,
     &     integration_time, effective_integration, temp_time
      double precision total_time, flux, uresp, wl_cm,e_photon
      character full_date*23, full_time_end*23, group_end_time*23
      
      
      integer ih, im, year, month, day, time_counter
      integer distortion, precise, tute_distortion
c
c     filter-related
c
      double precision mirror_area
      double precision wavelength, bandwidth, system_transmission, bkg
      double precision filters, filtpars
      double precision photplam, photflam, f_nu, stmag, abmag, vega_zp
      integer nfilter_wl, nbands, npar, nfilters, use_filter,
     &     filters_in_cat, nf_used, nf, filter_index, cat_filter
      character filterid*20, temp*20, filter_path*180
c
c     image-related
c
      real base_image, accum, image, latent_image, gain_image,
     &     dark_image, well_depth, linearity, bias, scratch
      real flat_image
      integer image_3d, zero_frames, max_nint, nint_level
      integer ii, jj, ll, mm, nn, mirage_counter
c
      integer debug
      integer verbose, skip, dhas, i, j, k, seed, n_image_x, n_image_y
      integer (kind=4) int_image, fpixels, lpixels, group, nullval
      integer (kind=4) plane
      character noise_file*180,latent_file*180, flat_file*180,
     &     dark_ramp*180,
     &     biasfile*180, darkfile*180, sigmafile*180, 
     &     welldepthfile*180, gainfile*180, linearityfile*180,
     &     badpixelmask*180, ipc_file*80, ipc_name*180
c
      character cube_name*180, test_name*180, tute_name*180
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
      integer include_bg, include_cr,  include_dark, 
     *     include_dark_ramp, include_ktc, 
     *     include_latents, include_non_linear, include_readnoise, 
     *     include_reference, include_1_over_f, brain_dead_test,
     *     include_ipc, include_flat, include_bias
      logical ipc_add
      integer include_stars, include_galaxies, include_cloned_galaxies
      integer old_style
      character subarray*15,
     &     subpixel*16, comment*40
c
c     Cosmic rays
c      
      integer cr_mode, ncr, n_cr_levels
      integer ion
      real cr_matrix, cr_flux, cr_accum, mev
      
      parameter(ncr=21)
      dimension cr_matrix(ncr,ncr,10000),cr_flux(10000),cr_accum(10000),
     &     ion(10000), mev(10000)
c
c     define lengths
c
      parameter (nfilter_wl = 25000, nbands=200, npar=30,nfilters=54)
      parameter(nnn=2048, max_nint=1, max_order=7)
      parameter (nxny=3100*3100)
c      parameter (nxny=3072*3072)
c      parameter (nxny=6144*6144)
      parameter(max_stars=1000)
      parameter(max_objects = 60000, nsub = 4)
c
c     SCA parameters
c
      dimension dark_mean_cv3(10), dark_sigma_cv3(10), gain_cv3(10),
     *     read_noise_cv3(10), voltage_offset(10), ktc(10)
      dimension dark_mean(10), dark_sigma(10), gain(10),
     *     read_noise(10), voltage_sigma(10)
c     
c     images
c
      dimension ipc(3,3), ipc_file(10)
      dimension base_image(nnn,nnn), flat_image(nnn,nnn,2)
      dimension accum(nnn,nnn), image(nnn,nnn), latent_image(nnn,nnn)
      dimension gain_image(nnn,nnn), dark_image(nnn,nnn,2),
     *     well_depth(nnn,nnn), linearity(nnn,nnn,max_order),
     &     bias(nnn,nnn), scratch(nnn,nnn)
      dimension image_3d(nnn,nnn,20), naxes(4), tute_naxes(4),
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
!
c      type(clone_source) :: clone(max_objects)
      type(guitarra_source) :: galaxy(max_objects)
!
      dimension ra_stars(max_stars), dec_stars(max_stars),
     *     mag_stars(max_stars ,nfilters), counts(max_stars)
c      dimension ra_galaxies(max_objects), dec_galaxies(max_objects), 
c     *     z(max_objects), id(max_objects),
c     *     magnitude(max_objects), ncomponents(max_objects),
c     *     nsersic(max_objects, nsub), ellipticity(max_objects, nsub),
c     *     re(max_objects, nsub), theta(max_objects, nsub), 
c     *     flux_ratio(max_objects, nsub)
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
      common /accum_/ accum
      common /base/ base_image
      common /flat_/ flat_image
      common /four_d/ image_3d, zero_frames
      common /gain_/ gain_image
      common /image_/ image
      common /ipc_/ ipc
      common /latent/ latent_image
      common /scratch_/ scratch
      common /stars/ ra_stars, dec_stars, mag_stars, nstars
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
     *     dark_mean, dark_sigma, ktc, voltage_offset,
     *     voltage_sigma
c
      common /cr_list/ cr_matrix, cr_flux,cr_accum, n_cr_levels,
     &     ion, mev

c      
      common /filter/filters, filtpars, filterid
c
c      common /galaxy/ra_galaxies, dec_galaxies, z, magnitude, 
c     *     nsersic, ellipticity, re, theta, flux_ratio, ncomponents,id
      common /gdif_par/ two_n
      common /psf/ integrated_psf,n_psf_x, n_psf_y, 
     *     nxy, over_sampling_rate

c     OSIM units in arc seconds (i.e., OSIM measurements are in arc min)
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

c      data ipc/0.d0, 0.d0, 0.d0, 0.d0, 1.d0, 0.d0, 0.d0, 0.d0, 0.d0/
c
c     Gains  in e-/ADU
c     These come from Jarron L and are derived from ISIMCV3 measurements
c     2018-06-07
c
      data gain/2.07d0, 2.010d0, 2.16d0, 2.01d0, 1.83d0,
     *     2.00d0, 2.42d0, 1.93d0, 2.30d0, 1.85d0/
      data ipc_file/
     &     'cal/IPC/NRCA1_17004_IPCDeconvolutionKernel_2016-03-18.fits',
     &     'cal/IPC/NRCA2_17006_IPCDeconvolutionKernel_2016-03-18.fits',
     &     'cal/IPC/NRCA3_17012_IPCDeconvolutionKernel_2016-03-18.fits',
     &     'cal/IPC/NRCA4_17048_IPCDeconvolutionKernel_2016-03-18.fits',
     &     'cal/IPC/NRCA5_17158_IPCDeconvolutionKernel_2016-03-18.fits',
     &     'cal/IPC/NRCB1_16991_IPCDeconvolutionKernel_2016-03-18.fits',
     &     'cal/IPC/NRCB2_17005_IPCDeconvolutionKernel_2016-03-18.fits',
     &     'cal/IPC/NRCB3_17011_IPCDeconvolutionKernel_2016-03-18.fits',
     &     'cal/IPC/NRCB4_17047_IPCDeconvolutionKernel_2016-03-18.fits',
     &     'cal/IPC/NRCB5_17161_IPCDeconvolutionKernel_2016-03-18.fits'/
c     
c     Guitarra Version
c     version 1   first version committed to github
c     version 2   includes minor fixes for noise sources
c     version 3   includes FoV distortion
c     version 4   includes STScI format output
c     version 4.1 simplifies the distortion=2 calculation
c     version 4.2 includes subarrays
c     version 5.0 includes output to DMS format, includes cloned galaxies
      version    = 5.0
c
c     This is the path to input data files:
c
      call getenv('GUITARRA_AUX',guitarra_aux)
c     
c     constants
c
      pi     = dacos(-1.0d0)
      q      = pi/180.d0
      arc_sec_per_radian = 3600.d0*180.d0/pi
      hplanck = 6.62606957d-27  ! erg s 
      cee     = 2.99792458d10   ! cm/s
c
c=======================================================================
c
c     Instrument related parameters
c
c     Gain
c
      do i = 1, 10
         gain_cv3(i) = gain(i)
      end do
c
c     voltage offsets in ADU from Jarron Leisenring (JML)
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
c     Voltage sigma in ADU also from JML
c
      voltage_sigma(1)   = 20.d0
      voltage_sigma(2)   = 20.d0
      voltage_sigma(3)   = 30.d0
      voltage_sigma(4)   = 11.d0
      voltage_sigma(5)   = 50.d0
      voltage_sigma(6)   = 20.d0
      voltage_sigma(7)   = 20.d0
      voltage_sigma(8)   = 20.d0
      voltage_sigma(9)   = 20.d0
      voltage_sigma(10)  = 20.d0
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
c     The readnoise/reference pixel value is modulated by the relative
c     bias between amplifiers, here assumed as identical for all SCAs.
c     PyNRC does not make this assumption:
c
c     ch_off_arr   =
c     [1700, 530, -375, -2370]
c     [-150, 570, -500,   350]
c     [-530, 315,  460,  -200]
c     [ 480, 775, 1040, -2280]
c     [ 560, 100, -440,  -330]
c
c     [ 105,  -29, 550,  -735]
c     [ 315,  425,-110,  -590]
c     [ 918, -270, 400, -1240]
c     [-100,  500, 300,  -950]
c     [ -35, -160, 125,  -175]
c
c     Average darks from ISIM CV3
c
      do i = 1, 10
         dark_mean(i)      = dark_mean_cv3(i)
         dark_sigma(i)     = dark_sigma_cv3(i)
         read_noise(i)     = read_noise_cv3(i)
      end do
c
c     PSF oversampling rate (is read from PSF file)
c
      over_sampling_rate = 1
c
c     are coordinates plane (0) or do they include 
c
c     mirror area from JDOX
c
      mirror_area = 25.4d0 * 1.0D4 
      job       = 1000
      dhas      = 1
      old_style = 1
      write_tute= 0
c
c     if coordinate using distortion = 1 need a boost set to 1:
c
      precise    = 0
c
c     This insures that bitpix will be 16 and bzero=32K, bscale = 1
c     for unsigned integers
c
      bitpix = 16
c     must be OK or SUSPECT
      eng_qual  = 'OK'
c
      targoopp    = .false.
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
c     if read_parameters needs to be debugged, set to 1:
c
      debug = 1
c
c      read(5, 9) parameter_file
c      if(debug.gt.0) then
c         print *,'guitarra: parameter_file'
c         print *, parameter_file
c      end if
c
      call  read_parameters( nfilters,
     &     npsf,  sca_id, 
     &     patttype, primary_total, patt_num,  primary_dither_string,
     &     subpixel_dither_type, subpxpns ,subpixel_position,
     &     nints, ngroups, 
     &     subarray, colcornr, rowcornr, naxis1, naxis2,
     &     substrt1,substrt2,
     &     use_filter, filters_in_cat, verbose, 
     &     seed, noiseless,
     &     ra0, dec0, pa_degrees,
     &     include_bg, include_cloned_galaxies, include_cr,  
     *     include_dark, include_dark_ramp,
     *     include_galaxies, include_ipc, include_ktc, 
     *     include_bias, include_latents, include_flat, 
     &     include_non_linear, include_readnoise, 
     *     include_reference, include_1_over_f, 
     *     brain_dead_test,
     *     cr_mode, 
     &     aperture, filter_path, pupil,
     &     xoffset, yoffset, v2_dither, v3_dither,
     &     galaxy_catalogue,star_catalogue,
     &     clone_cat, clone_match,
     &     zodifile, flat_file,
     &     noise_file, cube_name, psf_file,
     &     readout_pattern, 
     &     observtn, obs_id, obslabel,
     &     program_id, category, visit_id, visit,
     &     visitgrp, seq_id, act_id, exposure_request,
     &     targprop, expripar, cr_history, distortion,
     &     siaf_version, write_tute, tute_name, 
     &     title,
     &     debug)
c     
      filename = cube_name
c
      debug = verbose
c     
      if(npsf .gt.0) then
         psf_add   = .TRUE.
      else
         psf_add   = .FALSE.
      end if
      if(include_ipc .eq.1) then
         ipc_add   = .TRUE.
      else
         ipc_add   = .FALSE.
      end if
c
c======================================================================= 
c
c     If this is a noiseless simulation set
c     noise values accordingly
c
c     Sensor Chip Assembly number (Possible values are 1-18, 1-10 being NRC)
      sca_num       = sca_id - 480
      readnoise     = read_noise_cv3(sca_num)
      if(noiseless .eqv. .TRUE.) then
         print *,'guitarra : noiseless eqv true'
         psf_add    = .false.    ! for now
         include_dark            = 0
         include_dark_ramp       = 0
         include_flat            = 0
         include_ipc             = 0
         include_ktc             = 0
         include_latents         = 0
         include_non_linear      = 0
         include_readnoise       = 0
         include_reference       = 0
         include_1_over_f        = 0
      end if
c
      if(brain_dead_test .eq.1) then
         include_ktc     =    1 
         ktc(sca_num)      = 1000.0
      end if
c
c     The raw dark ramp already includes the following
c     effects, so turn them off
c
      if(include_dark_ramp.eq.1) then
         include_ktc        = 0
         include_bias       = 0
         include_dark       = 0
         include_reference  = 0
         include_readnoise  = 0
         include_1_over_f   = 0
      end if
c
      if(include_ktc .eq. 0) ktc(sca_num) = 0.0d0
      if(include_bias .eq. 0) then
         voltage_offset(sca_num) = 0.0d0
         voltage_sigma(sca_num)  = 0.0d0
      end if
      if(include_dark .eq.0) then
         dark_mean(sca_num)      = 0.0d0
         dark_sigma(sca_num)     = 0.0d0
      end if
      if(include_readnoise .eq.0) readnoise  = 0.0d0
c     
c      print *,include_bg, include_cloned_galaxies, include_cr,  
c     *     include_dark, include_dark_ramp, 
c     *     include_galaxies, include_ktc, 
c     *     include_latents, include_non_linear, include_readnoise, 
c     *     include_reference, include_1_over_f
      print *,'readnoise ', readnoise
c
c======================================================================= 
c
c     These are some of the keywords for JWST. Most should come
c     from the XML output. For now leave as place holders
c
      object      = 'TARGNAME contents'
      equinox    = 2000.d0
c
c     Official FITS keywords 
c
c     Instrument configuration information
c
      pi_name    = 'ZebigBos'

      subcat     = 'NIRCAM'
      scicat     = 'Extragalac'
c
c     observation template
c
      template = 'NIRCam Imaging'
c
c     visit information
c
      visitype   = 'PRIME_TARGETED_FIXED'
c
c======================================================================
c
c     instrument configuration
c
      instrume   = 'NIRCAM  '
      if(sca_id .gt. 485) then
         module     = 'B'
      else
         module     = 'A'
      end if

c
c     Aperture information
c
      pps_aper = aperture
      pa_aper  = pa_degrees
      call set_detector_apername(sca_id, aperture, subarray,
     &      detector, apername, channel)

c
      coronmsk   = 'NONE'
      pilin      = .false.
c
c     telemetry problem ?
c
      dataprob  = .false.
c
c-----------------------
      print 15, trim(cube_name)
 9    format(a120)
      print 15, trim(filter_path)
c
c     print PSF files to use
c
      do i = 1, npsf
         print 15, trim(psf_file(i))
      end do
c
c     name of file containing background SED for observation date
c
      print 15, zodifile(1:len_trim(zodifile))
 10   format(i12)
c
 15   format(a) 
c
c
c      print *, 'PA ', pa_degrees
 40   format(a80)
 50   format(a30,2x,a80)
c
c     print some confirmation values
c
      idither = subpixel_position
c
c=======================================================================
c
c     read filter parameters
c
      print *,' use_filter' , use_filter, ' icat_f ', icat_f
      if(debug.gt.0) print 1111, filter_path
 1111 format(a180)

      call read_single_filter(filter_path, use_filter, verbose)
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
      photflam            = filtpars(j,25) ! use flux value, not the Vega magnitude
      vega_zp             = filtpars(j,3)  ! vega zero-point
      abmag               = filtpars(j,28)
      stmag               = filtpars(j,29)
c      print *,'filter_index ', j, wavelength, bandwidth, uresp, 
c     &     photflam, abmag
c
c
c
c=======================================================================
c     Zodiacal background:
c     use appropriate scales for SW/LW
c     
      if(photplam .gt. 2.5d0) then
         pixel = 0.0648d0
      else
         pixel = 0.0317d0
      end if
      scale = pixel
c     
c     read zodiacal background
c
      call read_jwst_background(zodifile, use_filter, pixel,
     &     mirror_area, background)
c
c     If scale and SCA/filter are incompatible exit!
c
      if(scale.eq.0.0317d0.and.wavelength.gt.2.4d0) go to 999
      if(scale.eq.0.0648d0.and.wavelength.lt.2.4d0) go to 999
c     
c     photometry information
c
c     Flux density (MJy/steradian) producing 1 count/second
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
      photmjsr  = (f_nu/1.0d06)/pixar_sr
c     Flux density (uJy/arcsec2) producing 1 cps
      photuja2 = (f_nu*1.d06)/pixar_a2
      print *, 'guitarra: '
c      print 92, sca_id, use_filter, filter_id, scale, wavelength
c 92   format('guitarra:   sca',2x,i3,' filter ',i4,2x,a5,
c     &     ' scale',2x,f6.4,' wavelength ',f7.4)
c
      print *, 'ra0                       ', ra0
      print *, 'dec0                      ', dec0
      print *, 'pa_degrees                ', pa_degrees
      print *, 'subpixel_position         ', idither
      print *, 'sca_id                    ', sca_id
      print *, 'scale                     ', scale
      print *, 'aperture:                 ', aperture
      print *, 'apername:                 ', apername
      print *, 'subarray:                 ', subarray
      print *, 'colcornr, rowcornr:       ', colcornr, rowcornr
      print *, 'readout pattern           ', readout_pattern
      print *, 'filter_index              ', j
      print *, 'filter_id                 ', filter_id
      print *, 'bandwidth (um)            ', bandwidth
      print *, 'effective wavelength      ', wavelength
      print *, 'photoplam (um) (pivot)    ', photplam
      print *, 'photflam (erg/[cm**2 s A])', photflam
      print *, 'f_nu 1 cps(Jy)            ', f_nu
c      print *, '-2.5log f_nu +8.9        ', -2.5d0*dlog10(f_nu)+8.9d0
      print *, 'abmag 1 cps               ', abmag
      print *, 'photmjsr  (MJy/sr)        ', photmjsr
      print *, 'photuja2  (uJy/arcsec**2) ', photuja2
c     
c=======================================================================
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
      mu_epoch  = '2000.0'
      prop_ra   = targ_ra
      prop_dec  = targ_dec
c     position angle of V3 axes of JWST
      pa_v3     = pa_degrees    ! This comes from read_parameters
c      ra_ref    = ra0           ! RA of SCA centre
c      dec_ref   = dec0          ! DEC of SCA centre

c     
c====================================================================      
c
c     NIRCam total number of points in primary dither pattern: 1-25, 27, 36, 45 
      NUMDTHPT  =  primary_total
      nresets   = 1
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
c=======================================================================
c
c     load table with transformations between OSIM coordinates
c     and SCA coordinates (valid only if distortion = 0)
c
      call load_osim_transforms(verbose)
c
c------------------------------------------------------------------------
c
c     WCS parameters
c
c     Number of axes is 3 - v2, v3 and time
      wcsaxes = 3
c
c     Spacecraft pointing information
c     (v2, v3) reference position. This is only true for full NIRCam
c
      if(distortion .eq.0) then
c
c     This is the SIAF position for the NRCALL aperture
c
         xc      = -0.00529d0
         yc      = -8.209855d0
         v2_ref  = xc * 60.d0
         v3_ref  = yc * 60.d0
c      pa_v3   = pa_degrees
c     Right Ascension of the reference point (deg) 
         ra_ref  =  targ_ra
c     Declination of the reference point (deg) 
         dec_ref =  targ_dec
c         
c     Telescope roll angle of V3 North over East at the ref. point (deg)
c     (from JWST pipeline)
c         
         call compute_local_roll(pa_v3, ra_ref, dec_ref,
     &         v2_ref, v3_ref, roll_ref)
c     This step calculates the equatorial coordinates of the SCA 
c     centre, at the same time setting the WCS keywords
c     
         x_sca = 1024.5d0
         y_sca = 1024.5d0
c     
         call wcs_keywords(sca_id, x_sca, y_sca, xc, yc, osim_scale,
     *        ra0, dec0,  pa_degrees,verbose)
         call osim_coords_from_sca(sca_id, x_sca, y_sca, x_osim, y_osim)
         call sca_to_ra_dec(sca_id, 
     *        ra0, dec0,
     *        ra_sca, dec_sca, pa_degrees, 
     *        xc, yc, osim_scale, x_sca, y_sca)
c     
c     From Karl Misselt 2018-02-23:
c     PCi_j are the equivalent of CDi_j where CDi_j include pixel scale and
c     the PCi_j do not (both include the rotation).
c      cdi_i = cdelt_i * pci_j
c      pc1_1    = cd1_1 /(osim_scale/3600.d0)  
c      pc1_2    = cd1_2 /(osim_scale/3600.d0)  
c      pc2_1    = cd2_1 /(osim_scale/3600.d0)  
c      pc2_2    = cd2_2 /(osim_scale/3600.d0)  
c      cdelt1   = scale/3600.d0
c      cdelt2   = scale/3600.d0
c     
c     This is the relation between PCi_j and CDi_j
c     
         pc1_1    = cd1_1/cdelt1
         pc1_2    = cd1_2/cdelt1
         pc2_1    = cd2_1/cdelt2
         pc2_2    = cd2_2/cdelt2
         print *,'pc1_1 ', pc1_1, pc1_2, pc2_1, pc2_2
         print *,'cd1_1 ', cd1_1, cd1_2, cd2_1, cd2_2
         print *,'cdelt ', cdelt1, cdelt2, cdelt3
         ctype1   = 'RA---TAN'
         ctype2   = 'DEC--TAN'
      end if
c
c     Using SIAF distortion
c
      if(distortion.gt.0) then
         call read_siaf_parameters(aperture, subarray,sca_num, 
     &        sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &        ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &        x_sci_scale, y_sci_scale, x_sci_size, y_sci_size,
     &        x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &        det_sci_yangle, det_sci_parity,
     &        v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &        nrcall_v3idlyangle, nrcall_v2, nrcall_v3,
     &        siaf_version,verbose)
c     
         call prep_wcs(
     &        sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &        ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &        x_sci_scale, y_sci_scale,
     &        x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &        det_sci_yangle, det_sci_parity, det_sign,
     &        v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &        nrcall_v3idlyangle, nrcall_v2, nrcall_v3,
     &        crpix1, crpix2,
     &        crval1, crval2,
     &        ctype1, ctype2,
     &        cunit1, cunit2,
     &        cd1_1, cd1_2, cd2_1, cd2_2,
     &        ra0, dec0, pa_degrees,
     &        a_order, aa, b_order, bb,
     &        ap_order, ap, bp_order, bp, 
     &        attitude_dir, attitude_inv,
     &        ra_sca, dec_sca,
     &        pc1_1, pc1_2, pc2_1, pc2_2,
     &        cdelt1, cdelt2,
     &        verbose)
c
c     Telescope roll angle of V3 North over East at the ref. point (deg) 
         roll_ref = pa_degrees
c     don't know what these are... but crvaln refer to the SCA's centre
         ra_ref   = crval1
         dec_ref  = crval2
c
c     Telescope roll angle of V3 N over East at ref. point (degrees)
c     This is what the ST Pipe reduction suggests:
c     
c         roll_ref = pa_degrees+v3_idl_yang  ! not this 
c         roll_ref = pa_degrees + nrcall_v3idlyangle  ! don't this it is this either
         roll_ref  = pa_v3
         if(roll_ref .gt.360.0d0) roll_ref = roll_ref -360.d0
c         print *, ra0, dec0
c         print *, crval1, crval2
c         stop
c
c     find RA, DEC of v1 boresight (v2=v3=0.0), assuming ra0, dec0 are
c     the coordinates corresponding to nrcall_v2, nrcall_v3 (i.e.,
c     NIRCam centre)
c
         ra_rad  = ra0  * q
         dec_rad = dec0 * q
         v2_rad  = nrcall_v2 * q/3600.d0
         v3_rad  = nrcall_v3 * q/3600.d0
         call attitude( v2_rad, v3_rad, ra_rad, dec_rad, pa_rad,
     *        attitude_nrc)
         v2_rad = 0.0d0
         v3_rad = 0.0d0
         call rot_coords(attitude_nrc, v2_rad, v3_rad, ra_rad, dec_rad)
         call coords_to_ra_dec(ra_rad, dec_rad, ra_v1, dec_v1)
c
c     Kludge so the no-distortion version produces
c     images with the correct orientation. The SIP (ra,dec)->(x,y)
c     transformation works if the AA, BB polynomials are
c     made consistent. The (x,y)->(ra,dec) transformation does
c     not work. 2021-03-19
c     
         if(distortion.eq.2) then
            ctype1 = 'RA---TAN'
            ctype2 = 'DEC--TAN'
            a_order = 0
            b_order = 0
            ap_order = 0
            bp_order = 0
c            do ii = 1, a_order + 1
c               do jj = 1, a_order+1
c                  aa(ii,jj) = 0.0d0
c                  bb(ii,jj) = 0.0d0
c                  ap(ii,jj) = 0.0d0
c                  bp(ii,jj) = 0.0d0
c               enddo
c            end do
c            cd1_1 = cd1_1 * det_sci_parity
c            cd1_2 = cd1_2 * det_sign
c            cd2_1 = cd2_1 * det_sci_parity 
c            cd2_2 = cd2_2 * det_sign
         end if
      endif
cccccccccccccccccccccccccccccccc

c     if(subarray(1:4) .eq. 'FULL') then
c      colcornr =  x_det_ref - x_sci_size/2.d0 +0.5d0
c      rowcornr =  y_det_ref - y_sci_size/2.d0 +0.5d0
cc      colcornr = 0
cc      rowcornr = 0
c      substrt1 =  colcornr      ! wrong : should be 
c      substrt2 =  rowcornr      ! in SCI frame not DET
      subsize1 =  x_sci_size
      subsize2 =  y_sci_size
c
      if(sca_id .eq. 481) then
         fastaxis =     -1
         slowaxis =      2
      end if
c
      if(sca_id .eq. 482) then
         fastaxis =      1
         slowaxis =     -2
      end if
c
      if(sca_id .eq. 483) then
         fastaxis =     -1
         slowaxis =      2
      end if
c
      if(sca_id .eq. 484) then
         fastaxis =      1
         slowaxis =     -2
      end if
c
      if(sca_id .eq. 485) then
         fastaxis =     -1
         slowaxis =      2
      end if
c
      if(sca_id .eq. 486) then
         fastaxis =      1
         slowaxis =     -2
      end if
c
      if(sca_id .eq. 487) then
         fastaxis =     -1
         slowaxis =      2
      end if
c
      if(sca_id .eq. 488) then
         fastaxis =      1
         slowaxis =     -2
      end if
c
      if(sca_id .eq. 489) then
         fastaxis =     -1
         slowaxis =      2
      end if
c
      if(sca_id .eq. 490) then
         fastaxis =      1
         slowaxis =     -2
      end if

c      endif
c
c      naxis1   = x_sci_size
c      naxis2   = y_sci_size
c
cccccccccccccccccccccccccccccccc
      xc =  nrcall_v2/60.d0
      yc =  nrcall_v3/60.d0
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
 120  format(i2.2,1x,i2.2,1x,f6.3)
      if(time_obs(7:7) .eq. ' ') time_obs(7:7) ='0'
      print  125,'date_obs', date_obs
      print  125,'time_obs', time_obs
 125  format(1x,a8,15x,a)
c     
c     calculate UT and other parameters
c
      vststart =date_obs
      call julian_day(year, month, day, ut, jday, mjd)
      ut = ih + im/60.d0 + sec/3600.d0
c
c     find what this means in terms of frames, groups, gaps
c
      call set_params(readout_pattern, nframes, groupgap, max_groups)
      nskip = groupgap
c     
c     Type of data in the exposure
      exp_type  = 'NRC_IMAGE'

c     Number of resets at start of exposure
      nrststrt = 1
c     Number of resets that separate integrations within an exposure
      NRESETS =  1
c     Number of frames dropped prior to first integration
      DRPFRMS1 = 0
c     Number of frames dropped after last readout in a group
      DRPFRMS3 = nskip
c     readout times -pointed out by K. Misselt 2021-03-29:
c     https://jwst-docs.stsci.edu/near-infrared-camera/nircam-instrumentation/nircam-detector-overview/nircam-detector-subarrays
C     "For most subarrays, pixels are read out one at a time (Noutputs = 1).
C     For subarrays spanning the full width of the detector (2,048 pixels),
C     four parallel output channels can be utilized for faster read out times 
C     (Noutputs = 4)."
c
      if(subsize1 .eq.2048) then
         n_outputs = 4
      else
         n_outputs = 1
      end if
c     nsamples   Number of A/D samples per pixel
      nsamples   =  1
c     Delta time between samples in units of microsec
      tsample    = 10.d0
      integration_time = (dble(subsize1)/n_outputs)+12.d0
      if(n_outputs .eq. 4) then
         integration_time = integration_time*(dble(subsize2)+1.0d0)
      else
         integration_time = integration_time*(dble(subsize2)+2.0d0)
      end if
c     integration time per read (is a function of the array size)
      integration_time = integration_time * tsample*1.d-6
c     Time between start of successive frames in units of seconds.
      tframe = integration_time
c     time between start of successive groups
      tgroup = (nframes + groupgap) * tframe
c     Effective integration time
      effective_integration = (ngroups-1)*tgroup + nframes*tframe
      effinttm  = effective_integration
c     effective exposure time
      exptime = total_time(nframes,groupgap,ngroups,1,tframe,verbose)
      exptime = exptime * nints
c
      if(verbose.ge.2) print *,' exptime',
     &     exptime
c
      effexptm = (ngroups*nframes) +(ngroups-1) * groupgap + drpfrms1
      effexptm = tframe * effexptm * nints
      duration = (ngroups* nframes) +(ngroups-1) * groupgap 
      duration = tframe * (duration + drpfrms1*nints)

c     UTC exposure start time
      expstart = mjd + ut/24.d0
c     UTC at mid-exposure
      expmid   = expstart + exptime/(2.d0*3600.d0*24.d0)
c     UTC at end of exposure
      expend   = expstart + exptime/(3600.d0*24.d0)
      ut_end = ut + exptime/3600.d0

      call ut_to_date_time(year, month, day, ut_end, 
     &     date_end, time_end, full_time_end)
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
c---------------------------------------------------------------------
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
c     pointing sequence number
      pntg_seq  = idither
c     running count of exposures in visit
      expcount  = patt_num
c
c     prime or parallel exposure (should come from script
c     reading APT output
c
c     Timer Series Observation visit indicator
      tsovisit = .false.
c
c     NIRCam dither pattern parameters
c
c     CRVAL3 
c     6 = 2 skip + 0.5 * readouts in medium8
c     thus 12 skip + 0.5*8 = -16*10.73776 for deep8
c
      crpix3 =   0.0
      crval3 =   -tframe *(groupgap+nframes/2.0)
      cdelt3 =    tgroup
      cunit3 =  'seconds'
c=======================================================================
c
c     parameters used when saving fits files and images
c
      status = 0 
      bscale = 1.d0
      bzero  = 32768.d0
c      bzero  = 0
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
c         bitpix    = 20
         naxis     =  3
         naxes(1)  = naxis1
         naxes(2)  = naxis2
         naxes(3)  = ngroups
         zerofram  = .false.
c         zerofram  = .true.
      else
c         bitpix    = 20
         naxis     =  4
         naxes(1)  = naxis1
         naxes(2)  = naxis2
         naxes(3)  = ngroups
         naxes(4)  = nints
         zerofram  = .true.
c         zerofram  = .false.
      end if
c     
c************************************************************************
c
c     Read source catalogues 
c
c************************************************************************
      if(verbose.gt.0) print *,'read catalogues'
c      if(include_galaxies .eq. 1 .and. ngal .gt. 0) then 
c
c      call read_fake_mag_cat(galaxy_catalogue, use_filter,cat_filter, 
c     &     filters_in_cat, catalogue_filters_used, ngal)
!
      print *,'guitarra: galaxy_catalogue ', galaxy_catalogue
      print *,'guitarra: clone_cat ', clone_cat
      call new_read_fake_mag_cat(galaxy_catalogue, clone_cat,
     &     use_filter, cat_filter,filters_in_cat,
     &     catalogue_filters_used,
     &     galaxy, ngal, max_objects, include_cloned_galaxies)
!
!=====================================================================
!     
!     read list of clone templates
!      
c      if(include_cloned_galaxies.eq.1) then
         hst_level = 5          ! this should be an input parameter
c         print *,'clone_cat ', clone_cat
c         call read_clone(clone_match, clone_cat,
c     &        use_filter, clone, nclone,
c     &        filters_in_cat, max_objects)
c      end if

!     
!     uncomment to read multiple Sersic components.
!     For now use the kludge where each component occupies
!     a single line
!      call read_multicomponent(galaxy_catalogue, cat_filter, 
!     &     filters_in_cat, catalogue_filters_used, ngal)
!
      print *,'filters in cat,catalogue_filters_used, use_filter,ngal', 
     &     filters_in_cat,catalogue_filters_used, use_filter, ngal
      close(7)
      close(8)
      close(9)
c
c======================================================================
c     
c     read IPC 
c
      if(include_ipc .eq.1) then
         ipc_name =
     &        guitarra_aux(1:len_trim(guitarra_aux))//ipc_file(sca_num) 
         call read_ipc(ipc_name, ipc)
c         do jj = 1, 3
c            print *, (ipc(ii,jj), ii = 1, 3)
c         end do
      else
         ipc_name = 'none'
         ipc(1,1) = 0.0d0
         ipc(1,2) = 0.0d0
         ipc(1,3) = 0.0d0
         ipc(2,1) = 0.0d0
         ipc(2,1) = 1.0d0
         ipc(2,3) = 0.0d0
         ipc(3,1) = 0.0d0
         ipc(3,1) = 0.0d0
         ipc(3,3) = 0.0d0
      end if
c     
c======================================================================
c     
c     read flatfield
c
      if(include_flat .eq. 1) then
         call read_funky_fits(flat_file,flat_image, nx, ny, 2,verbose)
      else
         flat_file = 'NONE'
      end if
c
c
c=======================================================================
c
c     Start simulation
c
c=======================================================================
c
c     Initialise the random number generator. Seed value is set in
c     the perl script such that 
c     seed value       effect
c        0          the system clock will be used to seed random numbers.
c        1          random numbers follow a deterministic sequence
c
      call zbqlini(seed)
c
c=======================================================================
c
c     If a dark ramp is being used, pick one randomly
c
      if(include_dark_ramp.eq.1) then
         call pick_dark_ramp(sca_id,dark_ramp, verbose)
      else
         dark_ramp          = 'NONE '
      end if
      print *,'guitarra: will use dark_ramp ', dark_ramp
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
c     Read calibration files
c
      call read_sca_calib(sca_id,
     &     biasfile, darkfile, sigmafile, 
     &     welldepthfile, gainfile, linearityfile, badpixelmask,
     &     verbose)
         darkfile = 'NONE '
      if(include_bias .eq.0) biasfile = 'NONE '
      if(include_dark .eq.0) then 
         darkfile = 'NONE '
         sigmafile = 'NONE '
      end if
      if(include_non_linear .eq.0) linearityfile = 'NONE '
c      
c======================================================================
c======================================================================
c
c     Open the fits data hyper-cube, write header
c
      open(9,file =cr_history)
      write(9, 1130)
 1130 format('# readout_number, x_pix, y_pix, cr_e-, cr_adu, cr_MeV,',
     &     1x,'ion (0=H, 1=He, 2=C, 3=N, 4=O, 5=Fe)')
c
      simple = .true.
      extend = .true.
c
      if(dhas.eq.1 .and.nints.eq.1) then
         if(verbose.gt.0) 
     &        print *,'going to call data_model_fits ', cube_name
         call data_model_fits(iunit, cube_name, verbose)
         if (status .gt. 0) then
            call printerror(status)
            if(verbose.ge.1) print *, 'ftpscl: ',status
         end if
         if(verbose .gt.0) then
            print *,'exited data_model_fits'
            print *, latent_file
            print *,'header number is ', hdn
            print *,'going to call write_dhas_header : ', cube_name
         end if
      endif
c
      if(dhas.eq.1 .and. nints.gt.1) then
c
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
         bitpix    = 16
         naxis     = 4
         naxes(1)  = naxis1
         naxes(2)  = naxis2
         naxes(3)  = ngroups
         naxes(4)  = nints
      end if
c      
c=======================================================================
c     
c     write header information in first extension
c
      if(subarray .ne. 'FULL') then
         crpix1_subarray = 0.5d0 +  dble(naxis1)/2.d0 
         crpix2_subarray = 0.5d0 +  dble(naxis2)/2.d0
      else
         crpix1_subarray =  crpix1
         crpix2_subarray =  crpix2
      end if
c      call write_dhas_header
      call write_dhas_header
     *     (iunit, nx, ny, 
     *     bitpix, naxis, naxes, pcount, gcount, cube_name,
     *     title, pi_name, category, subcat, scicat, cont_id,
     *     full_date,
     *     date_obs, time_obs, date_end, time_end, obs_id,
     *     visit_id, program_id, observtn, visit, obslabel,
     *     visitgrp, seq_id, act_id, exposure_request, template,
     *     eng_qual, visitype, vststart, nexposur, intarget,
     *     targoopp, targprop, targ_ra, targ_dec, 
     *     targura, targudec, mu_ra, mu_dec, mu_epoch,
     *     prop_ra, prop_dec, 
     *     instrume, module, channel, filter_id, coronmsk,
     *     pilin,
     *     effexptm, duration, bzero, bscale,
     *     pntg_seq, expcount, expripar, tsovisit, expstart,
     *     expmid, expend, readout_pattern, nints, ngroups, groupgap,
     *     tframe, tgroup, effinttm, exptime,nrststrt, nresets, 
     *     zerofram, sca_num, drpfrms1, drpfrms3,
     *     subarray, colcornr, rowcornr, naxis1, naxis2,
     *     substrt1, substrt2, 
     *     fastaxis, slowaxis, n_outputs, 
     &     patttype,  primary_dither_string, primary_total, patt_num,
     &     subpixel,  subpxpns, subpixel_position,
     *     xoffset, yoffset,
     *     jwst_x, jwst_y, jwst_z, jwst_dx, jwst_dy, jwst_dz,
     *     apername,  pa_aper, pps_aper, pa_v3,
     *     dva_ra,  dva_dec, va_scale,
     *     bartdelt, bstrtime, bendtime, bmidtime,
     *     helidelt, hstrtime, hendtime, hmidtime,
     *     photmjsr, photuja2, pixar_sr, pixar_a2,
     *     wcsaxes, distortion, siaf_version,
     *     crpix1_subarray, crpix2_subarray,
     *     crpix3, crval1, crval2, crval3,
     *     cdelt1, cdelt2, cdelt3, cunit1, cunit2, cunit3,
     *     ctype1, ctype2,
     *     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2,
     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3, equinox,
c     *     ra0, dec0, roll_ref, v2_ref, v3_ref, 
     *     ra_sca, dec_sca, roll_ref, v2_ref, v3_ref, 
     *     v_idl_parity, v3_idl_yang,
     *     det_sci_parity, det_sci_yangle,
     &     a_order, aa, b_order, bb,
     &     ap_order, ap, bp_order, bp, 
     &     nframes, object, sca_id,
     &     photplam, photflam, stmag, abmag, vega_zp,
     &     naxis1, naxis2,
     &     noiseless, include_ipc, include_bias,
     &     include_ktc, include_bg, include_cr, include_dark,
     &     include_dark_ramp,
     &     include_latents, include_readnoise, include_non_linear,
     &     include_flat, version,
     &     ktc(sca_num),voltage_offset(sca_num),voltage_sigma(sca_num),
     &     gain(sca_num),readnoise, background,
     &     dark_ramp, biasfile, darkfile, sigmafile, 
     &     welldepthfile, gainfile, linearityfile, 
     &     badpixelmask, ipc_name, flat_file,
     &     seed, dhas, origin, verbose)
      if(verbose.gt.0) print *,'exit write_dhas_header'
c      object = obs_id
c
c=======================================================================
c
c     output into format understood by STScI reduction pipeline
c     EXTNUM = 0 contains only keywords
c
      if(write_tute.eq.1) then
         extnum = 0
         extname = 'Primary'
         tute_naxis    = 4
         tute_naxes(1) = naxes(1)
         tute_naxes(2) = naxes(2)
         tute_naxes(3) = ngroups
         tute_naxes(4) = nints
         wcsaxes       = 2
         ctype1        = 'RA---TAN'
         ctype2        = 'DEC--TAN'
         tute_distortion    = 2
         nexposur      =  0
         call write_dms_header(
     &        tute_name,tute_unit, nx, ny, 
     *        bitpix, naxis, naxes, pcount, gcount, tute_name,
     *        title, pi_name, category, subcat, scicat, cont_id,
     *        full_date,
     *        date_obs, time_obs, date_end, time_end, obs_id,
     *        visit_id, program_id, observtn, visit, obslabel,
     *        visitgrp, seq_id, act_id, exposure_request, template,
     *        eng_qual, visitype, vststart, nexposur, intarget,
     *        targoopp, targprop, targ_ra, targ_dec, 
     *        targura, targudec, mu_ra, mu_dec, mu_epoch,
     *        prop_ra, prop_dec, 
     *        instrume, module, channel, filter_id, coronmsk,
     *        pilin,
     *        effexptm, duration, bzero, bscale,
     *        pntg_seq, expcount, expripar, tsovisit, expstart,
     *        expmid, expend, readout_pattern, nints, ngroups, groupgap,
     *        tframe, tgroup, effinttm, exptime,nrststrt, nresets, 
     *        zerofram, sca_num, drpfrms1, drpfrms3,
     *        subarray, substrt1, substrt2, subsize1, subsize2,
     *        fastaxis, slowaxis, n_outputs,
     &        patttype,primary_dither_string, numdthpt, patt_num, 
     &        subpixel,  subpxpns, subpixel_position,
     *        xoffset, yoffset,
     *        jwst_x, jwst_y, jwst_z, jwst_dx, jwst_dy, jwst_dz,
     *        apername,  pa_aper, pps_aper, pa_v3,
     *        dva_ra,  dva_dec, va_scale,
     *        bartdelt, bstrtime, bendtime, bmidtime,
     *        helidelt, hstrtime, hendtime, hmidtime,
     *        photmjsr, photuja2, pixar_sr, pixar_a2,
     *        wcsaxes, tute_distortion, siaf_version,
c     *        crpix1, crpix2, crpix3, crval1, crval2, crval3,
     *        x_sci_ref, y_sci_ref, crpix3, crval1, crval2, crval3,
     *        cdelt1, cdelt2, cdelt3, cunit1, cunit2, cunit3,
     *        ctype1, ctype2,
     *        pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2, 
     *        cd1_1, cd1_2, cd2_1, cd2_2, cd3_3, equinox,
     *        ra_ref, dec_ref, roll_ref, v2_ref, v3_ref, 
     *        v_idl_parity, v3_idl_yang,
     *        det_sci_parity, det_sci_yangle,    
     &        a_order, aa, b_order, bb,
     &        ap_order, ap, bp_order, bp, 
     &        nframes, object, sca_id,
     &        photplam, photflam, stmag, abmag,vega_zp,
     &        naxis1, naxis2,
     &        noiseless, include_ipc, include_bias,
     &        include_ktc, include_bg, include_cr, include_dark,
     &        include_dark_ramp,
     &        include_latents, include_readnoise, include_non_linear,
     &        include_flat, version,
     &        ktc,bias_value,voltage_sigma,
     &        gain,readnoise, background,
     &        dark_ramp,     
     &        biasfile, darkfile, sigmafile, 
     &        welldepthfile, gainfile, linearityfile,
     &        badpixelmask, ipc_file, flat_file,
     &        seed, dhas, origin,extnum, extname, verbose)
         if(verbose.gt.0) print *,'exit write_dms_header'
      end if
c
c=======================================================================
c
c     Initialise arrays
c
      time_counter = 0
      mirage_counter = 0
      do 500 nint_level = 1, nints
c     print *,'=========================='
         image_3d = 0
c         do im = 1, max_nint
cc         IM = nint_level
c         do k = 1, 20
c            do j = 1, 2048
c               do i =1, 2048
c                  image_3d(i,j,k) = 0
c                  zero_frames(i,j) = 0
c               end do
c            end do
c         end do
c         end do
         
         zero_frames = 0.0
         if(nints .gt.1) print *,' nint_level ', nint_level, 
     &        ' of ', nints
c
c     additional STScI pipeline keyword material
c         
         call get_date_time(date_obs, time_obs)
         read(date_obs, 130) year, month, day
         read(time_obs,120) ih, im, sec
c
c     calculate UT
c
         call julian_day(year, month, day, ut, jday, mjd)
         ut = ih + im/60.d0 + sec/3600.d0
         mjd_utc(1,nint_level) = mjd+ut/24.d0
         bjd_tbd(1,nint_level) = mjd+ut/24.d0
c     
c     Start by adding the detector footprint
c         
         call sca_footprint(sca_id, noiseless, naxis1, naxis2,
     &        include_bias, include_ktc, include_latents,
     &        include_non_linear, brain_dead_test, include_1_over_f,
     &        latent_file, idither, voltage_offset, verbose)
         print *, 'exit sca_footprint: image has been initialised'
c     
c     sample up the ramp
c
         print *,'+++ '
         print *,'+++ creating scene: ', trim(cube_name)
         print *,'+++ '
         call new_ramp(idither, ra0, dec0,
     *        pa_degrees,
     *        cube_name, noise_file,
     *        sca_id, module, brain_dead_test, 
     *        xc, yc, pa_v3, osim_scale,scale, 
     *        include_ipc,
     *        include_ktc, include_dark, include_dark_ramp, 
     *        include_readnoise, 
     *        include_reference, include_flat,
     *        include_1_over_f, include_latents, include_non_linear,
     *        include_cr, cr_mode, include_bg,
     *        include_stars, include_galaxies, include_cloned_galaxies,
     *        nstars, ngal,
     *        bitpix, ngroups, nframes, nskip, tframe, tgroup, object,
     *        nints,
     *        subarray, colcornr, rowcornr, naxis1, naxis2,
     *        filter_id, wavelength, bandwidth, system_transmission,
     *        mirror_area, photplam, photflam, stmag, abmag,
     *        background, icat_f,use_filter, npsf, psf_file, 
     *        dark_ramp,
     *        over_sampling_rate, noiseless, psf_add, 
     *        distortion, precise, attitude_inv,
     &        sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &        ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &        x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &        det_sci_yangle, det_sci_parity,
     &        v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &        aa, a_order, bb, b_order,
     &        ap, ap_order, bp, bp_order, det_sign,
     &        group_end_time, time_counter,
     &        galaxy, hst_level, max_objects,
     *        verbose)
c
c     STScI pipeline compatibility arrays
c         
         do ii = 1, ngroups
            mirage_counter = mirage_counter + 1
            columns(mirage_counter) = naxis1-colcornr+1
            rows(mirage_counter)    = naxis2-rowcornr+1
            gaps(mirage_counter)    = nskip
         end do
         mirage_exptime =
     &        total_time(nframes, groupgap, ngroups, 1, tframe,verbose)
c
c     These are _inconsistent_ with group end time
c     Ideally one should change group_end_time it is is compatible
c     with this. Only worth it _IF_ it makes a difference when
c     reducing with the STScI pipeline
c         
         mjd_utc(2,nint_level) = mjd_utc(1,nint_level) +
     &        mirage_exptime/86400.d0/2.d0
         bjd_tbd(2,nint_level) = mjd_utc(2,nint_level)
c
         mjd_utc(3,nint_level) = mjd_utc(1,nint_level) +
     &        mirage_exptime/86400.d0
         bjd_tbd(3,nint_level) = mjd_utc(3,nint_level)
         if(verbose .gt.0) then
            print *,'exited new_ramp'
         end if
c
c-----------------------------------------------------------------------
c-----------------------------------------------------------------------
c         
c     Output for file format compatible with current DHAS and NINTS == 1
c     
         if(dhas.eq.1 .and. nints.eq.1) then
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
                     int_image(i,j,k) = image_3d(i, j, k)
                     if(int_image(i,j,k) .gt. 65535) then
                        int_image(i,j,k) = 65535
c                        print *, i, j, k, image_3d(i,j,k)
                     end if
                     if(int_image(i,j,k) .lt.0) then
                        int_image(i,j,k) = 0
                     end if
                  end do
               end do
            end do
c     these keywords are added when writing the file header
c            comment = 'Scale data by       '
c            call ftpkyd(iunit,'BSCALE',bscale,-7,comment,status)
c            if (status .gt. 0) then
c               print *,'BSCALE'
c               call printerror(status)
c            end if
c            status = 0
cc     
c            comment = ' BSCALE * image + BZERO'
c            call ftpkyd(iunit,'BZERO',bzero,-7,comment,status)
c            if (status .gt. 0) then
c               print *,'BZERO'
c               call printerror(status)
c            end if
c            status = 0
c
            call ftpscl(iunit, bscale, bzero,status)
            if (status .gt. 0) then
               print *,'at ftpscl for dhas =', dhas, status
               call printerror(status)
            end if
            
            call ftp3dj(iunit, group, nnn, nnn, naxes(1), naxes(2), 
     &           naxes(3),int_image, status)
         end if
c
c-----------------------------------------------------------------------
c
c     DHAS output for NINTS > 1
c         
         if(dhas.eq.1 .and.nints.gt.1) then
            call ftghdn(iunit, hdn)
c            print *,'guitarra: header number is ', hdn, 'naxis ',naxis,
c     &           'naxes',naxes,' nint_level ', nint_level
            status = 0
c     
            nullval    = 0
            fpixels(1) = 1
            lpixels(1) = nnn
            fpixels(2) = 1
            lpixels(2) = nnn
            fpixels(4) = nint_level
            lpixels(4) = nint_level
c
            if(nint_level .eq.1) then
               status = 0
               extname = 'SCI'           
               comment = 'Extension name'
               call ftpkys(iunit,'EXTNAME',extname,comment,status)
               if (status .gt. 0) then
                  print *,'at EXTNAME'
                  call printerror(status)
               end if
c               comment = 'Scale data by '
c               call ftpkyd(iunit,'BSCALE',bscale,-7,comment,status)
c               if (status .gt. 0) then
c                  print *,'BSCALE'
c                  call printerror(status)
c               end if
c               status = 0
cc     
c               comment = ' BSCALE * image + BZERO'
c               call ftpkyd(iunit,'BZERO',bzero,-7,comment,status)
c               if (status .gt. 0) then
c                  print *,' BZERO'
c                  call printerror(status)
c               end if
c               status = 0
            end if
c     
c     store this ramp; since ftpssj does 
c     "transfer a rectangular subset of the pixels in a 
c     FITS N-dimensional image"
c     copy each group
c
            do ll = 1, naxes(3)
               fpixels(3) = ll
               lpixels(3) = ll
c               do jj = fpixels(2), lpixels(2)
c                  do ii = fpixels(1), lpixels(1)
               do jj = 1,  naxis2
                  j = jj + rowcornr - 1
                  do ii = 1, naxis2
                     i = ii + colcornr - 1 
                     plane(ii,jj) = image_3d(i,j,ll) 
                     scratch(i,j) = image_3d(i,j,ll) 
c                     if(i.eq.1978 .and.j.eq.71)
c     &                    print *, ii,jj, i, j, nint_level, plane(ii,jj)
c     if(ii.eq.jj) print *, ii,jj, ll,
c     &                    image_3d(ii,jj,ll),plane(ii,jj)
c     
c     if this kludge is not carried out, ftpssj will complain
c     of overflow and write an image with zeros or +/-32K . 
c     This limits legal values to  0 <= value <= 65535
c     
                     if(plane(ii,jj) .gt.  65535) then
                        plane(ii,jj) = 65535
                     end if
                     if(plane(ii,jj) .lt. 0) then
                        plane(ii,jj) = 0
                     end if
                  end do
               end do
c     
               if(nint_level .eq.1 .and. ll.eq.1) then
                  if(verbose .gt.0) then
                     print *,'DHAS: bzero bscale bitpix, nints',
     &                    bzero, bscale,bitpix, nints
                  end if
                  call ftpscl(iunit, bscale, bzero, status)
                  if (status .gt. 0) then
                     print *, 'guitarra: ftpscl for dhas =: ',
     &                    dhas,status
                     call printerror(status)
                     status = 0
                  end if
               end if
               group = 1
               status = 0
c               print *,'guitarra: writing NINTS DHAS', nint_level
               call ftpssj(iunit, group, naxis, naxes, fpixels, lpixels,
     &              plane, status)
               if (status .gt. 0) then
                  print *,'at ftpssj for ll =', ll, ' extnum ',extnum
                  call printerror(status)
                  print *,' quitting'
                  stop
               end if
               status = 0
c     monitor output using a test image
c               if(nint_level.eq. 1 .and. ll.eq.naxes(3)) then
c                  call write_float_2d_image('junk.fits', scratch,
c     &                 nnn, nnn,subarray, colcornr, rowcornr)
c               end if
            end do
         end if
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Output in format compatible with STScI pipeline
c     this will add a new extension when extension = 1
c     and fill in the appropriate header.
c     The fourth axis corresponds to individual NINTs
c
         if(write_tute.eq.1) then
            if(nint_level.eq.1) then
               call ftthdu(tute_unit, nhdu, status) ! # of HDU
               call ftghdn(tute_unit, hdn) ! current HDU
               call ftghdt(tute_unit, hdutype, status)
               print *,'guitarra: DMS #, hdn, type', nhdu, hdn, hdutype
               extname = 'SCI'
               extnum  =  1
               print *,'guitarra: write DMS extnum', extnum,' ', extname
               status = 0
               bitpix     = 16
               tute_naxis = 4
               tute_naxes(1) = naxes(1)
               tute_naxes(2) = naxes(2)
               tute_naxes(3) = ngroups
               tute_naxes(4) = nints
               tute_distortion = 2
               pc1_1_dms  = pc1_1/(det_sci_parity*det_sign)
               pc1_2_dms  = pc1_2/det_sign
               pc2_1_dms  = pc2_1/(det_sci_parity*det_sign)
               pc2_2_dms  = pc2_2/det_sign
c
               call write_dms_header(
     &        tute_name, tute_unit, nx, ny, 
     *        bitpix, tute_naxis, tute_naxes, pcount, gcount, tute_name,
     *        title, pi_name, category, subcat, scicat, cont_id,
     *        full_date,
     *        date_obs, time_obs, date_end, time_end, obs_id,
     *        visit_id, program_id, observtn, visit, obslabel,
     *        visitgrp, seq_id, act_id, exposure_request, template,
     *        eng_qual, visitype, vststart, nexposur, intarget,
     *        targoopp, targprop, targ_ra, targ_dec, 
     *        targura, targudec, mu_ra, mu_dec, mu_epoch,
     *        prop_ra, prop_dec, 
     *        instrume, module, channel, filter_id, coronmsk,
     *        pilin,
     *        effexptm, duration, bzero, bscale,
     *        pntg_seq, expcount, expripar, tsovisit, expstart,
     *        expmid, expend, readout_pattern, nints, ngroups, groupgap,
     *        tframe, tgroup, effinttm, exptime,nrststrt, nresets, 
     *        zerofram, sca_num, drpfrms1, drpfrms3,
     *        subarray, substrt1, substrt2, subsize1, subsize2,
     *        fastaxis, slowaxis, n_outputs,
     &        patttype,primary_dither_string, numdthpt, patt_num, 
     &        subpixel,  subpxpns, subpixel_position,
     *        xoffset, yoffset,
     *        jwst_x, jwst_y, jwst_z, jwst_dx, jwst_dy, jwst_dz,
     *        apername,  pa_aper, pps_aper, pa_v3,
     *        dva_ra,  dva_dec, va_scale,
     *        bartdelt, bstrtime, bendtime, bmidtime,
     *        helidelt, hstrtime, hendtime, hmidtime,
     *        photmjsr, photuja2, pixar_sr, pixar_a2,
     *        wcsaxes, tute_distortion, siaf_version,
c     *        crpix1, crpix2, crpix3, crval1, crval2, crval3,
     *        x_sci_ref, y_sci_ref, crpix3, crval1, crval2, crval3,
     *        cdelt1, cdelt2, cdelt3, cunit1, cunit2, cunit3,
     *        ctype1, ctype2,
     *        pc1_1_dms, pc1_2_dms, pc2_1_dms, pc2_2_dms, pc3_1, pc3_2, 
     *        cd1_1, cd1_2, cd2_1, cd2_2, cd3_3, equinox,
     *        ra_ref, dec_ref, roll_ref, v2_ref, v3_ref, 
     *              v_idl_parity, v3_idl_yang,
     &          det_sci_parity, det_sci_yangle,
     &        a_order, aa, b_order, bb,
     &        ap_order, ap, bp_order, bp, 
     &        nframes, object, sca_id,
     &        photplam, photflam, stmag, abmag,vega_zp,
     &        naxis1, naxis2,
     &        noiseless, include_ipc, include_bias,
     &        include_ktc, include_bg, include_cr, include_dark,
     &        include_dark_ramp,
     &        include_latents, include_readnoise, include_non_linear,
     &        include_flat, version,
     &        ktc,bias_value,voltage_sigma,
     &        gain,readnoise, background,
     &        dark_ramp,     
     &        biasfile, darkfile, sigmafile, 
     &        welldepthfile, gainfile, linearityfile,
     &        badpixelmask, ipc_file, flat_file,
     &        seed, dhas, origin,extnum, extname, verbose)
               if(verbose.gt.0)
     &              print *,'exit write_dms_header extnum: ', extnum

               keyword = 'EXTNAME'
               value   = 'SCI'
               call ftpkys(tute_unit,keyword, trim(value),
     &              comment, status)
               if (status .gt. 0) then
                  print *,'guitarra : ', keyword, ' ',status
                  call printerror(status)
                  status = 0
               end if
               comment = 'Scale data by '
               call ftpkyd(tute_unit,'BSCALE',bscale,-7,
     &              comment,status)
               if (status .gt. 0) then
                  print *,'BSCALE'
                  call printerror(status)
               end if
               status = 0
c     
               comment = ' BSCALE * image + BZERO'
               call ftpkyd(tute_unit,'BZERO',bzero,-7,comment,status)
               if (status .gt. 0) then
                  print *,' BZERO'
                  call printerror(status)
                  status = 0
               end if
               call ftpscl(tute_unit, bscale, bzero, status)
               if (status .gt. 0) then
                  print *, 'guitarra: ftpscl for DMS =: ',
     &                 dhas,status
                  call printerror(status)
               end if
            end if              ! close nint_level eq 1
            call ftthdu(tute_unit, nhdu, status)
            call ftghdn(tute_unit, hdn) 
            call ftmahd(tute_unit,nhdu, hdutype,status) 
            print *,'guitarra: DMS #, hdn, type', nhdu, hdn,hdutype
c     
            nullval    = 0
            fpixels(1) = 1
            lpixels(1) = nnn
            fpixels(2) = 1
            lpixels(2) = nnn
            fpixels(4) = nint_level
            lpixels(4) = nint_level
c
c     copy each plane
c     
            do ll = 1, tute_naxes(3)
               fpixels(3) = ll
               lpixels(3) = ll
               plane      = 0
               do jj = 1, naxis2
                  j = rowcornr +jj- 1
                  nn =idint(det_sign*(j-y_det_ref)+y_sci_ref)
                  do ii = 1, naxis1
                     i = colcornr +ii -1
                     mm= 
     &          idint(det_sci_parity*det_sign*(i-x_det_ref)+x_sci_ref)
c                     if(mod(jj,40).eq.1 .and. mod(ii,40).eq.1) then
c                        print *, "ii, jj, i, j, mm, nn",
c     &                       ii, jj, i, j, mm, nn
c                     end if
                     if(mm.le.0 .or. nn.le.0) then
                        print *, ' Aperture ', aperture
                        print *, ' subarray ', subarray
                        print *, ll, jj, ii, mm, nn
                        print *,'colcornr, rowcornr', colcornr, rowcornr
                        print *, ' mm, nn ', mm, nn
                        print *, ' x_det_ref, y_det_ref',
     &                       x_det_ref, y_det_ref
                        print *, ' x_sci_ref, y_sci_ref',
     &                       x_sci_ref, y_sci_ref
                        print *, ' Something is not correct'
                        print *, 'quitting'
                        stop
                     endif
c     set negative or very large pixel values to "legal" min and max
                     plane(mm,nn) = image_3d(i,j,ll)
                     if(plane(mm,nn) .gt.  65535) then
                        plane(mm,nn) = 65535
c                        print *, i, j, ll, image_3d(i,j,ll)
                     end if
                     if(plane(mm,nn) .lt. 0) then
                        plane(mm,nn) = 0
c                        print *, i, j, ll, image_3d(i,j,ll)
                     end if
                  end do
               end do
c               print *,'guitarra: enter DMS ftpssj nint_level',
c     &              nint_level, tute_unit,tute_naxis, tute_naxes,
c     &              fpixels, lpixels
               group  = 1
               status = 0
               call ftpssj(tute_unit, group, tute_naxis, tute_naxes, 
     &              fpixels, lpixels, plane, status)
               if (status .gt. 0) then
                  print *,'at ftpssj for ll =', ll, ' for extnum',extnum
                  call printerror(status)
                  print *, 'quitting'
                  stop
               end if
               status = 0
            end do
         endif                  ! closes write_tute
c     
 200     continue
 500  continue
c     close the loop over nint_level =1, nints
c     
c----------------------------------------------------------------------
c     
c     write the zero'th frame for DHAS
c
      if(zerofram .eqv. .true.) then
         if(nints.gt.1) then
            extnum  = 2
         else
            extnum = 1
         end if
         verbose = 1
         dms     = .false.
         call write_zero_frame(iunit, extnum, naxis1, naxis2, nints,
     *        nnn, max_nint, int_image, zero_frames, 
     *        det_sci_parity, det_sign, 
     &        x_det_ref, y_det_ref,
     &        x_sci_ref, y_sci_ref, x_sci_size, y_sci_size,
     &        dms, verbose)
         verbose = 0
      end if
c
c----------------------------------------------------------------------
c
c     write zero'th frame  for each nint
c
      if(write_tute.eq.1) then
         verbose = 0
         dms    = .true.
         extnum = 2
         print *,'guitarra: write DMS extnum', extnum
         call write_zero_frame(tute_unit, extnum, tute_naxes(1),
     &        tute_naxes(2), nints,
     *        nnn, max_nint, int_image, zero_frames, 
     *        det_sci_parity, det_sign, 
     &        x_det_ref, y_det_ref,
     &        x_sci_ref, y_sci_ref, x_sci_size, y_sci_size,
     &        dms,1)
c     &        dms,verbose)
         
c     
c     Extension 3: group data
c         
         print *,'guitarra: write DMS extnum 3'
         print *,' mirage_counter, time_counter ',
     &        mirage_counter, time_counter, nints, ngroups
         call group_header(tute_unit, nints, ngroups,
     &        columns, rows, gaps,
     &        group_end_time, time_counter, verbose)

c     Extension 4: integration time data
c         
         print *,'DMS header 4 : times '
         call int_times_header(tute_unit,mjd_utc, bjd_tbd,
     &        nints, verbose)
c
c     Extension 5: ASDF metadata
c
         print *,'DMS header 5 : asdf '
         call asdf_header
     *        (tute_unit, nx, ny, 
     *        bitpix, tute_naxis, tute_naxes, tute_name,
     *        title, pi_name, category, subcat, scicat, cont_id,
     *        full_date,
     *        date_obs, time_obs, date_end, time_end, obs_id,
     *        visit_id, program_id, observtn, visit, obslabel,
     *        visitgrp, seq_id, act_id, exposure_request, template,
     *        eng_qual, visitype, vststart, nexposur, intarget,
     *        targoopp, targprop, targ_ra, targ_dec, 
     *        targura, targudec, mu_ra, mu_dec, mu_epoch,
     *        prop_ra, prop_dec, 
     *        instrume, module, channel, filter_id, coronmsk,
     *        pupil, detector,
     *        effexptm, duration,
     *        pntg_seq, expcount, expripar, tsovisit, expstart,
     *        expmid, expend, readout_pattern, nints, ngroups, groupgap,
     *        tframe, tgroup, effinttm, exptime,nrststrt, nresets, 
     *        zerofram, sca_num, drpfrms1, drpfrms3,
     *        subarray,  colcornr, rowcornr, subsize1, subsize2,
     *        substrt1,substrt2, fastaxis, slowaxis, n_outputs,
     &        patttype, primary_dither_string, numdthpt, patt_num, 
     &        subpixel,  subpxpns, subpixel_position,
     &        subpixel_dither_type,
     *        xoffset, yoffset,
     *        jwst_x, jwst_y, jwst_z, jwst_dx, jwst_dy, jwst_dz,
     *        apername,  pa_aper, pps_aper, pa_v3,
     *        dva_ra,  dva_dec, va_scale,
     *        bartdelt, bstrtime, bendtime, bmidtime,
     *        helidelt, hstrtime, hendtime, hmidtime,
     *        photmjsr, photuja2, pixar_sr, pixar_a2,
     *        wcsaxes, distortion, siaf_version,
     *        crpix1, crpix2, crpix3, crval1, crval2, crval3,
     *        cdelt1, cdelt2, cdelt3, cunit1, cunit2, cunit3,
     *        ctype1, ctype2,
c     *     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2, 
c     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3, equinox,
     *        ra_ref, dec_ref, roll_ref, v2_ref, v3_ref, ra_v1, dec_v1,
     *        v_idl_parity, v3_idl_yang,
     *        det_sci_parity, det_sci_yangle,
c     &     a_order, aa, b_order, bb,
c     &     ap_order, ap, bp_order, bp, 
     &        nframes, object, sca_id,
c     &     photplam, photflam, stmag, abmag,vega_zp,
     &        naxis1, naxis2,
c     &     noiseless, include_ipc, include_bias,
c     &     include_ktc, include_bg, include_cr, include_dark,
c     &     include_dark_ramp,
c     &     include_latents, include_readnoise, include_non_linear,
c     &     include_flat,
     &        version,
c     &     ktc,bias_value,voltage_sigma,
     &        gain_cv3(sca_num),read_noise_cv3(sca_num), background,
c     &     dark_ramp,     
c     &     biasfile, darkfile, sigmafile, 
c     &     welldepthfile, gainfile, linearityfile,
c     &     badpixelmask, ipc_file, flat_file,
c     &     seed, dhas, origin,
     &        x_sci_ref, y_sci_ref, radesys,
     &        verbose)
c     
         CALL FTFLUS(tute_unit, status)
      end if

      call closefits(iunit)
      close(9)
      print *, 'Exposure complete! Output file(s) is(are)'
      print *, trim(cube_name)
      if(write_tute.eq.1)  then
         call closefits(tute_unit)
         print *, trim(tute_name)
      end if
      write(test_name,1100) filter_id,iabs(sca_id),idither
 1100 format('sim_',a5,'_',i3.3,'_',i3.3,'.fits')
c
      stop
c
 999  continue
      print *,'Error in guitarra.f: '
      print *,'Please verify if '
      print *,'one is using a SW filter for a LW detector'
      print *,'or'
      print *,'one is using a LW filter for a SW detector'
      print *,'this will require fixing the preparation script'
      stop
      end
      
