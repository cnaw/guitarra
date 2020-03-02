c
c-----------------------------------------------------------------------
c
      subroutine read_parameters(nfilters,
     &     npsf,  sca_id, 
     &     patttype, numdthpt, patt_num,
     &     subpixel_dither_type, subpxpns,subpxnum, nints,
     &     ngroups, 
     &     subarray, colcornr, rowcornr, naxis1, naxis2,
     &     filter_in_cat, filters_in_cat, verbose, 
     &     noiseless,
     &     ra0, dec0, pa_degrees,
     &     include_bg, include_cloned_galaxies, include_cr,  
     *     include_dark, include_galaxies, include_ipc, include_ktc, 
     *     include_latents, include_flat,
     &     include_non_linear, include_readnoise, 
     *     include_reference, include_1_over_f, 
     &     brain_dead_test,
     *     cr_mode, 
     &     aperture, filter_path,
     &     input_g_catalogue,input_s_catalogue, 
     &     background_file, flat_file, 
     &     noise_file, output_file, psf_file,
     &     readout_pattern, 
     &     observation_number, obs_id, obslabel,
     &     programme, category, visit_id, visit, targprop,
     &     expripar, cr_history,debug)
c
      implicit none
c
      logical noiseless
      logical ipc_add
c
      character background_file*180, cr_history*180,
     &     guitarra_aux*100, aperture*20, filter_path*180,
     &     input_g_catalogue*180,input_s_catalogue*180, 
     &     noise_file*180, output_file*180, psf_file*180,
     &     flat_file*180,
     &     readout_pattern*15,subpixel_dither_type*20
      character string1*30, type*1,string2*180
      character category*4, expripar*20,
     &     observation_number*3, obs_id*26, obslabel*40,
     &     patttype*15, programme*5,
     &     subarray*15, targprop*31,
     &     visit_id*11, visit*2
c
      integer include_bg, include_cloned_galaxies, include_cr,  
     *     include_dark, include_galaxies, include_ipc,
     *     include_ktc, include_flat,
     *     include_latents, include_non_linear, include_readnoise, 
     *     include_reference, include_1_over_f, brain_dead_test
      integer debug
      integer cr_mode, no_noise
      integer nfilters,numdthpt, patt_num, subpxpns,subpxnum
      integer ii, verbose, npsf, filter_in_cat, filters_in_cat
      integer colcornr, rowcornr, naxis1, naxis2
      integer sca_id, primary, position, nints, ngroups
      double precision ra0, dec0, pa_degrees
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
         if(string1(1:8).eq.'aperture') then
            aperture = string2(1:20)
            if(debug.ge.1) print *, ii,' aperture ', aperture
            go to 900
         end if
         if(string1(1:6).eq.'sca_id') then
            read(string2, 60) sca_id
 60         format(i20)
            if(debug.ge.1) print *, ii, 'sca_id ', sca_id
            go to 900
         end if
         if(string1(1:8).eq.'subarray') then
            subarray = string2(1:15)
            if(debug.ge.1) print *, ii, 'subarray ', subarray
            go to 900
         end if
c                            12345678901234567890
         if(string1(1:8).eq.'colcornr') then
            read(string2, 60) colcornr
            if(debug.ge.1) print *, ii, 'colcornr ', colcornr
            go to 900
         end if
c
         if(string1(1:8).eq.'rowcornr') then
            read(string2, 60) rowcornr
            if(debug.ge.1) print *, ii, 'rowcornr ', rowcornr
            go to 900
         end if
c
         if(string1(1:6).eq.'naxis1') then
            read(string2, 60) naxis1
            if(debug.ge.1) print *, ii, ' naxis1 ',naxis1
            go to 900
         end if
c
         if(string1(1:6).eq.'naxis2') then
            read(string2, 60) naxis2
            if(debug.ge.1) print *, ii, 'naxis2 ',naxis2
            go to 900
         end if
c
        if(string1(1:15).eq.'readout_pattern') then
            readout_pattern = string2(1:15)
            if(debug.ge.1) print *, ii, readout_pattern
            go to 900
         end if
c
         if(string1(1:7).eq.'ngroups') then
            read(string2, 60) ngroups
            if(debug.ge.1) print *, ii, ngroups
            go to 900
         end if
c                            12345678901234567890
         if(string1(1:8).eq.'patttype') then
            patttype = string2(1:15)
            if(debug.ge.1) print *, ii, patttype
            go to 900
         end if
c                            12345678901234
         if(string1(1:8).eq.'numdthpt') then
            read(string2, 60) numdthpt
            if(debug.ge.1) print *, ii, numdthpt
            go to 900
         end if
c                            12345678901234
         if(string1(1:8).eq.'patt_num') then
            read(string2, 60) patt_num
            if(debug.ge.1) print *, ii, position
            go to 900
         end if
c                            12345678901234567890
        if(string1(1:20).eq.'subpixel_dither_type') then
           subpixel_dither_type = string2(1:20)
           if(debug.ge.1) print *, ii, subpixel_dither_type
            go to 900
         end if
c                            123456789012345
         if(string1(1:8).eq.'subpxpns') then
            read(string2, 60) subpxpns
            if(debug.ge.1) print *, ii, subpxpns
            go to 900
         end if
c
         if(string1(1:8).eq.'subpxnum') then
            read(string2, 60) subpxnum
            if(debug.ge.1) print *, ii, subpxnum
            go to 900
         end if
c
         if(string1(1:5).eq.'nints') then
            read(string2, 60) nints
            if(debug.ge.1) print *, ii, nints
            go to 900
         end if
c
         if(string1(1:7).eq.'verbose') then
            read(string2, 60) verbose
            if(debug.ge.1) print *, ii, verbose
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
            if(debug.ge.1) print *, ii,'noiseless ', noiseless
            go to 900
         end if
c                             12345678901234567890
         if(string1(1:15).eq.'brain_dead_test') then
            read(string2, 60) brain_dead_test
            if(debug.ge.1)
     &           print *, ii, 'brain_dead_test',brain_dead_test
            go to 900
         end if
c
         if(string1(1:11).eq.'include_ipc') then
            read(string2, 60) include_ipc
            if(debug.ge.1) print *, ii, 'include_ipc',include_ipc
            go to 900
         end if
c
c
         if(string1(1:11).eq.'include_ktc') then
            read(string2, 60) include_ktc
            if(debug.ge.1) print *, ii, 'include_ktc',include_ktc
            go to 900
         end if
c
         if(string1(1:12).eq.'include_dark') then
            read(string2, 60) include_dark
            if(debug.ge.1) print *, ii, 'include_dark',include_dark
            go to 900
         end if
c
         if(string1(1:17).eq.'include_readnoise') then
            read(string2, 60) include_readnoise
            if(debug.ge.1)
     &           print *, ii, 'include_readnoise',include_readnoise
            go to 900
         end if
c
         if(string1(1:17).eq.'include_reference') then
            read(string2, 60) include_reference
            if(debug.ge.1) print *, ii, 'include_reference',
     *           include_reference
            go to 900
         end if
c
         if(string1(1:18).eq.'include_non_linear') then
            read(string2, 60) include_non_linear
            if(debug.ge.1) print *, ii,  'include_non_linear',
     &           include_non_linear
            go to 900
         end if
c
         if(string1(1:15).eq.'include_latents') then
            read(string2, 60) include_latents
            if(debug.ge.1) print *, ii, 'include_latents',
     &           include_latents
            go to 900
         end if
c
         if(string1(1:12).eq.'include_flat') then
            read(string2, 60) include_flat
            if(debug.ge.1) print *, ii, 'include_flat',
     &           include_flat
            go to 900
         end if
c
         if(string1(1:16).eq.'include_1_over_f') then
            read(string2, 60) include_1_over_f
            if(debug.ge.1) print *, ii,'include_1_over_f',
     &           include_1_over_f
            go to 900
         end if
c
         if(string1(1:10).eq.'include_cr') then
            read(string2, 60) include_cr
            if(debug.ge.1) print *, ii,'include_cr',
     &           include_readnoise
            go to 900
         end if
c
         if(string1(1:7).eq.'cr_mode') then
            read(string2, 60) cr_mode
            if(debug.ge.1) print *, ii, 'cr_mode',
     &           cr_mode
            go to 900
         end if
c
         if(string1(1:10).eq.'include_bg') then
            read(string2, 60) include_bg
            if(debug.ge.1) print *, ii, 'include_bg',
     &           include_bg
            go to 900
         end if
c
         if(string1(1:16).eq.'include_galaxies') then
            read(string2, 60) include_galaxies
            if(debug.ge.1) print *, ii, 'include_galaxies',
     &           include_galaxies
            go to 900
         end if
c
         if(string1(1:23).eq.'include_cloned_galaxies') then
            read(string2, 60) include_cloned_galaxies
            if(debug.ge.1) print *, ii, 'include_cloned_galaxies',
     &           include_cloned_galaxies
            go to 900
         end if
c                            12345678901234567890
         if(string1(1:8).eq.'targprop') then
            targprop  = string2(1:31)
            if(debug.ge.1) print *, ii, targprop
            go to 900
         end if

         if(string1(1:6).eq.'obs_id') then
            obs_id  = string2(1:26)
            if(debug.ge.1) print *, ii, obs_id
            go to 900
         end if
c
         if(string1(1:8).eq.'obslabel') then
            obslabel  = string2(1:40)
            if(debug.ge.1) print *, ii, obslabel
            go to 900
         end if
c
         if(string1(1:7).eq.'program') then
            programme = string2(1:15)
            if(debug.ge.1) print *, ii, programme

            go to 900
         end if
c
         if(string1(1:8).eq.'category') then
            category = string2(1:15)
            if(debug.ge.1) print *, ii, category
            go to 900
         end if
c
         if(string1(1:8).eq.'visit_id') then
            visit_id = string2(1:11)
            if(debug.ge.1) print *, ii, visit_id
            go to 900
         end if

         if(string1(1:8).eq.'observtn') then
            observation_number = string2(1:3)
            if(debug.ge.1) print *, ii, observation_number
            go to 900
         end if
c
         if(string1(1:8).eq.'expripar') then
            expripar = string2(1:20)
            if(debug.ge.1) print *, ii, expripar
            go to 900
         end if
c
         if(string1(1:9).eq.'ra_nircam') then
            read(string2, 80) ra0
            if(debug.ge.1) print *, ii, ra0

 80         format(f20.12)
            go to 900
         end if
c
         if(string1(1:10).eq.'dec_nircam') then
            read(string2, 80) dec0
            if(debug.ge.1) print *, ii, dec0
            go to 900
         end if
c
         if(string1(1:10).eq.'pa_degrees') then
            read(string2, 80) pa_degrees 
            if(debug.ge.1) print *, ii, pa_degrees
           go to 900
         end if
c                            12345678901234567890
        if(string1(1:17).eq.'star_subcatalogue') then
            input_s_catalogue = string2
            if(debug.ge.1) print *, ii, input_s_catalogue
            go to 900
         end if
c                            12345678901234567890
        if(string1(1:19).eq.'galaxy_subcatalogue') then
            input_g_catalogue = string2
            if(debug.ge.1) print *, ii, input_g_catalogue
            go to 900
         end if
c                            12345678901234567890
        if(string1(1:19).eq.'filter_in_catalogue') then
           read(string2, 60) filters_in_cat
           if(debug.ge.1) print *,ii, 'filters_in_cat',filters_in_cat
            go to 900
         end if
c                            12345678901234567890
        if(string1(1:20).eq.'filter_index') then
           read(string2, 60) filter_in_cat
           if(debug.ge.1) print *,ii, 'filter_in_cat',filters_in_cat
           go to 900
        end if
c                            12345678901234567890
        if(string1(1:11).eq.'filter_path') then
           filter_path = string2
           if(debug.ge.1) print *,ii,' filter_path ', filter_path
           go to 900
        end if
c                            12345678901234567890
        if(string1(1:11).eq.'output_file') then
           output_file = string2
           if(debug.ge.1) print *,ii, output_file
           go to 900
        end if
c                            12345678901234567890
        if(string1(1:10).eq.'cr_history') then
           cr_history = string2
           if(debug.ge.1) print *,ii, cr_history
           go to 900
        end if
c                            12345678901234567890
        if(string1(1:15).eq.'background_file') then
            background_file = string2
           if(debug.ge.1) print *,ii, background_file
           go to 900
        end if
c                            12345678901234567890
        if(string1(1:10).eq.'noise_file') then
            noise_file =  string2
           if(debug.ge.1) print *,ii, noise_file
           go to 900
        end if
c
        if(string1(1:10).eq.'flatfield') then
            flat_file =  string2
           if(debug.ge.1) print *,ii, flat_file
           go to 900
        end if
c
        if(string1(1:4).eq.'npsf') then
           read(string2, 60) npsf
           if(debug.ge.1) print *,ii, npsf
           go to 950
        end if
 900    continue
c        if(debug.ge.1) print *, ii,' brain_dead_test ', brain_dead_test
      end do
      if(debug.ge.1) print *,'read_parameters stop at 307??'
      stop
 950  continue
      do ii = 1, npsf
         read(5,10,end=1000)  string1, type, string2
         psf_file(ii) = string2
         if(debug.ge.1) print *,ii, psf_file(ii)
 960     format(a120)
      end do
 1000 close(1)
      return
      end

