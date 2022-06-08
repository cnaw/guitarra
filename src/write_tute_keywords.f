      subroutine write_tute_keywords
     *     (cube_name, iunit, nx, ny, 
     *     bitpix, naxis, naxes, pcount, gcount, filename,
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
     *     effexptm, duration,
     *     pntg_seq, expcount, expripar, tsovisit, expstart,
     *     expmid, expend, read_patt, nints, ngroups, groupgap,
     *     tframe, tgroup, effinttm, exptime,nrststrt, nresets, 
     *     zerofram, sca_num, drpfrms1, drpfrms3,
     *     subarray, substrt1, substrt2, subsize1, subsize2,
     *     fastaxis, slowaxis, 
     &     patttype,primary_dither_string, numdthpt, patt_num, 
     &     subpixel,  subpixel_total, subpixel_position,
     *     xoffset, yoffset,
     *     jwst_x, jwst_y, jwst_z, jwst_dx, jwst_dy, jwst_dz,
     *     apername,  pa_aper, pps_aper, pa_v3,
     *     dva_ra,  dva_dec, va_scale,
     *     bartdelt, bstrtime, bendtime, bmidtime,
     *     helidelt, hstrtime, hendtime, hmidtime,
     *     photmjsr, photuja2, pixar_sr, pixar_a2,
     *     wcsaxes, distortion, siaf_version,
     *     crpix1, crpix2, crpix3, crval1, crval2, crval3,
     *     cdelt1, cdelt2, cdelt3, cunit1, cunit2, cunit3,
     *     ctype1, ctype2,
     *     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2, 
     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3, equinox,
     *     ra_ref, dec_ref, roll_ref, v2_ref, v3_ref, 
     *     v_idl_parity, v3i_yang,
     &     a_order, aa, b_order, bb,
     &     ap_order, ap, bp_order, bp, 
     &     nframes, object, sca_id,
     &     photplam, photflam, stmag, abmag,vega_zp,
     &     naxis1, naxis2,
     &     noiseless, include_ipc, include_bias,
     &     include_ktc, include_bg, include_cr, include_dark,
     &     include_dark_ramp,
     &     include_latents, include_readnoise, include_non_linear,
     &     include_flat, version,
     &     ktc,bias_value,voltage_sigma,
     &     gain,readnoise, background,
     &     dark_ramp,     
     &     biasfile, darkfile, sigmafile, 
     &     welldepthfile, gainfile, linearityfile,
     &     badpixelmask, ipc_file, flat_file,
     &     seed, dhas, origin, extnum, extname,verbose)
c     
c     Write fits file in format acceptable to STScI pipeline; the file
c     is organised as follows:
c     Index  extension  type   dimension   
c     0      Primary    Image  0                        main header
c     1      SCI        Image  2048 x 2048 x ngroup x nints
c     2      ZEROFRAME  Image  2048 x 2048 x 1
c     3      GROUP      binary 13 cols x ngroup rows
c     4      INT_TIMES  binary  7 cols x 1 row  
c     comments:
c     Primary lists mirage parameters, visit data, some positional data
c     (ra_v1, dec_v1, pa_v3), date, filter, offsets, readout pattern, 
c     subarray, times, but no WCS data
c     
c     SCI     contains the WCS parameters (no distortion information
c     in Mirage image, even though it is used)
c     
c     ZEROFRAME contains only a basic header, no WCS
c     
c     GROUP lists integration number, group number, group end time,
c     number of columns, rows, completion code number, 
c     completion code text,
c     bary_end_time, helio_end_time as a binary table
c     
c     INT_TIMES basically repeats the exposure information in the
c     primary header as a fits table
c     
c=======================================================================
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
      double precision bscale, bzero
      character date*30, origin*20, timesys*10, filename*(*), 
     &     filetype*30, sdp_ver*20, xtension*20, cube_name*(*),
     &     extname*20
c     
c     coordinate system
c     
      character radesys*10
c     
c     programmatic information
c     
      character title*150, pi_name*183, category*4, subcat*10, 
     &     scicat*10
      integer cont_id, extver
c     
c     observation identifiers
c     
      character date_obs*10, time_obs*(*), date_end*10, time_end*(*),
     &     obs_id*26, visit_id*11, observtn*3, visit*11, obslabel*40,
     &     visitgrp*2, seq_id*1, act_id*2, exposure_request*5, 
     &     template*50, eng_qual*8,  program_id*7
      logical bkgdtarg
c     integer program_id
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
     &     mu_ra, mu_dec, prop_ra, prop_dec
      character mu_epoch*6
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
      character expripar*20, exp_type*30, readpatt*15,
     &     primary_dither_string*(*)
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
      character  apername*(*), pps_aper*40
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
      character siaf_version*13
      integer wcsaxes, v_idl_parity 
      double precision crpix1, crpix2, crpix3,
     &     crval1, crval2, crval3, cdelt1, cdelt2,cdelt3,
     &     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2,cd3_3,
     &     ra_ref, dec_ref, roll_ref,
     &     v3i_yang, wavstart, wavend, sporder

      character ctype1*(*), ctype2*(*), ctype3*15,
     &     cunit1*40, cunit2*40, cunit3*40,
     &     s_region*100
c     
c-----------------------------------------------------------------------
c     
c     Non-STScI keywords
c     
      double precision ktc,bias_value, readnoise, background, exptime,
     &     voltage_sigma
      double precision total_time, sec, ut, jday, mjd
      double precision photplam, photflam, vegamag, stmag, abmag, gain,
     *     vega_zp
      double precision cd1_1, cd1_2, cd2_1, cd2_2
      double precision equinox
      real image, version
      integer year, month, day, ih, im, dhas, verbose, status
      integer iunit, nx, ny, nz,  nnn, nskip, naxes, sca_id
      integer include_ktc, include_bg, include_cr, include_dark,
     *     include_dark_ramp,
     *     include_latents, include_readnoise, include_non_linear,
     *     include_flat, include_bias, include_ipc
      integer  subpixel_position, subpixel_total 
c     for compatibility with DHAS
      integer colcornr,rowcornr,ibrefrow,itrefrow,drop_frame_1,
     &     extnum, local_naxis
      character key*8, subarray*8, patttype*15, subpixel*16, card*80,
     &     comment*40, full_date*23,string*40, pw_filter*8, fw_filter*8
      character dark_ramp*(*),
     &     biasfile*(*), darkfile*(*), sigmafile*(*), 
     &     welldepthfile*(*), gainfile*(*), linearityfile*(*),
     &     badpixelmask*(*), ipc_file*(*), flat_file*(*)

      logical subarray_l, noiseless
c     
      character long_string*68
      integer indx, length
c     
      double precision attitude_dir, attitude_inv,
     &     aa, bb, ap, bp
      integer a_order, b_order, ap_order, bp_order
c     
      integer distortion, seed, iexp, jexp, ii, jj, hdn, hdutype
      character coeff_name*15
      parameter (nnn=2048)
c     common /wcs/ equinox, 
c     *     crpix1, crpix2, crpix3,
c     *     crval1, crval2, crval3,
c     *     cdelt1, cdelt2, cdelt3,
c     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3,
c     *     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2/
c     common /wcs/ equinox, crpix1, crpix2, crval1, crval2,
c     *     cdelt1,cdelt2, cd1_1, cd1_2, cd2_1, cd2_2,
c     *     pc1_1, pc1_2, pc2_1, pc2_2
c     
      dimension image(nnn,nnn),naxes(4), detector(10)
      dimension aa(9,9), bb(9,9), ap(9,9), bp(9,9)
c     
      data detector/'NRCA1','NRCA2','NRCA3','NRCA4','NRCALONG',
     &     'NRCB1','NRCB2','NRCB3','NRCB4','NRCBLONG'/
c     
c     define the required primary array keywords
c     
      if(verbose .ge.1) print *,'entered write_tute_keywords'
      if(verbose .ge.2) print *,
     *     crpix1, crpix2, crpix3, crval1, crval2, crval3,
     *     cdelt1, cdelt2, cdelt3, cunit1, cunit2, cunit3,
     *     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2, 
     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3, equinox,
     *     ra_ref, dec_ref, roll_ref, v2_ref, v3_ref
C     

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
c     basic keyword values
c     
      status   =  0
c     
      simple   = .true.
      extend   = .true.
      pcount      = 0
      gcount      = 1
c     
c     naxis    = 2
      if(subarray .eq. 'FULL')  then 
         naxes(1) = nnn
         naxes(2) = nnn
      else
         naxes(1) = naxis1
         naxes(2) = naxis2
      end if
      subsize1  = naxis1
      subsize2  = naxis2
c     if(naxis .gt.2)
c     naxis    =  3
c     naxes(3) = ngroups
c     end if
c     
c     c      if(nints.gt.1) then
c     naxis    =  4
c     naxes(4) = nints
c     end if
c     
c==================================================================
c     
      if(verbose.ge.2) print *,'write_tute_keywords: extnum', extnum
C0000000000000000000000000000000000000000000000000000000000000000000000
      extver = 1
c     
c     Extension 0 keywords
c     
      if(extnum .eq.0) then
c     
c     Create a new IMAGE and place the current counter
c     there.
c     
         call data_model_fits(iunit,cube_name, verbose)
c     
c     write basic keywords
c     
         bitpix   = 8
         local_naxis    = 0
         status   = 0
c     
c     Move to the primary FITS array
c     
         call ftcrhd(iunit,status)
         if (status .gt. 0) then
            print *,'write_tute_keywords: ftcrhd', status
            call printerror(status)
         end if         
c     
c     1. Write Standard parameters and basic information
c     
         call ftphpr(iunit,simple, bitpix, local_naxis, naxes, 
     &        pcount,gcount,extend,status)
         
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ftphr : status',status
         if (status .gt. 0) then
            print *, 'write_tute_keywords:simple,bitpix,local_naxis'
            call printerror(status)
         end if
         status =  0
c     
         string = full_date
         comment= 'UTC date file created            '
         call ftpkys(iunit,'DATE',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
         if(verbose.ge.2) print *,'write_tute_keywords: ftpkys ', string
c     
         string = 'AZLAB'
         comment= 'The organization that created the file '
         call ftpkys(iunit,'ORIGIN',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
         if(verbose.ge.2) print *,'write_tute_keywords: ftpkys ', string

         indx = index(filename,'/',.TRUE.)
         length = len(trim(filename))
         long_string  = filename(indx+1:length)
         if(verbose.gt.0) 
     &        print *,'write_tute_keywords FILENAME   ', filename
c     
         comment= 'file name                              '
         call ftpkys(iunit,'FILENAME',trim(long_string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     if(verbose.ge.2) print *,'write_tute_keywords: ftpkys ', 
c     &        long_string
c     
c     The test images downloaded from STScI show these as "raw"
c     string = 'uncalibrated'
c     
         string = 'raw'
         comment= 'type of data in the file               '
         call ftpkys(iunit,'FILETYPE',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
         if(verbose.ge.2) print *,'write_tute_keywords: ftpkys ', string
c     
         string = 'RampModel'
         comment= 'type of data model                     '
         call ftpkys(iunit,'DATAMODL',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
         if(verbose.ge.2) print *,'write_tute_keywords: ftpkys ', string
c     
         comment = 'Guitarra: the overhead-free telescope '
         key     = 'TELESCOP'
         string  = 'JWST'
         call ftpkys(iunit,key, trim(string), comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
 10         format(a80)
         end if
         status =  0
         if(verbose.ge.2) print *,'write_tute_keywords: ftpkys ', string
c     
c-------------------------------------------------------------------
c     
c     2. Programatic information
c     
         card = '                                              '
         call ftprec(iunit,card, status)
         status =  0
         card = '         Program information     '
         call ftprec(iunit,card, status)
         status =  0
         card = '                                              '
         call ftprec(iunit,card, status)
         status =  0

         comment  = 'Proposal title '
         string   = title
         key = 'TITLE'
         call ftpkys(iunit,key, trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
         if(verbose.ge.2) print *,'write_tute_keywords: ftpkys ', string
c     
         comment  = 'Principal investigator name '
         call ftpkys(iunit,'PI_NAME', trim(pi_name),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'PI_NAME'
         end if
         status =  0
c     
         comment  = 'Program category '
         key = 'CATEGORY'
         call ftpkys(iunit,key, trim(category),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, key
         end if
         status =  0
c     
c     
         comment  = 'Program sub-category '
         key = 'SUBCAT'
         call ftpkys(iunit,key, trim(subcat),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, key
         end if
         status =  0
c     
         comment  = 'Science category assigned by TAC '
         key = 'SCICAT'
         call ftpkys(iunit,key, trim(scicat),comment,status)
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
         if(verbose.ge.2) print *,'write_tute_keywords: ftpkyj ', 
     &        key,' ',cont_id
c     
c-------------------------------------------------------------------
c     
c     3. Observation identifiers
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
         string = 'UTC'
         comment= 'Reference time                         '
         call ftpkys(iunit,'TIMESYS',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
         if(verbose.ge.2) print *,'write_tute_keywords: ftpkys ', string
c     
         string = date_obs
         comment= 'UTC date of start of exposure               '
         call ftpkys(iunit,'DATE-OBS',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = time_obs
         comment= 'UTC time of start of exposure             '
         call ftpkys(iunit,'TIME-OBS',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = date_end
         comment= 'UTC date of end of exposure               '
         key = 'DATE-END'
         call ftpkys(iunit,key,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = time_end
         comment= 'UTC time of end  of exposure             '
         key = 'TIME-END'
         call ftpkys(iunit,key ,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = obs_id
         comment= 'Programmatic observation identifier      '
         key = 'OBS_ID'
         call ftpkys(iunit,key ,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = visit_id
         comment= 'Visit identifier                         '
         key = 'VISIT_ID'
         call ftpkys(iunit,key ,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = program_id
         comment= 'Program number                           '
         key = 'PROGRAM'
         call ftpkys(iunit,key ,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = observtn
         comment= 'Observation number                       '
         key = 'OBSERVTN'
         call ftpkys(iunit,key ,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = visit
         comment= 'Visit number                             '
         key = 'VISIT'
         call ftpkys(iunit,key ,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = visitgrp
         comment= 'Visit group identifier                  '
         key = 'VISITGRP'
         call ftpkys(iunit,key,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = seq_id
         comment= 'Parallel sequence identifier            '
         key = 'SEQ_ID'
         call ftpkys(iunit,key,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = act_id
         comment= 'Activity identifier                    '
         key = 'ACT_ID'
         call ftpkys(iunit,key,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = exposure_request
         comment= 'Exposure request number               '
         key = 'EXPOSURE'
         call ftpkys(iunit,key,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
c     
         string = obslabel
         comment= 'Proposer label for the observation      '
         key = 'OBSLABEL'
         call ftpkys(iunit,key,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
c-------------------------------------------------------------------------
c     4. Visit information
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
c------------------------------------------------------------------------
c     
c     5.Target information 
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
         call ftpkys(iunit, key ,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ', key,' ',string
c     
         comment='Standard astronomical catalog name     '
         string = object
         key    = 'TARGNAME'
         call ftpkys(iunit, key ,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'object'
         end if
         status =  0
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ', key,' ',string
c     
         comment = 'Target RA at mid time of exposure (deg)'
         key     = 'TARG_RA'
         call ftpkyd(iunit, key, targ_ra,-16,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'TARG_RA'
         end if
         status =  0
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ', key,' ',targ_ra
c     
         comment = 'Target Dec at mid time of exposure (deg)'
         key     = 'TARG_DEC'
         call ftpkyd(iunit, key, targ_dec,-16, comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'TARG_DEC'
         end if
         status =  0
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ', key,' ',targ_dec
c     
         comment='target RA uncertainty at mid-exposure'
         key = 'TARGURA'
         call ftpkyd(iunit,key,targura,12, comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ', key,' ',targura
c     
         comment='target DEC uncertainty at mid-exposure'
         key = 'TARGUDEC'
         call ftpkyd(iunit,key,targudec,12,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ', key,' ',targudec
c     
c     Mirage adds these here:
c     RA_V1
c     DEC_V1
c     
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
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ', key,' ',mu_ra
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
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ', key,' ',mu_dec
C     
         comment='EPOCH of proper motion values'
         key = 'MU_EPOCH'
         call ftpkys(iunit,key,trim(mu_epoch),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ', key,' ',mu_epoch
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
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ', key,' ',prop_ra
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
         string = 'FIXED'
         key    = 'TARGTYPE'
         comment='Target type (fixed, moving, generic)   '
         call ftpkys(iunit, key ,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ', key,' ',string
c     
c     
c-----------------------------------------------------------------------
c     
c     6. Instrument configuration
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
         call ftpkys(iunit,'INSTRUME',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
c     
c     write(string,330) detector(sca_id-480)
c     330  format(i2)
         string = detector(sca_id-480)
         comment='SCA name                               '
         call ftpkys(iunit,'DETECTOR',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
         if(verbose.ge.2) print *,'ftpkys ',key, ' ',string
c     
         string = module
         comment='NIRCam module:  A  or B                         '
         call ftpkys(iunit,'MODULE',trim(module),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = channel
         comment='NIRCam channel: short or long                  '
         call ftpkys(iunit,'CHANNEL',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = fw_filter
         comment='Name of filter element used             '
         call ftpkys(iunit,'FILTER',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         string = pw_filter
         comment='Name of pupil element used            '
         call ftpkys(iunit,'PUPIL',trim(string),comment,status)
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
         call ftpkys(iunit,key,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0

c     
c-----------------------------------------------------------------------
c     
c     7. Exposure parameters
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
         string = 'NRC_IMAGE'
         comment=' Type of data in the exposure              '
         call ftpkys(iunit,'EXP_TYPE',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
c     
         comment = 'UTC exposure start time (MJD) '
         call ftpkyd(iunit,'EXPSTART',expstart,-16,
     *        comment,status)
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
     *        comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'EXPMID'
         end if
         status =  0
c     
         comment = 'UTC exposure end   time (MJD)'
         call ftpkyd(iunit,'EXPEND',expend,-16,
     *        comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'EXPEND'
         end if
         status =  0

c     
         string = read_patt
         comment=' detector read-out pattern             '
         call ftpkys(iunit,'READPATT',trim(string),comment,status)
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
     *        comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'EXPTIME'
         end if
         status =  0
c     
         comment = 'Effective Exposure time (sec)'
         call ftpkyd(iunit,'EFFEXPTM',effexptm,-8,
     *        comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'EFFEXPTM'
         end if
         status =  0
c     
         comment = 'Total Duration of Exposure time (sec)'
         call ftpkyd(iunit,'DURATION',duration,-8,
     *        comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'DURATION'
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
c-----------------------------------------------------------------------
c     
c     8. Sub-array related keywords
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
         call ftpkys(iunit,'SUBARRAY',trim(subarray),comment,status)
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
c     9. NIRCam dither information
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
         string = patttype
         comment='Primary dither pattern type            '
         call ftpkys(iunit,'PATTTYPE',trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         comment='Position number in primary dither      '
         call ftpkyj(iunit,'PATT_NUM',patt_num,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         comment='Total number of positions in pattern    '
         call ftpkyj(iunit,'NUMDTHPT',numdthpt,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
c     
         comment='Total number of positions in pattern    '
         call ftpkys(iunit,'NDITHPTS',primary_dither_string,
     &        comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, primary_dither_string
         end if
         status =  0
c
c     
c     string = subpixel
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
     *        comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
c     
         comment = 'y offset from pattern starting position'
         key ='YOFFSET'
         call ftpkyd(iunit,key,yoffset,-7,
     *        comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
         if(verbose.ge.2) print *,'ftpkyj ',key, ' ',yoffset
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
c-------------------------------------------------------------------
c
c     10. Aperture information
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
c     e.g. NRCALL
c
c     
         comment='original AperName supplied by PPS  '
         string  = pps_aper
         key  = 'PPS_APER'
         call ftpkys(iunit,key, trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
c
c     e.g., NRCA1_FULL
c
         comment='PRD science aperture used                       '
         key  = 'APERNAME'
         call ftpkys(iunit,key,trim(apername),comment,status)
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
         if(verbose.ge.2) print *,'ftpkys ',key, ' ',string
c
c     X. visit information
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
         call ftpkys(iunit,key,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
c     
         string = vststart
         comment= 'UTC visit start                        '
         key = 'VSTSTART'
         call ftpkys(iunit,key,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
c     
         string = visitsta
         comment= 'Visit status                           '
         key = 'VISITSTA'
         call ftpkys(iunit,key,trim(string),comment,status)
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
         call ftpkys(iunit,key,trim(string),comment,status)
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
c      comment='Number of frames dropped prior to 1st integration'
c      key = 'DRPFRMS1'
c      call ftpkyj(iunit,key,drpfrms1,comment,status)
c      if (status .gt. 0) then
c         call printerror(status)
c         print 10, key
c      end if
c      status =  0
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

c     
c      association parameters
c     
c     ASNPOOL
c     ASNTABLE
c     
c-------------------------------------------------------------------
c     
c     11. JWST Ephemeris
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
         refframe = 'EME2000'   ! this seems to be hard coded.
         comment='Ephemeris reference frame (EME2000)'
         call ftpkys(iunit,key,trim(refframe),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
c     
         eph_type = 'Definitive'
         key  = 'EPH_TYPE'
         comment='Definitive or Predicted  '
         call ftpkys(iunit,key,trim(eph_type),comment,status)
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
c     12. Velocity aberration correction
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
c     13. time (barycentric, heliocentric)
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
c     14. Photometry 
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
         comment='Nominal pixel area in sq Arc Sec '
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
     *        comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'PHOTPLAM'
         end if
         status =  0
c     
         comment = 'Flux for 1e s-1 in erg cm**-2 s-1 A-1'
         call ftpkyd(iunit,'PHOTFLAM',photflam,6,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'PHOTFLAM'
         end if
         status =  0
c     
         comment = 'STMAG for 1 e- sec-1'
         call ftpkyd(iunit,'STMAG',stmag,-6,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'STMAG'
         end if
         status =  0
c     
         comment = 'ABMAG for 1 e- sec-1'
         call ftpkyd(iunit,'ABMAG',abmag,-6,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'ABMAG'
         end if
         status =  0
         
         
         comment = 'VEGAMAG for 1 e- sec-1'
         vegamag  = -2.5d0 * dlog10(photflam) - vega_zp
         call ftpkyd(iunit,'VEGAMAG',vegamag,-6,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'ABMAG'
         end if
         status =  0
         if(verbose.ge.2) print *,'ftpkyd ',key, ' ',abmag

c----------------------------------------------------------------
c
c     24. additional non-standard keywords that refer to
c     the simulation
c
c------------------------------------------------------------------------
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
         call ftpkys(iunit,key,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
c     
         string = eng_qual
         comment= 'engineering data quality indicator     '
         key = 'ENG_QUAL'
         call ftpkys(iunit,key,trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
c     
c     
c----------------------------------------------------------------------
c
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyj INC_KTC'
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
         comment = 'Guitarra version                      '
         key     = 'VERSION '
         call ftpkye(iunit,key, version,-2, comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, string
         end if
         status =  0
         if(verbose.ge.2) print *,'write_tute_keywords: ftpkys ', string

         comment = 'Randgen seed: clock(0) fixed(!=0)'
         call ftpkyj(iunit,'SEED',seed,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'SEED'
            status = 0
         end if
c     
         comment = 'include IPC F(0) T(1)'
         call ftpkyj(iunit,'INC_IPC',include_ipc,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'INC_IPC'
            status = 0
         end if
c     
         comment = 'include KTC F(0) T(1)'
         call ftpkyj(iunit,'INC_KTC',include_ktc,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'INC_KTC'
            status = 0
         end if
c     
         comment = 'include BIAS F(0) T(1)'
         call ftpkyj(iunit,'INC_BIAS',include_bias,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'INC_BIAS'
            status = 0
         end if
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyj INC_RON'
         comment = 'include readnoise F(0) T(1)'
         call ftpkyj(iunit,'INC_RON',include_readnoise,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'INC_NRON'
            status = 0
         end if
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyj INC_BKG'
         comment = 'include background F(0) T(1)'
         call ftpkyj(iunit,'INC_BKG',include_bg,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'INC_BKG'
            status = 0
         end if
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyj INC_CR'
         comment = 'include Cosmic Rays F(0) T(1)'
         call ftpkyj(iunit,'INC_CR',include_cr, comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'INC_CR'
            status = 0
         end if
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyj INC_DARK'
         comment = 'include darks F(0) T(1)'
         call ftpkyj(iunit,'INC_DARK',include_dark,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'INC_DARK'
            status = 0
         end if
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyj INC_DRKR'
         comment = 'include darks ramp F(0) T(1)'
         call ftpkyj(iunit,'INC_DRKR',include_dark_ramp,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'INC_DRKR'
            status = 0
         end if
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyj INC_LAT'
         comment = 'include latents F(0) T(1)'
         call ftpkyj(iunit,'INC_LAT',include_latents,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'INC_LAT'
            status = 0
         end if
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyj INC_NLIN'
         comment = 'include non-linearity F(0) T(1)'
         call ftpkyj(iunit,'INC_NLIN',include_non_linear,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'INC_NLIN'
            status = 0
         end if
c     
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords ftpkyl NOISELESS',ktc
         comment = 'NOISELESS (T or F)'
         call ftpkyl(iunit,'NOISELES',noiseless,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'KTC'
            status = 0
         end if
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyj INC_FLAT'
         comment = 'include flat F(0) T(1)'
         call ftpkyj(iunit,'INC_FLAT',include_flat,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'INC_FLAT'
            status = 0
         end if
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyd KTC',
     &        ktc
         comment = 'KTC value (e-)'
         call ftpkyd(iunit,'KTC',ktc,-7,comment,status)
         if (status .gt. 0) then
            print *, 'KTC', ktc, status
            call printerror(status)
            status = 0
         end if
         
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyd BIAS',
     &        bias_value
         comment = 'BIAS(e-) [voltage offset]'
         call ftpkyd(iunit,'BIAS',bias_value,-7,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'BIAS'
            status = 0
         end if
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyd BIASSIGM',
     &        voltage_sigma
         comment = 'BIAS(e-) [voltage sigma]'
         call ftpkyd(iunit,'BIASSIGM',voltage_sigma,-7,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'BIASSIGM'
            status = 0
         end if
c     
         if(verbose.ge.2) print *,'write_tute_keywords ftpkyd gain',
     &        gain
         comment = 'Average gain (e-/ADU)'
         call ftpkyd(iunit,'GAIN',gain,-3,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'GAIN'
            status = 0
         end if
c     
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords ftpkyd readnoise',readnoise
         comment = 'Readout noise (e-)'
         call ftpkyd(iunit,'RDNOISE',readnoise,-7,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'RDNOISE'
            status = 0
         end if
c     
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords ftpkyd background',background
         comment = 'background (e-/sec/pixel)'
         call ftpkyd(iunit,'BKG',background,-7,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'BKG'
            status = 0
         end if
c     
         card = '                                              '
         call ftprec(iunit,card, status)
         status =  0
         card = '         Calibration files used by Guitarra    '
         call ftprec(iunit,card, status)
         status =  0
         card = '                                              '
         call ftprec(iunit,card, status)
         status =  0
c     
c     recover the name (not full path) of calibration files
c     by finding the last instance of "/" in the file name;
c     the logical (.TRUE.) indicates the search starts at the
c     end of the string
c     
         indx = index(biasfile,'/',.TRUE.)
         length = len_trim(biasfile)
         long_string  = biasfile(indx+1:length)
         if(verbose.ge.2) print *,'write_tute_keywords ftpkys BIASFILE'
         comment = 'bias file used'
         call ftpkys(iunit,'BIASFILE',long_string,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'BIASFILE'
            status = 0
         end if
c     
         indx = index(darkfile,'/',.TRUE.)
         length = len_trim(darkfile)
         long_string  = darkfile(indx+1:length)
         if(verbose.ge.2) print *,'write_tute_keywords ftpkys DRK_SLP'
         comment = 'Average dark slope file used'
         call ftpkys(iunit,'DRK_SLP',long_string,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'DRK_SLP'
            status = 0
         end if
c     
         indx = index(sigmafile,'/',.TRUE.)
         length = len_trim(sigmafile)
         long_string  = sigmafile(indx+1:length)
         if(verbose.ge.2) print *,'write_tute_keywords ftpkys DRK_SIGM'
         comment = 'Average dark sigma file used'
         call ftpkys(iunit,'DRK_SIGM',long_string,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'DRK_SIGM'
            status = 0
         end if
         
         if(include_dark_ramp.eq.1) then
            indx = index(dark_ramp,'/',.TRUE.)
            length = len_trim(dark_ramp)
            long_string  = dark_ramp(indx+1:length)
         else
            long_string = dark_ramp
         end if
         if(verbose.ge.2) print *,'write_tute_keywords ftpkys DRK_RAMP'
         comment = 'dark ramp used'
         call ftpkys(iunit,'DRK_RAMP',long_string,comment,status)
c     call ftikls(iunit,'DRK_RAMP',long_string,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'DRK_RAMP'
            status = 0
         end if
c     
         indx = index(welldepthfile,'/',.TRUE.)
         length = len_trim(welldepthfile)
         long_string  = welldepthfile(indx+1:length)
         if(verbose.ge.2) print *,'write_tute_keywords ftpkys WELL_DPT'
         comment = 'Well Depth file used'
         call ftpkys(iunit,'WELL_DPT',long_string,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'WELL_DPT'
            status = 0
         end if
c     
         indx = index(gainfile,'/',.TRUE.)
         length = len_trim(gainfile)
         long_string  = gainfile(indx+1:length)
         if(verbose.ge.2) print *,'write_tute_keywords ftpkys GAIN_MAP'
         comment = 'Gain map file used'
         call ftpkys(iunit,'GAIN_MAP',long_string,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'GAIN_MAP'
            status = 0
         end if
c     
         indx = index(linearityfile,'/',.TRUE.)
         length = len_trim(linearityfile)
         long_string  = linearityfile(indx+1:length)
         if(verbose.ge.2) print *,'write_tute_keywords ftpkys LIN_FILE'
         comment = 'Linearity file used'
         call ftpkys(iunit,'LIN_FILE',long_string,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'LIN_FILE'
            status = 0
         end if
c     
         indx = index(ipc_file,'/',.TRUE.)
         length = len_trim(ipc_file)
         long_string  = ipc_file(indx+1:length)
         if(verbose.ge.2) print *,'write_tute_keywords ftpkys IPC_FILE'
         comment = 'IPC file used'
         call ftpkys(iunit,'IPC_FILE',long_string,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'IPC_FILE'
            status = 0
         end if
c     
         indx = index(flat_file,'/',.TRUE.)
         length = len_trim(flat_file)
         long_string  = flat_file(indx+1:length)
         if(verbose.ge.2) print *,'write_tute_keywords ftpkys FLATFILE'
         comment = 'Flatfield used'
         call ftpkys(iunit,'FLATFILE',long_string,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'FLATFILE'
            status = 0
         end if
      end if
      if(extnum.eq.0) return
c
c11111111111111111111111111111111111111111111111111111111111111111111111
c
c     Extension 1  data 4-D array
c
      if(extnum .eq.1) then
c         
c     create new image extension
c
         call ftiimg(iunit,bitpix,naxis,naxes, status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'ftpiimg: ',status
         end if
         comment = 'Extension name'
         call ftpkys(iunit,'EXTNAME',extname,comment,status)
         if (status .gt. 0) then
            print *,'at EXTNAME'
            call printerror(status)
         end if
         if(verbose.gt.0)  print *,'write_write_tute_keywords: ftpkys ',
     &        iunit, ' ', extname,' ',status
c
         comment = 'Extension version'
         call ftpkyj(iunit,'EXTVER',extver,comment,status)
         if (status .gt. 0) then
            print *,'at EXTVER'
            call printerror(status)
         end if
         if(verbose.gt.0)  print *,'write_write_tute_keywords: ftpkys ',
     &        iunit, extver ,status
c
         call ftmahd(iunit,2,hdutype, status)
         if (status .gt. 0) then
            print *,'at ftmahd'
            call printerror(status)
            stop
         end if
c     
c     4. Coordinate system
c     
         card = '                                              '
         call ftprec(iunit,card, status)
         status =  0
         if(verbose.ge.2) 
     &        print *,'write_tute_keywords: ftprec ', status
         card = '         Infomation about the coordinates in the file'
         call ftprec(iunit,card, status)
         status =  0
         if(verbose.ge.2) print *,'write_tute_keywords: ftprec ', status
         card = '                                              '
         call ftprec(iunit,card, status)
         status =  0
         if(verbose.ge.2) print *,'write_tute_keywords: ftprec ', status
c     
         comment  = 'Name of coordinate reference frame '
         string   = 'ICRS'
         key      = 'RADESYS'
         call ftpkys(iunit,key, trim(string),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print 10, key
         end if
         status =  0
         if(verbose.ge.2) print *,'write_tute_keywords: ftpkys ', string
         end if
c
c     fake WCS keywords
c 
         card = '                                              '
         call ftprec(iunit,card, status)
         status =  0
         card = '      Spacecraft pointing information               '
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
c-------------------------------------------------------------------
c
c     23. WCS

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
         if(distortion.ne.0) then
            comment ='version of SIAF Coefficients'
            call ftpkys(iunit,'SIAF',siaf_version,comment,status)
            if (status .gt. 0) then
               call printerror(status)
               print *, 'SIAF'
            end if
            status =  0
         end if
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
c         comment='Axis 3 coordinate of reference pixel   '
c         if(read_patt .eq. 'RAPID') then
c            call ftpkyd(iunit,'CRPIX3',crpix3,-7,comment,status)
c         else
c            call ftpkyd(iunit,'CRPIX3',crpix3/2.d0,-7,comment,status)
c         end if
c         if (status .gt. 0) then
c            call printerror(status)
c            print *, 'CRPIX3'
c         end if
c         status =  0
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
c         comment='T at reference pixel (seconds)       '
c         call ftpkyd(iunit,'CRVAL3',crval3,-12,comment,status)
c         if (status .gt. 0) then
c            call printerror(status)
c            print *, 'CRVAL3'
c         end if
c         status =  0
c     
         comment='Projection type                        '
         call ftpkys(iunit,'CTYPE1',trim(ctype1),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'CTYPE1'
         end if
         status =  0
c     
         call ftpkys(iunit,'CTYPE2',trim(ctype2),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'CTYPE2'
         end if
         status =  0
c     
c         call ftpkys(iunit,'CTYPE3','none',comment,status)
c         if (status .gt. 0) then
c            call printerror(status)
c            print *, 'CTYPE3'
c         end if
c         status =  0
c     
         cunit1 = 'deg'
         comment='First axis units                       '
         call ftpkys(iunit,'CUNIT1',trim(cunit1),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'CUNIT1'
         end if
         status =  0
c     
         cunit2 = 'deg'
         comment='Second axis units                      '
         call ftpkys(iunit,'CUNIT2',trim(cunit2),comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'CUNIT2'
         end if
         status =  0
c     
c         cunit3 = 'sec'
c         comment='Third axis units                      '
c         call ftpkys(iunit,'CUNIT3',trim(cunit3),comment,status)
c         if (status .gt. 0) then
c            call printerror(status)
c            print *, 'CUNIT3'
c         end if
c         status =  0
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
         comment='V_IDL_PARITY rotation between Ideal xy and V2V3 '
         call ftpkyj(iunit,'VPARITY',v_idl_parity,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'v_idl_parity'
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
c     These keywords are non-STScI standard
c     
c     
c         if(naxis .eq.4) then
c            comment='Axis 4 coordinate of reference pixel   '
c            call ftpkyd(iunit,'CRPIX4',1.d0,-7,comment,status)
c            if (status .gt. 0) then
c               call printerror(status)
c               print *, 'CRPIX4'
c            end if
c            status =  0
c            comment='4th dimension at reference pixel (pixel)   '
c            call ftpkyd(iunit,'CRVAL4',1.d0,-7,comment,status)
c            if (status .gt. 0) then
c            call printerror(status)
c            print *, 'CRVAL4'
c         end if
cc         
c         status =  0
c         comment='Fourth axis increment per pixel         '      
c         call ftpkyd(iunit,'CDELT4',1.d0,12,comment,status)
c         if (status .gt. 0) then
c            call printerror(status)
c            print *, 'CDELT4'
c         end if
c         status =  0
c      end if
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
c      cd3_3  = cdelt3
c      call ftpkyd(iunit,'CD3_3',cd3_3,10,comment,status)
c      if (status .gt. 0) then
c         call printerror(status)
c         print *, 'CD3_3'
c      end if
c      status =  0
c     
      status =  0
      comment='First axis increment per pixel         '      
      call ftpkyd(iunit,'CDELT1',cdelt1,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CDELT1'
      end if
c
      status =  0
      comment='Second axis increment per pixel         '      
      call ftpkyd(iunit,'CDELT2',cdelt2,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CDELT2'
      end if
c
c
c      status =  0
c      comment='Third axis increment per pixel         '      
c      call ftpkyd(iunit,'CDELT3',cdelt3,12,comment,status)
c      if (status .gt. 0) then
c         call printerror(status)
c         print *, 'CDELT3'
c      end if
c
      status =  0
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
      pc3_1  = cdelt3
      call ftpkyd(iunit,'PC3_1',pc3_1,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'PC3_3'
      end if
      status =  0
c     
      if(distortion.ge.1) then

         card = 'WCS derived from SIAF coefficients'
         call ftpcom(iunit,card,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'ftpcom'
         end if
         status =  0
      end if
c     
      if(distortion.eq.1) then
         comment='polynomial order axis 1, detector to sky'
         call ftpkyj(iunit,'A_ORDER',a_order,comment,status)
         if (status .gt. 0) then
            print *, 'A_ORDER'
            call printerror(status)
         end if
         status =  0
c     
         comment='distortion coefficient'
         do ii = 1, a_order+1
            iexp = ii - 1
            do jj = 1, a_order+1
               jexp = jj - 1
               if(iexp+jexp.le.a_order .and.aa(ii,jj).ne.0.0d0) then
                  write(coeff_name, 100) iexp, jexp
 100              format('A_',i1,'_',i1)
                  call ftpkyd(iunit,coeff_name,aa(ii,jj),10,comment,
     &                 status)
 115              format(a10,2x,e15.8)
                  if (status .gt. 0) then
                     print 130,coeff_name, aa(ii,jj)
 130                 format(a8,2x,e15.8)
                     call printerror(status)
                  end if
                  status =  0
               end if
            end do
         end do
c     
         comment='polynomial order axis 2, detector to sky'
         call ftpkyj(iunit,'B_ORDER',b_order,comment,status)
         if(status .gt. 0) then
            print *, 'B_ORDER'
            call printerror(status)
         end if
         status =  0
c     
         comment='SIP coefficient, forward transform'
         do ii = 1, b_order+1
            iexp = ii - 1
            do jj = 1, b_order+1
               jexp = jj - 1
               if(iexp+jexp.le.b_order.and.bb(ii,jj).ne.0.0d0) then
                  write(coeff_name, 140) iexp, jexp
 140              format('B_',i1,'_',i1)
                  call ftpkyd(iunit,coeff_name,bb(ii,jj),10,comment,
     &                 status)
c     print 115, coeff_name, bb(ii,jj)
                  if (status .gt. 0) then
                     print 130,coeff_name, bb(ii,jj)
                     call printerror(status)
                  end if
                  status =  0
               end if
            end do
         end do
c     
c     inverse 
c     
         comment='polynomial order axis 1, sky to detector'
         call ftpkyj(iunit,'AP_ORDER',ap_order,comment,status)
         if (status .gt. 0) then
            print *, 'AP_ORDER'
            call printerror(status)
         end if
         status =  0
c     
         comment='SIP coefficient, reverse transform'
         do ii = 1, ap_order+1
            iexp = ii - 1
            do jj = 1, ap_order+1
               jexp = jj - 1
               if(iexp+jexp.le.ap_order.and.ap(ii,jj).ne.0.0d0) then
                  write(coeff_name, 150) iexp, jexp
 150              format('AP_',i1,'_',i1)
                  call ftpkyd(iunit,coeff_name,ap(ii,jj),10,comment,
     &                 status)
c     print 115, coeff_name, ap(ii,jj)
                  if (status .gt. 0) then
                     print 130,coeff_name, ap(ii,jj)
                     call printerror(status)
                  end if
                  status =  0
               end if
            end do
         end do
c     
         comment='polynomial order axis 2, sky to detector'
         call ftpkyj(iunit,'BP_ORDER',bp_order,comment,status)
         if(status .gt. 0) then
            print *, 'BP_ORDER'
            call printerror(status)
         end if
         status =  0
c     
         comment='distortion coefficient'
         do ii = 1, bp_order+1
            iexp = ii - 1
            do jj = 1, bp_order+1
               jexp = jj - 1
               if(iexp+jexp.le.bp_order.and.bp(ii,jj).ne.0.0d0) then
                  write(coeff_name, 160) iexp, jexp
 160              format('BP_',i1,'_',i1)
                  call ftpkyd(iunit,coeff_name,bp(ii,jj),10,comment,
     &                 status)
c     print 115, coeff_name, bp(ii,jj)
                  if (status .gt. 0) then
                     print 130,coeff_name, bp(ii,jj)
                     call printerror(status)
                  end if
                  status =  0
               end if
            end do
         end do
      end if
c
      return
      end
