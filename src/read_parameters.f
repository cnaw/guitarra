c
c-----------------------------------------------------------------------
c
      subroutine read_parameters(nfilters,
     &     npsf,  sca_id, 
     &     patttype, numdthpt, patt_num, primary_dither_string,
     &     subpixel_dither_type, subpxpns, subpxnum,
     &     nints, ngroups, 
     &     subarray, colcornr, rowcornr, naxis1, naxis2,
     &     substrt1,substrt2,
     &     filter_in_cat, filters_in_cat, verbose, 
     &     seed, noiseless,
     &     ra0, dec0, pa_degrees,
     &     include_bg, include_cloned_galaxies, include_cr,  
     *     include_dark,  include_dark_ramp, 
     *     include_galaxies, include_ipc, include_ktc, 
     *     include_bias, include_latents, include_flat,
     &     include_non_linear, include_readnoise, 
     *     include_reference, include_1_over_f, 
     &     brain_dead_test,
     *     cr_mode, 
     &     aperture, filter_path, pupil,
     &     xoffset, yoffset, v2, v3,
     &     input_g_catalogue,input_s_catalogue, 
     &     background_file, flat_file, 
     &     noise_file, output_file, psf_file,
     &     readout_pattern, 
     &     observation_number, obs_id, obslabel,
     &     programme, category, visit_id, visit,
     &     visitgrp, seq_id, act_id, exposure,
     &     targprop, expripar, cr_history, distortion,
     &     siaf_version, write_tute, tute_name, 
     &     title,
     &     debug)
c
      implicit none
c
      logical noiseless
      logical ipc_add
c
      character background_file*180, cr_history*180,
     &     guitarra_aux*100, aperture*27, filter_path*180,
     &     input_g_catalogue*180,input_s_catalogue*180, 
     &     noise_file*180, output_file*180, psf_file*180,
     &     flat_file*180, tute_name*(*),
     &     readout_pattern*15,subpixel_dither_type*20,
     &     title*(*)
      character string1*30, type*1,string2*180
      character category*4, expripar*20,
     &     observation_number*3, obs_id*26, obslabel*40,
     &     patttype*15, programme*5, primary_dither_string*(*),
     &     subarray*15, targprop*31,
     &     visit_id*11, visit*11, siaf_version*13
         character visitgrp*2, seq_id*1, act_id*2, exposure*5
c     
      character pupil*7
c
      integer include_bg, include_cloned_galaxies, include_cr,  
     *     include_dark, include_dark_ramp, 
     *     include_galaxies, include_ipc,
     *     include_bias, include_ktc, include_flat,
     *     include_latents, include_non_linear, include_readnoise, 
     *     include_reference, include_1_over_f, brain_dead_test
      integer debug
      integer seed
      integer distortion, write_tute
      integer cr_mode, no_noise
      integer nfilters,numdthpt, patt_num, subpxpns,subpxnum
      integer ii, jj,verbose, npsf, filter_in_cat, filters_in_cat
      integer colcornr, rowcornr, naxis1, naxis2,substrt1,substrt2
      integer sca_id, primary, position, nints, ngroups
      double precision ra0, dec0, pa_degrees, xoffset, yoffset, v2, v3
c
      dimension psf_file(nfilters)
c
      do ii = 1, 1000
         read(5,10,err=20) string1, type, string2
 10      format(a30,1x,a1,1x,a180)
         go to 50
 20      print 10, string1, type, string2
         stop
 50      continue
c         print 10, string1, type, string2
         if(string1(1:8).eq.'aperture') then
            aperture = string2(1:27)
            if(debug.ge.1) print 55, ii,'aperture', trim(aperture)
 55         format(i3,2x,a23,2x, a)
            go to 900
         end if
         if(string1(1:6).eq.'sca_id') then
            read(string2, 60) sca_id
 60         format(i20)
            if(debug.ge.1) print 65, ii, 'sca_id', sca_id
 65         format(i3,2x,a23,2x,i8)
            go to 900
         end if
         if(string1(1:8).eq.'subarray') then
            subarray = string2(1:15)
            if(debug.ge.1) print 55, ii, 'subarray', subarray
            go to 900
         end if
c                            12345678901234567890
         if(string1(1:8).eq.'colcornr') then
            read(string2, 60) colcornr
            if(debug.ge.1) print 65, ii, 'colcornr', colcornr
            go to 900
         end if
c
         if(string1(1:8).eq.'rowcornr') then
            read(string2, 60) rowcornr
            if(debug.ge.1) print 65, ii, 'rowcornr', rowcornr
            go to 900
         end if
c
         if(string1(1:6).eq.'naxis1') then
            read(string2, 60) naxis1
            if(debug.ge.1) print 65, ii, 'naxis1',naxis1
            go to 900
         end if
c
         if(string1(1:6).eq.'naxis2') then
            read(string2, 60) naxis2
            if(debug.ge.1) print 65, ii, 'naxis2',naxis2
            go to 900
         end if
c
c
         if(string1(1:8).eq.'substrt1') then
            read(string2, 60) substrt1
            if(debug.ge.1) print 65, ii,  'substrt1',substrt1
            go to 900
         end if
c
c
         if(string1(1:8).eq.'substrt2') then
            read(string2, 60) substrt2
            if(debug.ge.1) print 65, ii, 'substrt2',substrt2
            go to 900
         end if
c
        if(string1(1:15).eq.'readout_pattern') then
            readout_pattern = string2(1:15)
            if(debug.ge.1) print 55, ii, 'readout_pattern',
     &           readout_pattern
            go to 900
         end if
c
         if(string1(1:7).eq.'ngroups') then
            read(string2, 60) ngroups
            if(debug.ge.1) print 65, ii, 'ngroups',ngroups
            go to 900
         end if
c                            12345678901234567890
         if(string1(1:8).eq.'patttype') then
            patttype = string2(1:15)
            if(debug.ge.1) print 55, ii, 'patttype',
     &           patttype
            go to 900
         end if
c                            12345678901234
         if(string1(1:8).eq.'nmdthpts') then
            primary_dither_string = string2
            if(debug.ge.1) 
     &           print 55, ii, 'nmdthpts', primary_dither_string
            go to 900
         end if

         if(string1(1:8).eq.'numdthpt') then
            read(string2, 60) numdthpt
 105        format(i1)
            if(debug.ge.1) print 65, ii, 'numdthpt',numdthpt
            go to 900
         end if
c                            12345678901234
         if(string1(1:8).eq.'patt_num') then
            read(string2, 60) patt_num
c            if(debug.ge.1) print *, ii, position
            if(debug.ge.1) print 65, ii, 'patt_num',patt_num
            go to 900
         end if
c                            12345678901234567890
        if(string1(1:20).eq.'subpixel_dither_type') then
           subpixel_dither_type = string2(1:20)
           if(debug.ge.1) print 55, ii, 'subpixel_dither_type',
     &          subpixel_dither_type
            go to 900
         end if
c                            123456789012345
         if(string1(1:8).eq.'subpxpns') then
            read(string2, 60) subpxpns
            if(debug.ge.1) print 65, ii, 'subpxpns',subpxpns
            go to 900
         end if
c
         if(string1(1:8).eq.'subpxnum') then
            read(string2, 60) subpxnum
            if(debug.ge.1) print 65, ii, 'subpxnum', subpxnum
            go to 900
         end if
c
         if(string1(1:5).eq.'nints') then
            read(string2, 60) nints
            if(debug.ge.1) print 65, ii, 'nints',nints
            go to 900
         end if
c
         if(string1(1:7).eq.'verbose') then
            read(string2, 60) verbose
            if(debug.ge.1) print 65, ii, 'verbose', verbose
            go to 900
         end if
c
         if(string1(1:9).eq.'noiseless') then
            read(string2, 60) no_noise
            if(no_noise .eq. 1) then
               noiseless = .TRUE.
            else
               noiseless = .FALSE.
            end if
            if(debug.ge.1) print 75, ii,'noiseless', noiseless
 75         format(i3,2x,a23,2x,l7)
            go to 900
         end if
c                             12345678901234567890
         if(string1(1:15).eq.'brain_dead_test') then
            read(string2, 60) brain_dead_test
            if(debug.ge.1)
     &           print 65, ii, 'brain_dead_test',brain_dead_test
            go to 900
         end if
c
         if(string1(1:11).eq.'include_ipc') then
            read(string2, 60) include_ipc
            if(debug.ge.1) print 65, ii, 'include_ipc',include_ipc
            go to 900
         end if
c
         if(string1(1:12).eq.'include_bias') then
            read(string2, 60) include_bias
            if(debug.ge.1) print 65, ii, 'include_bias',include_bias
            go to 900
         end if
c
         if(string1(1:11).eq.'include_ktc') then
            read(string2, 60) include_ktc
            if(debug.ge.1) print 65, ii, 'include_ktc',include_ktc
            go to 900
         end if
c
         if(string1(1:12).eq.'include_dark' ) then
            if(string1(1:17).eq.'include_dark_ramp') then
               read(string2, 60) include_dark_ramp
               if(debug.ge.1) 
     &              print 65, ii, 'include_dark_ramp',include_dark_ramp
               go to 900
            else
               read(string2, 60) include_dark
               if(debug.ge.1) print 65, ii, 'include_dark',include_dark
               go to 900
            end if
         end if
c
         if(string1(1:17).eq.'include_readnoise') then
            read(string2, 60) include_readnoise
            if(debug.ge.1)
     &           print 65, ii, 'include_readnoise',include_readnoise
            go to 900
         end if
c
         if(string1(1:17).eq.'include_reference') then
            read(string2, 60) include_reference
            if(debug.ge.1) print 65, ii, 'include_reference',
     *           include_reference
            go to 900
         end if
c
         if(string1(1:18).eq.'include_non_linear') then
            read(string2, 60) include_non_linear
            if(debug.ge.1) print 65, ii,  'include_non_linear',
     &           include_non_linear
            go to 900
         end if
c
         if(string1(1:15).eq.'include_latents') then
            read(string2, 60) include_latents
            if(debug.ge.1) print 65, ii, 'include_latents',
     &           include_latents
            go to 900
         end if
c
         if(string1(1:12).eq.'include_flat') then
            read(string2, 60) include_flat
            if(debug.ge.1) print 65, ii, 'include_flat',
     &           include_flat
            go to 900
         end if
c
         if(string1(1:16).eq.'include_1_over_f') then
            read(string2, 60) include_1_over_f
            if(debug.ge.1) print 65, ii,'include_1_over_f',
     &           include_1_over_f
            go to 900
         end if
c
         if(string1(1:10).eq.'include_cr') then
            read(string2, 60) include_cr
            if(debug.ge.1) print 65, ii,'include_cr',
     &           include_cr
            go to 900
         end if
c
         if(string1(1:7).eq.'cr_mode') then
            read(string2, 60) cr_mode
            if(debug.ge.1) print 65, ii, 'cr_mode',
     &           cr_mode
            go to 900
         end if
c
         if(string1(1:10).eq.'include_bg') then
            read(string2, 60) include_bg
            if(debug.ge.1) print 65, ii, 'include_bg',
     &           include_bg
            go to 900
         end if
c
         if(string1(1:16).eq.'include_galaxies') then
            read(string2, 60) include_galaxies
            if(debug.ge.1) print 65, ii, 'include_galaxies',
     &           include_galaxies
            go to 900
         end if
c
         if(string1(1:23).eq.'include_cloned_galaxies') then
            read(string2, 60) include_cloned_galaxies
            if(debug.ge.1) print 65, ii, 'include_cloned_galaxies',
     &           include_cloned_galaxies
            go to 900
         end if
c
         if(string1(1:4).eq.'seed') then
            read(string2, 60) seed
            if(debug.ge.1) print 65, ii, 'seed', seed
            go to 900
         end if
c
         if(string1(1:10) .eq. 'distortion') then
            read(string2, 60) distortion
            if(debug.ge.1) print 65, ii, 'focal plane distortion',
     &           distortion
            go to 900
         end if
c
         if(string1(1:13) .eq. 'SIAF_version') then
            siaf_version = string2(1:13)
            if(debug.ge.1) print 55, ii, 'SIAF version',
     &           siaf_version
            go to 900
         end if
c                            12345678901234567890
         if(string1(1:8).eq.'targprop') then
            targprop  = string2(1:31)
            if(debug.ge.1) print 55, ii, 'Targprop', trim(targprop)
            go to 900
         end if

         if(string1(1:6).eq.'obs_id') then
            obs_id  = string2(1:26)
            if(debug.ge.1) print 55, ii,'obs_id', obs_id
            go to 900
         end if
c
         if(string1(1:8).eq.'obslabel') then
            obslabel  = string2(1:40)
            if(debug.ge.1) print 55, ii, 'obslabel',trim(obslabel)
            go to 900
         end if
c
         if(string1(1:8).eq.'visitgrp') then
            visitgrp  = string2(1:40)
            if(debug.ge.1) print 55, ii, 'visitgrp',trim(visitgrp)
            go to 900
         end if
c
         if(string1(1:6).eq.'seq_id') then
            seq_id = string2(1:40)
            if(debug.ge.1) print 55, ii, 'seq_id',trim(seq_id)
            go to 900
         end if
c
         if(string1(1:6).eq.'act_id') then
            act_id = string2(1:40)
            if(debug.ge.1) print 55, ii, 'act_id',trim(act_id)
            go to 900
         end if
c
         if(string1(1:8).eq.'exposure') then
            exposure = string2(1:40)
            if(debug.ge.1) print 55, ii, 'exposure',trim(exposure)
            go to 900
         end if
c
         if(string1(1:7).eq.'program') then
            programme = string2(1:5)
            if(debug.ge.1) print 55, ii, 'program', trim(programme)

            go to 900
         end if
c
         if(string1(1:8).eq.'category') then
            category = string2(1:15)
            if(debug.ge.1) print 55, ii,'Category', category
            go to 900
         end if
c
         if(string1(1:8).eq.'visit_id') then
            visit_id = string2(1:11)
            visit    = string2(9:11)
            if(debug.ge.1) print 55, ii,'Visit_id', visit_id
            go to 900
         end if

         if(string1(1:8).eq.'observtn') then
            observation_number = string2(1:3)
            if(debug.ge.1) print 55, ii, 'observtn',observation_number
            go to 900
         end if
c
         if(string1(1:8).eq.'expripar') then
            expripar = string2(1:20)
            if(debug.ge.1) print 55, ii, 'EXPRIPAR', expripar
            go to 900
         end if
c
         if(string1(1:9).eq.'ra_nircam') then
            read(string2, 80) ra0
            if(debug.ge.1) print 85, ii, 'ra0',ra0
 80         format(f20.12)
 85         format(i3,2x,a23,2x,f20.12)
            go to 900
         end if
c
         if(string1(1:10).eq.'dec_nircam') then
            read(string2, 80) dec0
            if(debug.ge.1) print 85, ii, 'dec0',dec0
            go to 900
         end if
c
         if(string1(1:10).eq.'pa_degrees') then
            read(string2, 80) pa_degrees 
            if(debug.ge.1) print 85, ii, 'pa_degrees',pa_degrees
           go to 900
         end if
c                            12345678901234567890
        if(string1(1:17).eq.'star_subcatalogue') then
            input_s_catalogue = string2
            if(debug.ge.1) print 55, ii, 'star catalog',
     &           trim(input_s_catalogue)
            go to 900
         end if
c                            12345678901234567890
        if(string1(1:19).eq.'galaxy_subcatalogue') then
            input_g_catalogue = string2
            if(debug.ge.1) print 55, ii, 'galaxy catalog',
     &           trim(input_g_catalogue)
            go to 900
         end if
c                            12345678901234567890
        if(string1(1:19).eq.'filter_in_catalogue') then
           read(string2, 60) filters_in_cat
           if(debug.ge.1) print 65,ii, 'filters_in_cat',filters_in_cat
            go to 900
         end if
c                            12345678901234567890
        if(string1(1:20).eq.'filter_index') then
           read(string2, 60) filter_in_cat
           if(debug.ge.1) print 65,ii, 'filter_in_cat',filters_in_cat
           go to 900
        end if
c                            12345678901234567890
        if(string1(1:11).eq.'filter_path') then
           filter_path = string2
           if(debug.ge.1) print 55,ii,' filter_path', trim(filter_path)
           go to 900
        end if
c
        if(string1(1:7).eq.'xoffset') then
           read(string2, *) xoffset
           if(debug.ge.1) print 85,ii,' xoffset', xoffset
        end if
c
        if(string1(1:7).eq.'yoffset') then
           read(string2, *) yoffset
           if(debug.ge.1) print 85,ii,' yoffset', yoffset
        end if
c
        if(string1(1:2).eq.'v2') then
           read(string2, *) v2
           if(debug.ge.1) print 85,ii,' v2', v2
        end if
c
        if(string1(1:2).eq.'v3') then
           read(string2, *) v3
           if(debug.ge.1) print 85,ii,' v3', v3
        end if
c
        if(string1(1:5).eq.'pupil') then
           pupil = string2
           go to 900
        end if
c     12345678901234567890
        if(string1(1:11).eq.'output_file') then
           output_file = string2
           if(debug.ge.1) print 55,ii,'output', trim(output_file)
           go to 900
        end if
c                            12345678901234567890
        if(string1(1:10).eq.'write_tute') then
           read(string2,*) write_tute
           if(debug.ge.1) print 65,ii,'write_tute', write_tute
           go to 900
        end if
c                            12345678901234567890
        if(string1(1:11).eq.'tute_file') then
           tute_name = string2
           if(debug.ge.1) print 55,ii,'tute_name', trim(tute_name)
           go to 900
        end if
c                            12345678901234567890
        if(string1(1:10).eq.'cr_history') then
           cr_history = string2
           if(debug.ge.1) print 55,ii,'cr_history', trim(cr_history)
           go to 900
        end if
c                            12345678901234567890
        if(string1(1:15).eq.'background_file') then
            background_file = string2
           if(debug.ge.1) print 55,ii,'background',
     &           trim(background_file)
           go to 900
        end if
c                            12345678901234567890
        if(string1(1:10).eq.'noise_file') then
            noise_file =  string2
           if(debug.ge.1) print 55,ii,'noise', trim(noise_file)
           go to 900
        end if
c
        if(string1(1:10).eq.'flatfield') then
            flat_file =  string2
           if(debug.ge.1) print 55,ii,'flat', trim(flat_file)
           go to 900
        end if
c
        if(string1(1:5).eq.'title') then
            title =  string2
           if(debug.ge.1) print 55,ii,'title', trim(title)
           go to 900
        end if
c
        if(string1(1:4).eq.'npsf') then
           read(string2, 60) npsf
           if(debug.ge.1) print 65,ii, 'nsf', npsf
           go to 950
        end if
 900    continue
c        if(debug.ge.1) print *, ii,' brain_dead_test ', brain_dead_test
      end do
      if(debug.ge.1) print *,'read_parameters stop at 307??'
      stop
 950  continue
      jj = ii
      do ii = 1, npsf
         read(5,10,end=1000)  string1, type, string2
         psf_file(ii) = string2
         if(debug.ge.1) print 955,ii+jj, trim(psf_file(ii))
 955     format(i3, 2x, a)
 960     format(a120)
      end do
 1000 close(1)
      return
      end

