      subroutine add_ipc (ix, iy,intensity,n_image_x, n_image_y,
     &     ipc_add)
c
c     add intensity + IPC to an image, excluding reference pixels
c
      implicit none
      double precision intensity, ipc, charge
      real image
      integer nnn, n_image_x, n_image_y, i, j, k, l, index_x, index_y,
     *     ix, iy
      logical ipc_add
c
      integer order, max_order
      real base_image, well_depth, bias, linearity
      double precision linearity_gain, lincut, well_fact
c
      parameter (nnn=2048, max_order=7)
c
      dimension ipc(3,3)
      dimension image(nnn,nnn)
      dimension base_image(nnn, nnn)
      dimension well_depth(nnn, nnn)
      dimension bias(nnn, nnn)
      dimension linearity(nnn,nnn, max_order)
c
      common /image_/ image
      common /base/ base_image
      common /well_d/ well_depth, bias, linearity,
     *     linearity_gain,  lincut, well_fact, order
c

c      data ipc/0.002d0, 0.014d0,0.001d0, 0.014d0, 1.d0, 0.014d0,
c     *     0.001d0, 0.014d0, 0.001d0/
c
c     These are values for the new detectors (2013) using the SCA 16989
c     values for hot pixels
c
c      data ipc/0.0004d0, 0.0060d0,0.0004d0, 
c     *     0.0062d0, 1.d0, 0.0062d0,
c     *     0.0004d0, 0.0060d0, 0.0004d0/
c
c     Values calculated by Marcia Rieke providing better fits
c     to existing data (2020-05-17)
c
      data ipc/0.00030068d0, 0.006148d0,0.00030487d0,
     *     0.006148d0, 0.975904d0, 0.00614822d0,
     *     0.00030068d0, 0.006148d0,0.00030487d0/
c
c     Kernel used in the NCDHAS
c
c      data ipc/0.00030068d0, 0.005776d0,0.00030487d0, 
c     *     0.00614775d0, 1.02469d0, 0.00577622d0,
c     *     0.00030068d0, 0.005776d0,0.00030487d0/
c      data ipc/0.d0, 0.d0, 0.d0, 0.d0, 1.d0, 0.d0, 0.d0, 0.d0, 0.d0/
      if(ipc_add .eqv. .true.) then
         do i = 1, 3
            k = i-2
            index_y = iy + k
            if( index_y .gt. 4 .and. index_y .le. n_image_y-4) then 
               do l = 1, 3
                  j = l -2 
                  index_x = ix + j
                  if(index_x .gt. 4 .and. index_x .le. n_image_x-4) then  
                     charge = real(ipc(l,i)*intensity)
c
c     test whether this is over saturation
c     (needs testing cnaw 2019-12-16)
c     probably will only be effective for cosmic rays, if at all.
c     cnaw 2020-04-24
c
c                     if(charge .gt.
c     *                    well_depth(index_x, index_y)) then
c                        charge = well_depth(index_x, index_y)
c                     end if
c
                     image(index_x, index_y) = image(index_x, index_y) + 
     *                    charge
c     print *,'add_ipc', charge, image(index_x, index_y)
                  endif
               end do
            end if
         enddo
      else
         image(ix,iy) = image(ix,iy) + intensity
      end if
c      print *, ix, iy, image(ix, iy), intensity
      return
      end
