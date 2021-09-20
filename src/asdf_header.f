c
c-----------------------------------------------------------------------
c
c     This subroutine re-writes keywords found in the previous HDUs
c     into a single place. The  keywords are written into a file that
c     is then read as a series of strings. These are stored in an 
c     integer array where each array element contains the ASCII code of 
c     the corresponding string character. End of line/linefeed has the
c     ASCII code of 10 in the STScI version. This is then saved as a
c     binary table.

      subroutine asdf_header
     *     (unit, nx, ny, 
     *     bitpix, naxis, naxes, filename,
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
     *     pupil, detector,
     *     effexptm, duration,
     *     pntg_seq, expcount, expripar, tsovisit, expstart,
     *     expmid, expend, read_patt, nints, ngroups, groupgap,
     *     tframe, tgroup, effinttm, exptime,nrststrt, nresets, 
     *     zerofram, sca_num, drpfrms1, drpfrms3,
     *     subarray,  colcornr, rowcornr, subsize1, subsize2,
     *     substrt1,substrt2, fastaxis, slowaxis, 
     &     patttype, primary_dither_string, numdthpt, patt_num, 
     &     subpixel,  subpxpns, subpxnum,
     &     subpixel_dither_type,
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
c     *     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2, 
c     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3, equinox,
     *     ra_ref, dec_ref, roll_ref, v2_ref, v3_ref, ra_v1, dec_v1,
     *     v_idl_parity, v3i_yang,
     *     det_sci_parity, det_sci_yangle,
c     &     a_order, aa, b_order, bb,
c     &     ap_order, ap, bp_order, bp, 
     &     nframes, object, sca_id,
c     &     photplam, photflam, stmag, abmag,vega_zp,
     &     naxis1, naxis2,
c     &     noiseless, include_ipc, include_bias,
c     &     include_ktc, include_bg, include_cr, include_dark,
c     &     include_dark_ramp,
c     &     include_latents, include_readnoise, include_non_linear,
c     &     include_flat,
     &     version,
c     &     ktc,bias_value,voltage_sigma,
     &     gain,readnoise, background,
c     &     dark_ramp,     
c     &     biasfile, darkfile, sigmafile, 
c     &     welldepthfile, gainfile, linearityfile,
c     &     badpixelmask, ipc_file, flat_file,
c     &     seed, dhas, origin,
     &     x_sci_ref, y_sci_ref, radesys,
     &     verbose)

    
c
c========================================================================
c
      implicit none
      double precision gain, readnoise, background, 
     &     exptime, x_sci_ref, y_sci_ref
      integer bitpix, unit, nx, ny, naxis, naxes, naxis1, naxis2,
     &     verbose, sca_id, distortion
      character filename*(*), full_date*23, string*40, 
     &     pw_filter*8, fw_filter*8, subarray*8
      character pattern_size*20, subpixel_dither_type*(*),
     &     primary_dither_string*(*)
      logical zerofram
      real version
      integer indx, length, pad
c     
c     fits extension related
c
      integer pcount, gcount, tfields,
     &     extver, status, blocksize, ii, jj, ll, varidat, colnum,
     &     nrows, frow, felem
      character var*1, line*512, temp*8
      character extname*18, ttype*40, tform*10, tunit*40,xtension*20
      integer array
      dimension array(30000), ttype(30), tform(30), 
     &     tunit(40)
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
      character date_obs*10, time_obs*(*), date_end*10, time_end*(*),
     &     obs_id*26, visit_id*11, observtn*3, visit*11, obslabel*40,
     &     visitgrp*2, seq_id*1, act_id*2, exposure_request*5, 
     &     template*50, eng_qual*8,  program_id*7
      logical bkgdtarg
      integer activity_id
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
     &     pupil*7
      logical pilin
c
c     exposure parameters
c
      double precision expstart, expmid, expend, 
     &     tframe, tgroup, effinttm, effexptm, duration
      integer pntg_seq, expcount, nints, ngroups, nframes, groupgap,
     &     nsamples, nrststrt, NRESETS, sca_num, drpfrms1,drpfrms3,
     &     tsample
      character expripar*20, exp_type*30
      logical tsovisit
c
c     subarray parameters
c
      integer substrt1,substrt2, subsize1,subsize2, fastaxis, slowaxis,
     &      colcornr, rowcornr
c
c     NIRCam dither pattern parameters
c
      double precision xoffset, yoffset
      integer patt_num, numdthpt,subpxnum, subpxpns,
     &     position_number
      character  read_patt*10, subpixel*16, patttype*15
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
      character apername*(*), pps_aper*(*)
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
      character siaf_version*(*)
c
      integer wcsaxes, v_idl_parity, det_sci_parity 
      double precision crpix1, crpix2, crpix3,
     &     crval1, crval2, crval3, cdelt1, cdelt2,cdelt3,
     &     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2,cd3_3,
     &     ra_ref, dec_ref, roll_ref,
     &     v3i_yang, det_sci_yangle,wavstart, wavend, sporder

      character ctype1*(*), ctype2*(*), ctype3*15,
     &     cunit1*40, cunit2*40, cunit3*40,
     &     s_region*100
c
      character header*128, history*128, keys*30, datatype*20,
     &     asdf_library*128, byteorder*20, source*128, fmt*100

      dimension header(5), history(5), keys(30)
c
      dimension naxes(4)
c--------------------
      if(verbose.gt.1) then
      print *, ' '
      print *,'asdf_header'
      print *,'1', ' unit ', unit, ' nx ', nx,' ny ', ny, 
     *     ' bitpix ',bitpix, ' naxis ',naxis, ' naxes ',naxes,
     *     ' filename ', trim(filename),' title ',
     *     trim(title), ' pi_name ', trim(pi_name), ' category ', 
     *     category, ' subcat ', subcat, ' scicat ', scicat,
     *     ' cont_id ', cont_id, ' full_date ', full_date,
     *     ' date_obs ', date_obs, ' time_obs ',time_obs
      print *, '1.5 date_end ',
     *     date_end, ' time_end ',time_end, ' obs_id ',obs_id,
     *     ' visit_id ', visit_id, 
     *     ' program_id ', program_id, 
     *     ' observtn   ',observtn, 
     *     ' visit    ', visit, ' obslabel ', obslabel,
     *     ' visitgrp ', visitgrp, ' seq_id ', seq_id, 
     *     ' act_id ', act_id, ' exposure ' , exposure_request,
     *     ' template ', template, 
     *     ' eng_qual ', eng_qual, 
     *     ' visitype ', visitype, 
     *     ' vststart ', vststart, 
     *     ' nexposur ', nexposur, ' intarget ', intarget,
     *     targoopp, targprop, targ_ra, targ_dec, 
     *     targura, targudec, mu_ra, mu_dec, mu_epoch,
     *     prop_ra, prop_dec
      print *, '1.6 ',
     *     instrume, module, channel, filter_id, coronmsk,
     *     pupil, detector,
     *     effexptm, duration
      print *, '2 ',
     *     pntg_seq, expcount, expripar, tsovisit, expstart,
     *     expmid, expend, read_patt, nints, ngroups, groupgap,
     *     tframe, tgroup, effinttm, exptime,nrststrt, nresets, 
     *     zerofram, sca_num, drpfrms1, drpfrms3,
     *     subarray,  colcornr, rowcornr, subsize1, subsize2,
     *     substrt1,substrt2, fastaxis, slowaxis, 
     &     patttype,  primary_dither_string, numdthpt, patt_num, 
     &     subpixel,  subpxpns, subpxnum,
     &     subpixel_dither_type
      print *, '3',
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
     *     ctype1, ctype2
c     *     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2, 
c     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3, equinox,
      print *, '4',
     *     ra_ref, dec_ref, roll_ref, v2_ref, v3_ref, 
     *     v_idl_parity, v3i_yang,
     *     det_sci_parity, det_sci_yangle,
c     &     a_order, aa, b_order, bb,
c     &     ap_order, ap, bp_order, bp, 
     &     nframes, object, sca_id,
c     &     photplam, photflam, stmag, abmag,vega_zp,
     &     naxis1, naxis2,
c     &     noiseless, include_ipc, include_bias,
c     &     include_ktc, include_bg, include_cr, include_dark,
c     &     include_dark_ramp,
c     &     include_latents, include_readnoise, include_non_linear,
c     &     include_flat,
     &     version
c     &     ktc,bias_value,voltage_sigma,
      print *, '5',
     &     gain,readnoise, background
c     &     dark_ramp,     
c     &     biasfile, darkfile, sigmafile, 
c     &     welldepthfile, gainfile, linearityfile,
c     &     badpixelmask, ipc_file, flat_file,
c     &     seed, dhas, origin,
      print *, '6',
     &     x_sci_ref, y_sci_ref, radesys
      print *,'7',
     &     verbose
      end if
c-------------------
      naxis1 = naxes(1)
      naxis2 = naxes(2)
      tsample = 10              ! microseconds
      activity_id = 1
      position_number = 1

      pattern_size   = 'DEFAULT'

      open(1,file = 'poubelle.asdf')
c
c-------
c
c     1. header
c
      header(1) = '#ASDF 1.0.0'
      header(2) = '#ASDF_STANDARD 1.5.0'
      header(3) = '%YAML 1.1'
      header(4) = '%TAG ! tag:stsci.edu:asdf/'
      header(5) = '--- !core/asdf-1.1.0'
      do ii = 1, 5
         write(1,10) trim(header(ii))
 10      format(A)
      end do
      keys(1)  = 'asdf_library:'
      asdf_library = " !core/software-1.0.0 {author: Space Telescope Sci
     &ence Institute, homepage: 'http://github.com/spacetelescope/asdf',
     &"
     
      write(1,30) trim(keys(1)),trim(asdf_library)
 30   format(A,1x,A)
      write(1,40)
 40   format(2x,'name: asdf, version: 2.7.2}')
c
      keys(2)   ='history:'
      history(1)='  extensions:'
      history(2)='  - !core/extension_metadata-1.0.0'
      history(3)='    extension_class: asdf.extension.BuiltinExtension'
      history(4)='    software: !core/software-1.0.0 {name: asdf, versio
     &n: 2.7.2}'
      history(5)='_fits_hash: 0d4a8a489b11dbf9d5bec7adeb82a9bac6e2cc10e
     &a82b201b523dfed9d6dd4da'
      write(1,10) keys(2)
      do ii = 1, 4
         write(1,10) trim(history(ii))
      end do
c
      keys(3)  = 'data: !core/ndarray-1.0.0'
      source   = '  source: fits:SCI,1'
      if(bitpix.eq.16) then
         datatype = '  datatype: uint16'
      end if
      byteorder = '  byteorder: big'
      write(1,10) keys(3)
      write(1,10) trim(source)
      write(1,10) trim(datatype)
      write(1,10) trim(byteorder)
      write(1, 150) nints, ngroups, nx, ny
 150  format(2x,'shape: [ ',i2,', ',i2,', ',i4,', ',i4,']')
c
c
c-------
c
c     2. simulation parameters
c     (catalogues etc)
c
      keys(4)  = 'extra_fits:'
      keys(5)  = '  PRIMARY:'
      keys(6)  = '    header:'
      do ii = 4, 6
         write(1,10) trim(keys(ii))
      end do
      write(1, 160) version
 160  format(4x,'- [VERSION,', f5.2,',Guitarra version]')
c
      write(1, 170) gain
 170  format(4x,'- [GAIN,', f5.2,', gain value used]')
c
c     This lists the extension 2 FITS keywords and data type
c
      write(1, 180)
 180  format('group: !core/ndarray-1.0.0',/,'  source: fits:GROUP,1',
     &     /,'  datatype:',
     &/,2x,'- {byteorder: little, datatype: int16, name: ',
     &'integration_number}',
     &/,2x,'- {byteorder: little, datatype: int16, name: group_number}',
     &/,2x,'- {byteorder: little, datatype: int16, name: end_day}',
     &/,2x,'- {byteorder: little, datatype: int32, name: end_millisecond
     &s}'
     &     ,/,2x,'- {byteorder: little, datatype: int16, name: ',
     &     'end_submilliseconds}')
      write(1,181)
 181  format(2x,'- byteorder: big',
     &     /,4x, 'datatype: [ascii, 26]',
     &     /,4x, 'name: group_end_time',
     &     /,2x, '- {byteorder: little, datatype: int16, name: ',
     &     'number_of_columns}',
     &     /,2x, '- {byteorder: little, datatype: int16, name: ',
     &     'number of rows}',
     &     /,2x, '- {byteorder: little, datatype: int16, name: ',
     &     'number of gaps}',
     &     /,2x, '- {byteorder: little, datatype: int16, name: ',
     &     'completion_code_number}',
     &     /'  - byteorder: big',
     &     /,4x, 'datatype: [ascii, 36]',
     &     /,4x, 'name: completion_code_text',
     &     /,2x, '- {byteorder: little, datatype: float64, name: ',
     &     'bary_end_time}',
     &     /,2x, '- {byteorder: little, datatype: float64, name: ',
     &     'helio_end_time}',
     &     /,2x, 'byteorder: big',
     &     /,2x, 'shape: [4, 1]',
     &     /,2x, 'offset: 98')
c
c     This repeats the contents of extension 3
c
      write(1,190)
 190  format('int_times: !core/ndarray-1.0.0',
     &     /,2x,'source: fits:INT_TIMES,1',
     &     /,2x,'datatype:',
     &     /,2x,'- {byteorder: little, datatype: int32, name: ',
     &     'integration_number}',
     &     /,2x,'- {byteorder: little, datatype: float64, name: ',
     &     'int_start_MJD_UTC}',
     &     /,2x,'- {byteorder: little, datatype: float64, name: ',
     &     'int_mid_MJD_UTC}',
     &     /,2x,'- {byteorder: little, datatype: float64, name: ',
     &     'int_end_MJD_UTC}',
     &     /,2x,'- {byteorder: little, datatype: float64, name: ',
     &     'int_start_BJD_TDB}',
     &     /,2x,'- {byteorder: little, datatype: float64, name: ',
     &     'int_mid_BJD_TDB}',
     &     /,2x,'- {byteorder: little, datatype: float64, name: ',
     &     'int_end_BJD_TDB}',
     &     /,2x, 'byteorder: big',
     &     /,2x, 'shape: [1]')
c
c     This write parameters describing  aperture, coordinate system
c     etc.
c
      keys(12) = 'meta:'
      if(verbose.eq.1) write(*, 300) trim(keys(12))
      write(1, 300) trim(keys(12))
 300  format(a5)
c
c     1. basics
c
      if(verbose.eq.1) write(*,310) apername(1:len_trim(apername))
      write(1,310) apername(1:len_trim(apername))
 310  format(2x, "aperture: {name: ",A,"}")
c
      write(1, 320) trim(radesys)
      if(verbose.eq.1) write(*, 320) trim(radesys)
 320  format(2x,"coordinates : {reference_frame: ",A,"}")
c
      if(verbose.eq.1) write(*,315) full_date
      write(1,315) full_date
 315  format(2x, "date: '",A,"'")
c
c     2. dither
c
      if(verbose.eq.1) then
         write(*, 330)  numdthpt, !trim(primary_dither_string),
     &        trim(pattern_size), 
     &        position_number,
     &        trim(patttype),
     &        subpxnum, 
     &        subpxpns, 
     &        trim(subpixel_dither_type),
     &        subpxpns, 
     &        xoffset, 
     &        yoffset
      end if
c
      write(1, 330) numdthpt, ! trim(primary_dither_string),
     &     trim(pattern_size), 
     &     position_number,
     &     trim(patttype),
     &     subpxnum, 
     &     subpxpns, 
     &     trim(subpixel_dither_type),
     &     subpxpns, 
     &     xoffset, 
     &     yoffset
c     dither points has to be defined as string:
c  dither: {dither_points: 8NIRSPEC, pattern_size: DEFAULT, position_number: 1, primary_type: FULLBOX,
c    subpixel_number: 1, subpixel_total_points: 1, subpixel_type: STANDARD, total_points: 8,
c    x_offset: -24.60009, y_offset: -64.09999}

c 330  format(2x,"dither: {dither_points: ",a,",",
 330  format(2x,"dither: {dither_points: ",i0,",",
     &     /,4x,'pattern_size: ',    A,',',
     &     /,4x,'position_number: ',i1,',',
     &     /,4x,'primary_type: ',    a,',',
     &     /,4x,'subpixel_number: ',i2,',',
     &     /,4x,'subpixel_total_points: ',i2,',',
     &     /,4x,'subpixel_type: ',   A,',',
     &     /,4x,'total_points: ',   i2,',',
     &     /,4x,'x_offset: ',     f8.3,',',
     &     /,4x,'y_offset: ',     f8.3,'}')
c
c     3. Exposure
c
      if(verbose.eq.1) then 
         write(*, 341) duration,
     &        expend, 
     &        effexptm,
     &        tframe,  
     &        tgroup, 
     &        groupgap,
     &        effinttm, 
     &        expmid, 
     &        nframes, 
     &        ngroups, 
     &        nints, 
     &        nrststrt, 
     &        nresets,
     &        read_patt, 
     &        tsample, 
     &        expstart
      end if
      write(1, 341) duration, 
     &     expend, 
     &     effexptm,
     &     tframe,  
     &     tgroup, 
     &     groupgap,
     &     effinttm, 
     &     expmid, 
     &     nframes, 
     &     ngroups, 
     &     nints, 
     &     nrststrt, 
     &     nresets,
     &     read_patt, 
     &     tsample, 
     &     expstart
 341  format(2x,'exposure: {duration: ',f11.5,',',
     &     /,4x,'end_time: ', f11.5,',',
     &     /,4x,'exposure_time: ', f11.5,',',
     &     /,4x,'frame_time: ', f11.5,',',
     &     /,4x,'group_time: ', f11.5,',',
     &     /,4x,'groupgap: ', i2,',',
     &     /,4x,'integration_end: 0,',
     &     /,4x,'integration_start: 1 ,',
     &     /,4x,'integration_time: ',f11.5,',',
     &     /,4x,'mid_time: ', f11.5,','
     &     /,4x,'nframes: ',i2, ',',
     &     /,4x,'ngroups: ',i2, ',',
     &     /,4x,'nints: '  ,i2, ',',
     &     /,4x,'nresets_at_start: '    ,i2,',',
     &     /,4x,'nresets_between_ints: ',i2,',',
     &     /,4x,'readpatt: ',A,             ',',
     &     /,4x,'sample_time: ', i2,',',
     &     /,4x,'start_time: ',f11.5,',',
     &     /,4x,'type: NRC_IMAGE}')
c
c     4. filename
c
      indx = index(filename,'/',.TRUE.)
      length = len_trim(filename)

      if(verbose.eq.1) write(*, 351) trim(filename(indx+1:length))
      write(1, 351) trim(filename(indx+1:length))
 351  format(2x,'filename: ',A)
c
c     5. file type
c
      if(verbose.eq.1) write(*, 352)
      write(1, 352)
 352  format(2x,'filetype: raw')
c
c     6. instrument setup
c
      if(verbose.eq.1) then 
         write(*, 353) trim(channel),
     &        trim(detector),
     &        trim(filter_id), 
     &        module, 
     &        instrume,
     &        trim(pupil)
      endif
      write(1, 353) trim(channel), 
     &     trim(detector),
     &     trim(filter_id), 
     &     module, 
     &     instrume,
     &     trim(pupil)
 353  format(2x,'instrument: {channel: ',a,',',
     &     /,4x,'detector: ', a, ',',
     &     /,4x,'filter: ', a,',',
     &     /,4x,'module: ',a1,',',
     &     /,4x,'name: ' , a,',',
     &     /,4x,'pupil: ', a,'}')
c
c     7. model - unclear what this is supposed to mean; using the mirage value
c
      if(verbose.eq.1) write(*, 354)
      write(1, 354)
 354  format(2x,'model_type:',1x,'Level1bModel')
c
c     8. observation
c
      if(verbose.eq.1) then
         write(*, 361) activity_id, 
     &        date_obs, 
     &        exposure_request,
     &        obs_id,
     &        obslabel, 
     &        observtn, 
     &        program_id, 
     &        seq_id, 
     &        trim(time_obs),
     &        visitgrp,
     &        visit_id, 
     &        visit
      end if
      write(1, 361) activity_id, 
     &     date_obs, 
     &     exposure_request, 
     &     obs_id,
     &     trim(obslabel), 
     &     observtn, 
     &     program_id, 
     &     seq_id,
     &     trim(time_obs),
     &     visitgrp, 
     &     trim(visit_id), 
     &     trim(visit)
 361  format(2x,"observation: {activity_id: '",i2.2,"',",
     &     /,4x,"date: '",a,"',",
     &     /,4x,"exposure_number: '",A,"',",
     &     /,4x,"obs_id: ", A,",",
     &     /,4x,"observation_label: '", A, "',",
     &     /,4x,"observation_number: '",A, "',",
     &     /,4x,"program_number: '", A,"',",
     &     /,4x,"sequence_id: '", A,"',",
     &     /,4x,"time: '",A,"',",
     &     /,4x,"visit_group: '", A, "',",
     &     /,4x,"visit_id: '", A,"',",
     &     /,4x,"visit_number: '",A,"'}")
c
c     9. origin
c
      if(verbose.eq.1) write(*,363)
      write(1,363)
 363  format(2x,'origin:',1x,'AZLAB')
c
c     10. pointing
c
      if(verbose.eq.1) write(*, 364) dec_v1, pa_v3, ra_v1
      write(1, 364) dec_v1, pa_v3, ra_v1
 364  format(2x, 'pointing: {dec_v1: ',f14.8,',',
     &     /,4x,'pa_v3: ', f6.2, ',',
     &     /,4x,'ra_v1: ',f14.8,'}')
c
c     11.Program 
c     
      if(verbose.eq.1) write(*, 365) category, cont_id, pi_name, scicat
      write(1, 365) category, cont_id, trim(pi_name), scicat
c     &     , subcat,title
 365  format(2x,'program: {category: ', a4,',',
     &     /,4x,'continuation_id: ',i1,',',
     &     /,4x,'pi_name: ', a, ',',
     &     /,4x,'science_category: ',A,',',
     &     /,4x,'sub_category: UNKNOWN',',',
     &     /,4x,'title: None }')
c
c     12. subarray
c
      if(verbose.eq.1) write(*, 371) fastaxis, subarray, slowaxis,
     &      subsize1, substrt1,subsize2, substrt2
      write(1, 371) fastaxis, 
     &     trim(subarray), 
     &     slowaxis,
     &     subsize1, 
     &     substrt1, 
     &     subsize2, 
     &     substrt2
 371  format(2x,'subarray: {fastaxis: ',i0,',',
     &     /,4x,'name: ', a,',',
     &     /,4x,'slowaxis: ',i0,',',
     &     /,4x,'xsize: ', i0,',',
     &     /,4x,'xstart: ', i0,',',
     &     /,4x,'ysize: ',   i0,',',
     &     /,4x,'ystart: ', i0,'}')
c
c     13. target
c
      if(verbose.eq.1) write(*, 381) trim(targprop), targ_dec,  
     &     trim(pi_name),targ_ra
      write(1, 381) trim(targprop), 
     &     targ_dec, 
     &     trim(pi_name), 
     &     targ_ra
 381  format(2x,'target: {catalog_name: ',A,',',
     &     /,4x,'dec: ', f10.4, ',',
     &     /,4x,'proposer_name: ', A,',',
     &     /,4x,'ra: ',f10.4,'}')
c
c     14. telescope
c
      if(verbose.eq.1) write(*,382)
      write(1,382)
 382  format(2x,'telescope : JWST')
c
c     15. TSO visit
c
      if(verbose.eq.1) write(*,383)
      write(1,383)
 383  format(2x,'visit: {tsovisit : false}')
c
c     16. WCS
c      
      if(verbose.eq.1) then 
         write(*,391) cdelt1, cdelt2, crpix1,crpix2, crval1, crval2,
     &        trim(ctype1), trim(ctype2), trim(cunit1), trim(cunit2), 
     &        roll_ref, x_sci_ref, y_sci_ref, v2_ref, v3_ref,v3i_yang,
     &        v_idl_parity, wcsaxes
      end if
      write(1,391) cdelt1, 
     &     cdelt2, 
     &     crpix1, 
     &     crpix2,
     &     crval1,
     &     crval2,
     &     trim(ctype1),
     &     trim(ctype2),
     &     trim(cunit1),
     &     trim(cunit2),
     &     roll_ref,
     &     x_sci_ref, 
     &     y_sci_ref,
     &     v2_ref, 
     &     v3_ref,
     &     v3i_yang,
     &     v_idl_parity,
     &     wcsaxes
 391  format(2x, 'wcsinfo: {cdelt1: ', e21.15, ',',
     &     /,4x, 'cdelt2: ', e21.15, ',',
     &     /,4x, 'crpix1: ', f6.1,   ',',
     &     /,4x, 'crpix2: ', f6.1,',',
     &     /,4x, 'crval1: ',f15.9,',',
     &     /,4x, 'crval2: ',f15.9,',',
     &     /,4x, 'ctype1: ', A,',',
     &     /,4x, 'ctype2: ', A,',',
     &     /,4x, 'cunit1: ', a6,',', 
     &     /,4x, 'cunit2: ', a6,',',
     &     /,4x, 'roll_ref: ',      f15.9,',',
     &     /,4x, 'siaf_xref_sci: ',  f6.1,',',
     &     /,4x, 'siaf_yref_sci: ',  f6.1,',',
     &     /,4x, 'v2_ref: '       , f15.9,',',
     &     /,4x, 'v3_ref: '       , f15.9,',',
     &     /,4x, 'v3yangle: '     , f15.9,',',
     &     /,4x, 'vparity:  '     ,    i2,',',
     &     /,4x, 'wcsaxes: '      ,    i2,'}')
c
c--   New extention:
c
c     zeroframe
c
c      if(zerofram .eqv. .true.) then
      if(verbose.eq.1) write(*,410)
      write(1,410)
 410  format('zeroframe: !core/ndarray-1.0.0')
      if(verbose.eq.1) write(*,420)
      write(1,420)
 420  format(2x, 'source: fits:ZEROFRAME,1')

      if(bitpix.eq.16) then
         datatype = 'datatype: uint16'
      end if
      if(verbose.eq.1) write(*,430) datatype
      write(1,430) datatype
 430  format(2x,a20)
      if(verbose.eq.1) write(*,440) 
      write(1,440) 
 440  format(2x,'byteorder: big')
      if(verbose.eq.1) write(*,450) nints, naxis1, naxis2
      write(1,450) nints, naxis1, naxis2
 450  format(2x,'shape: [',i0,',',i0,',',i0,']')
c     end if
c     
c     close the asdf file
c     
      if(verbose.eq.1)  write(*, 460)
      write(1, 460)
 460  format('...')
c      write(1, 470)
c 470  format('END')
c
c     read all entries as a character array
c
      rewind 1
c      close(1)
c      open(1,file = '/home/cnaw/test/guitarra/asdf.dat')
      ll = 0
      do ii = 1, 6000
         read(1,510,end=600) line
 510     format(a512)
         if(verbose.gt.0) print *, trim(line)
         do jj = 1, len_trim(line)
            var = line(jj:jj)
            ll= ll+1
            array(ll)= ichar(var)
         end do
         ll = ll + 1
         array(ll) = 10         ! this is the ascii code for carriage return
      end do
 600  close(1)
c
      pad = 0
c      if(mod(ll,2880) .ne.0) then
c         ii = ll/2880
c         pad = (ii+1)*2880 - ll
c         print *,' asdf_header : ll , ii, pad ', ll, ii, pad
c         do ii = 1, pad
c            ll = ll + 1
cc            array(ll) = 32      ! ascii code for space 
c         end do
c      end if
c     
c     write as a new header extension
c 
      XTENSION = 'BINTABLE'
      extname  = 'ASDF'
      extver   = 1
      bitpix   = 8
      naxis    = 2
      naxes(1) = ll
      naxes(2) =  1
      nrows    =  1
      pcount   =  0
      gcount   =  1
      tfields  =  1
      ttype(1) = 'ASDF_METADATA'
      write(temp, 710) ll
 710  format(i4,"B")
      if(verbose.gt.0) print *,'format : ', temp,' pad: ',pad
      tform(1)  = temp
c     
      status    = 0
      blocksize = 1
      varidat   = 0
      nrows     = naxes(2)
c      
c     
c     create new empty HDU
c
      call ftcrhd(unit,status)
      if (status .gt. 0) then
         call printerror(status)
         if(verbose.eq.1) print *, 'int_times_header ftcrhd: ',status
         stop
      end if
c     
c
c     FTPHBN writes all the required header keywords which define the
c     structure of the binary table. NROWS and TFIELDS gives the number of
c     rows and columns in the table, and the TTYPE, TFORM, and TUNIT arrays
c     give the column name, format, and units, respectively of each column.
c 
      if(verbose.eq.1) 
     *     print *,'entering ftphbn', unit, nrows, tfields, status
      call ftphbn(unit,nrows,tfields,ttype,tform,tunit,
     &            extname,varidat,status)
c       if(status .ne. 0) then
      frow= 1 
      felem=1
      colnum = 1                !
      call ftpclj(unit,colnum,frow,felem,ll,array ,status)
      if(status .ne. 0) then
         print *,'asdf_header '
         call printerror(status)
      end if
c
      return
      end

