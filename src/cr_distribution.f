      subroutine cr_distribution(mode, sca_id, verbose)
      implicit none
      integer mode, sca_id, verbose
      if(mode.eq.0) then
         call acs_cosmic_rays
      else
         call read_cr_matrix(mode, sca_id, verbose)
      end if
      return
      end
