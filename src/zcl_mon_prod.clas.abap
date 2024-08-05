class ZCL_MON_PROD definition
  public
  create public .

public section.

  types:
    tt_where TYPE STANDARD TABLE OF string .
  types:
      "section 1
    BEGIN OF ty_matid_range ,            "mater id
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /sapapo/matid, "/SCWM/DE_MATID,
        high   TYPE  /sapapo/matid, "/SCWM/DE_MATID,
      END OF ty_matid_range .
  types:
    BEGIN OF ty_matnr_range ,          "product number
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /sapapo/matnr,
        high   TYPE  /sapapo/matnr,
      END OF ty_matnr_range .
  types:
    BEGIN OF ty_entit_range ,            "entitle to party
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scwm/de_entitled,
        high   TYPE  /scwm/de_entitled,
      END OF ty_entit_range .
  types:
    BEGIN OF ty_maktx_range ,           "product description
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /sapapo/maktx,
        high   TYPE  /sapapo/maktx,
      END OF ty_maktx_range .
  types:
    BEGIN OF ty_matkl_range ,             "Material Group
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /sapapo/matkl,
        high   TYPE  /sapapo/matkl,
      END OF ty_matkl_range .
  types:
    BEGIN OF ty_whmgr_range ,             "warehouse product grooup
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scmb/de_whmatgr,
        high   TYPE  /scmb/de_whmatgr,
      END OF ty_whmgr_range .
  types:
    BEGIN OF ty_qgrp_range ,              "quality inspection group
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scwm/de_qgrp,
        high   TYPE  /scwm/de_qgrp,
      END OF ty_qgrp_range .
  types:
    BEGIN OF ty_packgr_range ,           "packing group
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scwm/de_packgr,
        high   TYPE  /scwm/de_packgr,
      END OF ty_packgr_range .
  types:
      "section 2
    BEGIN OF ty_ptind_range ,              "prcess deter indicator
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scwm/de_ptdetind,
        high   TYPE  /scwm/de_ptdetind,
      END OF ty_ptind_range .
  types:
    BEGIN OF ty_pcind_range ,              "putaway control ind
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scwm/de_put_stra,
        high   TYPE  /scwm/de_put_stra,
      END OF ty_pcind_range .
  types:
    BEGIN OF ty_rmind_range ,               "removla control ind
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scwm/de_rem_stra,
        high   TYPE  /scwm/de_rem_stra,
      END OF ty_rmind_range .
  types:
    BEGIN OF ty_ccind_range ,               "cycle counting ind
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scwm/pi_ccind,
        high   TYPE  /scwm/pi_ccind,
      END OF ty_ccind_range .
  types:
    BEGIN OF ty_lgbkz_range ,               "storage section indicator
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scwm/lvs_lgbkz,
        high   TYPE  /scwm/lvs_lgbkz,
      END OF ty_lgbkz_range .
  types:
      "section 3
    BEGIN OF ty_styp_range ,
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scwm/lgtyp,
        high   TYPE  /scwm/lgtyp,
      END OF ty_styp_range .
  types:
    BEGIN OF ty_sbtyp_range ,
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scwm/de_bintype,
        high   TYPE  /scwm/de_bintype,
      END OF ty_sbtyp_range .
  types:
    BEGIN OF ty_meinh_range ,
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /sapapo/lrmei,
        high   TYPE  /sapapo/lrmei,
      END OF ty_meinh_range .
  types:
    BEGIN OF ty_ty2tq_range ,
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scmb/mdl_ty2tq,
        high   TYPE  /scmb/mdl_ty2tq,
      END OF ty_ty2tq_range .
  types:
    BEGIN OF ty_mtart_range ,
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /sapapo/de_mtart,
        high   TYPE  /sapapo/de_mtart,
      END OF ty_mtart_range .
  types:
    BEGIN OF ty_mmsta_range ,
        sign   TYPE  /scmb/sign,
        option TYPE  /scmb/option,
        low    TYPE  /scwm/de_mmsta,
        high   TYPE  /scwm/de_mmsta,
      END OF ty_mmsta_range .
  types:
    tt_mmsta_range  TYPE STANDARD TABLE OF ty_mmsta_range .
  types:
    tt_matid_range  TYPE STANDARD TABLE OF ty_matid_range .
  types:
    tt_matnr_range  TYPE STANDARD TABLE OF ty_matnr_range .
  types:
    tt_entit_range  TYPE STANDARD TABLE OF ty_entit_range .
  types:
    tt_maktx_range  TYPE STANDARD TABLE OF ty_maktx_range .
  types:
    tt_matkl_range  TYPE STANDARD TABLE OF ty_matkl_range .
  types:
    tt_whmgr_range  TYPE STANDARD TABLE OF ty_whmgr_range .
  types:
    tt_qgrp_range   TYPE STANDARD TABLE OF ty_qgrp_range .
  types:
    tt_packgr_range TYPE STANDARD TABLE OF ty_packgr_range .
  types:
    tt_ptind_range  TYPE STANDARD TABLE OF ty_ptind_range .
  types:
    tt_pcind_range  TYPE STANDARD TABLE OF ty_pcind_range .
  types:
    tt_rmind_range  TYPE STANDARD TABLE OF ty_rmind_range .
  types:
    tt_ccind_range  TYPE STANDARD TABLE OF ty_ccind_range .
  types:
    tt_lgbkz_range  TYPE STANDARD TABLE OF ty_lgbkz_range .
  types:
    tt_styp_range   TYPE STANDARD TABLE OF ty_styp_range .
  types:
    tt_sbtyp_range  TYPE STANDARD TABLE OF ty_sbtyp_range .
  types:
    tt_meinh_range  TYPE STANDARD TABLE OF ty_meinh_range .
  types:
    tt_ty2tq_range  TYPE STANDARD TABLE OF ty_ty2tq_range .
  types:
    tt_mtart_range  TYPE STANDARD TABLE OF ty_mtart_range .
  types:
    tt_ext_matkey  TYPE STANDARD TABLE OF /sapapo/ext_matkey .
  types:
    tt_ext_matkeyx  TYPE STANDARD TABLE OF /sapapo/ext_matkeyx .
  types:
    tt_ext_matlwh  TYPE STANDARD TABLE OF /sapapo/ext_matlwh .
  types:
    tt_ext_matlwhx  TYPE STANDARD TABLE OF /sapapo/ext_matlwhx .
  types:
    tt_ext_matlwhst  TYPE STANDARD TABLE OF /sapapo/ext_matlwhst .
  types:
    tt_ext_matlwhstx  TYPE STANDARD TABLE OF /sapapo/ext_matlwhstx .
  types:
    ty_rng_twomh  TYPE RANGE OF /scwm/s_prod_mon_out-zz1_twomh_whd .
  types:
    ty_rng_disp   TYPE RANGE OF /scwm/s_prod_mon_out-zz1_disp_whd .
  types:
    ty_rng_noslo  TYPE RANGE OF /scwm/s_prod_mon_out-zz1_noslo_whd .
  types:
    ty_rng_nospo  TYPE RANGE OF /scwm/s_prod_mon_out-zz1_nospo_whd .
  types:
    ty_rng_sign01 TYPE RANGE OF /scwm/s_prod_mon_out-zz1_hmsign01_whd .
  types:
    ty_rng_sing01 TYPE RANGE OF /scwm/s_prod_mon_out-zz1_hmsingle01_whd .
  types:
    ty_rng_box01  TYPE RANGE OF /scwm/s_prod_mon_out-zz1_hmbox01_whd .
  types:
    ty_rng_sign02 TYPE RANGE OF /scwm/s_prod_mon_out-zz1_hmsign02_whd .
  types:
    ty_rng_sing02 TYPE RANGE OF /scwm/s_prod_mon_out-zz1_hmsingle02_whd .
  types:
    ty_rng_box02  TYPE RANGE OF /scwm/s_prod_mon_out-zz1_hmbox02_whd .
  types:
    ty_rng_sign03 TYPE RANGE OF /scwm/s_prod_mon_out-zz1_hmsign03_whd .
  types:
    ty_rng_sing03 TYPE RANGE OF /scwm/s_prod_mon_out-zz1_hmsingle03_whd .
  types:
    ty_rng_box03  TYPE RANGE OF /scwm/s_prod_mon_out-zz1_hmbox03_whd .
  types:
    ty_rng_keepcr TYPE RANGE OF /scwm/s_prod_mon_out-zz1_keepcar_whd .
  types:
    ty_rng_fragile TYPE RANGE OF /scwm/s_prod_mon_out-zz1_fragile_whd .
  types:
    ty_rng_noncnv TYPE RANGE OF /scwm/s_prod_mon_out-zz1_nonconveyable_whd .
  types:
    ty_rng_dirrpl TYPE RANGE OF /scwm/s_prod_strg_mon_out-zz1_dirrpl_stt .
  types:
    ty_rng_maxput TYPE RANGE OF /scwm/s_prod_strg_mon_out-zz1_maxput_stt .
  types:
    BEGIN OF ty_lgnum_matlwh_new.
        INCLUDE TYPE /scwm/s_material_lgnum.
    TYPES:
        sgt_csgr   TYPE /scwm/de_sgt_csgr,
        sgt_covs   TYPE /scwm/de_sgt_covs,
        sgt_scope  TYPE /scwm/de_sgt_scope,
        createuser TYPE ernam,
        createutc  TYPE /sapapo/tsucr,
        changeuser TYPE aenam,
        changeutc  TYPE /sapapo/tsuup,
      END OF ty_lgnum_matlwh_new .
  types:
    tt_lgnum_matlwh_new TYPE STANDARD TABLE OF ty_lgnum_matlwh_new .

  class-methods CHANGE_MATLWHX_RECORD
    changing
      !CV_UPD_FLD_COUNT type I
      !CS_MATLWHST type /SAPAPO/EXT_MATLWHST
      !CS_MATLWHSTX type /SAPAPO/EXT_MATLWHSTX
      !CS_MATKEY type /SAPAPO/EXT_MATKEY
      !CS_MATKEYX type /SAPAPO/EXT_MATKEYX
      !CT_RETURN type BAPIRET2_T .
  class-methods CHANGE_MATLWH_RECORD
    changing
      !CV_UPD_FLD_COUNT type I
      !CS_MATLWH type /SAPAPO/EXT_MATLWH
      !CS_MATLWHX type /SAPAPO/EXT_MATLWHX .
  class-methods SET_PARAMS_MASS_CHANGE
    importing
      !IV_TWOMH type /SCWM/S_PROD_MON_OUT-ZZ1_TWOMH_WHD optional
      !IV_TWORES type /SCWM/DE_ATTR_RES optional
      !IV_DISP type /SCWM/S_PROD_MON_OUT-ZZ1_DISP_WHD optional
      !IV_DISRES type /SCWM/DE_ATTR_RES optional
      !IV_NOSLO type /SCWM/S_PROD_MON_OUT-ZZ1_NOSPO_WHD optional
      !IV_NOSRES type /SCWM/DE_ATTR_RES optional
      !IV_NOSPO type /SCWM/S_PROD_MON_OUT-ZZ1_NOSLO_WHD optional
      !IV_KEEPCR type /SCWM/S_PROD_MON_OUT-ZZ1_KEEPCAR_WHD optional
      !IV_DIRRPL type /SCWM/S_PROD_STRG_MON_OUT-ZZ1_DIRRPL_STT optional
      !IV_RESDRP type /SCWM/DE_ATTR_RES optional
      !IV_MAXPUT type /SCWM/S_PROD_STRG_MON_OUT-ZZ1_MAXPUT_STT optional
      !IV_RESMPU type /SCWM/DE_ATTR_RES optional .
  class-methods UPDATE_LGNUM_MATLWH
    changing
      !CT_LGNUM_MATLWH type TT_LGNUM_MATLWH_NEW .
  methods CONSTRUCTOR .
  methods GET_STYP_NODE_DATA
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_LGTYP type /SCWM/LGTYP
      !IT_MATNR_RANGE type TT_MATNR_RANGE
      !IT_ENTIT_RANGE type TT_ENTIT_RANGE optional
      !IT_MTART_RANGE type TT_MTART_RANGE optional
      !IT_MMSTA_RANGE type TT_MMSTA_RANGE optional
      !IT_MAKTX_RANGE type TT_MAKTX_RANGE optional
      !IT_QGRP_RANGE type TT_QGRP_RANGE optional
      !IT_MATKL_RANGE type TT_MATKL_RANGE optional
      !IT_WHMGR_RANGE type TT_WHMGR_RANGE optional
      !IT_PACKGR_RANGE type TT_PACKGR_RANGE optional
      !IT_PTIND_RANGE type TT_PTIND_RANGE optional
      !IT_PCIND_RANGE type TT_PCIND_RANGE optional
      !IT_RMIND_RANGE type TT_RMIND_RANGE optional
      !IT_CCIND_RANGE type TT_CCIND_RANGE optional
      !IT_LGBKZ_RANGE type TT_LGBKZ_RANGE optional
      !IT_STYP_RANGE type TT_STYP_RANGE optional
      !IT_SBTYP_RANGE type TT_SBTYP_RANGE optional
      !IV_CWREL type /SCMB/DE_CWREL optional
      !IT_SELECTED_WH_PRODUCTS type /SCWM/TT_PROD_MON_OUT optional
      !IV_ONLY_WITH_WHST type ABAP_BOOL optional
      !IV_ONLY_WITHOUT_WHST type ABAP_BOOL optional
      !IV_BOTH type ABAP_BOOL optional
      !IT_RNG_SIGN01 type TY_RNG_SIGN01 optional
      !IT_RNG_SING01 type TY_RNG_SING01 optional
      !IT_RNG_BOX01 type TY_RNG_BOX01 optional
      !IT_RNG_SIGN02 type TY_RNG_SIGN02 optional
      !IT_RNG_SING02 type TY_RNG_SING02 optional
      !IT_RNG_BOX02 type TY_RNG_BOX02 optional
      !IT_RNG_SIGN03 type TY_RNG_SIGN03 optional
      !IT_RNG_SING03 type TY_RNG_SING03 optional
      !IT_RNG_BOX03 type TY_RNG_BOX03 optional
      !IT_RNG_TWOMH type TY_RNG_TWOMH optional
      !IT_RNG_DISP type TY_RNG_DISP optional
      !IT_RNG_NOSLO type TY_RNG_NOSLO optional
      !IT_RNG_NOSPO type TY_RNG_NOSPO optional
      !IT_RNG_DIRRPL type TY_RNG_DIRRPL optional
      !IT_RNG_MAXPUT type TY_RNG_MAXPUT optional
    exporting
      !ET_DATA type /SCWM/TT_PROD_STRG_MON_OUT .
  class-methods SET_CUSTOM_SELOPT
    importing
      !IV_SHOW_WH_ONLY type C optional
      !IT_RNG_SIGN01 type RSELOPTION optional
      !IT_RNG_SING01 type RSELOPTION optional
      !IT_RNG_BOX01 type RSELOPTION optional
      !IT_RNG_SIGN02 type RSELOPTION optional
      !IT_RNG_SING02 type RSELOPTION optional
      !IT_RNG_BOX02 type RSELOPTION optional
      !IT_RNG_SIGN03 type RSELOPTION optional
      !IT_RNG_SING03 type RSELOPTION optional
      !IT_RNG_BOX03 type RSELOPTION optional
      !IT_RNG_TWOMH type RSELOPTION optional
      !IT_RNG_DISP type RSELOPTION optional
      !IT_RNG_NOSLO type RSELOPTION optional
      !IT_RNG_NOSPO type RSELOPTION optional
      !IT_RNG_KEEPCR type RSELOPTION optional
      !IT_RNG_FRAGILE type RSELOPTION optional
      !IT_RNG_NONCNV type RSELOPTION optional
      !IT_RNG_DIRRPL type RSELOPTION optional
      !IT_RNG_MAXPUT type RSELOPTION optional .
  PROTECTED SECTION.
private section.

  class-data MT_RNG_BOX01 type TY_RNG_BOX01 .
  class-data MT_RNG_BOX02 type TY_RNG_BOX02 .
  class-data MT_RNG_BOX03 type TY_RNG_BOX03 .
  class-data MT_RNG_DIRRPL type TY_RNG_DIRRPL .
  class-data MT_RNG_DISP type TY_RNG_DISP .
  class-data MT_RNG_FRAGILE type TY_RNG_FRAGILE .
  class-data MT_RNG_KEEPCR type TY_RNG_KEEPCR .
  class-data MT_RNG_MAXPUT type TY_RNG_MAXPUT .
  class-data MT_RNG_NONCNV type TY_RNG_NONCNV .
  class-data MT_RNG_NOSLO type TY_RNG_NOSLO .
  class-data MT_RNG_NOSPO type TY_RNG_NOSPO .
  class-data MT_RNG_SIGN01 type TY_RNG_SIGN01 .
  class-data MT_RNG_SIGN02 type TY_RNG_SIGN02 .
  class-data MT_RNG_SIGN03 type TY_RNG_SIGN03 .
  class-data MT_RNG_SING01 type TY_RNG_SING01 .
  class-data MT_RNG_SING02 type TY_RNG_SING02 .
  class-data MT_RNG_SING03 type TY_RNG_SING03 .
  class-data MT_RNG_TWOMH type TY_RNG_TWOMH .
  class-data MV_DIRRPL type /SCWM/S_PROD_STRG_MON_OUT-ZZ1_DIRRPL_STT .
  class-data MV_DISP type /SCWM/S_PROD_MON_OUT-ZZ1_DISP_WHD .
  class-data MV_DISRES type /SCWM/DE_ATTR_RES .
  class-data MV_KEEPCR type /SCWM/S_PROD_MON_OUT-ZZ1_KEEPCAR_WHD .
  class-data MV_MAXPUT type /SCWM/S_PROD_STRG_MON_OUT-ZZ1_MAXPUT_STT .
  class-data MV_NOSLO type /SCWM/S_PROD_MON_OUT-ZZ1_NOSPO_WHD .
  class-data MV_NOSPO type /SCWM/S_PROD_MON_OUT-ZZ1_NOSLO_WHD .
  class-data MV_NOSRES type /SCWM/DE_ATTR_RES .
  class-data MV_RESDRP type /SCWM/DE_ATTR_RES .
  class-data MV_RESMPU type /SCWM/DE_ATTR_RES .
  class-data MV_SHOW_WH_ONLY type C .
  class-data MV_TWOMH type /SCWM/S_PROD_MON_OUT-ZZ1_TWOMH_WHD .
  class-data MV_TWORES type /SCWM/DE_ATTR_RES .
  data MV_LGNUM type /SCWM/LGNUM .

  methods PRODUCT_AUTHORITY_CHECK
    importing
      !IV_LGNUM type /SCWM/LGNUM optional
      !IV_MATNR type /SCWM/S_PROD_STRG_MON_OUT-MATNR
      !IV_ACTVT type ACTIV_AUTH
    exporting
      !EV_FAILED type ABAP_BOOL
    changing
      !CT_RETURN type BAPIRET2_T .
ENDCLASS.



CLASS ZCL_MON_PROD IMPLEMENTATION.


  METHOD change_matlwhx_record.
********************************************************************
*& Key          : <BSUGAREV>-Nov 10, 2023
*& Request No.  : GAP-037_040 - CrossTopics additional product master field
********************************************************************
*& Description  : Enhancement ZEI_MON_PROD_CHANGE_MATLWH_REC
*&  Implementation /SCWM/LPROD_OVERVIEWF05, subroutine CHANGE_MATLWHX_RECORD
*&
********************************************************************

    IF mv_dirrpl IS NOT INITIAL.
      cs_matlwhstx-zz1_dirrpl_stt = 'X'.
      cs_matlwhst-zz1_dirrpl_stt  = mv_dirrpl.
      cv_upd_fld_count = cv_upd_fld_count + 1.
    ELSEIF mv_resdrp EQ abap_true.
      cs_matlwhstx-zz1_dirrpl_stt = 'X'.
      cs_matlwhst-zz1_dirrpl_stt  = ''.
      cv_upd_fld_count = cv_upd_fld_count + 1.
    ENDIF.

    IF  mv_maxput IS NOT INITIAL.
      cs_matlwhstx-zz1_maxput_stt = 'X'.
      cs_matlwhst-zz1_maxput_stt  = mv_maxput.
      cv_upd_fld_count = cv_upd_fld_count + 1.
    ELSEIF mv_resmpu EQ abap_true.
      cs_matlwhstx-zz1_maxput_stt = 'X'.
      CLEAR cs_matlwhst-zz1_maxput_stt.
      cv_upd_fld_count = cv_upd_fld_count + 1.
    ENDIF.
  ENDMETHOD.


  METHOD change_matlwh_record.
********************************************************************
*& Key          : <BSUGAREV>-Nov 10, 2023
*& Request No.  : GAP-037_040 - CrossTopics additional product master field
********************************************************************
*& Description  : Enhancement ZEI_MON_PROD_CHANGE_MATLWH_REC
*&  Implementation /SCWM/LPROD_OVERVIEWF05, subroutine CHANGE_MATLWH_RECORD
*&
********************************************************************
    BREAK-POINT ID zcg_badi.
    BREAK-POINT ID zcg_mon_product.

    IF mv_twomh  IS NOT INITIAL.
      cs_matlwh-zz1_twomh_whd = mv_twomh .
      cs_matlwhx-zz1_twomh_whd = abap_true.
      ADD 1 TO cv_upd_fld_count.
    ELSEIF mv_twores EQ abap_true.
      CLEAR cs_matlwh-zz1_twomh_whd.
      cs_matlwhx-zz1_twomh_whd = abap_true.
      ADD 1 TO cv_upd_fld_count.
    ENDIF.

    IF mv_disp   IS NOT INITIAL.
      cs_matlwh-zz1_disp_whd = mv_disp  .
      cs_matlwhx-zz1_disp_whd = abap_true.
      ADD 1 TO cv_upd_fld_count.
    ELSEIF mv_disres EQ abap_true.
      CLEAR cs_matlwh-zz1_disp_whd.
      cs_matlwhx-zz1_disp_whd = abap_true.
      ADD 1 TO cv_upd_fld_count.
    ENDIF.

    IF mv_noslo  IS NOT INITIAL.
      cs_matlwh-zz1_nospo_whd = mv_noslo .
      cs_matlwhx-zz1_nospo_whd = abap_true.
      ADD 1 TO cv_upd_fld_count.
    ELSEIF mv_nosres EQ abap_true.
      CLEAR cs_matlwh-zz1_nospo_whd.
      cs_matlwhx-zz1_nospo_whd = abap_true.
      ADD 1 TO cv_upd_fld_count.
    ENDIF.

    IF mv_nospo  IS NOT INITIAL.
      cs_matlwh-zz1_noslo_whd = mv_nospo .
      cs_matlwhx-zz1_noslo_whd = abap_true.
      ADD 1 TO cv_upd_fld_count.
    ELSEIF mv_nosres EQ abap_true.
      CLEAR cs_matlwh-zz1_noslo_whd.
      cs_matlwhx-zz1_noslo_whd = abap_true.
      ADD 1 TO cv_upd_fld_count.
    ENDIF.
**********************************************************************
    "aahmedov-<17.05.23> - GAP 37&40 keep carton change
    IF mv_keepcr IS NOT INITIAL.
      cs_matlwh-zz1_keepcar_whd = mv_keepcr .
      cs_matlwhx-zz1_keepcar_whd = abap_true.
      ADD 1 TO cv_upd_fld_count.
    ENDIF.
**********************************************************************
  ENDMETHOD.


  METHOD constructor.

  ENDMETHOD.


  METHOD get_styp_node_data.
**********************************************************************
*& Key           : LH-021223
*& Request No.   : GAP-37-40 – "Additional Product Master Fields”
**********************************************************************
*& Description (short)
*& Copied from /SCWM/CL_MON_PROD=>GET_STYP_NODE_DATA and nehanced with
*& custom fields
**********************************************************************
    DATA:
      ls_prod_strg_mon_out TYPE /scwm/s_prod_strg_mon_out,
      lt_prodlwhst         TYPE /sapapo/dm_matlwhst_tab,
      lt_new_records       TYPE /sapapo/dm_matlwhst_tab,
      ls_new_record        TYPE /sapapo/dm_matlwhst,
      lt_prodlwhstid       TYPE /sapapo/dm_matlwhst_id_tab,
      ls_prodlwhstid       TYPE /sapapo/dm_matlwhst_id,
      lv_where             TYPE string,
      lt_where             TYPE tt_where,
      lv_mat16             TYPE /scmb/mdl_matid,
      lt_matlwh            TYPE /scwm/tt_prod_mon_out,
      lv_failed            TYPE abap_bool,
      lt_return            TYPE bapiret2_t.

    FIELD-SYMBOLS:
      <fs_matlwh>       TYPE /scwm/s_prod_mon_out,
      <ls_matlwhst>     TYPE /sapapo/dm_matlwhst,
      <fs_data>         TYPE /scwm/s_prod_mon_out,
      <fs_prodlwhst_id> TYPE  /sapapo/dm_matlwhst_id,
      <fs_prodlwhst>    TYPE /sapapo/dm_matlwhst.

    DATA(lo_mon_prod) = NEW /scwm/cl_mon_prod( ).

    lo_mon_prod->set_lgnum( iv_lgnum ).

    CLEAR lt_matlwh.

    set_custom_selopt(
      iv_show_wh_only = abap_true
      it_rng_sign01  = VALUE #( FOR <la> IN it_rng_sign01 ( CORRESPONDING #( <la> ) ) )
      it_rng_sing01  = VALUE #( FOR <lb> IN it_rng_sing01 ( CORRESPONDING #( <lb> ) ) )
      it_rng_box01   = VALUE #( FOR <lc> IN it_rng_box01  ( CORRESPONDING #( <lc> ) ) )
      it_rng_sign02  = VALUE #( FOR <ld> IN it_rng_sign02 ( CORRESPONDING #( <ld> ) ) )
      it_rng_sing02  = VALUE #( FOR <le> IN it_rng_sing02 ( CORRESPONDING #( <le> ) ) )
      it_rng_box02   = VALUE #( FOR <lf> IN it_rng_box02  ( CORRESPONDING #( <lf> ) ) )
      it_rng_sign03  = VALUE #( FOR <lg> IN it_rng_sign03 ( CORRESPONDING #( <lg> ) ) )
      it_rng_sing03  = VALUE #( FOR <lh> IN it_rng_sing03 ( CORRESPONDING #( <lh> ) ) )
      it_rng_box03   = VALUE #( FOR <li> IN it_rng_box03  ( CORRESPONDING #( <li> ) ) )
      it_rng_twomh   = VALUE #( FOR <lj> IN it_rng_twomh  ( CORRESPONDING #( <lj> ) ) )
      it_rng_disp    = VALUE #( FOR <lk> IN it_rng_disp   ( CORRESPONDING #( <lk> ) ) )
      it_rng_noslo   = VALUE #( FOR <ll> IN it_rng_noslo  ( CORRESPONDING #( <ll> ) ) )
      it_rng_nospo   = VALUE #( FOR <lm> IN it_rng_nospo  ( CORRESPONDING #( <lm> ) ) ) ).

    IF it_selected_wh_products IS INITIAL.
      NEW /scwm/cl_mon_prod( )->get_prod_node_data(
         EXPORTING
           iv_lgnum        = iv_lgnum
           iv_show_wh_only = abap_true
           it_matnr_range  = it_matnr_range
           it_entit_range  = it_entit_range
           it_maktx_range  = it_maktx_range
           it_matkl_range  = it_matkl_range
           it_whmgr_range  = it_whmgr_range
           it_qgrp_range   = it_qgrp_range
           it_packgr_range = it_packgr_range
           it_ptind_range  = it_ptind_range
           it_pcind_range  = it_pcind_range
           it_rmind_range  = it_rmind_range
           it_ccind_range  = it_ccind_range
           it_lgbkz_range  = it_lgbkz_range
           it_mtart_range  = it_mtart_range
           it_mmsta_range  = it_mmsta_range
           iv_cwrel        = iv_cwrel
         IMPORTING
           et_data         = lt_matlwh ).

    ELSE.
*     eliminate entries where the warehouse product does not exist
      LOOP AT it_selected_wh_products ASSIGNING <fs_data> WHERE no_wh_data IS INITIAL.
        APPEND <fs_data> TO lt_matlwh.
      ENDLOOP.
    ENDIF.


*   read table /sapapo/matlhwst from DB
    SORT lt_matlwh BY matid scuguid entitled_id.
    IF lt_matlwh IS NOT INITIAL.
      LOOP AT lt_matlwh ASSIGNING <fs_matlwh> WHERE no_wh_data IS INITIAL.
        ls_prodlwhstid-matid = <fs_matlwh>-matid.
        ls_prodlwhstid-scuguid = <fs_matlwh>-scuguid.
        ls_prodlwhstid-entitled_id = <fs_matlwh>-entitled_id.
        APPEND ls_prodlwhstid  TO lt_prodlwhstid.
      ENDLOOP.
    ENDIF.

    "==========================================
    CALL FUNCTION '/SAPAPO/MATLWHST_READ_MULTI_2'
      EXPORTING
        it_key              = lt_prodlwhstid
      IMPORTING
        et_locprodwhst      = lt_prodlwhst
      EXCEPTIONS
        interface_incorrect = 1
        data_not_found      = 2
        OTHERS              = 3.
    "==========================================

    CLEAR lt_new_records.

*   if option 2 or 3, creation of empty records for warehouse products without sto.type data for iv_lgtyp
    IF ( NOT iv_only_without_whst IS INITIAL OR NOT iv_both IS INITIAL ) AND "option 2 or 3
         it_selected_wh_products IS INITIAL. "in drill down case, shown only the existing records
*     remove records with other warehouse types than iv_lgtyp
      LOOP AT lt_prodlwhst ASSIGNING <fs_prodlwhst> WHERE lgtyp <> iv_lgtyp.
        DELETE lt_prodlwhst.
      ENDLOOP.

      SORT lt_prodlwhst BY matid scuguid entitled_id.
      CLEAR ls_new_record.

      LOOP AT lt_prodlwhstid ASSIGNING <fs_prodlwhst_id>.
        READ TABLE lt_prodlwhst WITH KEY matid = <fs_prodlwhst_id>-matid
                                               scuguid = <fs_prodlwhst_id>-scuguid
                                               entitled_id = <fs_prodlwhst_id>-entitled_id
                                               lgtyp = iv_lgtyp
                                               TRANSPORTING NO FIELDS
                                               BINARY SEARCH .
        IF sy-subrc <> 0.
          ls_new_record-matid = <fs_prodlwhst_id>-matid.
          ls_new_record-entitled_id = <fs_prodlwhst_id>-entitled_id .
          ls_new_record-scuguid = <fs_prodlwhst_id>-scuguid.

          ls_new_record-lgtyp = iv_lgtyp.
          APPEND ls_new_record TO lt_new_records.
        ENDIF.
      ENDLOOP.

      IF NOT iv_only_without_whst IS INITIAL.
        CLEAR lt_prodlwhst.
      ENDIF.
      APPEND LINES OF lt_new_records TO lt_prodlwhst.
      SORT lt_prodlwhst BY matid scuguid entitled_id lgtyp.

      SORT lt_new_records BY matid scuguid entitled_id lgtyp.
    ENDIF.

*   build the where clause
    CLEAR lt_where .
    CLEAR lv_where.
    lv_where = ' matid is not initial ' ##NO_TEXT.
    APPEND lv_where TO lt_where.

    IF it_styp_range IS INITIAL AND
      it_sbtyp_range IS INITIAL.
      "do nothing
    ELSE.
      IF it_styp_range IS NOT INITIAL.
        lv_where =  ' and LGTYP in IT_STYP_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_sbtyp_range IS NOT INITIAL.
        lv_where =  ' and BINTYPE in IT_SBTYP_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
    ENDIF.

    IF it_rng_dirrpl IS NOT INITIAL.
      APPEND | and ZZ1_DIRRPL_STT in IT_RNG_DIRRPL | TO lt_where.
    ENDIF.

    IF it_rng_maxput IS NOT INITIAL.
      APPEND | and ZZ1_MAXPUT_STT in IT_RNG_MAXPUT | TO lt_where.
    ENDIF.

*   build the output table
    CLEAR et_data.
    CLEAR ls_prod_strg_mon_out.

    LOOP AT lt_prodlwhst ASSIGNING <ls_matlwhst> WHERE (lt_where)  .
      CLEAR ls_prod_strg_mon_out.
      MOVE-CORRESPONDING <ls_matlwhst> TO ls_prod_strg_mon_out.

*     mark new created records with 'X' in field NO_WHSTDATA
      READ TABLE lt_new_records WITH KEY matid = <ls_matlwhst>-matid
                                         scuguid = <ls_matlwhst>-scuguid
                                         entitled_id = <ls_matlwhst>-entitled_id
                                         lgtyp = <ls_matlwhst>-lgtyp
                                         BINARY SEARCH
                                         TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        ls_prod_strg_mon_out-no_whstdata = 'X'.
        ls_prod_strg_mon_out-whst_data_exists = TEXT-002.
      ELSE.
        CLEAR ls_prod_strg_mon_out-no_whstdata.
        ls_prod_strg_mon_out-whst_data_exists = TEXT-001.
      ENDIF.

*     get corresponding warehouse product data
      READ TABLE lt_matlwh WITH KEY matid = <ls_matlwhst>-matid
                                    scuguid = <ls_matlwhst>-scuguid
                                    entitled_id = <ls_matlwhst>-entitled_id BINARY SEARCH
                           ASSIGNING <fs_matlwh>.

      IF sy-subrc EQ 0. "must be always the case
        ls_prod_strg_mon_out-matnr = <fs_matlwh>-matnr.
        ls_prod_strg_mon_out-entitled = <fs_matlwh>-entitled.
        ls_prod_strg_mon_out-meins = <fs_matlwh>-meins.
        ls_prod_strg_mon_out-mtart = <fs_matlwh>-mtart.
        ls_prod_strg_mon_out-mmsta = <fs_matlwh>-mmsta.

        CALL FUNCTION '/SCMB/MDL_GUID_CONVERT'
          EXPORTING
            iv_guid22 = <ls_matlwhst>-matid
          IMPORTING
            ev_guid16 = lv_mat16.

        IF ls_prod_strg_mon_out-repqty_plan IS NOT INITIAL.
          CALL METHOD lo_mon_prod->quan_convert
            EXPORTING
              iv_matid = lv_mat16
              iv_s_qty = ls_prod_strg_mon_out-repqty_plan
              iv_s_uom = <fs_matlwh>-meins
              iv_d_uom = ls_prod_strg_mon_out-repqty_uom_dsp
            CHANGING
              cv_d_qty = ls_prod_strg_mon_out-repqty_plan.
        ENDIF.

        IF ls_prod_strg_mon_out-maxqty_plan IS NOT INITIAL.
          CALL METHOD lo_mon_prod->quan_convert
            EXPORTING
              iv_matid = lv_mat16
              iv_s_qty = ls_prod_strg_mon_out-maxqty_plan
              iv_s_uom = <fs_matlwh>-meins
              iv_d_uom = ls_prod_strg_mon_out-maxqty_uom_dsp
            CHANGING
              cv_d_qty = ls_prod_strg_mon_out-maxqty_plan.
        ENDIF.

        IF ls_prod_strg_mon_out-minqty_plan IS NOT INITIAL.
          CALL METHOD lo_mon_prod->quan_convert
            EXPORTING
              iv_matid = lv_mat16
              iv_s_qty = ls_prod_strg_mon_out-minqty_plan
              iv_s_uom = <fs_matlwh>-meins
              iv_d_uom = ls_prod_strg_mon_out-minqty_uom_dsp
            CHANGING
              cv_d_qty = ls_prod_strg_mon_out-minqty_plan.
        ENDIF.

        IF ls_prod_strg_mon_out-repqty IS NOT INITIAL.
          CALL METHOD lo_mon_prod->quan_convert
            EXPORTING
              iv_matid = lv_mat16
              iv_s_qty = ls_prod_strg_mon_out-repqty
              iv_s_uom = <fs_matlwh>-meins
              iv_d_uom = ls_prod_strg_mon_out-repqty_uom_dsp
            CHANGING
              cv_d_qty = ls_prod_strg_mon_out-repqty.
        ENDIF.

        IF ls_prod_strg_mon_out-maxqty IS NOT INITIAL.
          CALL METHOD lo_mon_prod->quan_convert
            EXPORTING
              iv_matid = lv_mat16
              iv_s_qty = ls_prod_strg_mon_out-maxqty
              iv_s_uom = <fs_matlwh>-meins
              iv_d_uom = ls_prod_strg_mon_out-maxqty_uom_dsp
            CHANGING
              cv_d_qty = ls_prod_strg_mon_out-maxqty.
        ENDIF.

        IF ls_prod_strg_mon_out-minqty IS NOT INITIAL.
          CALL METHOD lo_mon_prod->quan_convert
            EXPORTING
              iv_matid = lv_mat16
              iv_s_qty = ls_prod_strg_mon_out-minqty
              iv_s_uom = <fs_matlwh>-meins
              iv_d_uom = ls_prod_strg_mon_out-minqty_uom_dsp
            CHANGING
              cv_d_qty = ls_prod_strg_mon_out-minqty.
        ENDIF.

*     check authority
        "==========================================
        product_authority_check(
          EXPORTING
            iv_lgnum  = mv_lgnum
            iv_matnr  = ls_prod_strg_mon_out-matnr
            iv_actvt  = '03'           "Display
          IMPORTING
            ev_failed = lv_failed
          CHANGING
            ct_return = lt_return
        ).
        "==========================================

        IF NOT lv_failed IS INITIAL.
          CONTINUE.
        ENDIF.

        APPEND ls_prod_strg_mon_out TO et_data.
      ENDIF. "read warehouse product
    ENDLOOP.
  ENDMETHOD.


  METHOD product_authority_check.
********************************************************************
*& Key          : <BSUGAREV>-Nov 10, 2023
*& Request No.  : GAP-037_040 - CrossTopics additional product master field
********************************************************************
*& Original Object: /scwm/cl_mon_prod(lcl_isolated_doc=>
*&                            lif_isolated_doc~product_authority_check)
********************************************************************
    CONSTANTS:
      gc_auth_matkey(3) TYPE c VALUE 'MKY' ##NO_TEXT.

    DATA: ls_return       TYPE bapiret2.
    DATA: lv_prod_check_failed TYPE abap_bool,
          lo_af_whse_auth      TYPE REF TO /scwm/if_af_whse_auth.

    CLEAR ev_failed.

    " Perform additional checks on /SCWM/PROD
    IF iv_lgnum IS NOT INITIAL.
      TRY.
          lo_af_whse_auth ?= /scmb/cl_af_factory=>get_instance( )->get_service( /scwm/if_af_whse_auth=>sc_me_as_a_service ).

          lv_prod_check_failed = lo_af_whse_auth->check_for_warehouse_product(
            EXPORTING iv_lgnum   = iv_lgnum
                      iv_actvt   = iv_actvt
                      iv_product = iv_matnr ).
        CATCH /scmb/cx_af_factory.
          lv_prod_check_failed = abap_true.
      ENDTRY.
    ENDIF.

    CALL FUNCTION '/SAPAPO/MD_AUTHORITY_CORE_CHK'
      EXPORTING
        i_check_obj     = gc_auth_matkey "Product
        i_actvt         = iv_actvt           "Create
        i_matnr         = iv_matnr
      EXCEPTIONS
        value_not_found = 1
        no_authority    = 2
        OTHERS          = 3.

    IF sy-subrc <> 0 OR lv_prod_check_failed = abap_true.
      CLEAR ls_return.
      ls_return-type = 'W'.
      ls_return-id = '/SCWM/MONITOR'.
      ls_return-number = 253.
      ls_return-message_v1 = iv_matnr.
      APPEND ls_return TO ct_return.

      ev_failed = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD set_custom_selopt.
**********************************************************************
*& Key           : LH-021223
*& Request No.   : GAP-37-40 – "Additional Product Master Fields”
**********************************************************************
*& Description (short)
*& save select options to member attributes
**********************************************************************

    mv_show_wh_only = iv_show_wh_only.
    mt_rng_sign01  = it_rng_sign01 .
    mt_rng_sing01  = it_rng_sing01 .
    mt_rng_box01   = it_rng_box01  .
    mt_rng_sign02  = it_rng_sign02 .
    mt_rng_sing02  = it_rng_sing02 .
    mt_rng_box02   = it_rng_box02  .
    mt_rng_sign03  = it_rng_sign03 .
    mt_rng_sing03  = it_rng_sing03 .
    mt_rng_box03   = it_rng_box03  .
    mt_rng_twomh   = it_rng_twomh  .
    mt_rng_disp    = it_rng_disp   .
    mt_rng_noslo   = it_rng_noslo  .
    mt_rng_nospo   = it_rng_nospo  .
    mt_rng_keepcr  = it_rng_keepcr .
    mt_rng_fragile = it_rng_fragile.
    mt_rng_noncnv  = it_rng_noncnv .
    mt_rng_dirrpl  = it_rng_dirrpl.
    mt_rng_maxput  = it_rng_maxput.
  ENDMETHOD.


  METHOD set_params_mass_change.
**********************************************************************
*& Key           : LH-021223
*& Request No.   : GAP-37-40 – "Additional Product Master Fields”
**********************************************************************
*& Description (short)
*& Save parameters to member attributes
**********************************************************************
    CLEAR: mv_twomh, mv_twores, mv_disp, mv_disres, mv_noslo, mv_nosres, mv_nospo,
           mv_keepcr, mv_dirrpl, mv_resdrp, mv_maxput, mv_resmpu.

    mv_twomh  = iv_twomh .
    mv_twores = iv_twores.
    mv_disp   = iv_disp  .
    mv_disres = iv_disres.
    mv_noslo  = iv_noslo .
    mv_nosres = iv_nosres.
    mv_nospo  = iv_nospo .
    mv_keepcr = iv_keepcr.
    mv_dirrpl = iv_dirrpl.
    mv_resdrp = iv_resdrp.
    mv_maxput = iv_maxput.
    mv_resmpu = iv_resmpu.
  ENDMETHOD.


  METHOD update_lgnum_matlwh.
********************************************************************
*& Key          : <BSUGAREV>-Nov 10, 2023
*& Request No.  : GAP-037_040 - CrossTopics additional product master field
********************************************************************
*& Description  : Enhancement: ZEI_MON_READ_MATLWH_MULTI
*&   path to the enhancement /SCWM/CL_MON_PROD - >
*&                    LCL_ISOLATED_DOC->LIF_ISOLATED_DOC~READ_MATLWH_MULTI
*&
********************************************************************
    BREAK-POINT ID zcg_badi.
    BREAK-POINT ID zcg_mon_product.

    IF mv_show_wh_only IS INITIAL.
      RETURN.
    ENDIF.

    IF mt_rng_sign01 IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_hmsign01_whd NOT IN mt_rng_sign01.
    ENDIF.

    IF mt_rng_sing01 IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_hmsingle01_whd NOT IN mt_rng_sing01.
    ENDIF.

    IF mt_rng_box01  IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_hmbox01_whd NOT IN mt_rng_box01.
    ENDIF.

    IF mt_rng_sign02 IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_hmsign02_whd NOT IN mt_rng_sign02.
    ENDIF.

    IF mt_rng_sing02 IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_hmsingle02_whd NOT IN mt_rng_sing02.
    ENDIF.

    IF mt_rng_box02  IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_hmbox02_whd NOT IN mt_rng_box02.
    ENDIF.

    IF mt_rng_sign03 IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_hmsign03_whd NOT IN mt_rng_sign03.
    ENDIF.

    IF mt_rng_sing03 IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_hmsingle03_whd NOT IN mt_rng_sing03.
    ENDIF.

    IF mt_rng_box03  IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_hmbox03_whd NOT IN mt_rng_box03.
    ENDIF.

    IF mt_rng_twomh IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_twomh_whd NOT IN mt_rng_twomh.
    ENDIF.

    IF mt_rng_disp  IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_disp_whd NOT IN mt_rng_disp.
    ENDIF.

    IF mt_rng_noslo IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_noslo_whd NOT IN mt_rng_noslo.
    ENDIF.

    IF mt_rng_nospo IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_nospo_whd NOT IN mt_rng_nospo.
    ENDIF.

    IF mt_rng_keepcr IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_keepcar_whd NOT IN mt_rng_keepcr.
    ENDIF.

    IF mt_rng_fragile IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_fragile_whd NOT IN mt_rng_fragile.
    ENDIF.

    IF mt_rng_noncnv IS NOT INITIAL.
      DELETE ct_lgnum_matlwh WHERE zz1_nonconveyable_whd NOT IN mt_rng_noncnv.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
