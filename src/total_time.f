      double precision function total_time(nframe, nskip, ngroups,
     *     ndither, integration_time)
      implicit none
      double precision integration_time, t_group, t_int
      integer nframe, nskip, ngroups, ndither
c
      t_group = (nframe + nskip) * integration_time
      t_int   = (ngroups * nframe + (ngroups-1)*nskip) 
c     APT adds 1 frame per ramp - is this the zero'th read ?
c      t_int   = t_int + 1.d0
      t_int   = t_int * integration_time
c     
      total_time = dble(ndither) * t_int
      print *,'nframe                   ', nframe
      print *,'nskip                    ', nskip
      print *,'ngroups                  ', ngroups
      print *,'ndither                  ', ndither
      print *,'read out cycle time      ', integration_time
      print *,'Exposure time per group  ', t_group
      print *,'Exposure time last group ', nframe*integration_time
      print *,'Exposure time per dither ', t_int
      print *,'Total exposure time      ', total_time
      return
      end
