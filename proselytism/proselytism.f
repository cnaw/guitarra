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
      double precision cd1_1, cd1_2, cd2_1, cd2_2,
     &     pc1_1, pc1_2, pc2_1, pc2_2, cdelt1, cdelt2,
     &     crpix1, crpix2, crval1, crval2,
     &     ra_sca, dec_sca
      double precision aa, bb, ap, bp
      character ctype1*40, ctype2*40,  cunit1*40, cunit2*40 

      double precision ra_ref, dec_ref, ra_inv, dec_inv
      double precision xdet, ydet, v2, v3,
     &     ra_rad, dec_rad, pa_rad, ra, dec,
     &     v2_rad, v3_rad, v2_arcsec,v3_arcsec
      integer precise, ii, jj, sca_n

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
     *     x_sca, y_sca, x_osim, y_osim, array, xx, yy, q, cosdec
c
      integer sca_id, verbose, indx, nstars, i,j, l,mm, max_stars,
     *     nfilters, sca, distortion
c
      character catalogue*180, output_file*180, reg_rd*180,reg_xy*180,
     &     header*400,
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
      dimension array(54)
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
c
      print 30,ra0, dec0,pa_degrees, distortion
 30   format('Proselytism : NIRCam centre position, distortion ', 
     &     3(2x,f16.10), i4)
      sca_n = sca_id - 480

      call getenv('GUITARRA_AUX',guitarra_aux)
c
c     this needs to be used to find the centre coordinates of each SCA
c     relative to the NIRCam pointing position
c     This maybe unnecessary with the use of SIAF (2021-04-07)
      outline=guitarra_aux//siaf_version//'/NIRCam_outline.ascii'
      call StripSpaces(outline)
      print *, outline
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
      open(20,file = output_file)
c      write(reg, 170) sca_id
      open(30,file = reg_rd)
c      write(reg, 180) sca_id
      open(40,file = reg_xy)
      print 10, catalogue
      read(10, 190) header
      write(20, 190) header
      nstars = 0
      l = 0
      do i = 1, max_stars
         read(10, *, err= 1030, end=2000) objid, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic,
     *        (array(j), j = 1, nfilters)
         l = l + 1
c         if(tnsersic .gt. 0.5) go to 1090
c         if(tmagnitude .gt.28.) go to 1090
         if(tmagnitude .lt. bright .or. tmagnitude.gt.faint) go to 1090
         go to 1050
c
c     if there is an error print this:
c
 1030    continue
         print *,'skipping ',i
         print 1040, objid, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic
     *        ,(array(j), j = 1, nfilters)
 1040    format(a25,20(1x,f15.6))
         go to 1090
c     
 1050    if(distortion.ge.1) then
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
     &        precise,verbose)

c               call v2v3_to_det(
c     &              x_det_ref, y_det_ref, 
c     &              x_sci_ref, y_sci_ref,
c     &              sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
c     &              ideal_to_sci_x,ideal_to_sci_y,ideal_to_sci_degree,
c     &              v3_sci_x_angle,v3_sci_y_angle,
c     &              v3_idl_yang, v_idl_parity,
c     &              det_sci_yangle, det_sci_parity,
c     &              v2_ref, v3_ref,
c     &              v2_arcsec, v3_arcsec, x_sca, y_sca,
c     &              precise,verbose)
c     
c               call siaf_xy_to_rd(
c     &              ra_inv, dec_inv, 
c     &              x_det_ref, y_det_ref,
c     &              x_sci_ref, y_sci_ref,
c     &              sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
c     &              ideal_to_sci_x, ideal_to_sci_y,ideal_to_sci_degree,
c     &              v3_sci_x_angle,v3_sci_y_angle,
c     &              v3_idl_yang,v_idl_parity,
c     &              det_sci_yangle,det_sci_parity,
c     &              v2_ref, v3_ref,
c     &              v2_arcsec, v3_arcsec, x_sca, y_sca,
c     &              attitude_dir, attitude_inv,
c     &              precise,verbose)
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
c         print *,' x_sca, y_sca', x_sca, y_sca
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
            if(verbose.gt.1) print 1059, x_sca, y_sca, tra, tdec
 1059       format(' x_sca, y_sca',2(1x,f8.2),2(1x,f14.10))
            nstars = nstars + 1
            write(20, 1060) l, tra, tdec, tmagnitude,
     *           tz, semi_major, semi_minor, ttheta, tnsersic,
     *           (array(j), j = 1, nfilters), x_sca, y_sca
c     print *,'nfilters ', nfilters
            
c     print 1060, l, tra, tdec, tmagnitude,
c     *        tz, semi_major, semi_minor, ttheta, tnsersic,
c     *        (array(j), j = 1, nfilters), x_sca, y_sca
 1060       format(i6,100(1x,f12.6))
c
c     write regions file
c
            if(sca_id .eq.485. or. sca_id .eq. 490) then
               write(30, 1070) tra, tdec, l !array(nfilters)
 1070          format('fk5;point(',f13.9,',',f14.9,')#point=boxcircle ',
     &              'color=magenta',1x,  'text={',i5,'}')
               write(40, 1080) x_sca,y_sca , l
 1080          format('image;point(',f13.2,',',f13.2,')#point=cross ',
     &              'color=red',1x,'text={',i5,'}')
c               write(30, 1081) ra_inv, dec_inv !, l
 1081          format('fk5;point(',f13.9,',',f13.9,')#point=x ',
     &              'color=green')
            else
               write(30, 1075) tra, tdec,  l
 1075          format('fk5;point(',f13.9,',',f13.9,')#point=box ',
     &              'color=grey',1x, 'text={',i5,'}')
               write(40, 1085) x_sca, y_sca , l
 1085          format('image;point(',f13.9,',',f13.9,')#point= circle ',
     &              'color=red',1x, 'text={',i5,'}')
c               write(30, 1081) ra_inv, dec_inv 
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
      print *,'kept ', nstars,' out of ',i-1, ' read'
      stop
      end
