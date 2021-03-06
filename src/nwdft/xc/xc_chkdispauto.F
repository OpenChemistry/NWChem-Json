      logical function xc_chkdispauto()
C
      implicit none
c
c     see if any functional has automatic dispersion included
c
#include "cdft.fh"
#include "nwxc.fh"
#include "util.fh"
c     note in cdft.fh, they define cfac(numfunc) and xfac(numfunc)
c 
      logical lhasautodisp
      lhasautodisp = .false.
c
c     beck97-d, ssb-d
      lhasautodisp = xccomb(37).or.xccomb(46).or.xccomb(60).or.
     &               xccomb(61).or.xccomb(62).or.xccomb(63)
      if (util_module_avail("nwxc")) then
          lhasautodisp = lhasautodisp.or.nwxc_has_disp()
      endif
c
      if (lhasautodisp) then
         xc_chkdispauto = .true.
      else
         xc_chkdispauto = .false.
      endif
c
      return
      end
c $Id: xc_chkdispauto.F 27137 2015-05-24 06:16:42Z d3y133 $
