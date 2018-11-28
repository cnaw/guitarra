      subroutine get_date_time(date, time)
      implicit none
      character date*10, time*12, zone*6, the_date_string*22, seconds*6
      integer time_zone_h, time_zone_m, year, month, day, hour,minute,
     *     days
      real    time_zone
      integer values
      dimension values(8), days(12)
      data days/31,28,31,30,31,30,31,31,30,31,30,31/
c
      call date_and_time(date, time, zone, values)

      read(zone,10) time_zone_h, time_zone_m
 10   format(i3,i2)
c
      read(date,20) year, month, day
 20   format(i4,i2,i2)
c
      read(time,30) hour, minute, seconds
 30   format(i2,i2,a6)

c
      minute = minute + time_zone_m
      if(minute.ge.60) then
         hour = hour + 1
         minute = minute - 60
      end if
c
      hour = hour - time_zone_h
      if(hour.ge.24) then
         hour = hour - 24
         day  = day + 1
      end if
c
      if(mod(year,4).eq. 0) days(2) = 29
c
      if(day.gt.days(month)) then
         day = day - days(month)
         month = month + 1
      end if
c
      if(month.gt.12) then
         month = month - 12
         year  = year  + 1
      end if
c
c     This is the FITS standard for date:
c
      write(date,40) year,month, day 
 40   format(i4.4,'-',i2.2,'-',i2.2)
      write(time,50) hour, minute, seconds
 50   format(i2.2,':',i2.2,':',a6)
      return
      end

 
