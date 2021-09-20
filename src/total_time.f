      double precision function total_time(nframe, nskip, ngroups,
     *     ndither, integration_time, verbose)
      implicit none
      double precision integration_time, t_group, t_int
      integer nframe, nskip, ngroups, ndither, verbose
c
      t_group = (nframe + nskip) * integration_time
      t_int   = (ngroups * nframe + (ngroups-1)*nskip) 
c     APT adds 1 frame per ramp - is this the zero'th read ?
c      t_int   = t_int + 1.d0
      t_int   = t_int * integration_time
c     
      total_time = dble(ndither) * t_int
      if(verbose.gt.0) then
      print *,'total_time: nframe                   ', nframe
      print *,'total_time: nskip                    ', nskip
      print *,'total_time: ngroups                  ', ngroups
      print *,'total_time: ndither                  ', ndither
      print *,'total_time: TFRAME                   ', integration_time
      print *,'total_time: Exposure time per group  ', t_group
      print *,'total_time: Exposure time last group ', 
     &     nframe*integration_time
      print *,'total_time: Exposure time per dither ', t_int
      print *,'total_time: Total exposure time      ', total_time
      end if
      return
      end
