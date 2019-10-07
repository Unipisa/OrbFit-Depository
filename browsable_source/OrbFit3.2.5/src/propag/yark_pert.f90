! ==========MODULE yark_pert============
! CONTAINS
!                 yarkdi   yarkovsky diurnal                            
!                 yarkse   yarkovsky seasonal                           
!               yarkinit   initialisation of yarkovsky 
! MODULES AND HEADERS
! yark_pert.o: \
!	../include/sysdep.h90 \
!	../suit/FUND_CONST.mod 

MODULE yark_pert
USE fund_const
IMPLICIT NONE
PRIVATE

PUBLIC yarkdi, yarkse, yarkinit

! private common data
! former yarkom.h
! controls and directory for Yarkovski force
      INTEGER iyark,iyarpt
      CHARACTER*80 yardir

! fromer yarkov.h 
! common containing all physical information
! on the current asteroid needed to compute Yarkovsky acceleration
      DOUBLE PRECISION yarkp(9),beya(7),alya(7)
      DOUBLE PRECISION spya,sqya,etaya75,fmeaya,thfacya,radfluya
! logical flggs: availability of physical data, 
!  has yarkinit routine been called
      LOGICAL yarfil,yarini
      PUBLIC iyark,iyarpt,yardir,yarfil,yarini
CONTAINS 
! ******************************************************************    
      SUBROUTINE yarkdi(xast,a,iparti) 
! ******************************************************************    
!                                                                       
! This subroutine computes the heliocentric components of the           
! Yarkovsky thermal acceleration -- the diurnal variant only.           
! If the flag (iparti) in the common block is set to 1, one gets at     
! the output also partials wrt to some parameters of the thermal        
! model (if these are desired to be adjusted).                          
!                                                                       
! Input parameters:                                                     
! -----------------                                                     
!                                                                       
! - via header   xast(3) ... heliocentric coordinates of the body (in AU
! - via common   yarkp(1-3) ... sx, sy, sz (unit vector of the          
!                               body's spin axis orientation)           
!                yarkp(4-5) ... k_0 and k_1 parameters of the           
!                               surface thermal conductivity            
!                               [K(T) = k_0 + k_1 T_av^3]               
!                yarkp(6) ... density of the surface layer              
!                yarkp(7) ... radius of the body                        
!                yarkp(8) ... rotation frequency                        
!                yarkp(9) ... surface absorptivity                      
!                iparti   ... partials (yes=1/no=0)                     
!                             [presently only partials listed below,    
!                              a(4) - a(21) are available]              
!                                                                       
!                                                                       
! Output parameters: a(1-3) ... diurnal acceleration                    
! ------------------ a(4-6) ... partials wrt the radius of the body     
!                    a(7-9) ... partials wrt the thermal conductivity   
!                               parameter k_0                           
!                    a(10-12) ... partials wrt the thermal conductivity 
!                                 parameter k_1                         
!                    a(13-15) ... partials wrt the x-component of the   
!                                 spin axis unit vector                 
!                    a(16-18) ... partials wrt the y-component of the   
!                                 spin axis unit vector                 
!                    a(19-21) ... partials wrt the z-component of the   
!                                 spin axis unit vector                 
!                                                                       
! SI units are assumed internally in the subroutine, but the results    
! (e.g. accelerations) are given in AU and days.                        
!                                                                       
! Written by: D. Vokrouhlicky, Oct 99                                   
! (queries to vokrouhl@mbox.cesnet.cz)                                  
! ..................................................................    
      implicit double precision (a-h,o-z) 
! here we specify two more parameters that eventually might be changed: 
! -- the average bulk density of the body (densityb) which is now set   
!    to 2 g/cm^3                                                        
! -- the heat capacity of the surface layer (capacity) which is now set 
!    to 680 J/kg/K                                                      
      DOUBLE PRECISION, parameter :: densityb=2.d3,capacity=680.d0,solcon=1371.d0
      DOUBLE PRECISION, parameter :: emiss=0.9d0,stefboltz=5.66962d-8,clight3=8.99377374d8 
      DOUBLE PRECISION, parameter :: dsqrt2=1.414213562373d0,dsqrt23=1414.213562373d0 
      DOUBLE PRECISION, parameter :: aceuni=0.049900176d0 
! input: asteroid position, flag for partials                           
      double precision xast(3) 
      integer iparti 
! output: acceleration and partials                                     
      double precision a(21) 
! internal variables                                                    
      double precision vprod1(3),vprod2(3)
      double precision rau2,rau,xn,yn,zn,radfku,tstar, tav1000,surcon,bgama,theta,diudepth,rp 
! physical data on the current asteroid                                 
! ----------------------------------------------------------------------
      rau2=xast(1)*xast(1)+xast(2)*xast(2)+xast(3)*xast(3) 
      rau=dsqrt(rau2) 
      xn=xast(1)/rau 
      yn=xast(2)/rau 
      zn=xast(3)/rau 
! initializations & constants                                           
      radflu=solcon/rau2 
! - subsolar temperature                                                
      tstar=(yarkp(9)*radflu/emiss/stefboltz)**0.25d0 
      tav1000=tstar/dsqrt23 
! - surface conductivity                                                
      surcon=yarkp(4)+yarkp(5)*(tav1000**3) 
! - thermal inertia & diurnal thermal parameter                         
      bgama=dsqrt(surcon*yarkp(6)*capacity) 
      theta=bgama*dsqrt(yarkp(8))/emiss/stefboltz/(tstar**3) 
      diudepth=dsqrt(surcon/yarkp(6)/capacity/yarkp(8)) 
! - radius of the body scaled by the depth of the diurnal wave          
      rp=yarkp(7)/diudepth 
      al=dsqrt2*rp 
      tau=theta/al 
      tau1=1.d0+tau 
! - the auxiliary functions A-D, a,b                                    
      cal=dcos(al) 
      sal=dsin(al) 
      if (al.lt.90.d0) then 
       ealm=dexp(-al) 
      else 
       ealm=0.d0 
      endif 
      af=3.d0*(al+2.d0)*ealm+(3.d0*(al-2.d0)*cal+al*(al-3.d0)*sal) 
      bf=al*(al+3.d0)*ealm+(-al*(al-3.d0)*cal+3.d0*(al-2.d0)*sal) 
      caf=-(al+2.d0)*ealm+(-(al-2.d0)*cal+al*sal) 
      cbf=-al*ealm-(al*cal+(al-2.d0)*sal) 
      ccf=caf+tau*af/tau1 
      cdf=cbf+tau*bf/tau1 
! - G exp(i delta) & amplitude computed                                 
      facp=aceuni*yarkp(9)*radflu/yarkp(7)/densityb/clight3 
      deno=ccf*ccf+cdf*cdf 
      deno1=deno*tau1 
      gcosd=(caf*ccf+cbf*cdf)/deno1 
      gsind=(cbf*ccf-caf*cdf)/deno1 
! geometric products                                                    
! - r x s                                                               
      vprod1(1)=yn*yarkp(3)-zn*yarkp(2) 
      vprod1(2)=zn*yarkp(1)-xn*yarkp(3) 
      vprod1(3)=xn*yarkp(2)-yn*yarkp(1) 
! - s x (r x s) = r - (r.s) s                                           
      scalar=xn*yarkp(1)+yn*yarkp(2)+zn*yarkp(3) 
      vprod2(1)=xn-scalar*yarkp(1) 
      vprod2(2)=yn-scalar*yarkp(2) 
      vprod2(3)=zn-scalar*yarkp(3) 
! diurnal acceleration                                                  
      a(1)=facp*(gsind*vprod1(1)+gcosd*vprod2(1)) 
      a(2)=facp*(gsind*vprod1(2)+gcosd*vprod2(2)) 
      a(3)=facp*(gsind*vprod1(3)+gcosd*vprod2(3)) 
! Partials?                                                             
      if (iparti.eq.0) return 
! - general                                                             
      cafp=-ealm+cal+(2.d0*al-1.d0)*sal 
      cbfp=-ealm-(2.d0*al-1.d0)*cal+sal 
      afp=3.d0*ealm+(al*al-3.d0)*cal+(al*(al-4.d0)+3.d0)*sal 
      bfp=(2.d0*al+3.d0)*ealm-(al*(al-4.d0)+3.d0)*cal                   &
     &     +(al*al-3.d0)*sal                                            
! - thermal conductivity parameters (k_0,k_1)                           
      xi1r=caf*ccf-cbf*cdf 
      xi1i=cbf*ccf+caf*cdf 
      xi2r=cafp*af-cbfp*bf 
      xi2i=cbfp*af+cafp*bf 
      xi2r=xi2r-caf*afp+cbf*bfp 
      xi2i=xi2i-cbf*afp-caf*bfp 
      deno=xi1r*xi1r+xi1i*xi1i 
      facr=1.d0+0.5d0*al*(xi2r*xi1r+xi2i*xi1i)/deno 
      faci=     0.5d0*al*(xi2i*xi1r-xi2r*xi1i)/deno 
      derikr=-tau*(gcosd*facr-gsind*faci)/tau1 
      deriki=-tau*(gsind*facr+gcosd*faci)/tau1 
      a(7)=facp*(deriki*vprod1(1)+derikr*vprod2(1)) 
      a(8)=facp*(deriki*vprod1(2)+derikr*vprod2(2)) 
      a(9)=facp*(deriki*vprod1(3)+derikr*vprod2(3)) 
      a(10)=a(7)*(tav1000**3) 
      a(11)=a(8)*(tav1000**3) 
      a(12)=a(9)*(tav1000**3) 
! - radius of the body                                                  
      rfac=(tau+tau1)/tau1 
      a(4)=-a(1)*rfac-2.d0*a(7) 
      a(5)=-a(2)*rfac-2.d0*a(8) 
      a(6)=-a(3)*rfac-2.d0*a(9) 
! - partials d_K (a), d_R (a) ...                                       
      a(4)=a(4)/yarkp(7) 
      a(5)=a(5)/yarkp(7) 
      a(6)=a(6)/yarkp(7) 
      a(7)=a(7)/surcon 
      a(8)=a(8)/surcon 
      a(9)=a(9)/surcon 
      a(10)=a(10)/surcon 
      a(11)=a(11)/surcon 
      a(12)=a(12)/surcon 
! - spin axis components                                                
! ... sx                                                                
      a(13)=-facp*gcosd*(xn*yarkp(1)+scalar) 
      a(14)=facp*(gsind*zn-gcosd*xn*yarkp(2)) 
      a(15)=-facp*(gsind*yn+gcosd*xn*yarkp(3)) 
! ... sy                                                                
      a(16)=-facp*(gsind*zn+gcosd*yn*yarkp(1)) 
      a(17)=-facp*gcosd*(yn*yarkp(2)+scalar) 
      a(18)=facp*(gsind*xn-gcosd*yn*yarkp(3)) 
! ... sz                                                                
      a(19)=facp*(gsind*yn-gcosd*zn*yarkp(1)) 
      a(20)=-facp*(gsind*xn+gcosd*zn*yarkp(2)) 
      a(21)=-facp*gcosd*(zn*yarkp(3)+scalar) 
      return 
      END SUBROUTINE yarkdi                                          
! ******************************************************************    
      SUBROUTINE yarkse(xast,vast,a,iparti) 
! ******************************************************************    
!                                                                       
! This subroutine computes the heliocentric components of the           
! Yarkovsky thermal acceleration -- the seasonal variant only.          
! If the flag (iparti) is set to 1, one gets at the output also         
! partials wrt to some parameters of the thermal model (if these        
! are desired to be adjusted).                                          
!                                                                       
! Input parameters:                                                     
! -----------------                                                     
!                                                                       
! - via header   iparti  ... partials (yes=1/no=0)                      
!                (xast,vast) ... state vector of the asteroid           
! - via common   yarkp(1-3) ... sx, sy, sz (unit vector of the          
!                               body's spin axis orientation)           
!                yarkp(4-5) ... k_0 and k_1 parameters of the           
!                               surface thermal conductivity            
!                               [K(T) = k_0 + k_1 T_av^3]               
!                yarkp(6) ... density of the surface layer              
!                yarkp(7) ... radius of the body                        
!                yarkp(8) ... rotation frequency                        
!                yarkp(9) ...  surface absorptivity                     
!                + some more precomputed useful variables               
!                                                                       
! Output parameters: a(1-3) ... seasonal acceleration                   
! ------------------ a(4-6) ... partials wrt the radius of the body     
!                    a(7-9) ... partials wrt the thermal conductivity   
!                                                                       
! REM. PARTIALS ARE DISABLED AT THIS MOMENT                             
!                                                                       
! SI units are assumed throughout the subroutine, but the results       
! (e.g. accelerations) are given in AU and days.                        
!                                                                       
! Written by: D. Vokrouhlicky, Oct 99                                   
! (queries to vokrouhl@mbox.cesnet.cz)                                  
! ..................................................................    
      implicit double precision (a-h,o-z) 
      integer, parameter:: napprox=7 
      parameter (densityb=2.d3,capacity=680.d0,dsqrt2=1.414213562373d0) 
      parameter (emiss=0.9d0,clight3=8.99377374d8,aceuni=0.049900176d0) 
      dimension xast(3),vast(3) 
      dimension brac(7),bras(7),gcosd(7),gsind(7),a(21) 
      integer iparti
      integer k
! ----------------------------------------------------------------------
! - thermal inertia & seasonal thermal parameter                        
       bgama=dsqrt(yarkp(4)*yarkp(6)*capacity) 
       theta=bgama*thfacya/emiss 
       seadepth=dsqrt(yarkp(4)/yarkp(6)/capacity/fmeaya) 
! - radius of the body scaled by the depth of the seasonal wave         
       rp=yarkp(7)/seadepth 
       rp2=dsqrt2*rp 
       tau=theta*etaya75/rp2 
       tau1=1.d0+tau 
! - amplitude of the effect                                             
       fac=aceuni*yarkp(9)*radfluya/yarkp(7)/densityb/clight3/tau1 
! - G_k cos(d_k) & G_K sin(d_k) functions computed                      
       do 10 k=1,napprox 
        fk=k 
        alk=dsqrt(fk)*rp2 
! - the auxiliary functions A-D, a,b                                    
        cal=dcos(alk) 
        sal=dsin(alk) 
        if (alk.lt.90.d0) then 
         ealm=dexp(-alk) 
        else 
         ealm=0.d0 
        endif 
        af=3.d0*(alk+2.d0)*ealm+(3.d0*(alk-2.d0)*cal+alk*(alk-3.d0)*sal) 
        bf=alk*(alk+3.d0)*ealm+(-alk*(alk-3.d0)*cal+3.d0*(alk-2.d0)*sal) 
        caf=-(alk+2.d0)*ealm+(-(alk-2.d0)*cal+alk*sal) 
        cbf=-alk*ealm-(alk*cal+(alk-2.d0)*sal) 
        ccf=caf+tau*af/tau1 
        cdf=cbf+tau*bf/tau1 
! - G exp(i delta)                                                      
        deno=ccf*ccf+cdf*cdf 
        gcosd(k)=(caf*ccf+cbf*cdf)/deno 
        gsind(k)=(cbf*ccf-caf*cdf)/deno 
! compute cos- & sin-related brackets                                   
        brac(k)=spya*alya(k)*gcosd(k)+sqya*beya(k)*gsind(k) 
        bras(k)=sqya*beya(k)*gcosd(k)-spya*alya(k)*gsind(k) 
   10  continue 
! mean anomaly detremined                                               
! - approximated by a linear term only                                  
!      anomaly=ele0(6)+(fmea*t)                                         
! - computed from the state vector                                      
      r2=xast(1)*xast(1)+xast(2)*xast(2)+xast(3)*xast(3) 
      v2=vast(1)*vast(1)+vast(2)*vast(2)+vast(3)*vast(3) 
      rdot=xast(1)*vast(1)+xast(2)*vast(2)+xast(3)*vast(3) 
      r=dsqrt(r2) 
      aaxi=1.d0/(2.d0/r-(v2/gms)) 
      esinu=rdot/dsqrt(aaxi*gms) 
      ecosu=(r*v2/gms)-1.d0 
      uano=datan2(esinu,ecosu) 
      anomaly=uano-esinu 
      if (anomaly.lt.0.d0) anomaly=anomaly+dpig 
! compute the sum...                                                    
      fact=0.d0 
      do 100 k=napprox,1,-1 
       fk=k 
       canomaly=dcos(fk*anomaly) 
       sanomaly=dsin(fk*anomaly) 
       fact=fact+(brac(k)*canomaly+bras(k)*sanomaly) 
  100 continue 
      fact=fact*fac 
! seasonal acceleration (~ factor * {\bf s})                            
      a(1)=fact*yarkp(1) 
      a(2)=fact*yarkp(2) 
      a(3)=fact*yarkp(3) 
! Partials? -- DISABLED AT THE MOMENT                                   
!      if (iparti.eq.0) return                                          
! - general                                                             
!      cafp=-ealm+cal+(2.d0*al-1.d0)*sal                                
!      cbfp=-ealm-(2.d0*al-1.d0)*cal+sal                                
!      afp=3.d0*ealm+(al*al-3.d0)*cal+(al*(al-4.d0)+3.d0)*sal           
!      bfp=(2.d0*al+3.d0)*ealm-(al*(al-4.d0)+3.d0)*cal                  
!     .     +(al*al-3.d0)*sal                                           
! - thermal conductivity parameters (k_0,k_1)                           
!      xi1r=caf*ccf-cbf*cdf                                             
!      xi1i=cbf*ccf+caf*cdf                                             
!      xi2r=cafp*af-cbfp*bf                                             
!      xi2i=cbfp*af+cafp*bf                                             
!      xi2r=xi2r-caf*afp+cbf*bfp                                        
!      xi2i=xi2i-cbf*afp-caf*bfp                                        
!      deno=xi1r*xi1r+xi1i*xi1i                                         
!      facr=1.d0+0.5d0*al*(xi2r*xi1r+xi2i*xi1i)/deno                    
!      faci=     0.5d0*al*(xi2i*xi1r-xi2r*xi1i)/deno                    
!      derikr=-tau*(gcosd*facr-gsind*faci)/tau1                         
!      deriki=-tau*(gsind*facr+gcosd*faci)/tau1                         
!      a(7)=fac*(deriki*vprod1(1)+derikr*vprod2(1))                     
!      a(8)=fac*(deriki*vprod1(2)+derikr*vprod2(2))                     
!      a(9)=fac*(deriki*vprod1(3)+derikr*vprod2(3))                     
!      a(10)=a(7)*(tav1000**3)                                          
!      a(11)=a(8)*(tav1000**3)                                          
!      a(12)=a(9)*(tav1000**3)                                          
! - radius of the body                                                  
!      rfac=(tau+tau1)/tau1                                             
!      a(4)=-a(1)*rfac-2.d0*a(7)                                        
!      a(5)=-a(2)*rfac-2.d0*a(8)                                        
!      a(6)=-a(3)*rfac-2.d0*a(9)                                        
! - partials d_K (a), d_R (a) ...                                       
!      a(4)=a(4)/yarkp(7)                                               
!      a(5)=a(5)/yarkp(7)                                               
!      a(6)=a(6)/yarkp(7)                                               
!      a(7)=a(7)/surcon!!!!!! --> yarkp(4)                              
!      a(8)=a(8)/surcon                                                 
!      a(9)=a(9)/surcon                                                 
!      a(10)=a(10)/surcon                                               
!      a(11)=a(11)/surcon                                               
!      a(12)=a(12)/surcon                                               
! - spin axis components                                                
      return 
      END SUBROUTINE yarkse                                          
! ==================================================================    
! yarkinit: initialisation of the yarkovsky force model for a given aste
!           written by A. Milani & D. Vokrouhlicky, Oct 99              
SUBROUTINE yarkinit(astnam,elem)
  USE orbit_elements 
  IMPLICIT NONE 
  CHARACTER*(*), INTENT(IN) ::  astnam 
  TYPE(orbit_elem), INTENT(IN) :: elem
  CHARACTER*80 file 
  DOUBLE PRECISION lat,long,emiss,stefboltz,argu,argu2,tstarya,eta 
  TYPE(orbit_elem) :: elekep
  DOUBLE PRECISION elkep(6),pvya(3),qvya(3),nvya(3),enne,cgam,obli 
  INTEGER unit,le, fail_flag
  INCLUDE 'sysdep.h90' 
! yar is the logical flag for the existence of the physical data        
! allowing computation of Yarkovsky; otherwise, the non gravitational   
! force is set to zero                                                  
!                                                                       
  IF(iyark.eq.0)RETURN 
  yarini=.true. 
! convert elements to keplerian                                         
  call coo_cha(elem,'KEP',elekep,fail_flag)
  IF(fail_flag.ge.4)THEN
     WRITE(*,*)' yarkinit: not possible with comet ', fail_flag, elekep
     STOP
  ELSE
     elkep=elekep%coord
  ENDIF 
! compute the name of the file which could contain the yarkovsky data   
  CALL filnam(yardir,astnam,'yar',file,le) 
  INQUIRE(file=file(1:le),exist=yarfil) 
  IF(yarfil)THEN 
     call filopn(unit,file(1:le),'old') 
     read(unit,*,end=111) 
! ecliptic latitude and longitude of the spin axis                      
     read(unit,*,end=111)long 
     read(unit,*,end=111)lat 
! - via common   yarkp(1-3) ... sx, sy, sz (unit vector of the          
!                               body's spin axis orientation)           
!                yarkp(4-5) ... k_0 and k_1 parameters of the           
!                               surface thermal conductivity            
!                               [K(T) = k_0 + k_1 T_av^3]               
!                yarkp(6) ... density of the surface layer              
!                yarkp(7) ... radius of the body                        
!                yarkp(8) ... rotation frequency                        
!                yarkp(9) ... surface absorptivity                      
     yarkp(1)=dcos(lat*radeg)*dcos(long*radeg) 
     yarkp(2)=dcos(lat*radeg)*dsin(long*radeg) 
     yarkp(3)=dsin(lat*radeg) 
     read(unit,*,end=111)yarkp(4) 
     read(unit,*,end=111)yarkp(5) 
     read(unit,*,end=111)yarkp(6) 
     read(unit,*,end=111)yarkp(7) 
     read(unit,*,end=111)yarkp(8) 
     read(unit,*,end=111)yarkp(9) 
! precompute some variables for the seasonal variant of the Yarkovsky   
! effect:                                                               
! - constants                                                           
     emiss=0.9d0 
     stefboltz=5.66962d-8 
! - mean motion & solar radiation flux at r=a                           
     fmeaya=(1.9909837d-7)/elkep(1)/dsqrt(elkep(1)) 
     radfluya=1371.d0/elkep(1)/elkep(1) 
! - subsolar temperature                                                
     tstarya=(yarkp(9)*radfluya/emiss/stefboltz)**0.25d0 
     thfacya=dsqrt(fmeaya)/stefboltz/(tstarya**3) 
! - projections s_P and s_Q of the spin axis computed                   
     pvya(1)=dcos(elkep(4))*dcos(elkep(5))-                         &
     &           dcos(elkep(3))*dsin(elkep(4))*dsin(elkep(5))           
     pvya(2)=dsin(elkep(4))*dcos(elkep(5))+                         &
     &           dcos(elkep(3))*dcos(elkep(4))*dsin(elkep(5))           
     pvya(3)=dsin(elkep(3))*dsin(elkep(5)) 
     qvya(1)=-dcos(elkep(4))*dsin(elkep(5))-                        &
     &           dcos(elkep(3))*dsin(elkep(4))*dcos(elkep(5))           
     qvya(2)=-dsin(elkep(4))*dsin(elkep(5))+                        &
     &         dcos(elkep(3))*dcos(elkep(4))*dcos(elkep(5))             
     qvya(3)=dsin(elkep(3))*dcos(elkep(5)) 
     nvya(1)=dsin(elkep(3))*dsin(elkep(4)) 
     nvya(2)=-dsin(elkep(3))*dcos(elkep(4)) 
     nvya(3)=dcos(elkep(3)) 
     spya=yarkp(1)*pvya(1)+yarkp(2)*pvya(2)+yarkp(3)*pvya(3) 
     sqya=yarkp(1)*qvya(1)+yarkp(2)*qvya(2)+yarkp(3)*qvya(3) 
     cgam=yarkp(1)*nvya(1)+yarkp(2)*nvya(2)+yarkp(3)*nvya(3) 
     obli=dacos(cgam)/radeg 
     write(*,*)' Obliquity of the spin axis; Yarkovsky: ',obli 
! - compute the \alpha(k) and \beta(k) coefficients                     
     eta=dsqrt(1.d0-elkep(2)*elkep(2)) 
     etaya75=eta**0.75d0 
! -- \beta_1(x) ... \beta_7(x) functions                                
     argu=elkep(2) 
     argu2=argu*argu 
     beya(1)=eta*(1.d0+argu2*(-1152.d0+argu2*(48.d0-argu2))/9216.d0) 
     argu=2.d0*elkep(2) 
     argu2=argu*argu 
     beya(2)=eta*argu*(1.d0+argu2*(-1920.d0+argu2*(60.d0-argu2))    &
     &           /23040.d0)                                             
     argu=3.d0*elkep(2) 
     argu2=argu*argu 
     beya(3)=3.d0*eta*argu2*(1.d0+argu2*(-40.d0+argu2)/640.d0)/8.d0 
     argu=4.d0*elkep(2) 
     argu2=argu*argu 
     beya(4)=eta*argu2*argu*(1.d0+argu2*(-48.d0+argu2)/960.d0)/12.d0 
     argu=5.d0*elkep(2) 
     argu2=argu*argu 
     beya(5)=5.d0*eta*argu2*argu2*(1.d0-argu2/24.d0)/384.d0 
     argu=6.d0*elkep(2) 
     argu2=argu*argu 
     beya(6)=eta*argu2*argu2*argu*(1.d0-argu2/28.d0)/640.d0 
     argu=7.d0*elkep(2) 
     argu2=argu*argu 
     beya(7)=7.d0*eta*argu2*argu2*argu2/46080.d0 
! -- \alpha_1(x) ... \alpha_7(x) functions                              
     argu=elkep(2) 
     argu2=argu*argu 
     alya(1)=1.d0+argu2*(-3456.d0+argu2*(240.d0-7.d0*argu2))/9216.d0 
     argu=2.d0*elkep(2) 
     argu2=argu*argu 
     alya(2)=argu*(1.d0+argu2*(-960.d0+argu2*(45.d0-argu2))/5760.d0) 
     argu=3.d0*elkep(2) 
     argu2=argu*argu 
     alya(3)=3.d0*argu2*(1.d0+argu2*(-200.d0+7.d0*argu2)/1920.d0)/  &
     &           8.d0                                                   
     argu=4.d0*elkep(2) 
     argu2=argu*argu 
     alya(4)=argu*argu2*(1.d0+argu2*(-36.d0+argu2)/480.d0)/12.d0 
     argu=5.d0*elkep(2) 
     argu2=argu*argu 
     alya(5)=argu2*argu2*(1.d0-7.d0*argu2/120.d0)/76.8d0 
     argu=6.d0*elkep(2) 
     argu2=argu*argu 
     alya(6)=argu*argu2*argu2*(1.d0-argu2/21.d0)/640.d0 
     argu=7.d0*elkep(2) 
     argu2=argu*argu 
     alya(7)=7.d0*argu2*argu2*argu2/46080.d0 
! close the input file                                                  
     call filclo(unit,' ') 
  ELSE 
     WRITE(*,*)' Yarkovsky datafile not found:',file(1:le) 
     stop 
  ENDIF
  WRITE(*,*)' Yarkovsky data loaded for asteroid ', astnam 
  RETURN 
111 yarfil=.false. 
  WRITE(*,*)' incomplete yarkovsky file for asteroid ', astnam 
END SUBROUTINE yarkinit

END MODULE yark_pert
