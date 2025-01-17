* Copyright (C) 1997-1998 by Mario Carpino (carpino@brera.mi.astro.it)
* Version: December 7, 1998
* ---------------------------------------------------------------------
* Options for orbit identification (orbfit)
*
* amfit       -  Preliminary 2-par fit (a,M)
* delcr       -  Convergency control (correction norm)
* iicidn      -  Initialization check
*
      LOGICAL amfit
      INTEGER iicidn
      DOUBLE PRECISION delcr
      COMMON/cmidn1/amfit
      COMMON/cmidn2/iicidn
      COMMON/cmidn3/delcr
