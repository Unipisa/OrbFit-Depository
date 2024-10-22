
! Given the multi-index coefficients of two bivariate polinomials
! coe_p, coe_q of degrees 24 and 2 respectively, 
! computes the coefficients of the partial derivatives.
! written by L. Dimare, March 2008

SUBROUTINE pq_derpar(pmod,qmod,coe_p,coe_q, &
     & coe_p_r1,coe_p_r2,coe_q_r1,coe_q_r2)
  USE fund_const, ONLY: dkind
  IMPLICIT NONE
  INTEGER,INTENT(IN) :: pmod,qmod ! modulus of the multi-index
  REAL(KIND=dkind), INTENT(IN) :: coe_p(0:pmod,0:pmod)
  REAL(KIND=dkind), INTENT(IN) :: coe_q(0:qmod,0:qmod)
!
  REAL(KIND=dkind), INTENT(OUT) :: coe_p_r1(0:pmod-1,0:pmod-1) 
  REAL(KIND=dkind), INTENT(OUT) :: coe_p_r2(0:pmod-1,0:pmod-1)
  REAL(KIND=dkind), INTENT(OUT) :: coe_q_r1(0:qmod-1,0:qmod-1)
  REAL(KIND=dkind), INTENT(OUT) :: coe_q_r2(0:qmod-1,0:qmod-1)
  INTEGER :: h,k   ! loop index
! ==== end interface =============================================

  coe_p_r1 = 0.q0
  coe_p_r2 = 0.q0
  coe_q_r1 = 0.q0
  coe_q_r2 = 0.q0

DO h=0,pmod-1
   DO k=0,pmod-1
      coe_p_r1(h,k)=(h+1)*coe_p(h+1,k)
      coe_p_r2(k,h)=(h+1)*coe_p(k,h+1)
   ENDDO
ENDDO

DO h=0,qmod-1
   DO k=0,qmod-1
      coe_q_r1(h,k)=(h+1)*coe_q(h+1,k)
      coe_q_r2(k,h)=(h+1)*coe_q(k,h+1)
   ENDDO
ENDDO

END SUBROUTINE pq_derpar

SUBROUTINE pq_derpar_QP(pmod,qmod,coe_p,coe_q, &
     & coe_p_r1,coe_p_r2,coe_q_r1,coe_q_r2)
  USE fund_const, ONLY: qkind
  IMPLICIT NONE
  INTEGER,INTENT(IN) :: pmod,qmod ! modulus of the multi-index
  REAL(KIND=qkind), INTENT(IN) :: coe_p(0:pmod,0:pmod)
  REAL(KIND=qkind), INTENT(IN) :: coe_q(0:qmod,0:qmod)
!
  REAL(KIND=qkind), INTENT(OUT) :: coe_p_r1(0:pmod-1,0:pmod-1) 
  REAL(KIND=qkind), INTENT(OUT) :: coe_p_r2(0:pmod-1,0:pmod-1)
  REAL(KIND=qkind), INTENT(OUT) :: coe_q_r1(0:qmod-1,0:qmod-1)
  REAL(KIND=qkind), INTENT(OUT) :: coe_q_r2(0:qmod-1,0:qmod-1)
  INTEGER :: h,k   ! loop index
! ==== end interface =============================================

  coe_p_r1 = 0.q0
  coe_p_r2 = 0.q0
  coe_q_r1 = 0.q0
  coe_q_r2 = 0.q0

DO h=0,pmod-1
   DO k=0,pmod-1
      coe_p_r1(h,k)=(h+1)*coe_p(h+1,k)
      coe_p_r2(k,h)=(h+1)*coe_p(k,h+1)
   ENDDO
ENDDO

DO h=0,qmod-1
   DO k=0,qmod-1
      coe_q_r1(h,k)=(h+1)*coe_q(h+1,k)
      coe_q_r2(k,h)=(h+1)*coe_q(k,h+1)
   ENDDO
ENDDO

END SUBROUTINE pq_derpar_QP
