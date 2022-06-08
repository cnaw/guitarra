c
      implicit none
      character siaf_version*13, aperture*27, subarray*27
      character outline*180
      double precision attitude_dir, attitude_inv
      integer ideal_to_sci_degree, v_idl_parity,
     &     sci_to_ideal_degree, det_sci_parity
      double precision 
     &     x_det_ref, y_det_ref,
     &     x_sci_ref, y_sci_ref,
     &     x_sci_scale, y_sci_scale,
     &     x_sci_size, y_sci_size,
     &     sci_to_ideal_x, sci_to_ideal_y,
     &     ideal_to_sci_x, ideal_to_sci_y,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang,
     &     det_sci_yangle, det_sign,
     &     v2_ref, v3_ref,
     &     nrcall_v3idlyangle, nrcall_v2, nrcall_v3
      integer a_order, b_order, ap_order, bp_order
      integer colcornr, rowcornr
      double precision cd1_1, cd1_2, cd2_1, cd2_2,
     &     pc1_1, pc1_2, pc2_1, pc2_2, cdelt1, cdelt2,
     &     crpix1, crpix2, crval1, crval2,
     &     ra_sca, dec_sca
      double precision aa, bb, ap, bp
      character ctype1*40, ctype2*40,  cunit1*40, cunit2*40 
      character template*180
      double precision ra_ref, dec_ref, ra_inv, dec_inv
      double precision xdet, ydet, v2, v3,
     &     ra_rad, dec_rad, pa_rad, ra, dec,
     &     v2_rad, v3_rad, v2_arcsec,v3_arcsec
      integer precise, ii, jj, sca_n, len_reg, l1, l2

      double precision xnircam, ynircam,x0_nircam, y0_nircam
      double precision xshift, yshift, xmag, ymag, xrot,
     *     yrot, xrms, yrms, oxshift, oyshift, oxmag, oymag,
     *     oxrot, oyrot, oxrms, oyrms, osim_scale
c
      double precision tra, tdec, tmagnitude,
     *     tz, semi_major, semi_minor, ttheta, tnsersic
      
      double precision xmin, xmax, ymin, ymax, buffer
      double precision bright, faint

      double precision rra, ddec, ra0, dec0, pa_degrees, xc, yc,
     *     x_sca, y_sca, x_osim, y_osim, array, xx, yy, q, cosdec,
     &     x_dms, y_dms, x_offset, y_offset, amags, xm, ym
c
      integer sca_id, verbose, indx, nstars, i,j, l,mm, max_stars,
     *     nfilters, sca, distortion, nclone, nmodel, nread
c
      character hst_filter*7
      integer include_clone, hst_filter_level
      character one_d_name*180, clone_catalogue*180, clone_output*180
c     
      character catalogue*180, output_file*180, reg_rd*180,reg_xy*180,
     &     header*400, reg_dms*180, reg_clone*180,
     &     scatalogue*180, soutput_file*180,guitarra_aux*100,
     &     list*180, objid*25, mockid*10
c
      dimension attitude_dir(3,3), attitude_inv(3,3)
ccc     &     v2_ref(10), v3_ref(10)
      dimension 
     &     sci_to_ideal_x(6,6), sci_to_ideal_y(6,6), 
     &     ideal_to_sci_x(6,6), ideal_to_sci_y(6,6)

      dimension sca(10), xnircam(6,10), ynircam(6,10)
      dimension xshift(10), yshift(10), xmag(10), ymag(10), xrot(10),
     *     yrot(10)
      dimension oxshift(10), oyshift(10), oxmag(10), oymag(10),
     *      oxrot(10), oyrot(10)
      dimension array(54), amags(54)
      dimension aa(9,9), bb(9,9), ap(9,9), bp(9,9)
c
      common /nircam/  x0_nircam,  y0_nircam,  xnircam,  ynircam, sca
      common /transform/ xshift, yshift, xmag, ymag, xrot, yrot
      common /otransform/ oxshift, oyshift, oxmag, oymag, oxrot, oyrot
c      data xc, yc/0.0d0, 0.0d0/
c
c     modified 2018-02-03 such that NIRCam centre is in V2, V3
c     This makes coordinates compatible  with read_nircam_outline
c
      data xc, yc/-0.00529d0, -8.209855d0/
      data osim_scale/60.d0/ 
      q = dacos(-1.0d0)/180.d0
      max_stars = 1000000
      verbose = 0
      precise = 0
c
c     Load the conversion coefficients (without distortion)
c     this is obsolete with SIAF being used
      call load_osim_transforms(verbose)
c
c     read parameters
c
c     ra0, dec0 are the NIRCam footprint centre coordinates 
c     that correspond to nrcall_v2,nrcall_v3
c
      include_clone   =  0
      clone_catalogue = 'none'
      distortion = 0
      read(5, *) nfilters
      read(5,*) ra0, dec0, pa_degrees
      read(5,*) sca_id
 10   format(a180)
c
c     star catalogue
c
      read(5,10) scatalogue
      read(5,10) soutput_file
c
c     read galaxy catalogue
c     
      read(5,10) catalogue
      read(5,10) output_file
      read(5,*,end=20) distortion
 20   continue
      read(5,10) siaf_version
      read(5,10) reg_rd
      read(5,10) reg_xy
      read(5,10) aperture
      read(5,10) subarray
      read(5, *) bright
      read(5, *) faint
      read(5, *, end=21) include_clone
      go to 22
 21   include_clone = 0
 22   continue
      if(include_clone.eq.1) then
         read(5,10) clone_catalogue
         read(5,10) clone_output
         read(5,10) hst_filter
      end if
c     
      print 30,ra0, dec0,pa_degrees, distortion, include_clone
 30   format('Proselytism : NIRCam centre position, distortion, clone', 
     &     3(2x,f16.10), i4,2x, i1)
      sca_n = sca_id - 480
!     DS9 regions files 
      reg_dms = reg_xy
      len_reg = len(trim(reg_dms))
      l1 = len_reg-6
      l2 = len_reg+1
      reg_dms(l1:l2) = '_dms.reg'
      print *, reg_dms,' ', reg_dms
      reg_clone  = reg_rd
      len_reg = len(trim(reg_clone))
      l1 = len_reg-6
      l2 = len_reg+3
      reg_clone(l1:l2) = '_clone.reg'
      print *, reg_clone,' ', reg_clone
      call getenv('GUITARRA_AUX',guitarra_aux)
c
c     this needs to be used to find the centre coordinates of each SCA
c     relative to the NIRCam pointing position
c     This maybe unnecessary with the use of SIAF (2021-04-07)
      outline=guitarra_aux//siaf_version//'/NIRCam_outline.ascii'
      call StripSpaces(outline)
      call read_nircam_outline(outline)
c        
cccccccccccccccccccc
c
c     version with distortions
c
      if(distortion.ge.1) then
c
c     read the V2, V3 parameters for the centre of NIRCam and the
c     10 detectors
c
         list = guitarra_aux(1:len_trim(guitarra_aux))//'v2v3_reference_
     &coords.dat'
c
         print *,'proselytism : sca_n ', sca_n
         call read_siaf_parameters(aperture, subarray, sca_n,
     &        sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &        ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &        x_sci_scale, y_sci_scale, x_sci_size, y_sci_size,
     &        x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &        det_sci_yangle, det_sci_parity,
     &        v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &        nrcall_v3idlyangle, nrcall_v2, nrcall_v3,     
     &        siaf_version, verbose)
c         print *,' nrcall_v2,nrcall_v3 ', nrcall_v2,nrcall_v3
c         print *,' v2_ref, v3_ref      ', v2_ref, v3_ref
c         print *,' '
c
      call prep_wcs(
     &        sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &        ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &        x_sci_scale, y_sci_scale,
     &        x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &        det_sci_yangle, det_sci_parity,det_sign,
     &        v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &        nrcall_v3idlyangle,nrcall_v2,nrcall_v3,
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
      if(distortion.eq.2) then
         a_order = 0
         b_order = 0
         ap_order = 0
         bp_order = 0
      end if
c
c     Because objects can be extended, create a buffer zone which may
c     contain the centre of a larger object and have the outskirts 
c     contained within the boundaries of this detector
c
      xmin   = x_det_ref - x_sci_size/2.d0 + 0.5
      ymin   = y_det_ref - y_sci_size/2.d0 + 0.5
      xmax   = x_det_ref + x_sci_size/2.d0 - 0.5
      ymax   = y_det_ref + y_sci_size/2.d0 - 0.5
      buffer =   200.d0
      xmin   =    5.d0 - buffer
      xmax   = 2044.d0 + buffer
      ymin   =    5.d0 - buffer
      ymax   = 2044.d0 + buffer

      if(verbose.gt.0) then
      print *,' nrcall_v2,nrcall_v3 ', nrcall_v2,nrcall_v3
      print *,' v2_ref, v3_ref      ', v2_ref, v3_ref
      print *,' '
      print *,' x_det_ref,y_det_ref ', x_det_ref,y_det_ref
      print *,' ra0,    dec0        ', ra0, dec0
      print *,' ra_sca, dec_sca     ', ra_sca, dec_sca
      print *,'include_clone        ', include_clone
      end if
c
      else
c
c     Version without distortions
c     Position of SCA centre
c
         i = sca_n
         call rotate_coords2(xx, yy,  xnircam(i,6),ynircam(i,6),
     *        xc, yc, pa_degrees)
         
         ddec = dec0 - yy/60.d0
         cosdec = dcos(ddec*q)
         rra  = ra0  - xx/60.d0/cosdec
         if(verbose.gt.0) then
            print *, xnircam(i,6), ynircam(i,6), ra0, dec0
            print *, xx, yy, rra, ddec
         end if
      end if
cccccccccccccccccccc 
c
      nstars = 0
c      open(1,file=scatalogue)
c      open(2,file=soutput_file)
c      do i = 1, max_stars
c         read(1,110,end= 1000) indx, rra, ddec, x_osim, y_osim,
c     *        (array(j),j=1,nfilters)
c         call ra_dec_to_sca(sca_id, 
c     *        ra0, dec0, rra, ddec, pa_degrees,
c     *        xc, yc,  osim_scale, x_sca, y_sca)
cc         print 120, rra, ddec, xc, yc, x_sca, y_sca
cc     
c         if(x_sca.ge.xmin .and. x_sca.le. xmax .and.
c     *        y_sca.ge. ymax .and.y_sca.le.ymin) then
c            write(2, 140) indx, rra, ddec, x_sca, y_sca,
c     *           (array(j),j=1,nfilters)
c            nstars = nstars + 1
c         end if
c      end do
 1000 continue
c      close(1)
c      close(2)
c      print *,'kept ', nstars,' out of ',i-1, 'stars read'
c      close(10)
c     
 110  format(i5,2(2x, f16.12), 2(1x,f8.3), 58(2x,f8.3))
 120  format(20(1x,f10.4))
 140  format(i5,2(2x, f16.12), 2(1x,f8.3), 58(2x,f8.3))
 170  format('test_',i3.3,'_rd.reg')
 180  format('test_',i3.3,'_xy.reg')
 190  format(a400)
      header = header//'xpix ypix'
c
      open(10,file = catalogue)
c      write(reg, 170) sca_id
      open(30,file = reg_rd)
c      write(reg, 180) sca_id
      open(40,file = reg_xy)
      open(45,file = reg_dms(1:l2))
c
      open(20,file = output_file)
      print 10, catalogue
      read(10, 190) header
      write(20, 190) header
      nstars = 0
      l = 0
      nmodel = 0
      nread  = 0
      do i = 1, max_stars
         read(10, *, err= 1030, end=2000) objid, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic,
     *        (array(j), j = 1, nfilters)
         l = l + 1
         nread = nread + 1
c     if(tnsersic .gt. 0.5) go to 1090
c         if(tmagnitude .gt.28.) go to 1090
         if(tmagnitude .lt. bright .or. tmagnitude.gt.faint) go to 1090
c         print *, objid, tra, tdec
         go to 1050
c
c     if there is an error print this:
c
 1030    continue
         print *,'skipping ',i, 'nfilters ',nfilters
         print 1040, objid, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic
     *        ,(array(j), j = 1, nfilters)
 1040    format(a25,27(1x,f15.6))
         stop
         go to 1090
c     
 1050    continue
         if(distortion.ge.1) then
            if(distortion.eq.1) then
               ra_rad  = tra * q
               dec_rad = tdec * q
               call rot_coords(attitude_inv, ra_rad, dec_rad, 
     &              v2_rad, v3_rad)
               call coords_to_v2v3(v2_rad, v3_rad,v2_arcsec,v3_arcsec)
c     print *,'tra,tdec v2_arcsec, v3_arcsec',  
c     &           tra, tdec, v2_arcsec, v3_arcsec

               if(v2_arcsec.lt.-200.0d0 .or. v2_arcsec.gt.200.d0)
     &              go to 1090
            
c     if(v3_arcsec.lt.-600.0d0 .or. v3_arcsec.gt.-400.d0)
c     &           go to 1090
c     
            call v2v3_to_det(
     &           x_det_ref, y_det_ref,
     &           x_sci_ref, y_sci_ref,
     &           sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
     &           ideal_to_sci_x,ideal_to_sci_y,ideal_to_sci_degree,
     &           v3_sci_x_angle,v3_sci_y_angle,
     &           v3_idl_yang, v_idl_parity,
     &           det_sci_yangle, det_sci_parity,
     &           v2_ref, v3_ref,
     &           v2_arcsec, v3_arcsec,  xx, yy,
     &           precise, verbose)
         call siaf_rd_to_xy(
     &        tra, tdec,
     &        x_det_ref, y_det_ref,
     &        x_sci_ref, y_sci_ref,
     &        sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
     &        ideal_to_sci_x, ideal_to_sci_y,ideal_to_sci_degree,
     &        v3_sci_x_angle,v3_sci_y_angle,
     &        v3_idl_yang,v_idl_parity,
     &        det_sci_yangle,det_sci_parity,
     &        v2_ref, v3_ref,
     &        v2_arcsec, v3_arcsec, x_sca, y_sca,
     &        attitude_dir, attitude_inv,
     &           precise,verbose)
         x_offset = x_det_ref - x_sci_size/2.d0 + 1
         y_offset = y_det_ref - y_sci_size/2.d0 + 1
!     this matches the values on /home/cnaw/guitarra/data/nircam_subarrays.ascii
         colcornr = x_det_ref - x_sci_size/2.d0 + 1
         rowcornr = y_det_ref - y_sci_size/2.d0 + 1
!     this matches the output from guitarra for full frames
!     (i.e., the value that siaf_rd_to_xy produces)
         xx       = x_sca - colcornr + 1
         yy       = y_sca - rowcornr + 1
            else
c     
c     no distortion using SIAF WCS
c     
               call wcs_rd_to_xy(x_sca, y_sca,tra, tdec,
     &              crpix1, crpix2, crval1, crval2,
     &              cd1_1, cd1_2, cd2_1, cd2_2)
            end if
c     
         else
c     
c     No distortion using ISIM CV3
c
            call ra_dec_to_sca(sca_id, 
     *           rra, ddec, tra, tdec, pa_degrees,
     *           xc, yc,  osim_scale, x_sca, y_sca)
         end if
c     
c     process for both distorted and un-distorted cases
c     check that object falls inside buffer zone
c     
         if(x_sca.ge.xmin.and. x_sca.le. xmax .and.
     *        y_sca.ge. ymin .and.y_sca.le.ymax) then
            do mm = 1, nfilters
               if(array(mm).lt. 10.0d0) then
c               if(array(mm).lt. 0.0d0) then
                  print *,' skipping bright object', l,  l, tra, tdec, 
     *                 tmagnitude,array(mm)
                  go to 1090
               end if
            enddo
            if(verbose.eq.1)
     &           print 1001, l, tra,tdec, x_sca, y_sca, xx,yy,
     &           colcornr,rowcornr
 1001       format('proselytism: ra, dec, x_sca, y_sca, xx, yy, cornr ',
     *        i6,2(1x,f14.8),4(1x,f8.2),2i6)
c
            nstars = nstars + 1
            nmodel = nmodel + 1
            write(20, 1060) objid, tra, tdec, tmagnitude,
     *           tz, semi_major, semi_minor, ttheta, tnsersic,
     *           (array(j), j = 1, nfilters), x_sca, y_sca
c     print *,'nfilters ', nfilters
            
c     print 1060, l, tra, tdec, tmagnitude,
c     *        tz, semi_major, semi_minor, ttheta, tnsersic,
c     *        (array(j), j = 1, nfilters), x_sca, y_sca
 1060       format(a25,2(1x,f14.8),100(1x,f12.6))
cccc            if(include_clone.eq.1) then
c               write(25, 10) one_d_name
c               if(trim(one_d_name).ne.'none') then
c                  write(49, 1065) tra, tdec, l
c 1065             format('fk5;point(',f13.9,',',f13.9,
c     &                 ')#point=boxcircle', 1x,'color=magenta',
c     &                 1x,  'text={',i0,'}')
c               end if
c               if(verbose .gt. 0) print *,'one_d_name ', one_d_name
cc               print *,'one_d_name ', one_d_name
cccc            end if
c
c     write regions file

            x_dms = det_sci_parity*det_sign*(x_sca-x_det_ref)
     &           +x_sci_ref
            y_dms = det_sign*(y_sca-y_det_ref)+y_sci_ref

            if(sca_id .eq.485. or. sca_id .eq. 490) then
               write(30, 1070) tra, tdec, trim(objid) !array(nfilters)
 1070          format('fk5;point(',f13.9,',',f14.9,
     &              ')#point=boxcircle ',
     &              'color=magenta',1x,  'text={',A,'}')
c     write(40, 1080) x_sca,y_sca , l
               write(40, 1080) xx, yy , trim(objid)
               write(45, 1080) x_dms,y_dms , trim(objid)
 1080          format('image;point(',f13.2,',',f13.2,')#point=cross ',
     &              'color=red',1x,'text={',A,'}')
 1081          format('image;point(',f13.2,',',f13.2,
     &              ')#point=diamond ',
     &              'color=green width=3')
            else
               write(30, 1075) tra, tdec,  trim(objid)
 1075          format('fk5;point(',f13.9,',',f13.9,')#point=box ',
     &              'color=grey',1x, 'text={',A,'} width=3')
c               write(40, 1085) x_sca, y_sca , l
               write(40, 1085) xx, yy , l
               write(45, 1085) x_dms, y_dms , trim(objid)
 1085          format('image;point(',f13.2,',',f13.2,
     &              ')#point= circle ',
     &              'color=red',1x,'text={',A,'}')
c               x_sca = idnint(x_sca)
c               y_sca = idnint(y_sca)
               xx = idnint(xx)
               yy = idnint(yy)
               x_dms = det_sci_parity*det_sign*(x_sca-x_det_ref)
     &              +x_sci_ref
               y_dms = det_sign*(y_sca-y_det_ref)+y_sci_ref
c               write(40, 1081) x_sca, y_sca
               write(40, 1081) xx, yy
               write(45, 1081) x_dms, y_dms
            end if
         end if
 1090    continue
c         if(verbose.gt.0) print *,'distortion', 
c     &        distortion, i, l, x_sca, y_sca
      end do
 2000 close(10)
      close(20)
      close(30)
      close(40)
!
!======================================================================
!      
      nclone = 0
      if(include_clone.eq.1) then
         open(15,file=clone_catalogue)
         open(25,file=clone_output)
         read(15, 190) header
         write(25,190) header
         open(49,file = reg_clone)
!
!     This is a kludge for now, as it should  this should really be
!     reading the header and NIRCam filter to be simulated, but will
!     require quite a bit more work 2021-12-03
!         
         if(hst_filter .eq. 'F606W') hst_filter_level = 5
         if(hst_filter .eq. 'F160W') hst_filter_level = 1
!         
         do i = 1, max_stars
            read(15, 2050, err=2030,end=3000) objid, tra, tdec,
     &           xm, ym, tz,(array(j), j = 1, 10),
     &           (amags(j),j=1,18), template
            go to 2070
 2030       print 2050,objid, tra, tdec,
     &           xm, ym, tz,(array(j), j = 1, 10),
     &           (amags(j),j=1,18), trim(template)
 2050       format(a25,2(2x, f14.9), 2(2x,f10.2), 2x, f9.5,
     &           28(2x,f8.4),2x, A180)
            go to 2090
 2070       continue
c            print 2071, trim(template)
 2071       format('template ', A)
c            stop
            nread = nread + 1
            l = l + 1
            tmagnitude = amags(hst_filter_level)
            if(tmagnitude .lt. bright-1 .or. tmagnitude.gt.faint+2)
     &           go to 2090

            if(distortion.ge.1) then
               if(distortion.eq.1) then
                  ra_rad  = tra * q
                  dec_rad = tdec * q
                  call rot_coords(attitude_inv, ra_rad, dec_rad, 
     &                 v2_rad, v3_rad)
                  call coords_to_v2v3(v2_rad, v3_rad,
     &                 v2_arcsec,v3_arcsec)
                  if(v2_arcsec.lt.-200.0d0 .or. v2_arcsec.gt.200.d0)
     &                 go to 2090
c     
                  call v2v3_to_det(
     &                 x_det_ref, y_det_ref,
     &                 x_sci_ref, y_sci_ref,
     &                 sci_to_ideal_x,sci_to_ideal_y,
     &                 sci_to_ideal_degree,
     &                 ideal_to_sci_x,ideal_to_sci_y,
     &                 ideal_to_sci_degree,
     &                 v3_sci_x_angle,v3_sci_y_angle,
     &                 v3_idl_yang, v_idl_parity,
     &                 det_sci_yangle, det_sci_parity,
     &                 v2_ref, v3_ref,
     &                 v2_arcsec, v3_arcsec,  xx, yy,
     &                 precise, verbose)
                  call siaf_rd_to_xy(
     &                 tra, tdec,
     &                 x_det_ref, y_det_ref,
     &                 x_sci_ref, y_sci_ref,
     &                 sci_to_ideal_x,sci_to_ideal_y,
     &                 sci_to_ideal_degree,
     &                 ideal_to_sci_x, ideal_to_sci_y,
     &                 ideal_to_sci_degree,
     &                 v3_sci_x_angle,v3_sci_y_angle,
     &                 v3_idl_yang,v_idl_parity,
     &                 det_sci_yangle,det_sci_parity,
     &                 v2_ref, v3_ref,
     &                 v2_arcsec, v3_arcsec, x_sca, y_sca,
     &                 attitude_dir, attitude_inv,
     &                 precise,verbose)
                  x_offset = x_det_ref - x_sci_size/2.d0 + 1
                  y_offset = y_det_ref - y_sci_size/2.d0 + 1
!     this matches the values on /home/cnaw/guitarra/data/nircam_subarrays.ascii
                  colcornr = x_det_ref - x_sci_size/2.d0 + 1
                  rowcornr = y_det_ref - y_sci_size/2.d0 + 1
!     this matches the output from guitarra for full frames
!     (i.e., the value that siaf_rd_to_xy produces)
                  xx       = x_sca - colcornr + 1
                  yy       = y_sca - rowcornr + 1
               else
c     
c     no distortion using SIAF WCS
c     
                  call wcs_rd_to_xy(x_sca, y_sca,tra, tdec,
     &                 crpix1, crpix2, crval1, crval2,
     &                 cd1_1, cd1_2, cd2_1, cd2_2)
               end if           ! if(distortion == 1)
c     
            else
c     
c     No distortion using ISIM CV3
c
               call ra_dec_to_sca(sca_id, 
     *              rra, ddec, tra, tdec, pa_degrees,
     *              xc, yc,  osim_scale, x_sca, y_sca)
            end if              ! if(distortion > 0)
c
            if(x_sca.ge.xmin.and. x_sca.le. xmax .and.
     *           y_sca.ge. ymin .and.y_sca.le.ymax) then
               if(verbose.eq.1)
     &              print 1001, l, tra,tdec, x_sca, y_sca, xx,yy,
     &           colcornr,rowcornr
c     
               nstars = nstars + 1
               write(25, 2050) objid, tra, tdec, xm, ym, tz,
!     semi_major, semi_minor, ttheta, tnsersic,
     *              (array(j), j = 1, 10),(amags(j),j=1,18),
     &              trim(template)
               write(49, 2075) tra, tdec, trim(objid)
 2075          format('fk5;point(',f13.9,',',f13.9,
     &              ')#point=boxcircle ',
     &              'color=gold',1x, 'text={',A,'} width=3')
               
               x_dms = det_sci_parity*det_sign*(x_sca-x_det_ref)
     &              +x_sci_ref
               y_dms = det_sign*(y_sca-y_det_ref)+y_sci_ref
               write(45, 1080) x_dms, y_dms, trim(objid)
               nclone = nclone + 1
c               print *, nclone, tmagnitude, nint(x_sca),nint(y_sca),
c     &              ' ',trim(template)
            end if              ! if(x_sca >xmin etc
 2090       continue
         end do
 3000    close(15)
         close(25)
         close(35)
         print *,'clones in ',trim(clone_output)
      end if
      close(49)
      print *,'models in ', output_file
      print *,'nmodel ', nmodel,' nclone ', nclone,' total ',
     &     nmodel + nclone
      print *,'kept ', nstars,' out of ',nread, ' read'
      stop
 2100 print *,'error with cloned image',l
      print *,'clone file name not defined or clone list too small'
      stop
      end


      
