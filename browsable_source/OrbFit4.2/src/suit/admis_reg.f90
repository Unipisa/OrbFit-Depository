! submodule admis_reg
! contains
!   admis_reg
!   find_pos_roots
!   sorting
! ======================================================================
! ADMIS_REG
! computes the positive roots of the sixth degree polynomial
! and the roots of its derivative 
! defining the radial admissible region for a given attributable
! last modified October 2003 GFG
! ======================================================================
  SUBROUTINE admis_reg(name0,iun,tc,att,idsta_s,nroots,roots,c,refs, &
       & xo,vo,a_orb,E_bound,nrootsd,rootsd)
    USE fund_const
    USE reference_systems
    USE planet_masses
    USE station_coordinates
!    USE force_sat
    IMPLICIT NONE
    CHARACTER*(*),INTENT(IN) :: name0 ! asteroid name
    INTEGER,INTENT(IN) :: iun ! output unit (former 12)
                              ! write for matlab if iun>0
    DOUBLE PRECISION,INTENT(IN) :: tc ! central time
    ! attributable alpha,delta,adot,ddot
    DOUBLE PRECISION,INTENT(IN),DIMENSION(4) :: att
    CHARACTER*3,INTENT(IN) :: idsta_s ! station alphanumeric code
    INTEGER,INTENT(OUT) :: nroots ! number of positive roots 
    INTEGER,INTENT(OUT) :: nrootsd ! number of pos. roots of the derivative 
    DOUBLE PRECISION,INTENT(OUT),DIMENSION(3) :: roots ! not more than 3
    DOUBLE PRECISION,INTENT(OUT),DIMENSION(8) :: rootsd ! roots of the
                                                    ! polynomial derivative
    DOUBLE PRECISION,INTENT(OUT) :: c(0:5) ! polynomial coefficients
    ! matrix of the (r,eps,theta) ref.sys. (topocentric equatorial)
    DOUBLE PRECISION,INTENT(OUT) :: refs(3,3)
    ! heliocentric observer coordinates, equatorial     
    DOUBLE PRECISION,INTENT(OUT) :: xo(3),vo(3)
    ! bound for E_sun
    DOUBLE PRECISION,INTENT(IN) :: a_orb ! maximum value for semimajor axis
    DOUBLE PRECISION,INTENT(OUT) :: E_bound
! ---------------- END INTERFACE -------------------------------------------
    INTEGER, DIMENSION(3) :: indsrt ! index for sorted roots
    INTEGER, DIMENSION(8) :: inddsrt ! index for sorted roots of derivatives
    !auxiliary
    DOUBLE PRECISION,DIMENSION(6) :: tmproots 
    DOUBLE PRECISION,DIMENSION(3) :: sroots ! not more than 3
    DOUBLE PRECISION,DIMENSION(8) :: srootsd ! roots of the poly derivative
    DOUBLE PRECISION,DIMENSION(8) :: rootsdtmp
    INTEGER :: nrootsdtmp 
    DOUBLE PRECISION :: gmcenter,rootgm,gamma,gammod,eta,a(0:6),b(0:8)
    ! Earth and observer coordinates, equatorial
    DOUBLE PRECISION :: xea(6),xoec(3),voec(3),xeaeq(6),xogeo(3)
    DOUBLE PRECISION :: rhat(3),repshat(3),rthetahat(3) 
    ! for interface with find_pos_roots (accuracy of roots)
!    DOUBLE PRECISION :: radius(6),radiusd(8)
    LOGICAL :: hzflag ! hzflag = .true.  OK!
                      ! hzflag = .false. abs(root)>10^5
    LOGICAL :: multfl ! multfl = .true.  OK!
                      ! multfl = .false. 0 has multiplicity > 4

    LOGICAL :: hzflagd,multfld !same for roots of the derivative

    INTEGER :: idsta_i ! station integer code
    DOUBLE PRECISION :: vsize,prscal ! functions
    INTEGER :: lflag
    DOUBLE PRECISION :: r
    INTEGER :: j ! loop index
    DOUBLE PRECISION :: rot(3,3), rotinv(3,3)
! ====================================
! assignement of gmcenter and root_gm
    IF(rhs.EQ.1)THEN
       gmcenter=gms
       CALL earcar(tc,xea,1) ! earth coord, heliocentric ecliptic
    ELSEIF(rhs.EQ.2)THEN  
       gmcenter=gmearth
       xea=0.d0 ! geocentric
    ELSE
       WRITE(*,*)'admis_reg: wrong rhs=', rhs
       STOP
    END IF
    rootgm=SQRT(gmcenter)
     CALL statcode(idsta_s,idsta_i) 
!    CALL pvobs(tc,idsta_i,xoec,voec) ! obs. coord, geocentric ecliptic 
    CALL observer_position(tc,xoec,voec,idsta_i)
    IF(rhs.EQ.1)THEN
       xogeo=MATMUL(roteceq,xoec) ! obs coord, geocentric equatorial
       xoec=xoec+xea(1:3) ! obs coord, heliocentric/geocentric ecliptic
       voec=voec+xea(4:6) ! id velocity
       xo=MATMUL(roteceq,xoec) ! obs coord, heliocentric/geocentric equatorial
       vo=MATMUL(roteceq,voec) ! id velocity
    ELSEIF(rhs.EQ.2)THEN
       xogeo=xoec       
       xo=xoec ! obs coord, heliocentric/geocentric equatorial
       vo=voec
    ELSE
       STOP
    ENDIF
    IF(iun.gt.0)WRITE(iun,112)name0,tc,xo,vo,att,xogeo
112 FORMAT(a9,1x,f12.4,1p,6(1x,d13.6),0p,2(1x,f10.7),1p,2(1x,d12.5),3(1x,d13.6)) 
    ! eq. (5)
    c(0)=prscal(xo,xo)
    rhat(1)=cos(att(1))*cos(att(2))  ! unitv along obs, geocentric equatorial
    rhat(2)=sin(att(1))*cos(att(2))
    rhat(3)=sin(att(2))
    repshat(1)=-sin(att(1))*cos(att(2))
    repshat(2)=cos(att(1))*cos(att(2))
    repshat(3)=0.d0
    rthetahat(1)=-cos(att(1))*sin(att(2))
    rthetahat(2)=-sin(att(1))*sin(att(2))
    rthetahat(3)=cos(att(2))
    c(1) = 2.d0*prscal(rhat,vo)
    c(2) = (att(3)*cos(att(2)))**2 + att(4)**2
    c(3) = att(3)*2.d0*prscal(vo,repshat) + att(4)*2.d0*prscal(vo,rthetahat)
    c(4) = prscal(vo,vo)
    c(5) = 2.d0*prscal(xo,rhat)
    gamma=c(4)-c(1)*c(1)/4.d0
    

!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
! computation of the roots of the zero energy curve
! coefficients in eq. (8)
!    a0(0) = c(0)*gamma**2 - 4*rootgm**4
!    a0(1) = c(5)*gamma**2 + 2.d0*c(0)*c(3)*gamma
!    a0(2) = gamma**2 + 2.d0*c(3)*c(5)*gamma + c(0)*(c(3)**2 + 2.d0*c(2)*gamma)
!    a0(3) = 2.d0*c(3)*gamma + c(5)*(c(3)**2 + 2.d0*c(2)*gamma) +&
!         & 2.d0*c(0)*c(2)*c(3)
!    a0(4) = c(3)**2 + 2.d0*c(2)*gamma + 2.d0*c(2)*c(3)*c(5) + c(0)*c(2)**2
!    a0(5) = c(2)*(2.d0*c(3) + c(2)*c(5))
!    a0(6) = c(2)*c(2)
!    ! find positive roots
!    IF(a0(6).ne.0.d0)THEN
!       call solv6(a0,roots0,nroots0,radius0)
!    ELSE
!       write(*,*)'admis_reg ERROR!: zero leading coefficient'
!       nroots0=0
!    ENDIF

!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
! computation of the roots of the -gm/2*a_orb energy curve
! coefficients in eq. (8)
    E_bound = -gmcenter/(2.d0*a_orb)
    gammod= c(4) -2.d0* E_bound - c(1)*c(1)/4.d0
    
    a(0) = c(0)*gammod**2 - 4*rootgm**4
    a(1) = c(5)*gammod**2 + 2.d0*c(0)*c(3)*gammod
    a(2) = gammod**2 + 2.d0*c(3)*c(5)*gammod + c(0)*(c(3)**2 + &
         & 2.d0*c(2)*gammod)
    a(3) = 2.d0*c(3)*gammod + c(5)*(c(3)**2 + 2.d0*c(2)*gammod) + & 
         & 2.d0*c(0)*c(2)*c(3)
    a(4) = c(3)**2 + 2.d0*c(2)*gammod + 2.d0*c(2)*c(3)*c(5) + c(0)*c(2)**2
    a(5) = c(2)*(2.d0*c(3) + c(2)*c(5))
    a(6) = c(2)*c(2)

! *********************
! find positive roots
! *********************
    IF(a(6).ne.0.d0)THEN
       call find_pos_roots(6,a,tmproots,nroots,hzflag,multfl)
!       call solv6(a,roots,nroots,radius)
       IF(nroots.gt.3) THEN
          WRITE(*,*)'MORE THAN 3 ROOTS! nroots=',nroots
          WRITE(*,*)'roots(1:nroots)',tmproots(1:nroots)
          STOP
       ENDIF
    ELSE
       write(*,*)'admis_reg ERROR!: zero leading coefficient'
       nroots=0
    ENDIF
    roots(1:3)=tmproots(1:3)

! &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
! coefficients of the derivative
      b(0) = -rootgm**4*c(5)**2 + c(0)**3*c(3)**2
      b(1) = 3.d0*c(5)*c(0)**2*c(3)**2 + 4.d0*c(3)*c(2)*c(0)**3 - &
           & 4.d0*c(5)*rootgm**4
      b(2) = -4.d0*rootgm**4 + 3.d0*c(0)*c(5)**2*c(3)**2 + &
           &3.d0*c(3)**2*c(0)**2 +&
           & 4.d0*c(2)**2*c(0)**3 + 12.d0*c(0)**2*c(5)*c(2)*c(3)
      b(3) = 6.d0*c(0)*c(5)*c(3)**2 + 12.d0*c(3)*c(2)*c(0)**2 + &
           & 12.d0*c(0)**2*c(5)*c(2)**2 + c(5)**3*c(3)**2 + &
           & 12.d0*c(0)*c(5)**2*c(2)*c(3)
      b(4) = 4.d0*c(5)**3*c(2)*c(3) + 12.d0*c(0)*c(5)**2*c(2)**2 + &
           & 3.d0*c(3)**2*c(0) + 3.d0*c(5)**2*c(3)**2 + &
           & 12.d0*c(2)**2*c(0)**2 + 24.d0*c(0)*c(5)*c(2)*c(3)
      b(5) = 12.d0*c(3)*c(2)*c(0) + 12.d0*c(5)**2*c(2)*c(3) + &
           & 24.d0*c(0)*c(5)*c(2)**2 + 3.d0*c(5)*c(3)**2 + 4.d0*c(5)**3*c(2)**2
      b(6) = c(3)**2 + 12.d0*c(5)*c(2)*c(3) + 12.d0*c(2)**2*c(0) + &
           & 12.d0*c(5)**2*c(2)**2
      b(7) = 4.d0*c(3)*c(2) + 12.d0*c(5)*c(2)**2
      b(8) = 4.d0*c(2)**2
    ! write(*,*)'b:',b

! *********************
! find positive roots
! *********************
    IF(b(8).ne.0.d0)THEN
       call find_pos_roots(8,b,rootsd,nrootsd,hzflagd,multfld)
!       call solv8(b,rootsd,nrootsd,radiusd)
    ELSE
       write(*,*)'admis_reg ERROR!: zero leading coefficient of drivative'
       nrootsd=0
    ENDIF

    nrootsdtmp=0
    DO j = 1,nrootsd
       r = rootsd(j)
       IF(SIGN(1.d0,2*c(2)*r+c(3)).eq.SIGN(1.d0,-(2.d0*r+c(5))/&
            &((r**2+c(5)*r+c(0))**(3.d0/2.d0)))) THEN
          nrootsdtmp =  nrootsdtmp+1
          rootsdtmp(nrootsdtmp) = r
       ELSE
!          write(*,*)'find_pos_roots:*** boh! ***'
       ENDIF
    ENDDO
    DO j = 1,nrootsdtmp
       rootsd(j) = rootsdtmp(j)
    ENDDO
    nrootsd = nrootsdtmp

!    if (nrootsd.eq.0) then
!       write(*,*)'nrootsd=',nrootsd
!       write(*,*)'rootsd=',rootsd
!    endif

! copy the reference system rhat, repshat, rthetahat in
! equatorial coordinates
    refs(1:3,1)=rhat
    refs(1:3,2)=repshat
    refs(1:3,3)=rthetahat

! sorting roots defining the connected components of the AR
    CALL heapsort(roots(1:nroots),nroots,indsrt(1:nroots))
    sroots(1:nroots)=roots(indsrt(1:nroots))
    roots(1:nroots)=sroots(1:nroots)

! sorting roots of the polynomial derivative
    IF(nrootsd.gt.0) THEN
       CALL heapsort(rootsd(1:nrootsd),nrootsd,inddsrt(1:nrootsd))
       srootsd(1:nrootsd)=rootsd(inddsrt(1:nrootsd))
       rootsd(1:nrootsd)=srootsd(1:nrootsd)
    ENDIF

  END SUBROUTINE admis_reg

! *************************************
!      F I N D _ P O S _ R O O T S 
! *************************************
! find the positive real roots of a polynomial with 
! real coefficients and degree poldeg
! October 2003, GFG

 SUBROUTINE find_pos_roots(poldeg,coef,roots,nroots,hzflag,multfl)
   IMPLICIT NONE 
   INTEGER, INTENT(IN) :: poldeg ! polynomial degree
   DOUBLE PRECISION, INTENT(IN) :: coef(0:poldeg) ! z^i coeff. (i=0,poldeg)   
   DOUBLE PRECISION, INTENT(OUT) :: roots(poldeg) !real roots
   INTEGER, INTENT(OUT) :: nroots ! number of real roots
   LOGICAL,INTENT(INOUT) :: hzflag ! hzflag = .true.  OK!
                                   ! hzflag = .false. abs(root)>10^5
   LOGICAL,INTENT(INOUT) :: multfl ! multfl = .true.  OK!
                                   ! multfl = .false. 0 has multiplicity > 4
! =============== end interface =======================================
   DOUBLE COMPLEX :: zr1(poldeg) 
   DOUBLE PRECISION :: radius(poldeg) 
   DOUBLE COMPLEX :: poly(0:poldeg)
   DOUBLE PRECISION :: epsm,big,small,rad(poldeg),a1(poldeg+1), &
        & a2(poldeg+1),rim,rre 
   INTEGER :: nit,j,i,pdeg 
   INTEGER :: numzerosol,numzerocoe
   LOGICAL err(poldeg+1) 
! =====================================================================
! initialization
   numzerosol = 0
   numzerocoe = 0
   roots(1:poldeg) = 0.d0
   pdeg = poldeg

! for polzeros
   epsm=2.D0**(-53) 
   big=2.D0**1023 
   small=2.D0**(-1022) 

   poly(0:pdeg)=coef(0:pdeg) 
   
! **********************************************
! look for zero solutions up to multeplicity 4   
! **********************************************
   IF(poly(0).eq.0.d0) THEN
      WRITE(*,*)'CONSTANT TERM is ZERO!',poly(0),poly(1)
      numzerosol = 1
      pdeg = pdeg-1
      IF(poly(1).eq.0.d0) THEN
         WRITE(*,*)'FIRST DEGREE TERM is ZERO!',poly(1)
         numzerosol = 2
         pdeg = pdeg-1
         IF(poly(2).eq.0.d0) THEN
            WRITE(*,*)'SECOND DEGREE TERM is ZERO!',poly(2),poly(3)
            numzerosol = 3
            pdeg = pdeg-1
            IF(poly(3).eq.0.d0) THEN
               WRITE(*,*)'THIRD DEGREE TERM is ZERO!',poly(3)
               numzerosol = 4
               pdeg = pdeg-1
               IF(poly(4).eq.0.d0) THEN
                  WRITE(*,*)'solvpoly: ERROR! &
                       & zero solution has multiplicity > 4'
                  multfl = .false.
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   
! *************************************************
! check the decrease of the degree up to 4 powers  
! *************************************************
   IF(poly(poldeg).eq.0.d0) THEN
      WRITE(*,*)'1ST COEFFICIENT is ZERO!',poly(0)
      pdeg = pdeg-1
      numzerocoe = 1
      IF(poly(poldeg-1).eq.0.d0) THEN
         WRITE(*,*)'2ND COEFFICIENT is ZERO!',poly(1)
         pdeg = pdeg-1
         numzerocoe = 2
         IF(poly(poldeg-2).eq.0.d0) THEN
            WRITE(*,*)'3RD COEFFICIENT is ZERO!',poly(2)
            pdeg = pdeg-1
            numzerocoe = 3
            IF(poly(poldeg-3).eq.0.d0) THEN
               WRITE(*,*)'4TH COEFFICIENT is ZERO!',poly(3)
               pdeg = pdeg-1
               numzerocoe = 4
            ENDIF
         ENDIF
      ENDIF
   ENDIF

! *********************************************************************   
   CALL polzeros(pdeg,poly(numzerosol:poldeg-numzerocoe),epsm,big,small, &
        & 50,zr1,rad,err,nit,a1,a2) 
! *********************************************************************   
   
   nroots=0 
   
   DO 11 j = 1,pdeg
! WRITE(*,*)'ROOT(',j,')=',zr1(j)
      rim=AIMAG(zr1(j)) 
!      IF(ABS(rim).LT.10.d-4) THEN                                      
      IF(ABS(rim).LT.rad(j)) THEN 
         rre=DBLE(zr1(j)) 
         
! uncomment if you want only positive real roots                    
         IF(rre.LT.0.D0) GOTO 11                                      

         nroots=nroots+1 
         roots(nroots)=rre 
         radius(nroots)=rad(j) ! error estimate            
         
! ************************************
! check if some positive root is big
! ************************************
         IF(abs(roots(nroots)).gt.1.d5) THEN
            write(*,*)'find_pos_roots: large value for a root',roots(nroots)
            hzflag=.false.
!            write(*,*)'hzflag',hzflag
         ENDIF

      ENDIF
11 ENDDO
   
!   write(*,*)'roots:',roots(1:nroots)

   IF(numzerosol.gt.0) THEN
      DO i = 1,numzerosol
         nroots=nroots+1 
         roots(nroots)=0.d0 
         radius(nroots)=0.d0 ! dummy
!         write(*,*)'roots(',nroots,')=',roots(nroots)
      ENDDO
   ENDIF

   if((nroots.ge.3).and.(poldeg.eq.6)) then
!      write(*,*)'nroots=',nroots
!      write(*,103)'3 roots:',roots(1:nroots)
   endif
103 FORMAT(a7,2x,10f20.5)

 END SUBROUTINE find_pos_roots
