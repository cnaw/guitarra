c
c-----------------------------------------------------------------------
c     
      subroutine rotate_axis(axis, angle, rmatrix)
c
c     http://mathworld.wolfram.com/RotationMatrix.html
c     Rotate by angle measured in degrees, about axis 1 2 or 3
c     cnaw@as.arizona.edu
c     2017-03-20
c     use angle in radians
c     2020-04-18
c
      implicit none
      double precision rmatrix, angle, theta, q
      integer axis, ax1, ax2, ax3, i, j
      dimension rmatrix(3,3)
      q = dacos(-1.0d0)/180.d0
      do j = 1, 3
         do i = 1, 3
            rmatrix(i,j)=0.0d0
         end do
      end do
      theta = angle !* q
c
      ax1 = axis - 1
      ax2 = mod(ax1 + 1,3)
      ax3 = mod(ax1 + 2,3)
      ax1 = ax1 + 1
      ax2 = ax2 + 1
      ax3 = ax3 + 1
      rmatrix(ax1, ax1) = 1.0d0
      rmatrix(ax2, ax2) = dcos(theta)
      rmatrix(ax3, ax3) = dcos(theta)
c
c     python code uses this:
c
      rmatrix(ax2, ax3) = -dsin(theta)
      rmatrix(ax3, ax2) =  dsin(theta)
      return
      end
