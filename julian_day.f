c
c     cnaw@as.arizona.edu
c     2017-04-28 (= MJD 57871.8)
c      implicit none
c      double precision ut, jday, mjd
c      integer year, month, day 
c      year = 2017
c      month =   4
c      day   =  28
c      ut    =  0.d0
c      call julian_day(year, month, day, ut, jday, mjd)
c      print *, jday
c      print *, mjd
c      stop
c      end
c
      subroutine julian_day(year, month, day, ut, jday, mjd)
      implicit none
      double precision ut, jday, mjd
      integer year, month, day 
c      double precision year, month, day, ut, jday, mjd
c     http://scienceworld.wolfram.com/astronomy/JulianDate.html
c
c      print *,'julian_day', year, month, day, ut
      jday = 367 * year - int(7*(year + int((month+9)/12))/4) 
     &     - int(3*(int((year+(month-9)/7)/100)+1)/4)
     &     + int((275*month)/9) +day + 1721028.5d0 + ut/24.d0
c
c     Modified Julian Day Number
c     http://scienceworld.wolfram.com/astronomy/ModifiedJulianDate.html
c     A modified version of the Julian date denoted MJD obtained by
c     subtracting 2,400,000.5 days from the Julian date JD
c     the modified Julian date is referenced to midnight instead of noon
c    
      mjd  = jday - 2400000.5d0
      return
      end
