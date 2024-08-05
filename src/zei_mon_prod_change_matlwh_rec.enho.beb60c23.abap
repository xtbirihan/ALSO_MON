"Name: \PR:SAPLZFG_PROD_OVERVIEW\FO:CHANGE_MATLWH_RECORD\SE:END\EI
ENHANCEMENT 0 ZEI_MON_PROD_CHANGE_MATLWH_REC.
  zcl_mon_prod=>change_matlwh_record(
    CHANGING
      cv_upd_fld_count = cv_upd_fld_count
      cs_matlwh        = cs_matlwh
      cs_matlwhx       = cs_matlwhx ).
ENDENHANCEMENT.
