c
c----------------------------------------------------------------------
c
c     Convert from "science" to "ideal" coordinates. Uses expressions
c     in JWST-STScI-001550, SM-12, section 4.2
c
      subroutine sci_to_ideal(x, y, x_sci_ref, y_sci_ref,
     &     x_ideal, y_ideal,  x_direct, y_direct, 
     &     sci_to_ideal_degree,verbose)
      implicit none
      integer ii, jj, iexp, jexp, sci_to_ideal_degree,verbose
      double precision x, y, x_sci_ref, y_sci_ref, x_ideal, y_ideal, 
     &     x_direct, y_direct, t1, t2
      dimension x_direct(6,6), y_direct(6,6)
c
      x_ideal = 0.0d0
      y_ideal = 0.0d0
      if(verbose.gt.0) print *,'sci_to_ideal ', sci_to_ideal_degree ,x,y
      do ii = 2, sci_to_ideal_degree
         do jj = 1, ii
            jexp = jj - 1
            iexp = ii - 1
            t1  =  (x-x_sci_ref)**(iexp-jexp)
            t2  =  (y-y_sci_ref)**jexp
            x_ideal  = x_ideal + x_direct(ii,jj)*t1*t2
c     for y_ideal the only difference is for the coefficients
            y_ideal  = y_ideal + y_direct(ii,jj)*t1*t2
            if(verbose .gt.2) then
               print 10,iexp, jexp, x_direct(ii,jj), y_direct(ii,jj)
     &           , x_ideal, y_ideal
 10            format(2(i3), 2(1x,e17.10), 2(1x,f17.10),
     &              ' sci_to_ideal')
            end if
         end do
      end do
      return
      end
