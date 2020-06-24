c
c----------------------------------------------------------------------
c
c     Convert from "ideal" to "science" coordinates. Uses expressions
c     in JWST-STScI-001550, SM-12, section 4.2
c
      subroutine ideal_to_sci(x_ideal, y_ideal, 
     &     x_sci, y_sci, x_sci_ref, y_sci_ref,  
     &     x_inverse, y_inverse, sci_to_ideal_degree, verbose)
      implicit none
      integer ii, jj, iexp, jexp, sci_to_ideal_degree, verbose
      double precision x_sci, y_sci, x_sci_ref, y_sci_ref,
     &      x_ideal, y_ideal, x_inverse, y_inverse, t1, t2, t3
      dimension x_inverse(6,6), y_inverse(6,6)
c
      t1 = 0.0d0
      t2 = 0.0d0
      do ii = 2, sci_to_ideal_degree
         iexp = ii - 1
         do jj = 1, ii
            jexp = jj - 1
            t3 = x_ideal**(iexp-jexp)
            t3 = t3 * (y_ideal**jexp)
            t1 = t1 + x_inverse(ii, jj) * t3
            t2 = t2 + y_inverse(ii, jj) * t3
            if(verbose.gt.2) then
               print 10, iexp, jexp,
     &              x_inverse(ii, jj),y_inverse(ii, jj), 
     &              t1,t2, x_ideal, y_ideal
 10            format(2(i3), 2(1x,e17.10), 4(1x,f16.10))
            end if
         end do
      end do
      if(verbose.gt.2) then
         print *, 'x_sci_ref, y_sci_ref ',x_ideal, y_ideal,
     &        x_sci_ref, y_sci_ref
      end if
      x_sci =  x_sci_ref + t1
      y_sci =  y_sci_ref + t2
      return
      end
