      subroutine jwst_keywords
     *     (iunit, nx, ny, 
     *     bitpix, naxis, naxes, pcount, gcount, filename,
     *     title, pi_name, category, subcat, scicat, cont_id,
     *     full_date,
     *     date_obs, time_obs, date_end, time_end, obs_id,
     *     visit_id, program_id, observtn, visit, obslabel,
     *     visitgrp, seq_id, act_id, exposure, template,
     *     eng_qual, visitype, vststart, nexposur, intarget,
     *     targoopp, targprop, targ_ra, targ_dec, 
     *     targura, targudec, mu_ra, mu_dec, mu_epoch,
     *     prop_ra, prop_dec, 
     *     instrume, module, channel, filter_id, coronmsk,
     *     pilin,
     *     effexptm, duration,
     *     pntg_seq, expcount, expripar, tsovisit, expstart,
     *     expmid, expend, read_patt, nints, ngroups, groupgap,
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
     *     ra_ref, dec_ref, roll_ref, v2_ref, v3_ref, 
     *     vparity, v3i_yang,
     &     nframes, object, sca_id,
     &     photplam, photflam, stmag, abmag,
     &     naxis1, naxis2,
     &     noiseless,
     &     include_ktc, include_bg, include_cr, include_dark,
     &     include_latents, include_readnoise, include_non_linear,
     &     ktc,bias_value, readnoise, background, dhas, verbose)
c
c===========================================================================
c
      implicit none
c
c     Keywords from 
c     https://mast.stsci.edu/portal/Mashup/clients/jwkeywords/index.html
c     list as of  2018-02-07 (version JWSTDP-2018_1-180207)
c     re-examined 2019-03-26 (version JWSTDP-2019.1.0-95~3f0d4fc0)
c
c     NIRCam Imaging
c     standard and basic parameters
c
      logical simple, extend, dataprob, targcoopp, zerofram
      integer bitpix, naxis, naxis1, naxis2, naxis3, naxis4, pcount,
     &     gcount
      integer bzero
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
      character date_obs*10, time_obs*15, date_end*10, time_end*15,
     &     obs_id*26, visit_id*11, observtn*9, visit*11, obslabel*40,
     &     visitgrp*2, seq_id*1, act_id*1, exposure_request*5, 
     &     template*50, eng_qual*8, exposure*7, program_id*7
      logical bkgdtarg
c      integer program_id
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
     &     object*20, filter_id*8, coronmsk*20,
     &     pupil*8
      logical pilin
c
c     exposure parameters
c
      double precision expstart, expmid, expend, tsample,
     &     tframe, tgroup, effinttm, effexptm, duration
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
      character apername*12, pps_aper*40
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
     &     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2,cd3_3,
     &     ra_ref, dec_ref, roll_ref,
     &     v3i_yang, wavstart, wavend, sporder

      character ctype1*10, ctype2*10, ctype3*10,
     &     cunit1*40, cunit2*40, cunit3*40,
     &     s_region*100
c
c-----------------------------------------------------------------------
c
c     Non-STScI keywords
c
      double precision ktc,bias_value, readnoise, background, exptime
      double precision total_time, sec, ut, jday, mjd
      double precision photplam, photflam, stmag, abmag
      double precision cd1_1, cd1_2, cd2_1, cd2_2
      double precision equinox
      real image
      integer year, month, day, ih, im, dhas, verbose, status
      integer iunit, nx, ny, nz,  nnn, nskip, naxes, sca_id
      integer include_ktc, include_bg, include_cr, include_dark,
     *     include_latents, include_readnoise, include_non_linear
      integer   primary_position, primary_total, 
     &     subpixel_position, subpixel_total 
c     for compatibility with DHAS
      integer colcornr,rowcornr,ibrefrow,itrefrow,drop_frame_1
      character key*8, subarray*8,primary*16, subpixel*16, card*80,
     &     comment*40, full_date*23,string*40, pw_filter*8, fw_filter*8

      logical subarray_l, noiseless
c
      parameter (nnn=2048)
c      common /wcs/ equinox, 
c     *     crpix1, crpix2, crpix3,
c     *     crval1, crval2, crval3,
c     *     cdelt1, cdelt2, cdelt3,
c     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3,
c     *     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2/
c      common /wcs/ equinox, crpix1, crpix2, crval1, crval2,
c     *     cdelt1,cdelt2, cd1_1, cd1_2, cd2_1, cd2_2,
c     *     pc1_1, pc1_2, pc2_1, pc2_2
c
      dimension image(nnn,nnn),naxes(4), detector(10)
c
      data detector/'NRCA1','NRCA2','NRCA3','NRCA4','NRCALONG',
     &     'NRCB1','NRCB2','NRCB3','NRCB4','NRCBLONG'/
c
c     define the required primary array keywords
c
      if(verbose .ge.1) print *,'entered jwst_keywords'
      if(verbose .ge.2) print *,
     *     crpix1, crpix2, crpix3, crval1, crval2, crval3,
     *     cdelt1, cdelt2, cdelt3, cunit1, cunit2, cunit3,
     *     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2, 
     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3, equinox,
     *     ra_ref, dec_ref, roll_ref, v2_ref, v3_ref


      status   =  0

      simple   = .true.
      extend   = .true.
      pcount      = 0
      gcount      = 1
c
      naxis    = 2
      if(subarray .eq. 'FULL')  then 
         naxes(1) = nnn
         naxes(2) = nnn
      else
         naxes(1) = naxis1
         naxes(2) = naxis2
      end if
      subsize1  = naxis1
      subsize2  = naxis2
      if(ngroups.gt.1) then
         naxis    =  3
         naxes(3) = ngroups
      end if
c
      if(dhas.ne.1.or.nints.gt.1) then
         if(nints.gt.1) then
            naxis    =  4
            naxes(4) = nints
         end if
      end if
c
      wcsaxes     = 2
      apername    = 'NRCALL_FULL'
c
c     set pupil and filter filter wheel values correctly
c     for filters in series
c
      pw_filter = 'CLEAR'
      fw_filter = filter_id
c
      if(filter_id .eq. 'F162M' .or. filter_id .eq.'F164N') then
         fw_filter = 'F150W2'
         pw_filter = filter_id
      end if
c
      if(filter_id .eq. 'F323N') then
         fw_filter = 'F356W'
         pw_filter = filter_id
      end if
c
      if(filter_id .eq. 'F405N' .or. filter_id .eq.'F466N' .or.
     &     filter_id.eq. 'F470N') then
         fw_filter = 'F444W'
         pw_filter = filter_id
      end if
c
c==================================================================
c
c     1. Standard parameters
c
c     
      if(verbose.ge.2) print *,'jwst_keywords: ftphr'
      if(dhas.ne.1) then
c         call ftphpr(iunit,simple, 8, 0, 0, 
c     &        pcount,gcount,extend,status)
      else
c
c     Move to the primary FITS array
c
         call ftcrhd(iunit,status)
         if (status .gt. 0) then
            print *,'ftcrhd', status
            call printerror(status)
         end if         
         call ftphpr(iunit,simple, bitpix, naxis, naxes, 
     &        pcount,gcount,extend,status)
      end if
      if(verbose.ge.2) print *,'jwst_keywords: ftphr : status',status
      if (status .gt. 0) then
         print *, 'simple,bitpix,naxis'
         call printerror(status)
      end if
      status =  0
c
c-------------------------------------------------------------------
c
c     2. Basic Parameters
c
      string = full_date
      comment= 'Date this file was created (UTC)       '
      call ftpkys(iunit,'DATE',string,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, string
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ftpkys ', string
c
      string = 'AZ_LAB'
      comment= 'The organization that created the file '
      call ftpkys(iunit,'ORIGIN',string,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, string
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ftpkys ', string
c     
      string = 'UTC'
      comment= 'Reference time                         '
      call ftpkys(iunit,'TIMESYS',string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
       status =  0
       if(verbose.ge.2) print *,'jwst_keywords: ftpkys ', string
c     
       string = filename
       comment= 'file name                              '
       call ftpkys(iunit,'FILENAME',string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
       status =  0
       if(verbose.ge.2) print *,'jwst_keywords: ftpkys ', string
c
c     The test images downloaded from STScI show these as "raw"
c     string = 'uncalibrated'
c
      string = 'UNCALIBRATED'
      comment= 'type of data in the file               '
      call ftpkys(iunit,'FILETYPE',string,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, string
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ftpkys ', string
c
      string  = 'Guitarra'
      comment = 'The overhead-free telescope            '
      key     = 'TELESCOP'
      call ftpkys(iunit,key, string, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, string
 10      format(a80)
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ftpkys ', string
c
c-------------------------------------------------------------------
c
c     4. Coordinate system
c
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ftprec ', status
      card = '         Infomation about the coordinates in the file'
      call ftprec(iunit,card, status)
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ftprec ', status
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ftprec ', status
c
      comment  = 'Name of coordinate reference frame '
      string   = 'FK5'
      key      = 'RADESYS'
      call ftpkys(iunit,key, string,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ftpkys ', string
c
c-------------------------------------------------------------------
c     
c     Programatic information
c
      
      comment  = 'Proposal title '
      string   = title
      key = 'TITLE'
      call ftpkys(iunit,key, string,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ftpkys ', string
c
      comment  = 'Principal investigator name '
      call ftpkys(iunit,'PI_NAME', pi_name,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'PI_NAME'
       end if
       status =  0
c
      comment  = 'Program category '
      key = 'CATEGORY'
      call ftpkys(iunit,key, category,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, key
       end if
       status =  0
c
c
      comment  = 'Program sub-category '
      key = 'SUBCAT'
      call ftpkys(iunit,key, subcat,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, key
       end if
       status =  0
c
      comment  = 'Science category assigned by TAC '
      key = 'SCICAT'
      call ftpkys(iunit,key, scicat,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, key
       end if
       status =  0
c     
      comment='continuation of previous program'
      key = 'CONT_ID'
      call ftpkyj(iunit,key,cont_id,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, key
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ftpkyj ', key,' ',cont_id
c
c-------------------------------------------------------------------
c
c     5. Observation identifiers
c
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         Observation identifiers '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      string = date_obs
      comment= 'UTC date of start of exposure               '
      call ftpkys(iunit,'DATE-OBS',string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = time_obs
      comment= 'UTC time of start of exposure             '
      call ftpkys(iunit,'TIME-OBS',string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = date_end
      comment= 'UTC date of end of exposure               '
      key = 'DATE-END'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = time_end
      comment= 'UTC time of end  of exposure             '
      key = 'TIME-END'
      call ftpkys(iunit,key ,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = obs_id
      comment= 'Programmatic observation identifier      '
      key = 'OBS_ID'
      call ftpkys(iunit,key ,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = visit_id
      comment= 'Visit identifier                         '
      key = 'VISIT_ID'
      call ftpkys(iunit,key ,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = program_id
      comment= 'Program number                           '
      key = 'PROGRAM'
      call ftpkys(iunit,key ,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = observtn
      comment= 'Observation number                       '
      key = 'OBSERVTN'
      call ftpkys(iunit,key ,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = visit
      comment= 'Visit number                             '
      key = 'VISIT'
      call ftpkys(iunit,key ,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = obslabel
      comment= 'Proposer label for the observation      '
      key = 'OBSLABEL'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = visitgrp
      comment= 'Visit group identifier                  '
      key = 'VISITGRP'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = seq_id
      comment= 'Parallel sequence identifier            '
      key = 'SEQ_ID'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = act_id
      comment= 'Activity identifier                    '
      key = 'ACT_ID'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = exposure
      comment= 'Exposure request number               '
      key = 'EXPOSURE'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      comment= 'Background Target                      '
      key = 'BKGDTARG'
      call ftpkyl(iunit,key,bkgdtarg,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      string = template
      comment= 'Observation template used               '
      key = 'TEMPLATE'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      string = eng_qual
      comment= 'engineering data quality indicator     '
      key = 'ENG_QUAL'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
c----------------------------------------------------------------------
c     6. visit information
c
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         Visit Information                           '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
c
      status =  0
      string = visitype
      comment= 'Visit type                             '
      key = 'VISITYPE'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      string = vststart
      comment= 'UTC visit start                        '
      key = 'VSTSTART'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      string = visitsta
      comment= 'Visit status                           '
      key = 'VISITSTA'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      comment= 'Total number of planned exposures      '
      key = 'NEXPOSUR'
      call ftpkyj(iunit,key,nexposur,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      comment= 'At least one exposure is internal      '
      key = 'INTARGET'
      call ftpkyl(iunit,key,intarget,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      comment= 'Visit scheduled as TOO                 '
      key = 'TARGOOPP'
      call ftpkyl(iunit,key,targoopp,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
      if(verbose.ge.2) print *,'ftpkyl ',key, ' ',targcoopp
c
c----------------------------------------------------------------------
c
c     7. target information
c
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         Target information '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      string = targprop
      key    = 'TARGPROP'
      comment="proposer's name for the target"
      call ftpkys(iunit, key ,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ', key,' ',string
c
      comment='Standard astronomical catalog name     '
      string = object
      key    = 'TARGNAME'
      call ftpkys(iunit, key ,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'object'
       end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ', key,' ',string
c
      string = 'FIXED'
      key    = 'TARGTYPE'
      comment='Target type (fixed, moving, generic)   '
      call ftpkys(iunit, key ,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ', key,' ',string
c      
      comment = 'Target RA at mid time of exposure (deg)'
      key     = 'TARG_RA'
      call ftpkyd(iunit, key, targ_ra,-16,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'TARG_RA'
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ', key,' ',targ_ra
c
      comment = 'Target Dec at mid time of exposure (deg)'
      key     = 'TARG_DEC'
      call ftpkyd(iunit, key, targ_dec,-16, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'TARG_DEC'
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ', key,' ',targ_dec
c     
      comment='target RA uncertainty at mid-exposure'
      key = 'TARGURA'
      call ftpkyd(iunit,key,targura,12, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ', key,' ',targura
c     
      comment='target DEC uncertainty at mid-exposure'
      key = 'TARGUDEC'
      call ftpkyd(iunit,key,targudec,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ', key,' ',targudec
c
c     arc sec/year
c
      comment='proper motion of the target in RA from APT'
      key = 'MU_RA'
      call ftpkyd(iunit,key,mu_ra,12, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ', key,' ',mu_ra
c
c     arc sec/year
c
      comment='proper motion of the target in DEC from APT'
      key = 'MU_DEC'
      call ftpkyd(iunit,key,mu_dec,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ', key,' ',mu_dec
C
      comment='EPOCH of proper motion values'
      key = 'MU_EPOCH'
      call ftpkyd(iunit,key,mu_epoch,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ', key,' ',mu_epoch
c
c     "degrees"
c
      comment='Target proper motion in RA'
      key = 'PROP_RA'
      call ftpkyd(iunit,key,prop_ra,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'jwst_keywords: ', key,' ',prop_ra
c
c     "degrees" 
c
      comment='Target proper motion in DEC'
      key = 'PROP_DEC'
      call ftpkyd(iunit,key,prop_dec,12, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'ftpkyd ',key, ' ',prop_dec
c
c-----------------------------------------------------------------------
c
c     8. Instrument configuration
c
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         Instrument configuration                    '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      string = 'NIRCAM  '
      comment='Instrument used to acquire data        '
      call ftpkys(iunit,'INSTRUME',string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
c
c      write(string,330) detector(sca_id-480)
c 330  format(i2)
      string = detector(sca_id-480)
      comment='SCA name                               '
      call ftpkys(iunit,'DETECTOR',string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
      if(verbose.ge.2) print *,'ftpkys ',key, ' ',string
c
      string = module
      comment='NIRCam module:  A  or B                         '
      call ftpkys(iunit,'MODULE',module,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = channel
      comment='NIRCam channel: short or long                  '
      call ftpkys(iunit,'CHANNEL',string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = fw_filter
      comment='Name of filter element used             '
      call ftpkys(iunit,'FILTER',string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = pw_filter
      comment='Name of pupil element used            '
      call ftpkys(iunit,'PUPIL',string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      comment= 'Pupil imaging lens in the optical path'
      key = 'PILIN'
      call ftpkyl(iunit,key,pilin,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      string = coronmsk
      comment='coronagraph mask used'
      key = 'CORONMSK'
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
c-----------------------------------------------------------------------
c
c     9. Exposure parameters
c
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         Exposure parameters                         '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      comment = 'Effective Exposure time (sec)'
      call ftpkyd(iunit,'EFFEXPTM',effexptm,-8,
     *     comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'EFFEXPTM'
      end if
      status =  0
c     
      comment = 'Total Duration of Exposure time (sec)'
      call ftpkyd(iunit,'DURATION',duration,-8,
     *     comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'DURATION'
      end if
      status =  0
c
c     GAINFACT
c
      comment= 'Running count of exposures in visit  '
      key = 'EXPCOUNT'
      call ftpkyj(iunit,key,expcount,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      string = expripar
      key    = 'EXPRIPAR'
      comment='prime or parallel exposure             '
      call ftpkys(iunit,key,string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      comment = 'UTC exposure start time (MJD) '
      call ftpkyd(iunit,'EXPSTART',expstart,-16,
     *     comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'EXPSTART'
      end if
      status =  0
c     
c     This and the next keywords cannot be written at this
c     time...
c     
      comment = 'UTC exposure mid   time (MJD)'
      call ftpkyd(iunit,'EXPMID',expmid,-16,
     *     comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'EXPMID'
      end if
      status =  0
c     
      comment = 'UTC exposure end   time (MJD)'
      call ftpkyd(iunit,'EXPEND',expend,-16,
     *     comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'EXPEND'
      end if
      status =  0
c     
      string = 'NRC_IMAGE'
      comment=' exposure type                         '
      call ftpkys(iunit,'EXP_TYPE',string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      string = read_patt
      comment=' detector read-out pattern             '
      call ftpkys(iunit,'READPATT',string,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, string
      end if
      status =  0
c     
      comment = 'Number of integrations in exposure   '
       call ftpkyj(iunit,'NINTS',nints,comment,status)
c     FITSWriter uses this
c     call ftpkyj(iunit,'NINT',nints,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'NINTS'
         status = 0
      end if
      status =  0
c
c     EXTSEGTOT
C     EXSEGNUM
c     INTSTART
c     INTEND
c     
      comment='Number groups in an integration'
      call ftpkyj(iunit,'NGROUPS',ngroups,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'NGROUPS'
      end if
      status =  0
c
      comment='Number of frames in group'
      call ftpkyj(iunit,'NFRAMES',nframes,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'NFRAMES'
      end if
      status =  0
c     
      comment='Number of frames skipped'
      call ftpkyj(iunit,'GROUPGAP',groupgap,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'GROUPGAP'
      end if
      status =  0
c
      nsamples = 1
      comment='Number of A/D samples per pixel'
      call ftpkyj(iunit,'NSAMPLES',nsamples,comment,status)
c     FITSWriter uses this:
c     call ftpkyj(iunit,'NSAMPLE',nsamples,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'NSAMPLES'
      end if
      status =  0
c     
      tsample = 10.d0
      comment='Time  between samples in microsec'
      call ftpkyd(iunit,'TSAMPLE',tsample,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'TSAMPLE'
      end if
      status =  0
c     
      comment='Time in seconds between frames'
      call ftpkyd(iunit,'TFRAME',tframe,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'TFRAME'
      end if
      status =  0
c     
      comment='Delta time between groups'
      call ftpkyd(iunit,'TGROUP',tgroup,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'TGROUP'
      end if
      status =  0
c     
      comment = 'Effective integration time (sec)'
      call ftpkyd(iunit,'EFFINTTM',effinttm,-8,
     *     comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'EXPTIME'
      end if
      status =  0
c
      comment='Number of resets at start of exposure'
      key = 'NRSTSTRT'
      call ftpkyj(iunit,key,nrststrt,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='Number of resets between integrations'
      key = 'NRESETS'
      call ftpkyj(iunit,key,nresets,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment= 'Zero frame was downlinked separately'
      key = 'ZEROFRAM'
      call ftpkyl(iunit,key,zerofram,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      comment= 'Science telemetry indicated a problem'
      key = 'DATAPROB'
      call ftpkyl(iunit,key,dataprob,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      comment='                              '
      call ftpkyj(iunit,'SCA_NUM',sca_id,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'SCA_NUM'
      end if
      status =  0
c
c     FRMDIVSR (divisor applied to frame-averaged groups
c
      comment='Number of frames dropped prior to 1st integration'
      key = 'DRPFRMS1'
      call ftpkyj(iunit,key,drpfrms1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='Number of frames dropped between integrations'
      key = 'DRPFRMS3'
      call ftpkyj(iunit,key,drpfrms3,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'ftpkyj ',key, ' ',drpfrms3
c     
      comment= 'Pointing sequence number              '
      key = 'PNTG_SEQ'
      call ftpkyj(iunit,key,pntg_seq,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
c     these are not in the JWSTDP-2019.1.0-95~3f0d4fc0 version
c
      comment= 'Time  Series Observation visit indicator'
      key = 'TSOVISIT'
      call ftpkyl(iunit,key,tsovisit,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
c     10. association parameters
c
c     ASNPOOL
c     ASNTABLE
c
c-----------------------------------------------------------------------
c
c     11. Sub-array related keywords
c
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         Subarray parameters                         '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      comment='Subarray used                          '
      call ftpkys(iunit,'SUBARRAY',subarray,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SUBARRAY'
       end if
      status =  0
c
      comment='Starting pixel in axis 1 direction'
      call ftpkyj(iunit,'SUBSTRT1',substrt1,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SUBSTRT1'
       end if
      status =  0
c
      comment='Starting pixel in axis 2 direction'
      call ftpkyj(iunit,'SUBSTRT2',substrt2,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SUBSTRT2'
       end if
      status =  0
c
      comment='Number of pixels in axis 1 direction'
      call ftpkyj(iunit,'SUBSIZE1',subsize1,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SUBSIZE1'
       end if
      status =  0
c
      comment='Number of pixels in axis 2 direction'
      call ftpkyj(iunit,'SUBSIZE2',subsize2,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SUBSIZE2'
       end if
      status =  0
c
      comment='Fast readout axis direction'
      key  ='FASTAXIS'
      call ftpkyj(iunit,key,fastaxis,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      comment='slow readout axis direction'
      key  ='SLOWAXIS'
      call ftpkyj(iunit,key,slowaxis,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
      if(verbose.ge.2) print *,'ftpkyj ',key, ' ',slowaxis
c
c-------------------------------------------------------------------
c
c     12. NIRCam dither information
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         NIRCam dither information                   '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      string = primary
      comment='Primary dither pattern type            '
      call ftpkys(iunit,'PATTTYPE',string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      comment='Position number in primary dither      '
      call ftpkyj(iunit,'PATT_NUM',primary_position,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c     
      comment='Total number of positions in pattern    '
      call ftpkyj(iunit,'NUMDTHPT',primary_total,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
c      string = subpixel
c      comment='Sub-pixel  dither type                   '
c      call ftpkys(iunit,'SUBPXTYP',string,comment,status)
c       if (status .gt. 0) then
c          call printerror(status)
c          print 10, string
c       end if
c      status =  0
c
      comment='Subpixel pattern number                  '
      call ftpkyj(iunit,'SUBPXNUM',subpixel_position,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      comment='Total number of points in subpixel pattern    '
      call ftpkyj(iunit,'SUBPXPNS',subpixel_total,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, string
       end if
      status =  0
c
      comment = 'x offset from pattern starting position'
      key ='XOFFSET'
      call ftpkyd(iunit,key,xoffset,-7,
     *     comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment = 'y offset from pattern starting position'
      key ='YOFFSET'
      call ftpkyd(iunit,key,yoffset,-7,
     *     comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'ftpkyj ',key, ' ',yoffset
c
c-------------------------------------------------------------------
c
c     13. JWST Ephemeris
c
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         JWST Ephemeris                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      key  = 'REFFRAME'
      refframe = 'EME2000'      ! this seems to be hard coded.
      comment='Ephemeris reference frame (EME2000)'
      call ftpkys(iunit,key,refframe,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      eph_type = 'Definitive'
      key  = 'EPH_TYPE'
      comment='Definitive or Predicted  '
      call ftpkys(iunit,key,eph_type,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
c     EPH_TIME
c
      comment='X spatial coordinate of JWST          '
      key  = 'JWST_X'
      call ftpkyd(iunit,key,jwst_x,7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='Y spatial coordinate of JWST          '
      key  = 'JWST_Y'
      call ftpkyd(iunit,key,jwst_y,7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='Z spatial coordinate of JWST          '
      key  = 'JWST_Z'
      call ftpkyd(iunit,key,jwst_z,7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='X component of JWST velocity'
      key  = 'JWST_DX'
      call ftpkyd(iunit,key,jwst_dx,7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='Y component of JWST velocity'
      key  = 'JWST_DY'
      call ftpkyd(iunit,key,jwst_dy,7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='Z component of JWST velocity'
      key  = 'JWST_DZ'
      call ftpkyd(iunit,key,jwst_dz,7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'ftpkyj ',key, ' ',jwst_dz
c
c-------------------------------------------------------------------
c
c     14. Aperture information
c
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         Aperture information                        '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      comment='Science Aperture name                          '
      key  = 'APERNAME'
      call ftpkys(iunit,key,apername,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
c
      comment='Position angle of aperture used '
      key  = 'PA_APER'
      call ftpkyd(iunit,key,pa_aper,7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='original AperName supplied by PPS  '
      string  = pps_aper
      key  = 'PPS_APER'
      call ftpkys(iunit,key, string,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print 10, key
       end if
      status =  0
      if(verbose.ge.2) print *,'ftpkys ',key, ' ',string
c
c-------------------------------------------------------------------
c     15. Velocity aberration correction
c
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         Dither information                          '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      comment='Velocity aberration correction RA offset (rad)'
      key  = 'DVA_RA'
      call ftpkyd(iunit,key,dva_ra,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='Velocity aberration correction Dec offset (rad)'
      key  = 'DVA_DEC'
      call ftpkyd(iunit,key,dva_dec,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='Velocity aberration scale factor'
      key  = 'VA_SCALE'
      call ftpkyd(iunit,key,va_scale,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'ftpkyd ',key, ' ',va_scale
c
c-------------------------------------------------------------------
c
c     16. time (barycentric, heliocentric)
c
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         TIME   information                          '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      comment = 'Barycentric time correction (sec)'
      key  = 'BARTDELT'
      call ftpkyd(iunit,key, bartdelt,-5, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c     
      comment = 'Barycentric exposure start time '
      key  = 'BSTRTIME '
      call ftpkyd(iunit,key, bstrtime,-12, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c     
      comment = 'Barycentric exposure end time '
      key  = 'BENDTIME '
      call ftpkyd(iunit,key, bendtime,-12, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c     
      comment = 'Barycentric exposure mid time '
      key  = 'BMIDTIME '
      call ftpkyd(iunit,key, bmidtime,-12, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment = 'Heliocentric time correction (sec)'
      key  = 'HELIDELT'
      call ftpkyd(iunit,key, helidelt,-12, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c     
      comment = 'Heliocentric exposure start time '
      key  = 'HSTRTIME '
      call ftpkyd(iunit,key, hstrtime,-12, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c     
      comment = 'Heliocentric exposure end time '
      key  = 'HENDTIME '
      call ftpkyd(iunit,key, hendtime,-12, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c     
      comment = 'Heliocentric exposure mid time '
      key  = 'HMIDTIME '
      call ftpkyd(iunit,key, hmidtime,-12, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
      if(verbose.ge.2) print *,'ftpkyd ',key, ' ',hmidtime
c
c-------------------------------------------------------------------
c
c     17. Photometry 
c      
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         Photometry parameters                       '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
c     these are the keyword Big Brother wants
c
c
      comment='Flux density (MJy/steradian) producing 1 cps'
      key  = 'PHOTMJSR'
      call ftpkyd(iunit,key,photmjsr,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='Flux density (uJy/arcsec2) producing 1 cps'
      key  = 'PHOTUJA2'
      call ftpkyd(iunit,key,photuja2,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='Nominal pixel area in steradians '
      key  = 'PIXAR_SR'
      call ftpkyd(iunit,key,pixar_sr,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
      comment='Nominal pixel area in steradians '
      key  = 'PIXAR_A2'
      call ftpkyd(iunit,key, pixar_a2,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print 10, key
      end if
      status =  0
c
c     these keywords are non-compliant
c
      comment = 'Pivot wavelength Angstroms'
      call ftpkyd(iunit,'PHOTPLAM',photplam*1.d04,10,
     *     comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'PHOTPLAM'
      end if
      status =  0
c
      comment = 'Flux for 1e s-1 in erg cm**-2 s-1 A-1'
      call ftpkyd(iunit,'PHOTFLAM',photflam,-6,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'PHOTFLAM'
      end if
      status =  0
c
      comment = 'STMAG zeropoint'
      call ftpkyd(iunit,'STMAG',stmag,-6,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'STMAG'
      end if
      status =  0
c
      comment = 'ABMAG zeropoint'
      call ftpkyd(iunit,'ABMAG',abmag,-6,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'ABMAG'
      end if
      status =  0
      if(verbose.ge.2) print *,'ftpkyd ',key, ' ',abmag
c
c-------------------------------------------------------------------
c
c     18. Reference files
c     19. Calibration steps
c     20. Resampling parameters
c
c-------------------------------------------------------------------
c
c     21. Spacecraft pointing (PA_V3)
c
c     fake WCS keywords
c 
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '      Spacecrft pointing information                 '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      comment = 'Position angle of V3-axis of JWST     '
      call ftpkyd(iunit,'PA_V3',pa_v3,-6,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'PA_V3'
      end if
      status =  0
c
c     
      comment='V2 coordinate of ref point (arcsec)'
      call ftpkyd(iunit,'V2_REF',v2_ref,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'v2_ref'
      end if
      status =  0
c     
      comment='V3 coordinate of ref point (arcsec)'
      call ftpkyd(iunit,'V3_REF',v3_ref,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'v3_ref'
      end if
      status =  0
c
c
c     RA_V1
c     DEC_V1
c
c     22.  miscellaneous items
c-------------------------------------------------------------------
c
c     23. WCS
c
c     fake WCS keywords
c 
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         WCS information                             '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      comment='                                       '
      call ftpkyj(iunit,'WCSAXES',wcsaxes,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'WCSAXES'
      end if
      status =  0
c     
      comment='Axis 1 coordinate of reference pixel   '
      call ftpkyd(iunit,'CRPIX1',crpix1,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CRPIX1'
      end if
      status =  0
c     
      comment='Axis 2 coordinate of reference pixel   '
      call ftpkyd(iunit,'CRPIX2',crpix2,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CRPIX2'
      end if
      status =  0
c     
      comment='Axis 3 coordinate of reference pixel   '
      if(read_patt .eq. 'RAPID') then
         call ftpkyd(iunit,'CRPIX3',crpix3,-7,comment,status)
      else
         call ftpkyd(iunit,'CRPIX3',crpix3/2.d0,-7,comment,status)
      end if
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CRPIX3'
      end if
      status =  0
c      
      comment='RA at reference pixel (degrees)        '
      call ftpkyd(iunit,'CRVAL1',crval1,-12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CRVAL1'
      end if
      status =  0
c     
      comment='DEC at reference pixel (degrees)       '
      call ftpkyd(iunit,'CRVAL2',crval2,-12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CRVAL2'
       end if
       status =  0
c     
      comment='T at reference pixel (seconds)       '
      call ftpkyd(iunit,'CRVAL3',crval3,-12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CRVAL3'
       end if
       status =  0
c     
      comment='Projection type                        '
      call ftpkys(iunit,'CTYPE1','RA---TAN',comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CTYPE1'
      end if
      status =  0
c     
      call ftpkys(iunit,'CTYPE2','DEC--TAN',comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CTYPE2'
      end if
      status =  0
c     
      call ftpkys(iunit,'CTYPE3','',comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CTYPE3'
      end if
      status =  0
c
      comment='First axis increment per pixel          '      
      call ftpkyd(iunit,'CDELT1',cdelt1,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CDELT1'
      end if
      status =  0
c     
      comment='Second axis increment per pixel         '      
      call ftpkyd(iunit,'CDELT2',cdelt2,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CDELT2'
      end if
      status =  0
c     
      comment='Third axis increment per pixel         '      
      call ftpkyd(iunit,'CDELT3',cdelt3,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CDELT3'
      end if
      status =  0
c     
      cunit1 = 'deg'
      comment='First axis units                       '
      call ftpkys(iunit,'CUNIT1',cunit1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CUNIT1'
      end if
      status =  0
c     
      cunit2 = 'deg'
      comment='Second axis units                      '
      call ftpkys(iunit,'CUNIT2',cunit2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CUNIT2'
      end if
      status =  0
c     
      cunit3 = 'sec'
      comment='Third axis units                      '
      call ftpkys(iunit,'CUNIT3',cunit3,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CUNIT3'
      end if
      status =  0
c     
c     PCi_j are the cos/sin of position angle and are such that
c
c     cd1_1     cd1_2      | cdelt1     0   |   | pc1_1    pc1_2 |
c     =   |                | * |                |
c     cd2_1     cd2_2      |   0     cdelt2 |   | pc2_1    pc2_2 |
c     
c     Calabretta & Greisen 2002, A&A, 395, 1077, eq(186) on page 1101
c     
      comment='                                       '
      call ftpkyd(iunit,'PC1_1',pc1_1,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'PC1_1'
      end if
      status =  0
c     
      comment='                                       '
      call ftpkyd(iunit,'PC1_2',pc1_2,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'PC1_2'
      end if
      status =  0
c     
      comment='                                       '
      call ftpkyd(iunit,'PC2_1',pc2_1,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'PC2_1'
      end if
      status =  0
c     
      comment='                                       '
      call ftpkyd(iunit,'PC2_2',pc2_2,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'PC2_2'
      end if
      status =  0
c     
      comment='                                       '
      call ftpkyd(iunit,'PC3_1',pc3_1,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'PC3_1'
      end if
      status =  0
c     
      comment='                                       '
      call ftpkyd(iunit,'PC3_2',pc3_2,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'PC3_2'
      end if
      status =  0
c     
      comment='RA  of the reference point (deg)'
      call ftpkyd(iunit,'RA_REF',ra_ref,-16,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'ra_ref'
      end if
      status =  0
c     
      comment='Dec of the reference point (deg)'
      call ftpkyd(iunit,'DEC_REF',dec_ref,-16,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'dec_ref'
      end if
      status =  0
c     
      comment='Telescope roll angle of V3 at ref point'
      call ftpkyd(iunit,'ROLL_REF',roll_ref,-8,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'roll_ref'
      end if
      status =  0
c     
      comment='Relative sense of rotation between Ideal xy and V2V3 '
      call ftpkyj(iunit,'VPARITY',vparity,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'vparity'
      end if
      status =  0
c     
      comment='Angle from V3 axis to Ideal y axis (deg)'
      call ftpkyd(iunit,'V3I_YANG',v3i_yang,4,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'V3I_YANG'
      end if
      status =  0
c     
c     These are non-STScI standard
c     
c     
      if(naxis .eq.4) then
         comment='Axis 4 coordinate of reference pixel   '
         call ftpkyd(iunit,'CRPIX4',1.d0,-7,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'CRPIX4'
         end if
         status =  0
         comment='4th dimension at reference pixel (pixel)   '
         call ftpkyd(iunit,'CRVAL4',1.d0,-7,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'CRVAL3'
         end if
         
         status =  0
         comment='Fourth axis increment per pixel         '      
         call ftpkyd(iunit,'CDELT4',1.d0,12,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'CDELT4'
         end if
         status =  0
      end if
c
      comment='                                       '
      call ftpkyd(iunit,'EQUINOX',equinox,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'EQUINOX'
      end if
      status =  0
c
c      comment='                                       '
c      call ftpkyd(iunit,'CD1_1',cd1_1,10,comment,status)
c      if (status .gt. 0) then
c         call printerror(status)
c         print *, 'CD1_1'
c      end if
c      status =  0
cc     
c      comment='                                       '
c      call ftpkyd(iunit,'CD1_2',cd1_2,10,comment,status)
c      if (status .gt. 0) then
c         call printerror(status)
c         print *, 'CD1_2'
c      end if
c      status =  0
cc     
c      comment='                                       '
c      call ftpkyd(iunit,'CD2_1',cd2_1,10,comment,status)
c      if (status .gt. 0) then
c         call printerror(status)
c         print *, 'CD2_1'
c      end if
c      status =  0
cc     
c      comment='                                       '
c      call ftpkyd(iunit,'CD2_2',cd2_2,10,comment,status)
c      if (status .gt. 0) then
c         call printerror(status)
c         print *, 'CD2_2'
c      end if
c      status =  0
cc     
c      comment='                                       '
c      call ftpkyd(iunit,'CD3_3',cd3_3,10,comment,status)
c      if (status .gt. 0) then
c         call printerror(status)
c         print *, 'CD3_3'
c      end if
c      status =  0
c
c----------------------------------------------------------------
c
c     24. additional non-standard keywords that refer to
c     the simulation
c     These refer to the simulation and are therefore non-standard
c
      if(verbose.ge.2) print *,'jwst_keywords ftpkyj INC_KTC'
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         Simulator parameters                        '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c     
      comment = 'include KTC F(0) T(1)'
      call ftpkyj(iunit,'INC_KTC',include_ktc,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'INC_KTC'
         status = 0
      end if
c     
      if(verbose.ge.2) print *,'jwst_keywords ftpkyj INC_RON'
      comment = 'include readnoise F(0) T(1)'
      call ftpkyj(iunit,'INC_RON',include_readnoise,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'INC_NRON'
         status = 0
      end if
c     
      if(verbose.ge.2) print *,'jwst_keywords ftpkyj INC_BKG'
      comment = 'include background F(0) T(1)'
      call ftpkyj(iunit,'INC_BKG',include_bg,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'INC_BKG'
         status = 0
      end if
c     
      if(verbose.ge.2) print *,'jwst_keywords ftpkyj INC_CR'
      comment = 'include Cosmic Rays F(0) T(1)'
      call ftpkyj(iunit,'INC_CR',include_cr, comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'INC_CR'
         status = 0
      end if
c     
      if(verbose.ge.2) print *,'jwst_keywords ftpkyj INC_DARK'
      comment = 'include darks F(0) T(1)'
      call ftpkyj(iunit,'INC_DARK',include_dark,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'INC_DARK'
         status = 0
      end if
c     
      if(verbose.ge.2) print *,'jwst_keywords ftpkyj INC_LAT'
      comment = 'include latents F(0) T(1)'
      call ftpkyj(iunit,'INC_LAT',include_latents,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'INC_LAT'
         status = 0
      end if
c
      if(verbose.ge.2) print *,'jwst_keywords ftpkyj INC_NLIN'
      comment = 'include non-linearity F(0) T(1)'
      call ftpkyj(iunit,'INC_NLIN',include_non_linear,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'INC_NLIN'
         status = 0
      end if
c     
      if(verbose.ge.2) print *,'jwst_keywords ftpkyl NOISELESS',
     &     ktc
      comment = 'NOISELES (T or F)'
      call ftpkyl(iunit,'NOISELES',noiseless,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'KTC'
         status = 0
      end if
c     
      if(verbose.ge.2) print *,'jwst_keywords ftpkyd KTC',
     &     ktc
      comment = 'KTC value (e-)'
      call ftpkyd(iunit,'KTC',ktc,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'KTC'
         status = 0
      end if
c     
      if(verbose.ge.2) print *,'jwst_keywords ftpkyd BIAS',
     &     bias_value
      comment = 'BIAS value (e-)'
      call ftpkyd(iunit,'BIAS',bias_value,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'BIAS'
         status = 0
      end if
c     
      if(verbose.ge.2) print *,'jwst_keywords ftpkyd readnoise',
     &     readnoise
      comment = 'Readout noise (e-)'
      call ftpkyd(iunit,'RDNOISE',readnoise,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'RDNOISE'
         status = 0
      end if
c     
      if(verbose.ge.2) print *,'jwst_keywords ftpkyd background',
     &     background
      comment = 'background (e-/sec/pixel)'
      call ftpkyd(iunit,'BKG',background,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'BKG'
         status = 0
      end if
c
c     Kludge to create a FITSWriter style output
c
      if(verbose.ge.2) print *,'jwst_keywords ftphis ',
     &     background
      call ftpkyj(iunit,'NSAMPLE',nsamples,comment,status)
      call ftpkyj(iunit,'NINT',nints,comment,status)
      call ftphis(iunit,'Science data not written by FITSWriter',status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'History'
         status = 0
      end if
c     
c=====================================================================
c
c     These keywords provide compatibility with the current version of
c     DHAS
c
c     Sub-array related keywords
c     
      if(dhas.eq.1) then
         drop_frame_1 = 0
         if(subarray(1:4).eq.'FULL') then
            subarray_l = .false.
            colcornr   = 1
            rowcornr   = 1
            ibrefrow   = 4
            itrefrow   = 4
         else
            subarray_l = .true.
            colcornr   = substrt1
            rowcornr   = substrt2
            ibrefrow   = 4
            itrefrow   = 4
         end if
         card = '                                              '
         call ftprec(iunit,card, status)
         status =  0
         card = '         Keywords required for DHAS           '
         call ftprec(iunit,card, status)
         status =  0
         card = '                                              '
         call ftprec(iunit,card, status)
         status =  0
c     
         comment='                                       '
         call ftpkyl(iunit,'SUBARRAY',subarray_l,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'SUBARRAY'
         end if
         status =  0
c     
         comment='                                       '
c     call ftpkyj(iunit,'SUBAR_X1',subar_x1,comment,status)
         call ftpkyj(iunit,'COLCORNR',colcornr,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'COLCORNR'
         end if
         status =  0
c     
         comment='                                       '
c     call ftpkyj(iunit,'SUBAR_Y1',subar_y1,comment,status)
         call ftpkyj(iunit,'ROWCORNR',rowcornr,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'ROWCORNR'
         end if
         status =  0
c     
         comment='bottom reference pixel rows'
         call ftpkyj(iunit,'BREFROW',ibrefrow,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'BREFROW'
         end if
         status =  0
c     
         comment='top reference pixel rows'
         call ftpkyj(iunit,'TREFROW',itrefrow,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'TREFROW'
         end if
c     1234567890123456789012345678901234567890
         comment='Number of frames skipped prior to first i'
         call ftpkyj(iunit,'DRPFRMS1',drop_frame_1,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'drop_frame_1'
         end if
c     
         comment='Number groups for ncdhas'
         call ftpkyj(iunit,'NGROUP',ngroups,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'NGROUP'
         end if
         status =  0
         comment='Number of frames for ncdhas'
         call ftpkyj(iunit,'NFRAME',nframes,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'NFRAME'
         end if
         status =  0
c     
         comment='                              '
         call ftpkyj(iunit,'SCA_ID',sca_id,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'SCA_ID'
         end if
         status =  0
      end if
      print *,'crval1, crval2, crval3',crval1, crval2, crval3
c       print *,'end keywords'
c     
c     Fake keywords to enable multi-drizzle
c     IDCTAB, ADCGAIN, EXPEND,
c     SAMP_SEQ, NSAMP, CENTERA1, CENTERA2, SIZAXIS1, SIZAXIS2,
c     These already exist:
c     CRPIX1, CRPIX2, CD1_1, CD1_2, CD2_1, CD2_2, NAXIS1, NAXIS2
c
c     IDCTAB  = 'iref$u1r16228i_idc.fits' / image distortion correction table
c     SAMP_SEQ= 'SPARS100'           / MultiAccum exposure time sequence name
c     NSAMP   =                   16 / number of MULTIACCUM samples
c     / READOUT DEFINITION PARAMETERS
c     CENTERA1=   513 / subarray axis1 center pt in unbinned dect. pix
c     CENTERA2=   513 / subarray axis2 center pt in unbinned dect. pix
c     SIZAXIS1=  1024 / subarray axis1 size in unbinned detector pixels
c     SIZAXIS2=  1024 / subarray axis2 size in unbinned detector pixels       
       return
       end

cPHOTFLAM is the flux of a source with constant flux per unit wavelength (in erg s-1 cm-2 Å-1) which produces a count rate of 1 DN per second. This keyword is generated by the synthetic photometry package synphot, which you may also find useful for a wide range of photometric and spectroscopic analyses. Using PHOTFLAM, it is easy to convert instrumental magnitude to flux density, and thus determine a magnitude in a flux-based system such as AB or STMAG (see previous Section); the actual steps required are detailed below. 
