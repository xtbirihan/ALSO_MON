"Name: \PR:/SCWM/CL_MON_PROD=============CP\TY:LCL_ISOLATED_DOC\IN:LIF_ISOLATED_DOC\ME:READ_MATLWH_MULTI\SE:END\EI
ENHANCEMENT 0 ZEI_MON_READ_MATLWH_MULTI.
  zcl_mon_prod=>update_lgnum_matlwh(
    CHANGING
      ct_lgnum_matlwh = et_prod_lwh  ).
ENDENHANCEMENT.
