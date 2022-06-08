!     
      subroutine read_clone(matched_list, filename,
     &     clone, npts, nmags, nnn)
c
      implicit none
c
      type clone_source
      character :: path*180, id*25
      integer :: number
      double precision :: ra, dec, mag(10), smag(18), zz, pa
      end type clone_source
c
      character :: matched_list*(*), filename*(*),
     &     clone_file*120, temp*25
      integer ii, jj, nmags, nnn, npts, hst_level
      double precision rra, ddec, amag, azz, asemi_a, asemi_b, apa,
     *     an_sersic, mags,smags
      dimension mags(20),smags(18)
c     
      type(clone_source) :: clone(nnn)
      npts = 0
      open(10, file= matched_list)
      open(11, file= filename)

      do ii = 1, nnn
         read(10, end = 1000) temp
         if(trim(temp).eq. 'none') go to 60
         read(11, *, err = 40, end=1000) temp, rra, ddec, amag, azz,
     &        apa,(mags(jj),jj=1, 10),(smags(jj),jj=1,18),clone_file
         go to 50
 40      print *, temp, rra, ddec, amag, azz, apa,
     &        (mags(jj),jj=1, 10), (smags(jj),jj=1,18)
         print *,'error at read_clone, item ', ii
         stop
 50      continue
         npts = npts + 1
         clone(npts)%id   = temp
         clone(npts)%ra   = rra
         clone(npts)%dec  = ddec
         clone(npts)%zz   = azz
         clone(npts)%pa   = apa
         do jj = 1, nmags
            clone(npts)%mag(jj)  = mags(jj)
         end do
         do jj = 1, 18
            clone(npts)%smag(jj)  = smags(jj)
         end do
         clone(npts)%path = clone_file
 60      continue
      end do
 1000 close(11)
      return
      end
      
         
