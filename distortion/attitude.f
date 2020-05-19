c
c-----------------------------------------------------------------------
c     
      subroutine attitude(v2, v3, ra, dec, pa, matrix2)
c
c     This will make a rotation matrix which rotates a unit vector 
c     representing a v2,v3 position to a unit vector representing 
c     an RA, Dec pointing with an assigned position angle
c     Described in JWST-STScI-001550, SM-12, section 5.1, page 25
c     cnaw@as.arizona.edu
c     2017-03-20
c     v2, v3, ra, dec in radians
c     2020-04-18
c
      implicit none
      double precision v2, v3, ra, dec, pa, matrix1, matrix2
      double precision v2d, v3d, mv2, mv3, mra, mdec, mpa
      integer n3x, n3y, nnn, i, j
      parameter(nnn=3)
      dimension matrix1(nnn, nnn), mv2(nnn, nnn), mv3(nnn, nnn), 
     &     mra(nnn, nnn), mdec(nnn, nnn), mpa(nnn, nnn),
     &     matrix2(nnn,nnn)
c    
c     Get separate rotation matrices
c
      call rotate_axis(3, -v2, mv2)
c      do i = 1, 3
c         PRINT 100, (mv2(i,j), j = 1,3)
 100     format(3(1x,e16.9))
c      end do
c      print 100, mv2
c
c      print *,' mv3'
      call rotate_axis(2,  v3, mv3)
c      do i = 1, 3
c         PRINT 100, (mv3(i,j), j = 1,3)
c      end do
c      print *,' mra'
      call rotate_axis(3,   ra, mra)
c      do i = 1, 3
c         PRINT 100, (mra(i,j), j = 1,3)
c      end do
c      print *,' mdec'
      call rotate_axis(2, -dec, mdec)
c      do i = 1, 3
c         PRINT 100, (mdec(i,j), j = 1,3)
c      end do
c      print *,' mpa'
      call rotate_axis(1,  -pa, mpa)
c      do i = 1, 3
c         PRINT 100, (mpa(i,j), j = 1,3)
c      end do
c
c     Combine as mra*mdec*mpa*mv3*mv2
      call dot_matrix(mv3, nnn, nnn, mv2,nnn, nnn, 
     &     matrix1, n3x, n3y,nnn)
c      print *,'mv3 . mv2 '
c      do i = 1, n3x
c         PRINT 100, (matrix1(i,j), j = 1,n3y)
c      end do

      call dot_matrix(mpa, nnn,nnn, matrix1, n3x, n3y, 
     &     matrix2, n3x, n3y,nnn)
c      print *,'mpa . matrix1'
c      do i = 1, n3x
c         PRINT 100, (matrix1(i,j), j = 1,n3y)
c      end do
c
      call dot_matrix(mdec,3, 3, matrix2, n3x, n3y, 
     &     matrix1, n3x, n3y,nnn)
c      print *,'mdec . matrix2'
c      do i = 1, n3x
c         PRINT 100, (matrix1(i,j), j = 1,n3y)
c      end do

      call dot_matrix(mra, 3, 3, matrix1, n3x, n3y, 
     &     matrix2, n3x, n3y,nnn)
c      print *,'mra . matrix1'
c      do i = 1, n3x
c         PRINT 100, (matrix2(i,j), j = 1,n3y)
c      end do
      return
      end
