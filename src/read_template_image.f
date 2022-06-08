c     
      subroutine read_template_image(filename, bitpix,
     &     cube, int_cube,
     &     mmm, nnn, ooo, nx, ny, nz,redshift, mag, number,
     &     radesys, equinox,
     &     ctype1, cunit1, crpix1, crval1,
     &     ctype2, cunit2, crpix2, crval2,
     &     ctype3, cunit3, crpix3, crval3, 
     &     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3,
     &     filter, wl_filter, magnitude, zp, source, nf,
     &     verbose)
c
      implicit none
      character filename*180, comment*20, source*120
      integer int_cube, mmm, nnn, ooo, nx, ny, nz, number
      real cube,real_null
      double precision redshift, mag
c      
      integer status, bitpix, verbose, group, naxis, naxes, in_unit,
     &     nullval, i, j, readwrite
      logical anyf
c
      double precision  equinox, crpix1, crpix2, crval1, crval2,
     *     crpix3, crval3, cd1_1, cd1_2, cd2_1, cd2_2, cd3_3
      character cunit1*(*), cunit2*(*), cunit3*(*), radesys*(*),
     *     ctype1*(*),ctype2*(*), ctype3*(*)
c
      character filter*(*)
      integer hdu, nf
      double precision wl_filter, magnitude, zp
      dimension filter(ooo), wl_filter(ooo), magnitude(ooo), zp(ooo),
     &     source(ooo)
c
      dimension cube(mmm,nnn,ooo), int_cube(mmm,nnn,ooo), naxes(3)
c
      naxes = 0
      cube = 0.0
      int_cube = 0
 
      if(verbose .eq.1) print *, ' entered read_template_image'
c     
c     read input file
c     
      readwrite = 0
      status = 0
      call openfits(in_unit, readwrite, filename)
c     Int or real ?
      call ftgkyj(in_unit,"BITPIX",bitpix,comment, status)
      if(verbose .eq.1) 
     *     print *,'read_template_image: status is ', 
     &     status,' bitpix ', bitpix
c     determine image size
      call ftgidm(in_unit, naxis, status)
      if(verbose .eq.1) 
     *     print *,'read_template_imagestatus is ', 
     &     status,' naxis ', naxis
c     
      call ftgisz(in_unit, naxis, naxes, status)
      if(verbose .eq.1) 
     *     print *,'read_template_image: status is ', 
     &     status,' naxes ', naxes
c
      if(naxes(1).gt. mmm .or. naxes(2).gt. nnn .or.
     &     naxes(3).gt. ooo) then
         print *,'******************************************'
         print *,'read_template_image : dimension mis-match:'
         print *,' mmm, nnn, ooo ', mmm, nnn, ooo
         print *,' naxes         ', naxes
         print *,'******************************************'
         stop
      end if
c
      call get_wcs(in_unit, radesys, equinox,
     &     ctype1, cunit1, crpix1, crval1,
     &     ctype2, cunit2, crpix2, crval2,
     &     ctype3, cunit3, crpix3, crval3, 
     &     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3,
     &     verbose)
c
      if(verbose.gt.0) then
         print *,'read_template_image equinox :', equinox
         print *,crpix1, crval1
         print *,crpix2, crval2
c         print *,crpix3, crval3
         print *,'read_template_image: cd1_1, cd1_2, cd2_1, cd2_2',
     &        cd1_1, cd1_2, cd2_1, cd2_2
      end if
c
      call ftgkyj(in_unit,"number",number,comment, status)
      if(status.ne.0) then
         print *,'read_template_image: ftgkyj status is ', 
     &        status,' at  number ', number
         call printerror(status)
         status = 0
      end if
c     
      call ftgkyd(in_unit,"REDSHIFT",redshift,comment, status)
      if(status.ne.0) then
         print *,'read_template_image: status is ', 
     &        status,' redshift ', redshift
         call printerror(status)
         status = 0
      end if
c     
      call ftgkyd(in_unit,"MAG",mag,comment, status)
      if(status.ne.0) then
         print *,'read_template_image: status is ', status,' mag ', mag
         call printerror(status)
         stop
      end if
c     
      nx = naxes(1)
      ny = naxes(2)
      if(naxis.eq.3) then
         nz = naxes(3)
      else
         nz = 1
      end if
c
      nullval    = -999
      real_null  = -999.0
      group      =     1
c
      if(naxis.eq.3) then
         if(bitpix.eq.16 .or. bitpix.eq.32) then
            call ftg3dj(in_unit,group,nullval,mmm,nnn,naxes(1),naxes(2),
     *           naxes(3), int_cube,anyf,status)
            call printerror(status)
         end if
         if(bitpix.eq.-32) then
            call ftg3de(in_unit,group,nullval,mmm,nnn,naxes(1),naxes(2),
     *           naxes(3), cube,anyf,status)
            call printerror(status)
         end if
      end if
      if(naxis.eq.2) then
c         print *,'read_template_image ', naxis, bitpix
         if(bitpix.eq.16 .or. bitpix.eq.32) then
            call ftg2dj(in_unit,group,nullval,mmm,naxes(1),naxes(2),
     *           int_cube,anyf,status)
            call printerror(status)
         end if
         if(bitpix.eq.-32) then
            call ftg2de(in_unit,group,real_null,mmm,naxes(1),naxes(2),
     *           cube,anyf,status)
            call printerror(status)
         end if
      end if
c
      hdu = 2
      call read_template_table(in_unit, filter, wl_filter,
     &     magnitude, zp, source, nf, ooo, hdu, verbose)
      call ftclos(in_unit, status)
      call ftfiou(in_unit, status)
      return
      end
