      subroutine sca_coords_from_osim(indx, xx, yy, x_lw, y_lw)
c
c     given the transformations in ox*, oy* find the SCA coordinate
c     corresponding to an OSIM position. In spite of "lw" this is
c     valid for SW and LW since xmag and ymag specify the scale.
c
c
c     (C) Copyright 2015 Christopher N. A. Willmer
c     Steward Observatory, University of Arizona
c     cnaw@as.arizona.edu 
c     2015-02-02
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
      integer index, indx
      double precision xx, yy, x_lw, y_lw, q
      double precision oxshift, oyshift, oxmag, oymag, oxrot, oyrot
      dimension oxshift(10), oyshift(10), oxmag(10), oymag(10),
     *      oxrot(10), oyrot(10)
      common /otransform/ oxshift, oyshift, oxmag, oymag, oxrot, oyrot
      q = dacos(-1.0d0)/180.d0
c
      if(indx.gt. 400) then
         index = indx - 480 
      else
         index = indx
      end if
      x_lw = oxshift(index) + oxmag(index) * dcos(oxrot(index)*q) * xx + 
     *        oymag(index) * dsin(oyrot(index)*q) * yy
      y_lw = oyshift(index) - oxmag(index) * dsin(oxrot(index)*q) * xx + 
     *     oymag(index) * dcos(oyrot(index)*q) * yy
c      end if
      return
      end
