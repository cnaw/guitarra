c      implicit none
c      character *180 file
c      file = 
c     &'/home/cnaw/guitarra/data/PRDOPSSOC-034/nircam_outline.ascii'
c      call read_nircam_outline(file)
c      stop
c      end
c=======================================================================
c
      subroutine read_nircam_outline(file)
c
c     this reads the XAN, YAN coordinates of the NIRCam footprint,
c     and converts into V2, V3 where
c     V2 =  XAN
c     V3 = -YAN - 7.8
c     nircam_cv2.dat is a file calculated at GSFC by Renee Gracey
c     using CV2 data
c
c
c     (C) Copyright 2015 Christopher N. A. Willmer
c     Steward Observatory, University of Arizona
c     cnaw@as.arizona.edu 
c     2015-05-06
c     Using now flight coordinates
c     2016-07-29
c     added Dan Coe's SIAF centre
c     2017-01-17
c     Read outline derived from SIAF files 
c     2021-04-07
c
c------------------------------------------------------------------------------
c This routine is free software; you can redistribute it and/or modify it
c under the terms of the GNU General Public License as published by the Free
c Software Foundation; either version 3 of the License, or (at your option) any
c later version.
c This program is distributed in the hope that it will be useful,
c but WITHOUT ANY WARRANTY; without even the implied warranty of
c MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
c GNU General Public License for more details.
c-----------------------------------------------------------------------------
c     
      implicit none
      integer sca, i, j, ii, jj, isca
      double precision  xnircam, ynircam, xx, yy, px, py, 
     *     x0_nircam, y0_nircam 
      dimension sca(10), xnircam(6,11), ynircam(6,11)
      character guitarra_aux*180, file*(*)
      common /nircam/ x0_nircam, y0_nircam, xnircam, ynircam, sca
c
c     Displacement of NIRCam centre relative to JWST FOV centre
c     Values from Dan Coe 2016-11-18 for pointing centroid (SIAF coordinates)
c     
      x0_nircam  =   -0.3174d0 ! arc sec
      y0_nircam  = -492.5913d0 ! arc sec
      x0_nircam  = x0_nircam/60.d0         ! = -0.00529 arc min
      y0_nircam  = y0_nircam/60.d0 !+ 7.8d0 ! = -0.409855 arc min
c
c     The "Y" values in jwst.dat are in XAN, YAN coordinates. 
c     V2 = XAN but V3 = -YAN +7.8 , so change sign for the latter
c
c      open(1,file='nircam_2014_02_12.dat')
c
c     nircam_flight.dat uses V2, V3 coordinates for the vertices
c
c      call getenv('GUITARRA_AUX',guitarra_aux)
c      file = guitarra_aux(1:len_trim(guitarra_aux))//'nircam_flight.dat'
      print 1, file
 1    format('read_nircam_outline ',a180)
c      open(1,file='nircam_flight.dat')
      open(1,file=file)
      do j = 1, 11
         do i = 1, 5
            read(1,*) xx, yy, px, py, isca
c            print 10,  xx, yy, px, py, isca
 10        format(4(1x,f16.10), 3i5)
           if(isca.eq.0) then
              if(px.eq.1024.5 .and. py.eq.1024.5) then
                 x0_nircam = xx/60.d0
                 y0_nircam = yy/60.0d0
              end if
              go to 90
           end if
           if(isca.ge.481 .and. isca.le.485) then
              ii = i
              jj = j
              if(px.eq.1024.5 .and. py.eq.1024.5) ii=6
           end if
           if(isca.ge.486) then
              ii = i
              jj = j-1
              if(px.eq.1024.5 .and. py.eq.1024.5) ii=6
           end if
           xnircam(ii,jj) = xx/60.d0
           ynircam(ii,jj) = yy/60.d0
           sca(jj) = isca
c           print 10, xnircam(ii,jj), ynircam(ii,jj), px, py, 
c     &          sca(jj),ii,jj
 90        continue
        end do
        if(isca.ne.0) then
           xnircam(5,jj) = xnircam(1,jj)
           ynircam(5,jj) = ynircam(1,jj) 
        end if
c         print 10, xnircam(6,j), ynircam(6,j), px, py, sca(j)
      end do
      close(1)
c
c      do jj = 1, 10
c         print *,' '
c         do ii = 1, 6
c            print 100, xnircam(ii,jj),
c     &           ynircam(ii,jj),sca(jj)
c 100        format(2(2x,f16.10), i5)
c         end do
c      end do
      print *,'read_nircam_outline: Centre of NIRCam in V2, V3 at'
      print 10, x0_nircam, y0_nircam
      return
      end
