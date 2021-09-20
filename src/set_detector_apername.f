c
c     In the infinite wisdom of STScI  apername means 2 different things
c     one in the XML files another in the images:
c     
c     "The PPS database specifies a single aperture for each exposure that
c     is used for telescope pointing. For NIRCam multi-detector exposures,
c     the PPS provided aperture name is mapped to detector specific apertures
c     for identifying the best reference pixel from which to set the 
c     WCS parameters for the individual exposure/detector based FITS files."
c     https://mast.stsci.edu/portal/Mashup/clients/jwkeywords/index.html
c     recovered 2021-06-22
c     
c     The original will be called aperture (NRCALL) and that used by
c     the reduction code apername (e.g. NRCA1_FULL)
c
      subroutine set_detector_apername(sca_id, aperture, subarray,
     &      detector, apername, channel)
      implicit none
      character apername*(*), subarray*(*), detector*(*),
     &     aperture*(*), channel*(*)
      integer sca_id
c
      if(sca_id.eq.485 .or.sca_id.eq.490) then
         channel    = 'LONG'
         if(sca_id .eq. 485) then 
            detector   = 'NRCALONG'
            if(subarray .eq. 'FULL') then
               apername = 'NRCA5_FULL'
            else
               apername = 'NRCA5'
            end if
            return
         end if
         if(sca_id .eq. 490) then 
            detector   = 'NRCBLONG'
            if(subarray .eq. 'FULL') then
               apername = 'NRCB5_FULL'
            else
               apername = 'NRCB5'
            end if
            return
         end if
      else
         channel    = 'SHORT'
         if(sca_id .eq. 481) detector   = 'NRCA1'
         if(sca_id .eq. 482) detector   = 'NRCA2'
         if(sca_id .eq. 483) detector   = 'NRCA3'
         if(sca_id .eq. 484) detector   = 'NRCA4'
         if(sca_id .eq. 486) detector   = 'NRCB1'
         if(sca_id .eq. 487) detector   = 'NRCB2'
         if(sca_id .eq. 488) detector   = 'NRCB3'
         if(sca_id .eq. 489) detector   = 'NRCB4'

         if(subarray .eq. 'FULL') then
            apername = detector(1:len_trim(detector))//'_FULL'
         else
            apername = detector
         end if
      end if
      return
      end
