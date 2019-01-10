      subroutine load_osim_transforms(debug)
c
c     Read CV2 OSIM <--> SCA transformations, faking those for A2
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
      double precision xshift, yshift, xmag, ymag, xrot,
     *     yrot, xrms, yrms, oxshift, oyshift, oxmag, oymag,
     *     oxrot, oyrot, oxrms, oyrms, xcorner,  ycorner, x_osim,
     *     y_osim, x_lw, y_lw, a2_v2, a2_v3,
     *     xavg_dir, xavg_inv, yavg_dir ,yavg_inv 
c
      integer sca, debug, choice, i, ii, j,nn
      character geomaps*30, file*80, guitarra_aux*80
      dimension sca(10), geomaps(2)

      dimension xcorner(5), ycorner(5)
      dimension xshift(10), yshift(10), xmag(10), ymag(10), xrot(10),
     *     yrot(10), xrms(10), yrms(10)
      dimension oxshift(10), oyshift(10), oxmag(10), oymag(10),
     *      oxrot(10), oyrot(10), oxrms(10), oyrms(10)
c
      common /transform/ xshift, yshift, xmag, ymag, xrot, yrot
      common /otransform/ oxshift, oyshift, oxmag, oymag, oxrot, oyrot
c
c      data geomaps/'CV2_nasa_transforms.dat','fake_transforms.dat'/
c     modified 2018-02-02:
c     to use the NIRCam flight solution from Renee Gracey's measurements.
c
      data geomaps/'NIRCam_flight_transforms.dat','fake_transforms.dat'/
      data xcorner /5.d0, 2044.d0, 2044.d0,    5.d0,    5.d0/
      data ycorner /5.d0,    5.d0, 2044.d0, 2044.d0,    5.d0/
c
c     Scales:
c
c     SW pixel width = 18 um = 0.0317 arc sec
c     LW pixel width = 18 um = 0.0648 arc sec
c
c     The average scale in OSIM units/pixel
c     SWX : 0.019841  SWY: 0.0198140   = 0.0317" nominal
c     LWX : 0.040270  LWY: 0.0401804   = 0.0648" nominal
c     
c     thus 
c     osim_x  = 1.597702 arc sec; osim_y = 1.599879 arc sec (SW) 
c     osim_x  = 1.609128 arc sec; osim_y = 1.612727 arc sec (LW)
c
c     However the osim unit must be the same for both detectors;
c     assuming SW_x = SW_y = 0.0317 "/pix this implies a scale of 
c     LW_x = 0.0643395"/pix
c     LW_y = 0.0642838"/pix
c     or average of 0.0643117"/pix
c     This is equivalent to 0.0648"/pix /1.00759
c
c     read coefficients
c     
      choice = 1
c      open(1,file=geomaps(choice))
      call getenv('GUITARRA_AUX',guitarra_aux)
      file = guitarra_aux(1:len_trim(guitarra_aux))//geomaps(choice)
      open(1,file=file)
      do i = 1, 10
c     direct 
c     (X_pix, Y_pix) -->  (X_osim, Y_osim)
c
         read(1,10,err=120,end=100) sca(i), xshift(i), yshift(i),
     *        xmag(i), ymag(i), xrot(i), yrot(i), xrms(i), yrms(i)
         go to 130
 120        print 10,sca(i), xshift(i), yshift(i),
     *        xmag(i), ymag(i), xrot(i), yrot(i), xrms(i), yrms(i)
            print *,'pause: enter return to continue'
            read(*,'(A)')
 130        continue
c     
c     inverse:
c     (X_osim, Y_osim) -- > (X_pix, Y_pix)
c     
         read(1,10,err=20,end=100) ii, oxshift(i), oyshift(i),
     *           oxmag(i), oymag(i), oxrot(i), oyrot(i), oxrms(i),
     *           oyrms(i)
 10      format(i3,8(1x,f20.13))
         go to 30
 20      print 10, ii, oxshift(i), oyshift(i),
     *        oxmag(i), oymag(i), oxrot(i), oyrot(i), oxrms(i),
     *        oyrms(i)
         print *,'error in load_osim_transforms inverse'
         stop
 30      continue
      end do
 100  close(1)
c
c      if(choice.eq.2) return
cc
c      xavg_dir = 0.d0
c      xavg_inv = 0.d0
c      yavg_dir = 0.d0
c      yavg_inv = 0.d0
c      nn = 0
c      do i = 1, 10
cc         if(i.ne.2 .and.i.ne.5 .and.i.ne.10) then
c         if(i.eq.5 .or. i.eq.10) then
c            xavg_dir = xavg_dir + xmag(i)
c            yavg_dir = yavg_dir + ymag(i)
c            xavg_inv = xavg_inv + oxmag(i)
c            yavg_inv = yavg_inv + oymag(i)
c            nn = nn + 1
c         end if
c      end do
c      xavg_dir = xavg_dir/nn
c      yavg_dir = yavg_dir/nn
c      xavg_inv = xavg_inv/nn
c      yavg_inv = yavg_inv/nn
c      if(debug.gt.2) then
c         print *,'load_osim_transform', xavg_dir, yavg_dir
c         print *, 'load_osim_transform',1.d0/xavg_inv, 1.d0/yavg_inv
c      end if
cc     
cc     fake corner coordinates for A2;
cc     for rotation use same angles as A4; same for xmag and ymag
cc     need to estimate xshift and yshift; use the fake coordinates
cc     of pixel (1,1) to estimate the other corners
cc
cc     this position came from V2 of A1 and V3 of A4
cc
cc      a2_v2 =   97.669d0
cc      a2_v3 = -274.630d0 
cc
c      a2_v2 =   2.551679d0
c      a2_v3 =   1.401090d0
cc
cc     use coefficients of A4 for A2
cc
c      xmag(2) = xmag(4)
c      ymag(2) = ymag(4)
c      xrot(2) = xrot(4)
c      yrot(2) = yrot(4)
cc     
c      oxmag(2) = oxmag(4)
c      oymag(2) = oymag(4)
c      oxrot(2) = oxrot(4)
c      oyrot(2) = oyrot(4)
cc
cc     calculate corner coordinates. For first corner, the treatment is 
cc     different so the zero-point shifts are determined.
cc
c      do j = 1, 4
c         call osim_coords_from_sca(482, xcorner(j), ycorner(j), x_osim,
c     *        y_osim)
c         if(j.eq.1) then
c            call sca_coords_from_osim(482, a2_v2, a2_v3, x_lw, y_lw)
c         else
c            call sca_coords_from_osim(482, x_osim, y_osim, x_lw, y_lw)
c         end if
c         if(debug.gt. 1) then
c            print *,'load_osim_transforms: determine zero-point for 482'
c            print 310, xcorner(j), ycorner(j), x_osim, y_osim, 
c     *           x_lw, y_lw
 310        format(6(1x,f9.3))
c         end if
c         if(j.eq.1) then
c            xshift(2) = a2_v2 - x_osim
c            yshift(2) = a2_v3 - y_osim
cc     
c            call sca_coords_from_osim(2, a2_v2, a2_v3, x_lw, y_lw)
cc
c            oxshift(2)  = xcorner(j) - x_lw 
c            oyshift(2)  = ycorner(j) - y_lw 
c         end if
cc     
c         call osim_coords_from_sca(482, xcorner(j), ycorner(j), 
c     *        x_osim, y_osim)
c         if(debug.gt. 1) then
c            print *,'load_osim_transforms: corner coordinates of 482'
c            print 310, xcorner(j), ycorner(j), x_osim, y_osim, 
c     *           x_lw, y_lw
c         end if
c      end do
c      if(debug.gt.1) then
c         j = 482
c         print 320, j, xshift(2), yshift(2), xmag(2), ymag(2), 
c     *        xrot(2), yrot(2), xrms(2), yrms(2)
c         print 330, j, oxshift(2), oyshift(2), oxmag(2), oymag(2), 
c     *        oxrot(2), oyrot(2), oxrms(2), oyrms(2)
 320     format(i3,8(1x,f20.13),' dir')
 330     format(i3,8(1x,f20.13),' inv')
c      end if
c
      return
      end
