      subroutine add_ipc (ix, iy,intensity, ipc_add)
c
c     add intensity + IPC to an image, excluding reference pixels
c
      implicit none
      double precision intensity, ipc, charge
      real image, accum
      integer nnn, n_image_x, n_image_y, i, j, k, l, index_x, index_y,
     *     ix, iy
      logical ipc_add
c
      parameter (nnn=2048)
c
      dimension ipc(3,3)
      dimension accum(nnn,nnn), image(nnn,nnn)
c
      common /images/ accum, image, n_image_x, n_image_y
c

c      data ipc/0.002d0, 0.014d0,0.001d0, 0.014d0, 1.d0, 0.014d0,
c     *     0.001d0, 0.014d0, 0.001d0/
c
c     These are values for the new detectors (2013) using the SCA 16989
c     values for hot pixels
c
      data ipc/0.0004d0, 0.0060d0,0.0004d0, 
     *     0.0062d0, 1.d0, 0.0062d0,
     *     0.0004d0, 0.0060d0, 0.0004d0/
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
