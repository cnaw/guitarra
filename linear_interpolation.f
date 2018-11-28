c
c-----------------------------------------------------------------------
c
c     Code for Linear interpolation
c
c     cnaw 2015-01-22
c     Steward Observatory, University of Arizona
c     
      subroutine linear_interpolation(npts, xarray, yarray, 
     *     xvalue, yvalue)
c
      implicit none
      double precision xarray, yarray, xvalue, yvalue, dx, w1,w2
      integer npts, nnn, indx
c     
      dimension xarray(npts), yarray(npts)
c
c     find closest index
c
      call find_index(npts, xarray, xvalue, indx)
c
c     calculate the linear interpolation
c
      if(indx.ge.1 .and. indx+1.le.npts) then
         dx = xarray(indx+1) - xarray(indx)
c     calculate the weights
         w1 = (xarray(indx+1) - xvalue)/dx
         w2 = (xvalue - xarray(indx))/dx
c     interpolate
         yvalue = w2 * yarray(indx+1) + w1 * yarray(indx)
         return
      end if
c    
      if(indx.eq.npts) then
         yvalue = yarray(npts)
         return
      end if
c     
      if(indx.lt.1 .or. indx.gt.npts) then
         print *,'linear_interpolation: index out of bounds', 
     *        indx, npts, xvalue, xarray(1), xarray(npts)
         yvalue = 0.d0
      end if
      return
      end
c
c-----------------------------------------------------------------------
c
c     find closest index location by bisection. Array has to be sorted.
c
c     cnaw 2015-01-22
c     Steward Observatory, University of Arizona
c
      subroutine find_index(npts, array, x, ii)
c
      implicit none
      double precision array, x
      integer  nnn, npts, ii, j, lower, upper, partition
      dimension array(npts)
c
      lower = 0
      upper = npts+1
c
 10   partition = (upper + lower)/2
c      print *, 'find_index ', lower, partition, upper, x, array(lower),
c     *     array(upper)
      if(x.lt.array(partition)) then
         upper = partition
      else
         lower = partition
      end if
      if(upper-lower.gt.1) go to 10 
      ii = lower
      return
      end
