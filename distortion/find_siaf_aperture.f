c      implicit none
c      integer sca, verbose
c      character apername*27, filename1*180, filename2*180,
c     &     guitarra_aux*180, temp*180, subarray*27,
c     &     siaf_version*13
c      siaf_version = 'PRDOPSSOC-031'
c
c      verbose = 1
cc
c      sca = 3
c      subarray = 'FULL'
c      apername = 'NRCBS_FULL'
c      call find_siaf_aperture(apername, sca, subarray,
c     &     siaf_version, filename1, filename2, verbose)
cc      stop
cc
c      siaf_version = 'PRDOPSSOC-031'
c      sca = 1
c      subarray = 'SUB160'
c      apername = 'NRCA5_SUB160'
c      call find_siaf_aperture(apername, sca, subarray,
c     &     siaf_version, filename1, filename2, verbose)
cc
c      subarray = 'FULL'
c      apername = 'NRCA5_GRISMR_WFSS'
c      call find_siaf_aperture(apername, sca, subarray,
c     &     siaf_version, filename1, filename2, verbose)
c      stop
c      end
c
c----------------------------------------------------------------------
c     
      subroutine find_siaf_aperture(apername, sca, subarray,
     &     siaf_version, filename1, filename2, verbose)
      implicit none
      integer sca, verbose, indx
      character apername*(*), filename1*180, filename2*180,
     &     guitarra_aux*180, temp*180, subarray*(*),siaf_version*13,
     &     sca_name*8
c
      filename1 = ''
      filename2 = ''
c      indx     = index(apername,'_',.TRUE.)
c      sca_name = apername(1:indx-1)
c      print *,'find_siaf_aperture:', sca_name
      if(verbose.gt.0) then
         print *,'find_siaf_aperture: apername ', apername
         print *,'find_siaf_aperture: subarray ', subarray
         print *,'find_siaf_aperture: sca      ', sca
         print *,'find_siaf_aperture: siaf_version ', siaf_version
 100     format(' find_siaf_aperture:', a180)
      endif
      call getenv('GUITARRA_AUX',guitarra_aux)
c      print 100, guitarra_aux
      filename1=
     &guitarra_aux(1:len_trim(guitarra_aux))//siaf_version
      call StripSpaces(filename1)
      temp  = filename1
      filename1 = temp(1:len_trim(temp))//'/'//apername
      call StripSpaces(filename1)
      temp  = filename1
      filename1 = temp(1:len_trim(temp))//'.ascii'
c
c     SIAF for individual SCAs
c
      call StripSpaces(apername)
      if(verbose.gt.0) then
         print *,'apername ', apername
         print *,'SCA      ', sca                                              
         print *,'subarray ', subarray
      end if
c
      if(sca .le.5) then
         write(temp, 28) sca,subarray
      else
         write(temp, 29) sca-5,subarray
      endif
      if(apername(1:len_trim(apername)) .eq. 'NRCA5_GRISMR_WFSS' .or.
     &     apername(1:len_trim(apername)).eq.'NRCALL_FULL') then
         if(sca.le.5) then
            write(temp, 28) sca,subarray
 28         format('NRCA',i1,'_',a)
         else
            write(temp, 29) sca-5,subarray
 29         format('NRCB',i1,'_',a)
         end if
      end if
c     
      if(apername .eq. 'NRCBS_FULL') then
         write(temp, 29) sca-5,subarray
      end if
c
      filename2=
     &guitarra_aux(1:len_trim(guitarra_aux))//siaf_version
      call StripSpaces(filename2)
      filename2 = filename2(1:len_trim(filename2))//'/'//temp
      call StripSpaces(filename2)
      temp = filename2
      filename2 = temp(1:len_trim(temp))//'.ascii'
      if(verbose.gt.0) then 
         print 110, filename1
 110     format(' find_siaf_aperture:filename1 ', a180)
         print 120, filename2
 120     format(' find_siaf_aperture:filename2 ', a180)
      end if
      return
      end
