c
c-----------------------------------------------------------------------
c
      subroutine read_psf_list(psf_file)
c
      implicit none
c
      integer i, nf, nfilters
      character psf_file*120, tempfile*120
c
      parameter (nfilters = 54)
c
      dimension psf_file(nfilters)
c
      open(1,file='psf.list')
      nf = 0
      do i = 1, nfilters
         read(1,10,end=100,err=20) tempfile
 10      format(a120)
         go to 40
 20      print 30, i, tempfile
 30      format('problem with ',i3,2x,a120)
         stop
 40      nf = nf + 1
         psf_file(nf) = tempfile ! average
c
c     for now just repeat the file name
c
c         nf = nf + 1
c         psf_file(nf) = tempfile ! module B
      end do
 100  close(1)
      print *,'number of PSFs read', nf
c
      return
      end
