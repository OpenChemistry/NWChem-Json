C> \ingroup selci
C> @{
      subroutine selci_prtri(d,n)
*
* $Id: prtri.F 24790 2013-11-11 18:56:49Z d3y133 $
*
c
c     ----- print out a real triangular matrix -----
c
#include "implicit.fh"
      dimension d(*),dd(6)
      iw = 6
c
      max = 6
      imax = 0
  100 imin = imax+1
      imax = imax+max
      if (imax .gt. n) imax = n
      write (iw,9008)
      write (iw,8028) (i,i = imin,imax)
      do 160 j = 1,n
         k = 0
         do 140 i = imin,imax
            k = k+1
            m = max0(i,j)*(max0(i,j)-1)/2 + min0(i,j)
            dd(k) = d(m)
 140     continue
         write (iw,8048) j,(dd(i),i = 1,k)
  160 continue
      if (imax .lt. n) go to 100
      return
 9008 format(/)
 8028 format(6x,6(4x,i4,4x))
 8048 format(i5,1x,6f12.6)
      end
C> @}
