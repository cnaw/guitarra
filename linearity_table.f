c
c=======================================================================
c
c     Given images with the bias, well-depth, gain and linearity 
c     correction coefficients, create a look-up table that can
c     be used to determine the number of accumulated electrons 
c     cnaw 2015-04-07
c
c
c     Karl Misselt tells me that the linearity correction already
c     starts at a count level of 1
c
c     cnaw 2015-05-08
c     Steward Observatory, University of Arizona
c
      subroutine linearity_table(i, j, xx, yvalue, ninterv) 

      implicit none
      double precision xx, yvalue, sum, xmin, xmax, dx, 
     *     linearity_gain, lincut, well_fact
      real bias, linearity, well_depth, gain
      integer nnn, nmax, order, ninterv, dq, i, j, l, m, max_order
c
      parameter(nnn=2048, max_order=7)
c
      dimension xx(nnn), yvalue(nnn)
      dimension well_depth(nnn,nnn), linearity(nnn,nnn,max_order), 
     *     bias(nnn,nnn), gain(nnn,nnn)
c     
      common /gain_/ gain
      common /well_d/ well_depth, bias, linearity, linearity_gain,
     *     lincut, well_fact, order
c
c     create a table for pixel (i,j)
c
      ninterv   =  30
      xmin      = 0.0 ! or lincut ?
      xmin      = lincut
      dx        = well_depth(i,j) * gain(i,j) ! ADU --> e-
      dx        = (dx-xmin)/dble(ninterv)
      xx(1)     = xmin
      yvalue(1) = 1.0d0 !* xmin
c     
      do m = 2,  ninterv
         xx(m)  = xmin + dble(m-1) * dx
         sum = linearity(i,j,1)
         do l = 2, order+1
            sum = sum + linearity(i,j,l) * xx(m)**(l-1)
         end do
         yvalue(m) = sum       
c         yvalue(m) = sum * xx(m)
c         print *, 'linearity_table ', m, xx(m), sum, yvalue(m)
c         if(i.eq.1024 .and.j.eq.1024) print *, sum, xx(m), yvalue(m)
c         print *,'linearity_table ',m, xx(m), yvalue(m)
      end do
      return
      end

