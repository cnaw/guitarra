      subroutine rotate_coords(xc, yc, xin, yin, pa_degrees, xrot, yrot)
c
c     Rotate coordinates around xc, yc by pa_degrees for a point at
c     xin, yin
c
c     (C) Copyright 2015 Christopher N. A. Willmer
c     Steward Observatory, University of Arizona
c     cnaw@as.arizona.edu 
c     2015-01-30
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
c     Calculate the rotated coordinates xrot, yrot, for input (xin, yin)
c     for a rotation of pa_degrees for axes centered at (xc, yc)
c
      implicit none
      double precision xc, yc, xin, yin, pa_degrees, xrot, yrot, q, 
     *     dx, dy, pa_rad,cospa, sinpa
c
      q = dacos(-1.0d0)/180.d0
c
      pa_rad = pa_degrees * q
      cospa = dcos(pa_rad)
      sinpa = dsin(pa_rad)
c
      dx    = xin - xc
      dy    = yin - yc
c
      xrot  = xc + dx * cospa + dy * sinpa
      yrot  = yc - dx * sinpa + dy * cospa
c      print *, 'rotate_coords',xin, yin, dx, dy, cospa, sinpa, 
c     *     xc, yc,xrot, yrot
      return
      end
