      subroutine get_sca_id(sca_id, partname)
      character partname*5
      integer sca_id
c
      if( sca_id .eq.    0) partname = 'none'
c
      if( sca_id .eq.  481) partname = '17004'
      if( sca_id .eq.  482) partname = '17006'
      if( sca_id .eq.  483) partname = '17024'
      if( sca_id .eq.  484) partname = '17048'
      if( sca_id .eq.  485) partname = '17158'
c                                             
      if( sca_id .eq.  486) partname = '16991'
      if( sca_id .eq.  487) partname = '17005'
      if( sca_id .eq.  488) partname = '17011'
      if( sca_id .eq.  489) partname = '17047'
      if( sca_id .eq.  490) partname = '17161'
      return
      end
