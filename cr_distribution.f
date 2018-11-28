      subroutine cr_distribution(mode, sca_id)
      implicit none
      integer mode, sca_id
      if(mode.eq.0) then
         call acs_cosmic_rays
      else
         call read_cr_matrix(mode, sca_id)
      end if
      return
      end
