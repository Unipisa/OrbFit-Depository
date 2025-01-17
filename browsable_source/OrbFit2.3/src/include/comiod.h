* Copyright (C) 1998-2000 by Mario Carpino (carpino@brera.mi.astro.it)
* Version: June 2, 2000
* ---------------------------------------------------------------------
* Options for initial orbit determination
*
* iodmet      -  List of initial orbit determination methods (integer)
* iodmen      -  List of initial orbit determination methods (character)
* iodnm       -  Number of initial orbit determination methods to be used
* iodvrb      -  Verbose level (1=summary, 2=more detailed, 3=verbose)
* iodmul      -  Multi-line output
* iodntr      -  Max number of triplets of observations to be tried
* iodexp      -  Expand factor for computing timespan for RMS check
* ioddtm      -  Max timespan extension for computing timespan for RMS check
* iodrok      -  Acceptable RMS value (stop iterations and keep this solution)
* iodrmx      -  Max acceptable RMS value (otherwise discard solution)
* iodnit      -  Number of trials with added noise for each triplet
* iodksi      -  Multiple of a-priori RMS to be added as noise
* iiciod      -  Initialization check
*
      INTEGER iodmet(iodnmx),iodnm,iodvrb,iodntr,iodnit,iiciod
      COMMON/cmiod1/iodmet,iodnm,iodvrb,iodntr,iodnit,iiciod
      CHARACTER*50 iodmen(iodnmx)
      COMMON/cmiod2/iodmen
      LOGICAL iodmul
      COMMON/cmiod3/iodmul
      DOUBLE PRECISION iodexp,ioddtm,iodrok,iodrmx,iodksi
      COMMON/cmiod4/iodexp,ioddtm,iodrok,iodrmx,iodksi
