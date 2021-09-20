c
c-----------------------------------------------------------------------
c
      subroutine read_guitarra_slope(filename, 
     &     image, ooo, nx, ny, nz, nhdu,
     &     subarray, colcornr, rowcornr,
     &     wcsaxes, 
     &     crpix1, crpix2, crpix3, 
     &     crval1, crval2, crval3, 
     &     ctype1, ctype2, ctype3,
     &     cunit1, cunit2, cunit3,
     &     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3,
     &     cdelt3,
     &     ra_ref, dec_ref, roll_ref, pa_v3,
     &     equinox, read_patt,
     &     v3i_yang, v_idl_parity, 
     &     a_order, aa, b_order, bb,
     &     ap_order, ap, bp_order, bp,
     &     max_i, max_j,
     &     targprop, detector, module, filter, pupil,
     &     header_only, verbose)
      implicit none
      double precision cd1_1, cd1_2, cd2_1, cd2_2, cd3_3,
     &     crpix1, crpix2, crpix3, 
     &     crval1, crval2, crval3, 
     &     cdelt1, cdelt2,
     &     ra_ref, dec_ref, roll_ref, pa_v3,
     &     equinox, cdelt3
      double precision v3i_yang, aa, bb, ap, bp
      integer wcsaxes, v_idl_parity
      integer a_order, b_order, ap_order, bp_order
      character read_patt*10, subarray*8
      character card*80, comment*40,  radesys*8
      character ctype1*(*), ctype2*(*), ctype3*(*)
      character cunit1*40, cunit2*40, cunit3*40
      character targprop*40, detector*40, module*2, filter*15, pupil*15
c
      real image
      integer nhdu, nx, ny, nz, naxes,colcornr, rowcornr
      integer verbose, header_only, max_i, max_j
      character filename*180
c
      integer i, j,iexp, jexp, ii, jj, kk, ll, nnn, ooo, nfound,
     &     ncol, nrow, group, number_of_hdu
      character coeff_name*10
      logical chabu
c
      dimension aa(max_i, max_j), bb(max_i, max_j),
     &     ap(max_i, max_j), bp(max_i, max_j)
      dimension naxes(3)
c
      double precision dx
      integer ix
      integer unit, status, bitpix, hdutype, readwrite
      character name*20, key*8
c
      parameter (nnn=2048)
c
      dimension image(ooo, ooo), dx(nnn,nnn), ix(nnn,nnn)
c
      status = 0
      readwrite = 0
      call openfits(unit, readwrite, filename)
      if(verbose.gt.0) print *,'read_fits : unit, status',unit, status
      if(verbose.gt.0) print 40, filename
 40   format('read_guitarra_slope: reading file ', a80)
c     
      status = 0
      call ftthdu(unit, number_of_hdu,  status)
c
c     WCS and header parameters are in primary header
c
      nhdu  = 1
      call ftmahd( unit, nhdu, hdutype, status)
c
      call get_guitarra_wcs(unit, radesys, equinox,
     &     ra_ref, dec_ref, roll_ref, pa_v3,
     &     v3i_yang, v_idl_parity, 
     &     ctype1, cunit1, crpix1, crval1, cdelt1, 
     &     ctype2, cunit2, crpix2, crval2, cdelt2,
     &     cd1_1, cd1_2, cd2_1, cd2_2,
     &     a_order, aa, b_order, bb, 
     &     ap_order, ap, bp_order, bp, 
     &     max_i, max_j, verbose)
c      
      key  = 'TARGPROP'
      call ftgkys(unit,key,targprop,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, key
      end if
c     
      key  = 'DETECTOR'
      call ftgkys(unit,key,detector,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, key
      end if
c
      key  = 'MODULE'
      call ftgkys(unit,key,module,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, key
      end if
c     
      key  = 'FILTER'
      call ftgkys(unit,key,filter,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, key
      end if
c
      key  = 'PUPIL'
      call ftgkys(unit,key,pupil,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, key
      end if
c
      if(header_only .eq. 1) then
          call closefits(unit)
          return
       end if
c     
      call ftgkyj(unit,"BITPIX",bitpix,comment, status)
      if(verbose.gt.0) print 50, bitpix
 50   format('read_funky_fits:BITPIX ', i4)
c
c     determine the image size
c     
      call ftgknj(unit,'NAXIS',1,3,naxes,nfound,status)
      if(status .ne.0) then
         call printerror(status)
      end if
c     
c     check that it found both NAXIS1 and NAXIS2 keywords
c     
      if(nfound .lt. 2) then
         if(verbose.gt.0) then
            print *,' read_guitarra_slope:',
     *           'This is the number of NAXISn keywords.', 
     *           nfound, (naxes(i),i=1,nfound)
         end if
      end if
c
c     read image
c     
      group=1
      ncol = naxes(1)
      nrow = max(1,naxes(2))
      nz   = max(1,naxes(3))
      if(bitpix.eq.16 .or.bitpix.eq.32) then
         call ftg2dj(unit,group,0,nnn,naxes(1),naxes(2),ix, 
     *        chabu, status)
         if(status.ne.0) then
            print *,'read_guitarra_slope :ftg2dj',nnn
            call printerror(status)
         end if
         do j = 1, nrow
            do i = 1, ncol
               image(i,j) = real(ix(i,j))
            end do
         end do
      end if
c
      if(bitpix.eq.-32) then
         call ftg2de(unit,group,0,nnn,naxes(1),naxes(2),image, 
     *        chabu, status)
         if(status .ne.0) then
            print *,'read_guitarra_slope :ftg2de',nnn
            call printerror(status)
         end if
      end if
c     
      if(bitpix.eq.-64) then
         call ftg2dd(unit,group,0,nnn,naxes(1),naxes(2),dx, 
     *        chabu, status)
         if(status .ne.0) then
            print *,'read_guitarra_slope :ftg2dd',nnn
            call printerror(status)
         end if
         do i = 1, ncol
            do j = 1, nrow
               image(i,j) = real(dx(i,j))
            end do
         end do
      end if
      call closefits(unit)
c     
      nx = naxes(1)
      ny = naxes(2)
c      nz = naxes(3)
      return
      end

