c
c----------------------------------------------------------------------
c
      subroutine get_sip_coeffs(unit, order, matrix, max_i, max_j,
     &     order_string, verbose)
c
      implicit none
      double precision matrix
      integer unit, order, max_i, max_j, verbose
      character order_string*(*)
      double precision coeff
      integer ii, jj, indx, jndx, string_length, status
      character key*8, comment*40, coeff_string*2
c
      dimension matrix(max_i, max_j)
      order  = 0
c
      do jj = 1, max_j
         do ii = 1, max_i
            matrix(ii,jj) = 0.0d0
         end do
      end do
c
      status =  0
      call ftgkyj(unit, order_string, order, comment, status)
      if (status .gt. 0) then
         call printerror(status)
         print *, order_string
      end if
      if(order.gt.max_i .or. order.gt. max_j) then 
         print *,'get_sip_coeffs:  order > max_i, max_j :',
     &        order, max_i, max_j
         print *,' quitting'
         stop
      end if
      if(verbose.gt.0) print 10, order_string, order
 10   format('get_sip_coeffs: order_string ',a10, ' order ', i2)
c
      if(order_string .eq. 'A_ORDER')  coeff_string = 'A'
      if(order_string .eq. 'B_ORDER')  coeff_string = 'B'
      if(order_string .eq. 'AP_ORDER') coeff_string = 'AP'
      if(order_string .eq. 'BP_ORDER') coeff_string = 'BP'

      string_length = len_trim(coeff_string)
c
c      order = order + 1
      if(string_length.eq.1) then
         do jndx = 1, order + 1
            jj = jndx - 1
            do indx = 1, order  + 1
               ii = indx - 1
               write(key, 40) coeff_string, ii, jj
 40            format(a1,'_',i1,'_',i1)
c
               status =  0
               call ftgkyd(unit,key,coeff,comment,status)
               if (status .gt. 0) then
                  if(status.ne.202) then
                     call printerror(status)
                     print *, key
                  else
                     coeff = 0.0d0
c                     print *, key, ' 0.0'
                     status = 0
                  end if
               end if
               matrix(indx, jndx) = coeff
c               if(verbose.gt.0 .and. coeff.ne.0.0d0) then
                  print 80, ii, jj, key, matrix(indx,jndx)
c               end if
            end do
         end do
      else
         do jndx = 1, order + 1
            jj = jndx - 1
            do indx = 1, order + 1
               ii = indx - 1
               write(key, 60) coeff_string, ii, jj
 60            format(a2,'_',i1,'_',i1)
c
               status =  0
               call ftgkyd(unit,key,coeff,comment,status)
               if (status .gt. 0) then
                  if(status.ne.202) then
                     call printerror(status)
                     print *, key
                  else
c                     print *, key, ' 0.0'
                     coeff  = 0.0d0
                     status = 0
                  end if
               end if
               matrix(indx, jndx) = coeff
               
               if(verbose.gt.0 .and. coeff.ne.0.0d0) 
     &              print 80, ii, jj, key, matrix(indx,jndx)
 80            format(i2,2x, i2, 3x, a10, 3x, e21.13)
            end do
         end do
      end if
      return
      end

