c=======================================================================
c
      subroutine read_nircam_outline
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
      integer sca, i, j, isca
      double precision  xnircam, ynircam, xx, yy, px, py, 
     *     x0_nircam, y0_nircam 
      dimension sca(10), xnircam(6,10), ynircam(6,10)
      character guitarra_aux*80, file*80
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
      call getenv('GUITARRA_AUX',guitarra_aux)
      file = guitarra_aux(1:len_trim(guitarra_aux))//'nircam_flight.dat'
c      open(1,file='nircam_flight.dat')
      open(1,file=file)
      do j = 1, 10
         do i = 1, 6
            read(1,*) xx, yy, px, py, isca
 10        format(4(1x,f16.10), i5)
            xnircam(i,j) = xx
            ynircam(i,j) = yy
            sca(j) = isca
c            print 10, xnircam(i,j), ynircam(i,j), px, py, sca(j)
         end do
c         xnircam(6,j) = xnircam(1,j) + (xnircam(2,j)-xnircam(1,j))/2.d0
c         ynircam(6,j) = ynircam(1,j) + (ynircam(3,j)-ynircam(1,j))/2.d0
c         print 10, xnircam(6,j), ynircam(6,j), px, py, sca(j)
      end do
      close(1)
c
c      print *,'read_nircam_outline: Centre of NIRCam in V2, V3 at'
c      print 10, x0_nircam, y0_nircam
      return
      end
