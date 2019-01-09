      subroutine spherical_to_plane(ra0, dec0, x, y, ra, dec)
c
c     Calculate coordinates on a plane using inverse gnomonic projection
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
      double precision ra0, dec0, x, y, ra, dec
      double precision q, cosdist, cosdec0, sindec0, cosdec, sindec,
     *     cosra, sinra, dra, d0, dd
c
      q = dacos(-1.0d0)/180.d0
      dra  = (ra-ra0)*q
      d0   = dec0 * q
      dd   = dec  * q
c     
      cosdec0 = dcos(d0)
      sindec0 = dsin(d0)
c
      cosdec = dcos(dd)
      sindec = dsin(dd)
c
      cosra  = dcos(dra)
      sinra  = dsin(dra)
c
      cosdist = sindec0 * sindec + cosdec0 * cosdec * cosra
c
      x  = cosdec*sinra/cosdist
      y  = sindec * cosdec0 - cosdec * sindec0 * cosra
      y  = y/cosdist
      return
      end
