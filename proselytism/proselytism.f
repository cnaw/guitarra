c
      implicit none
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
      integer sca_id, verbose, indx, nstars, i,j, l, max_stars,
     *     nfilters, sca
c
      character catalogue*180, output_file*180, reg*180, header*200
c
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
      verbose = 1
      call load_osim_transforms(verbose)
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
c     ra0, dec0 are the NIRCam footprint centre coordinates 
c
      read(5, *) nfilters
      read(5,*) ra0, dec0, pa_degrees
      read(5,*) sca_id
 10   format(a180)
c
c     star catalogue
c
      read(5,10) catalogue
      read(5,10) output_file
c
      print *,'Proselytism : NIRCam centre position at ', ra0, dec0
c
c     Position of SCA centre
c
      i = sca_id - 480
      call rotate_coords2(xx, yy,  xnircam(i,6),ynircam(i,6),
     *           xc, yc, pa_degrees)

      ddec = dec0 - yy/60.d0
      cosdec = dcos(ddec*q)
      rra  = ra0  - xx/60.d0/cosdec
      print *, xnircam(i,6), ynircam(i,6), ra0, dec0
      print *, xx, yy, rra, ddec
 
c      open(1,file=catalogue)
c      open(2,file=output_file)
      nstars = 0
c      do i = 1, max_stars
c         read(1,110,end= 1000) indx, rra, ddec, x_osim, y_osim,
c     *        (array(j),j=1,nfilters)
 110     format(i5,2(2x, f16.12), 2(1x,f8.3), 58(2x,f8.3))
c         call ra_dec_to_sca(sca_id, 
c     *        ra0, dec0, rra, ddec, pa_degrees,
c     *        xc, yc,  osim_scale, x_sca, y_sca)
cc         print 120, rra, ddec, xc, yc, x_sca, y_sca
 120     format(20(1x,f10.4))
cc     
c         if(x_sca.ge.xmin .and. x_sca.le. xmax .and.
c     *        y_sca.ge. ymax .and.y_sca.le.ymin) then
c            write(2, 140) indx, rra, ddec, x_sca, y_sca,
c     *           (array(j),j=1,nfilters)
 140        format(i5,2(2x, f16.12), 2(1x,f8.3), 58(2x,f8.3))
c            nstars = nstars + 1
c         end if
c      end do
 1000 continue
c      close(1)
c      close(2)
c      print *,'kept ', nstars,' out of ',i-1, 'stars read'
c
c     read galaxy catalogue
c     
      read(5,10) catalogue
      read(5,10) output_file
c      close(10)
c     
      open(1,file = catalogue)
      open(2,file = output_file)
      write(reg, 170) sca_id
 170  format('test_',i3.3,'_rd.reg')
      open(3,file = reg)
      write(reg, 180) sca_id
 180  format('test_',i3.3,'_xy.reg')
      open(4,file = reg)
      print 10, catalogue
      read(1, 190) header
      write(2, 190) header
 190  format(a200)
      nstars = 0
      do i = 1, max_stars
         read(1, *, err= 1030, end=2000) l, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic,
     *        (array(j), j = 1, nfilters)
         go to 1050
c
c     if there is an error print this:
c
 1030      continue
         print *,'skipping '
         print 1040, l, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic
     *        ,(array(j), j = 1, nfilters)
 1040      format(i8,20(1x,f15.6))
         go to 1090
c
 1050    call ra_dec_to_sca(sca_id, 
     *        ra0, dec0, tra, tdec, pa_degrees,
     *        xc, yc,  osim_scale, x_sca, y_sca)
         print 1040, l, tra, tdec,  x_sca, y_sca
         print *, sca_id
         print 1040, l, ra0, dec0, tra, tdec, xc,yc, x_sca, y_sca
c     
         if(x_sca.ge.xmin.and. x_sca.le. xmax .and.
     *        y_sca.ge. ymin .and.y_sca.le.ymax) then
c            print 120, tra, tdec,  x_sca, y_sca
            nstars = nstars + 1
            write(2, 1060) l, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic,
     *        (array(j), j = 1, nfilters), x_sca, y_sca
c            print *,'nfilters ', nfilters

c            print 1060, l, tra, tdec, tmagnitude,
c     *        tz, semi_major, semi_minor, ttheta, tnsersic,
c     *        (array(j), j = 1, nfilters), x_sca, y_sca
 1060       format(i6,100(1x,f12.6))
            if(sca_id .eq.485. or. sca_id .eq. 490) then
               write(3, 1070) tra, tdec, array(nfilters)
 1070          format('fk5;point(',f12.7,',',f12.7,'#point= boxcircle ',
     &              'color=magenta',1x,  'text={',f6.3,'}')
               write(4, 1080) x_sca, y_sca !, l
 1080          format('image;point(',f12.7,',',f12.7,'#point= cross ',
     &              'color=red') ! 'text={',i5,'}')
            else
               write(3, 1075) tra, tdec !, l
 1075          format('fk5;point(',f12.7,',',f12.7,'#point=box ',
     &              'color=grey') ! 'text={',i5,'}')
               write(4, 1085) x_sca, y_sca !, l
 1085          format('image;point(',f12.7,',',f12.7,'#point= circle ',
     &              'color=red') ! 'text={',i5,'}')
            end if
         end if
 1090    continue
      end do
 2000 close(1)
      close(2)
      close(3)
      close(4)
      print *,'kept ', nstars,' out of ',i-1, ' read'
      stop
      end
