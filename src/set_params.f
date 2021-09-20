      subroutine set_params(mode, nframe, nskip, max_groups)
      implicit none
      integer max_groups, nframe, nskip
      character mode*(*)
      
      if(mode(1:6) .eq. 'RAPID' .or. mode(1:6) .eq. 'rapid') then
         max_groups = 10
         nframe  = 1
         nskip   = 0
      endif
c     
      if(mode(1:7) .eq. 'BRIGHT1' .or. mode(1:7) .eq.'bright1'
     *     .or. mode(1:7) .eq. 'Bright1') then
         max_groups = 10
         nframe  = 1
         nskip   = 1
      endif
c     
      if(mode(1:7) .eq. 'BRIGHT2' .or. mode(1:7) .eq.'bright2'
     *     .or. mode(1:7) .eq. 'Bright2') then
         max_groups = 10
         nframe  = 2
        nskip   = 0
      endif
c     
      if(mode(1:8) .eq. 'SHALLOW2' .or. mode(1:8) .eq.'shallow2'
     *     .or. mode(1:8) .eq. 'Shallow2' )then
         max_groups = 10
         nframe  = 2
         nskip   = 3
      endif
c     
      if(mode(1:8) .eq. 'SHALLOW4' .or. mode(1:8) .eq.'shallow4'
     *     .or. mode(1:8) .eq. 'Shallow4' )then
         max_groups = 10
         nframe  = 4
         nskip   = 1
      endif
c     
      if(mode(1:7) .eq. 'MEDIUM2' .or. mode(1:8) .eq.'medium2'
     *     .or. mode(1:8) .eq. 'Medium2' )then
         max_groups = 10
         nframe  = 2
         nskip   = 8
      endif
c
      if(mode(1:7) .eq. 'MEDIUM8' .or. mode(1:8) .eq.'medium8'
     *     .or. mode(1:8) .eq. 'Medium8' )then
         max_groups = 10
         nframe  = 8
         nskip   = 2
      endif
c     
      if(mode(1:5) .eq. 'DEEP2' .or. mode(1:5) .eq.'deep2'
     *     .or. mode(1:8) .eq. 'Deep2' )then
         max_groups = 10
         nframe  = 2
         nskip   = 18
      endif
c     
      if(mode(1:5) .eq. 'DEEP8' .or. mode(1:5) .eq.'deep8'
     *     .or. mode(1:8) .eq. 'Deep8' )then
         max_groups = 20
         nframe  = 8
         nskip   = 12
      endif
c     
c     for tests
c     
      if(mode(1:4) .eq. 'NONE' .or. mode(1:4) .eq.'none') then
         max_groups = 160
         nframe = 1
         nskip  = 0
      endif
c
      if(mode(1:5) .eq. '10000') then
         max_groups = 950
         nframe = 10
         nskip  = 95
      endif
c
      print 10, mode, nframe, nskip, max_groups
 10   format('set_params: mode is ', a10,
     &     ' nframe, nskip, max_groups ', 3(i6))
      return
      end
