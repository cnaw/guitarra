      subroutine ut_to_date_time(year, month, day, ut,
     &     date_end, time_end, full_date)
      implicit none
      double precision ut, temp_time, seconds, xx
      integer year, month, day, hour, minutes
      character date_end*10, time_end*13, full_date*25
      temp_time = ut
c
      if(temp_time.gt.24.d0) then
         temp_time = temp_time - 24.d0
         day       = day + 1
         if(month.eq.1 .or. month.eq.3 .or. month.eq.5 .or.month.eq.7
     &        .or. month.eq.8 .or. month.eq.10 .or. month.eq.12) then
            if(day.gt.31) then
               day = 1
               if(month.eq.12) then
                  month = 1
                  year  = year + 1
               else
                  month = month +1
               end if
            end if
         end if
         if(month.eq.4 .or. month.eq.6 .or. month.eq.9 .or. 
     &        month.eq.11) then
            if(day.gt.30) then
               day = 1
               month = month +1
            end if
         end if
         if(month.eq.2) then
            if(mod(year,4) .eq.0) then
               if(day.gt.29) then
                  day = 1
                  month = month +1
               end if
               
               if(day.gt.28) then
                  day = 1
                  month = month +1
               end if
            end if
         end if
      end if
      write(date_end, 10) year, month, day
 10   format(i4.4,'-',i2.2,'-',i2.2)
c
      hour      = idint(temp_time)
      xx        = (temp_time - hour)*60.d0
      minutes   = idint(xx)
      seconds   = (xx  - minutes)*60.d0
      write(time_end, 20) hour, minutes, seconds
 20   format(i2.2,':',i2.2,':', f6.3)
      if(time_end(7:7) .eq. ' ') time_end(7:7)='0'
      write(full_date,30) date_end,time_end
 30   format(A10,'T',A12)
c      print 40,date_end
c      print 40,time_end
c      print 40,full_date
 40   format(a25)
      return
      end

      
