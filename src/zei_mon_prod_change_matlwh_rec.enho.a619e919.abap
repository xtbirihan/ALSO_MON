"Name: \PR:SAPLZFG_PROD_OVERVIEW\FO:CHANGE_MATLWHX_RECORD\SE:END\EI
ENHANCEMENT 0 ZEI_MON_PROD_CHANGE_MATLWH_REC.
  zcl_mon_prod=>change_matlwhx_record(
    CHANGING
      cv_upd_fld_count = cv_upd_fld_count
      cs_matlwhst      = cs_matlwhst
      cs_matlwhstx     = cs_matlwhstx
      cs_matkey        = cs_matkey
      cs_matkeyx       = cs_matkeyx
      ct_return        = ct_return ).
ENDENHANCEMENT.
