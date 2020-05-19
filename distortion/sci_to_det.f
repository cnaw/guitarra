c
c----------------------------------------------------------------------
c
c     Convert "science" to detector coordinates. Uses expressions
c     in JWST-STScI-001550, SM-12, section 4.1
c
      subroutine sci_to_det(x_sci, y_sci, x_det, y_det, 
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref, 
     &     det_sci_yangle, det_sci_parity)
      implicit none
      integer det_sci_parity
      double precision x_det, y_det, x_sci, y_sci, 
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref, 
     &     det_sci_yangle
      double precision q, angle, cosa, sina, t1, t2
c     for all NIRCam detectors 
      det_sci_parity = -1
      q = dacos(-1.0d0)/180.d0
      angle = det_sci_yangle * q
      cosa  = cos(angle)
      sina  = sin(angle)
c
c      print *, x_sci, y_sci,x_det_ref, y_det_ref,
c     &     x_sci_ref, y_sci_ref, det_sci_yangle, det_sci_parity
      t1 = (x_sci - x_sci_ref)
      t2 = (y_sci - y_sci_ref)
      x_det = x_det_ref + det_sci_parity*t1*cosa - t2*sina
c
      y_det = y_det_ref + det_sci_parity*t1*sina + t2*cosa
      return
      end
