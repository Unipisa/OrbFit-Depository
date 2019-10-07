* Copyright (C) 2000 by Mario Carpino (carpino@brera.mi.astro.it)
* Version: May 31, 2000
* ---------------------------------------------------------------------
* List of triplets of observations selected for initial orbit determination
*
* n3s         -  Number of triplets
* n3sm        -  Max number of triplets
* l3s         -  List of triplets
* w3s         -  Weights of triplets
* pri3        -  Priorities of triplets
* ords3       -  Sort order
* ipt3        -  Pointer to current triple
* iics3m      -  Initialization check
*
      INTEGER l3s(3,n3smax),pri3(n3smax),ords3(n3smax),n3s,n3sm,ipt3
      INTEGER iics3m
      COMMON/cms3m1/l3s,pri3,ords3,n3s,n3sm,ipt3,iics3m
      DOUBLE PRECISION w3s(n3smax)
      COMMON/cms3m2/w3s
