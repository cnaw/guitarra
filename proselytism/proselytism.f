c
      implicit none
      double precision attitude_dir, attitude_inv
      integer ideal_to_sci_degree, v_idl_parity,
     &     sci_to_ideal_degree, det_sci_parity
      double precision 
     &     x_det_ref, y_det_ref,
     &     x_sci_ref, y_sci_ref,
     &     sci_to_ideal_x, sci_to_ideal_y,
     &     ideal_to_sci_x, ideal_to_sci_y,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang,
     &     det_sci_yangle,
     &     v2_ref, v3_ref
      double precision ra_ref, dec_ref,
     &     nrcall_v2,nrcall_v3
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

      double precision rra, ddec, ra0, dec0, pa_degrees, xc, yc,
     *     x_sca, y_sca, x_osim, y_osim, array, xx, yy, q, cosdec
c
      integer sca_id, verbose, indx, nstars, i,j, l,mm, max_stars,
     *     nfilters, sca, distortion
c
      character catalogue*180, output_file*180, reg*180, header*200,
     &     scatalogue*180, soutput_file*180,guitarra_aux*100,
     &     list*180
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
c
c     Load the conversion coefficients (without distortion)
c
      max_stars = 1000000
      verbose = 0
      precise = 0
      call load_osim_transforms(verbose)
c
c     Because objects can be extended, create a buffer zone which may
c     contain the centre of a larger object and have the outskirts 
c     contained within the boundaries of this detector
c
      buffer =   300.d0
      xmin   =    5.d0 - buffer
      xmax   = 2044.d0 + buffer
      ymin   =    5.d0 - buffer
      ymax   = 2044.d0 + buffer
c
c     this needs to be used to find the centre coordinates of each SCA
c     relative to the NIRCam pointing position
c
      call read_nircam_outline
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

c
      print 30,ra0, dec0,distortion
 30   format('Proselytism : NIRCam centre position, distortion ', 
     &     2(2x,f16.10), i4)
      sca_n = sca_id - 480
c        
cccccccccccccccccccc
c
c     version with distortions
c
      if(distortion.eq.1) then
c
c     read the V2, V3 parameters for the centre of NIRCam and the
c     10 detectors
c
         call getenv('GUITARRA_AUX',guitarra_aux)
         list = guitarra_aux(1:len_trim(guitarra_aux))//'v2v3_reference_
     &coords.dat'
         print 190, list
         open(1,file=list)
         read(1,*)
         read(1, *)  nrcall_v2, nrcall_v3
ccc         do ii = 1, 10
ccc            read(1, *) v2_ref(ii), v3_ref(ii)
ccc            if(verbose.gt.0) print 40,  v2_ref(ii), v3_ref(ii)
ccc 40         format(2(2x,f16.10))
ccc         end do
         close(1)
         call read_siaf_parameters(sca_n,
     &        sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &        ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &        x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &        det_sci_yangle, det_sci_parity,
     &        v3_idl_yang, v_idl_parity, v2_ref, v3_ref, verbose)
c     
c     build attitude matrix
c     
         ra_rad   = ra0 * q
         dec_rad  = dec0 * q
         pa_rad   = pa_degrees * q
         v2_rad   = nrcall_v2 * q/3600.d0
         v3_rad   = nrcall_v3 * q/3600.d0
c         print *,  v2_rad, v3_rad, ra_rad, dec_rad, pa_rad
         call attitude( v2_rad, v3_rad, ra_rad, dec_rad, pa_rad,
     *        attitude_dir)
c
c     Find RA, DEC of SCA centre
c
         v2_rad   = v2_ref * q/3600.d0
         v3_rad   = v3_ref * q/3600.d0
         call rot_coords(attitude_dir, v2_rad, v3_rad, ra_rad, dec_rad)
         call coords_to_ra_dec(ra_rad, dec_rad, ra, dec)
c
c     3. Build attitude matrices for this new position that allow 
c     getting V2, V3 from the catalogue RA, DEC
c     direct does (v2,v3)   -> (ra, dec)
c     inverse     (ra, dec) -> (v2, v3)
c
c         print *,  v2_rad, v3_rad, ra_rad, dec_rad, pa_rad
         call attitude( v2_rad, v3_rad, ra_rad, dec_rad, pa_rad,
     *        attitude_dir)
         do jj = 1, 3
            do ii = 1, 3
               attitude_inv(jj,ii) = attitude_dir(ii,jj)
            end do
         end do
c        
cccccccccccccccccccc
c      else
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
 190  format(a200)
c
      open(10,file = catalogue)
      open(20,file = output_file)
      write(reg, 170) sca_id
      open(30,file = reg)
      write(reg, 180) sca_id
      open(40,file = reg)
      print 10, catalogue
      read(10, 190) header
      write(20, 190) header
      nstars = 0
      do i = 1, max_stars
         read(10, *, err= 1030, end=2000) l, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic,
     *        (array(j), j = 1, nfilters)
         go to 1050
c
c     if there is an error print this:
c
 1030    continue
         print *,'skipping ',i
         print 1040, l, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic
     *        ,(array(j), j = 1, nfilters)
 1040    format(i8,20(1x,f15.6))
         go to 1090
c     
 1050    if(distortion.eq.1) then
            ra_rad  = tra * q
            dec_rad = tdec * q
            call rot_coords(attitude_inv, ra_rad, dec_rad, 
     &           v2_rad, v3_rad)
            call coords_to_v2_v3(v2_rad, v3_rad,v2_arcsec,v3_arcsec)
            call v2v3_to_det(
     &           x_det_ref, y_det_ref, 
     &           x_sci_ref, y_sci_ref,
     &           sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
     &           ideal_to_sci_x,ideal_to_sci_y,ideal_to_sci_degree,
     &           v3_sci_x_angle,v3_sci_y_angle,
     &           v3_idl_yang, v_idl_parity,
     &           det_sci_yangle,
     &           v2_ref, v3_ref,
     &           v2_arcsec, v3_arcsec, x_sca, y_sca,
     &           precise,verbose)
         else
            call ra_dec_to_sca(sca_id, 
     *           ra0, dec0, tra, tdec, pa_degrees,
     *           xc, yc,  osim_scale, x_sca, y_sca)
         end if
         if(x_sca.ge.xmin.and. x_sca.le. xmax .and.
     *        y_sca.ge. ymin .and.y_sca.le.ymax) then
            do mm = 1, nfilters
               if(array(mm).lt. 10.0d0) then
                  print *,' skipping bright object', l, array(mm)
                  go to 1090
               end if
            enddo
c     print 120, tra, tdec,  x_sca, y_sca
            nstars = nstars + 1
            write(20, 1060) l, tra, tdec, tmagnitude,
     *           tz, semi_major, semi_minor, ttheta, tnsersic,
     *           (array(j), j = 1, nfilters), x_sca, y_sca
c     print *,'nfilters ', nfilters
            
c     print 1060, l, tra, tdec, tmagnitude,
c     *        tz, semi_major, semi_minor, ttheta, tnsersic,
c     *        (array(j), j = 1, nfilters), x_sca, y_sca
 1060       format(i6,100(1x,f12.6))
            if(sca_id .eq.485. or. sca_id .eq. 490) then
               write(30, 1070) tra, tdec, array(nfilters)
 1070          format('fk5;point(',f12.7,',',f12.7,'#point= boxcircle ',
     &              'color=magenta',1x,  'text={',f6.3,'}')
               write(40, 1080) x_sca, y_sca !, l
 1080          format('image;point(',f12.7,',',f12.7,'#point= cross ',
     &              'color=red') ! 'text={',i5,'}')
            else
               write(30, 1075) tra, tdec !, l
 1075          format('fk5;point(',f12.7,',',f12.7,'#point=box ',
     &              'color=grey') ! 'text={',i5,'}')
               write(40, 1085) x_sca, y_sca !, l
 1085          format('image;point(',f12.7,',',f12.7,'#point= circle ',
     &              'color=red') ! 'text={',i5,'}')
            end if
         end if
 1090    continue
         if(verbose.gt.0) print *,'distortion', 
     &        distortion, i, l, x_sca, y_sca
      end do
 2000 close(10)
      close(20)
      close(30)
      close(40)
      print *,'kept ', nstars,' out of ',i-1, ' read'
      stop
      end
