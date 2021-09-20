c
c https://stackoverflow.com/questions/27179549/removing-whitespace-in-string
c
      subroutine StripSpaces(string)
      character(len=*) :: string
      integer :: stringLen 
      integer :: last, actual
      
      stringLen = len (string)
      last = 1
      actual = 1
      
      do while (actual < stringLen)
         if (string(last:last) == ' ') then
            actual = actual + 1
            string(last:last) = string(actual:actual)
            string(actual:actual) = ' '
         else
            last = last + 1
            if (actual < last) actual = last
         endif
      end do
      return
      end
