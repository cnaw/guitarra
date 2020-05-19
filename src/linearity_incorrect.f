c
c     "incorrect" counts to become non-linear
c
c     cnaw@as.arizona.edu
c     2015-04-08
c     removed gain  correction which is now carried out in
c     calling subroutine 2020-02-24
c
      subroutine linearity_incorrect(include_non_linear,
     &     subarray,colcornr, rowcornr, naxis1, naxis2, verbose)

      implicit none
      double precision inverse_correction

c
      real  scratch, linearity, well_depth, bias
      double precision real_number_of_electrons
      integer i, j, include_non_linear, nnn, max_order, indx
c     
      integer istart, iend, jstart, jend, verbose
      integer colcornr, rowcornr, naxis1, naxis2
c      logical subarray
      character subarray*8
c     
      parameter(nnn=2048, max_order=7)
      dimension scratch(nnn,nnn),
     *     linearity(nnn,nnn,max_order), well_depth(nnn,nnn)
     *     , bias(nnn,nnn)
      common /well_d/ well_depth, bias,linearity
      common /scratch_/ scratch

      if(subarray .ne.'FULL') then
         istart = 1
         iend   = naxis1
         jstart = 1
         jend   = naxis2
      else
         istart = 1
         iend   = naxis1
         jstart = 1
         jend   = naxis2
      end if
c
      if(include_non_linear.eq.1) then
         if(verbose.gt.1) 
     *        print *,'Linearity_incorrect : linearity fudge'
         do j = jstart, jend
            do i = istart, iend 
c
c     reference pixels have gain = 1; leave them alone
c     for all others find linearity correction
c
               if(i.ge.5 .and. i.le.naxis1 - 5 .and. 
     *              j.ge.5 .and. j.le.naxis2 - 5) then
                  real_number_of_electrons = scratch(i,j)
                  scratch(i,j) = 
     *                 inverse_correction(i,j,real_number_of_electrons)
               end if
            end do
         end do
      end if
      return
      end
  
