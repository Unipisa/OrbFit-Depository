c reference system adapted to the MTP
      DOUBLE PRECISION vt3(3,3,njcx),v3(3,3,njcx)
c output from mtprot
      DOUBLE PRECISION tpc(3,njcx),dtpdet(6,3,njcx),sig(2,njcx),
     +         axes(2,2,njcx),tpr(njcx),svv(njcx),cxv(njcx),czv(njcx)
c trace of LOv on TP, time of close app.
      DOUBLE PRECISION wtp(2,njcx),wtpr(njcx),wtpal(njcx),wtpv(njcx)
c common with all this stored from strclan
      COMMON/strcl/vt3,v3,tpc,dtpdet,sig,axes,tpr,wtp,wtpr,wtpal,wtpv,
     +       svv,cxv,czv

