      subroutine plane_to_spherical(ra0, dec0, x, y, ra, dec)
c
c-----------------------------------------------------------------------
c
c     convert coordinates measured on a projected plane  to
c     spherical coordinates using the inverse gnomonic projection
c     
c     ra0     -  RA  corresponding to field center (degrees)
c     dec0    -  DEC corresponding to field center (degrees)
c     x       -  x coordinate on plane (radians) 
c     y       -  y coordinate on plane (radians)
c     ra      -  RA  corresponding to (x, y) in degrees
c     dec     -  DEC corresponding to (x, y) in degrees
c
c     Translated from IRAF SPP code under 
c     $iraf/sys/mwcs/wftan.x
c     SPP code copyrighted by AURA 1986
c
c     Steward Observatory, University of Arizona
c     cnaw@as.arizona.edu 
c     2015-02-06
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
c
      implicit none
      double precision ra0, dec0, x, y, ra, dec, rho, xx, yy, zz, q,
     *     cosdec0, sindec0, datan3
c
      q = dacos(-1.d0)/180.0d0
c
      cosdec0 = dcos(dec0*q)
      sindec0 = dsin(dec0*q)
c
      xx  =  cosdec0 - y * sindec0
      yy  =  x
      zz  =  sindec0 + y * cosdec0
      if(xx.eq.0.d0 .and. yy.eq.0.d0) then
         ra = 0.0d0
      else
         ra = datan2(yy,xx)
      end if
      rho = dsqrt(xx*xx + yy*yy)
      dec = datan2(zz, rho)
      ra  = ra/q + ra0
      dec = dec/q
      if(ra.gt.360.0d0) ra = ra - 360.0d0
      if(ra.lt.  0.0d0) ra = ra + 360.0d0
      return
      end
