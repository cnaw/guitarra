c*********************************************************************72
c
c
      double precision function gammain( x, p, ifault )

cc GAMMAIN computes the incomplete gamma ratio.
c
c  Discussion:
c
c    A series expansion is used if P > X or X <= 1.  Otherwise, a
c    continued fraction approximation is used.
c
c  Modified:
c
c    31 March 1999
c
c  Author:
c
c    G Bhattacharjee  1970 Applied Statistiscs, 19, 285,
c     algorithm AS 32. 
c
c    Modifications by John Burkardt
c
c     The code below includes  corrections by 
c     Rice & Das, 1985, Applied Statistiscs, 34, 326 and
c     Cran 1989,  Applied Statistiscs, 38, 423
c
c  Reference:
c
c    G Bhattacharjee,
c    Algorithm AS 32:
c    The Incomplete Gamma Integral,
c    Applied Statistics,
c    Volume 19, Number 3, 1970, pages 285-287.
c
c  Parameters:
c
c    Input, double precision X, P, the parameters of the incomplete gamma ratio.
c    0 <= X, and 0 < P.
c
c    Output, integer IFAULT, error flag.
c    0, no errors.
c    1, P <= 0.
c    2, X < 0.
c    3, underflow.
c    4, error return from the Log Gamma routine.
c
c    Output, double precision GAMMAIN, the value of the incomplete 
c    gamma ratio.
c
      implicit none

      double precision a
      double precision acu
      parameter ( acu = 1.0D-12 )
      double precision alngam
      double precision an
      double precision arg
      double precision b
      double precision dif
      double precision factor
      double precision g
      double precision gin
      integer i
      integer ifault
      double precision oflo
      parameter ( oflo = 1.0D+37 )
      double precision p
      double precision pn(6)
      double precision rn
      double precision term
      double precision uflo
      parameter ( uflo = 1.0D-37 )
      double precision x
c
c  Check the input.
c
      if ( p .le. 0.0D+00 ) then
        ifault = 1
        gammain = 0.0D+00
        return
      end if

      if ( x .lt. 0.0D+00 ) then
        ifault = 2
        gammain = 0.0D+00
        return
      end if

      if ( x .eq. 0.0D+00 ) then
        ifault = 0
        gammain = 0.0D+00
        return
      end if

      g = alngam ( p, ifault )

      if ( ifault .ne. 0 ) then
        ifault = 4
        gammain = 0.0D+00
        return
      end if

      arg = p * dlog ( x ) - x - g

      if ( arg .lt. dlog ( uflo ) ) then
        ifault = 3
        gammain = 0.0D+00
        return
      end if

      ifault = 0
      factor = dexp ( arg )
c
c  Calculation by series expansion.
c
      if ( x .le. 1.0D+00 .or. x .lt. p ) then

        gin = 1.0D+00
        term = 1.0D+00
        rn = p

10      continue

        rn = rn + 1.0D+00
        term = term * x / rn
        gin = gin + term

        if ( term .gt. acu ) then
          go to 10
        end if

        gammain = gin * factor / p
        return

      end if
c
c  Calculation by continued fraction.
c
      a = 1.0D+00 - p
      b = a + x + 1.0D+00
      term = 0.0D+00

      pn(1) = 1.0D+00
      pn(2) = x
      pn(3) = x + 1.0D+00
      pn(4) = x * b

      gin = pn(3) / pn(4)

20    continue

      a = a + 1.0D+00
      b = b + 2.0D+00
      term = term + 1.0D+00
      an = a * term
      do i = 1, 2
        pn(i+4) = b * pn(i+2) - an * pn(i)
      end do

      if ( pn(6) .ne. 0.0D+00 ) then

        rn = pn(5) / pn(6)
        dif = dabs ( gin - rn )
c
c  Absolute error tolerance satisfied?
c
        if ( dif .le. acu ) then
c
c  Relative error tolerance satisfied?
c
          if ( dif .le. acu * rn ) then
            gammain = 1.0D+00 - factor * gin
            return
          end if

        end if

        gin = rn

      end if

      do i = 1, 4
        pn(i) = pn(i+2)
      end do

      if ( oflo .le. dabs ( pn(5) ) ) then

        do i = 1, 4
          pn(i) = pn(i) / oflo
        end do

      end if

      go to 20
      end
