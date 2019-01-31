c
c-----------------------------------------------------------------------
c
      subroutine read_fits(filename, image, nx, ny, verbose)
      real image
      integer unit, status, bitpix, verbose, readwrite
      character name*20, comment*80
      character filename*(*)
c
      parameter (nnn=2048)
c
      dimension image(nnn,nnn)
c
      status = 0
      readwrite = 0
      call ftgiou(unit, status)
      if(verbose.gt.0)print *,'read_fits : unit, status',unit, status
      call openfits(unit, readwrite, filename)
      call ftgkyj(unit,"BITPIX",bitpix,comment, status)
      if(verbose.gt.0) print 40, filename
 40   format('reading file ', a80)
      call getfitsdata2d(unit,image,ncol,nrow, bitpix,verbose)
      call closefits(unit)
c      close (unit)
      nx = ncol
      ny = nrow
      return
      end
c
c----------------------------------------------------------------------
c
      subroutine nircam_keywords(iunit,nframe, tframe, groupgap, tgroup, 
     *     ngroup, object, partname, sca_id, module, filter, 
     *     subarrmd,subarszx, subarszy, subar_x1, subar_y1, job)
      logical subarrmd
      integer subarszx, subarszy, subar_x1, subar_y1
      integer status, groupgap, tgroup,drop_frame_1,sca_id
      character telescop*20, instrume*20, filter*20,
     *     module*20, partname*4,comment*40, object*20
c      real  
      double precision
     *     equinox, crpix1, crpix2, crval1, crval2,
     *      cdelt1, cdelt2, cd1_1, cd1_2, cd2_1, cd2_2
      common /wcs/ equinox, crpix1, crpix2, crval1, crval2,
     *     cdelt1,cdelt2, cd1_1, cd1_2, cd2_1, cd2_2


c     Put information into keywords and write them
c     
c     The following are fixed...
c
      instrume = 'simulator'
      telescop = 'Az_Lab'
      if(subarrmd) then
         ibrefrow = 0
         itrefrow = 0
      else
         ibrefrow = 4
         itrefrow = 4
      end if
      drop_frame_1 = 0
      cd3_3        = 1.00000
c
      status =  0
      comment='                                       '
      call ftpkyj(iunit,'NFRAME',nframe,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'NFRAME'
       end if
      status =  0

      comment='                                       '
      call ftpkye(iunit,'TFRAME',tframe,7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'TFRAME'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyj(iunit,'GROUPGAP',groupgap,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'GROUPGAP'
       end if
      status =  0
c
      comment='                                       '
      call ftpkyj(iunit,'TGROUP',tgroup,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'TGROUP'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyj(iunit,'NGROUP',ngroup,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'NGROUP'
       end if
      status =  0
c
c     job number so it is compatible with NIRCam tests
c
      comment='                                       '
      call ftpkyj(iunit,'SRCFIL1',job,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SRCFIL1'
       end if
      status =  0
c
      comment='                                       '
      call ftpkys(iunit,'OBJECT ',object,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'object'
       end if
      status =  0
c
      comment='                                       '
      call ftpkys(iunit,'TELESCOP',telescop,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'telescop'
       end if
      status =  0
c
      comment='                                       '
      call ftpkys(iunit,'INSTRUME',instrume,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'instrume'
       end if
      status =  0
c
      comment='                                       '
      call ftpkys(iunit,'FILTER',filter,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'filter'
       end if
      status =  0
c
      comment='                                       '
      call ftpkys(iunit,'PARTNAME',partname,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'filter'
       end if
      status =  0
c
      comment='                                       '
      call ftpkyj(iunit,'SCA_ID',sca_id,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SCA_ID'
       end if
      status =  0
c
      comment='                                       '
      call ftpkys(iunit,'MODULE',module,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'filter'
       end if
      status =  0
c
c
c     Sub-array related keywords
c
      comment='                                       '
      call ftpkyl(iunit,'SUBARRMD',subarrmd,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SUBARSZX'
       end if
      status =  0
c
      comment='                                       '
      call ftpkyj(iunit,'SUBARSZX',subarszx,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SUBARSZX'
       end if
      status =  0
c
      comment='                                       '
      call ftpkyj(iunit,'SUBARSZY',subarszy,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SUBARSZY'
       end if
      status =  0
c
      comment='                                       '
c      call ftpkyj(iunit,'SUBAR_X1',subar_x1,comment,status)
      call ftpkyj(iunit,'COLSTART',subar_x1,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SUBAR_X1'
       end if
      status =  0
c
      comment='                                       '
c      call ftpkyj(iunit,'SUBAR_Y1',subar_y1,comment,status)
      call ftpkyj(iunit,'ROWSTART',subar_y1,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'SUBAR_Y1'
       end if
      status =  0
c
      comment='                                       '
      call ftpkyj(iunit,'BREFROW',ibrefrow,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'BREFROW'
       end if
      status =  0
c
      comment='                                       '
      call ftpkyj(iunit,'TREFROW',itrefrow,comment,status)
       if (status .gt. 0) then
          call printerror(status)
          print *, 'TREFROW'
       end if
c
      comment='                                       '
      call ftpkyj(iunit,'DROPFRM1',drop_frame_1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'drop_frame_1'
       end if
c       print *,'end keywords'
c
c     fake WCS keywords
c
      comment='                                       '
      call ftpkys(iunit,'CTYPE1','RA---TAN',comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CTYPE1'
       end if
       status =  0
c
      call ftpkys(iunit,'CTYPE2','DEC---TAN',comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CTYPE2'
       end if
       status =  0
c
      call ftpkys(iunit,'RADESYS','FK5',comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'RADESYS'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyd(iunit,'EQUINOX',equinox,1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'EQUINOX'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyd(iunit,'CRVAL1',crval1,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CRVAL1'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyd(iunit,'CRPIX1',crpix1,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CRPIX1'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyd(iunit,'CRVAL2',crval2,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CRVAL2'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyd(iunit,'CRPIX2',crpix2,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CRPIX2'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyd(iunit,'CD1_1',cd1_1,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CD1_1'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyd(iunit,'CD1_2',cd1_2,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CD1_2'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyd(iunit,'CD2_1',cd2_1,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CD2_1'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyd(iunit,'CD2_2',cd2_2,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CD2_2'
       end if
       status =  0
c
      comment='                                       '
      call ftpkyd(iunit,'CD3_3',cd3_3,12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CD2_2'
       end if
       status =  0
      return
      end
