class ZCL_MON_PROD_BUFFER definition
  public
  create public .

public section.

  types:
    BEGIN OF t_scu_ids,
        scuguid TYPE guid_16,
        entity  TYPE /scmb/oe_entity,
      END OF t_scu_ids .
  types:
    BEGIN OF ty_matid_by_ent,
        matid TYPE /sapapo/matid,
        entit TYPE /scwm/tt_entitled_2,
      END OF ty_matid_by_ent .
  types:
    tt_matid_by_ent  TYPE SORTED TABLE OF ty_matid_by_ent WITH UNIQUE KEY matid .                   "TT_MATID_BY_ENT  TYPE STANDARD TABLE OF TY_MATID_BY_ENT .
  types:
    BEGIN OF ty_loc_vrsioid_str,
        vrsioid TYPE char22, "/SCMB/LC_VRSIOID, "/SAPAPO/VRSIOID,
      END OF ty_loc_vrsioid_str .
  types:
    tt_where TYPE STANDARD TABLE OF string .
  types:
    BEGIN OF ty_matid_entit,
        matid    TYPE /sapapo/matid,
        entitled TYPE /scwm/de_entitled,
      END OF ty_matid_entit .
  types:
    tt_matid_entit  TYPE SORTED TABLE OF ty_matid_entit WITH NON-UNIQUE KEY matid entitled .
  types:
    BEGIN OF ty_matid_entitid,
        matid       TYPE /sapapo/matid,
        entitled_id TYPE /scwm/de_entitled_id,
        meins       TYPE /sapapo/meins,
      END OF ty_matid_entitid .
  types:
    tt_matid_entitid  TYPE SORTED TABLE OF ty_matid_entitid WITH NON-UNIQUE KEY matid entitled_id .
  types:
    BEGIN OF ty_matid_meins,
        matid TYPE /sapapo/matid,
        meins TYPE /sapapo/meins,
      END OF ty_matid_meins .
  types:
    tt_matid_meins  TYPE SORTED TABLE OF ty_matid_meins WITH NON-UNIQUE KEY matid .
  types TY_MATID type /SAPAPO/MATID_STR .
  types:
    tt_matid TYPE STANDARD TABLE OF /sapapo/matid_str .
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

  constants:
    gc_auth_matkey(3) TYPE c value 'MKY' ##NO_TEXT.
  data MO_LOCK_MASS_PR type ref to /SCMB/IF_MD_LOCK_MASS_MAINT .
  constants SC_SHOW_ONLY_WH type C value 'W' ##NO_TEXT.
  constants SC_ONLY_PRODUCTS_WITHOUT_WH type C value 'N' ##NO_TEXT.
  constants SC_EVERY_PRODUCT type C value 'E' ##NO_TEXT.

  class-methods UPDATE_LGNUM_MATLWH
    changing
      !CT_LGNUM_MATLWH type TT_LGNUM_MATLWH_NEW .
  methods SET_LGNUM
    importing
      !IV_LGNUM type /SCWM/LGNUM
    exporting
      !ET_ENTITLED_GUID type BUP_PARTNER_GUID_T
      !EV_SCU type /SCMB/OE_ENTITY
      !EV_SCUGUID type /SCMB/MDL_SCUGUID .
  methods CONSTRUCTOR .
  methods WH_PROD_MASS_CHANGE
    importing
      !IT_MATKEY type TT_EXT_MATKEY
      !IT_MATKEYX type TT_EXT_MATKEYX
      !IT_MATLWH_CREATE type TT_EXT_MATLWH optional
      !IT_MATLWH_UPDATE type TT_EXT_MATLWH
      !IT_MATLWHX type TT_EXT_MATLWHX
      !IT_MATLWHST_CREATE type TT_EXT_MATLWHST optional
      !IT_MATLWHST_UPDATE type TT_EXT_MATLWHST optional
      !IT_MATLWHSTX type TT_EXT_MATLWHSTX optional
    exporting
      !ET_RETURN type BAPIRET2_T
      !EV_ABORT type XFELD
      !EV_LINES type INT8
      !EV_LINES_ST type INT8 .
  methods GET_PROD_NODE_DATA
    importing
      !IV_LGNUM type /SCWM/LGNUM optional
      !IV_UOM_INCLUDE type ABAP_BOOL default ABAP_FALSE
      !IT_MATNR_RANGE type TT_MATNR_RANGE optional
      !IT_MTART_RANGE type TT_MTART_RANGE optional
      !IT_MMSTA_RANGE type TT_MMSTA_RANGE optional
      !IT_ENTIT_RANGE type TT_ENTIT_RANGE optional
      !IT_MAKTX_RANGE type TT_MAKTX_RANGE optional
      !IT_MATKL_RANGE type TT_MATKL_RANGE optional
      !IT_WHMGR_RANGE type TT_WHMGR_RANGE optional
      !IT_QGRP_RANGE type TT_QGRP_RANGE optional
      !IT_PACKGR_RANGE type TT_PACKGR_RANGE optional
      !IT_PTIND_RANGE type TT_PTIND_RANGE optional
      !IT_PCIND_RANGE type TT_PCIND_RANGE optional
      !IT_RMIND_RANGE type TT_RMIND_RANGE optional
      !IT_CCIND_RANGE type TT_CCIND_RANGE optional
      !IT_LGBKZ_RANGE type TT_LGBKZ_RANGE optional
      !IT_RNG_KEEPCR type TY_RNG_KEEPCR optional
      !IV_CWREL type /SCMB/DE_CWREL optional
      !IV_SHOW_WH_ONLY type ABAP_BOOL default ABAP_FALSE
      !IV_SHOW_NON_WH_ONLY type ABAP_BOOL default ABAP_FALSE
      !IV_SHOW_EVERY_PROD type ABAP_BOOL default ABAP_FALSE
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
      !IT_RNG_FRAGILE type TY_RNG_FRAGILE optional
      !IT_RNG_NONCNV type TY_RNG_NONCNV optional
    exporting
      !ET_DATA type /SCWM/TT_PROD_MON_OUT
      !ET_PROD_UOM type /SCWM/TT_PROD_UOM_MON_OUT
      !ET_MARM type /SAPAPO/MARM_TAB
      !ET_MATERIAL type /SAPAPO/MATKEY_OUT_TAB .
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
  methods GET_UOM_NODE_DATA
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IT_MATID_RANGE type TT_MATID_RANGE optional
      !IT_MATNR_RANGE type TT_MATNR_RANGE optional
      !IT_ENTIT_RANGE type TT_ENTIT_RANGE optional
      !IT_MAKTX_RANGE type TT_MAKTX_RANGE optional
      !IT_MATKL_RANGE type TT_MATKL_RANGE optional
      !IT_MTART_RANGE type TT_MTART_RANGE optional
      !IT_MMSTA_RANGE type TT_MMSTA_RANGE optional
      !IT_WHMGR_RANGE type TT_WHMGR_RANGE optional
      !IT_QGRP_RANGE type TT_QGRP_RANGE optional
      !IT_PACKGR_RANGE type TT_PACKGR_RANGE optional
      !IT_PTIND_RANGE type TT_PTIND_RANGE optional
      !IT_PCIND_RANGE type TT_PCIND_RANGE optional
      !IT_RMIND_RANGE type TT_RMIND_RANGE optional
      !IT_CCIND_RANGE type TT_CCIND_RANGE optional
      !IT_LGBKZ_RANGE type TT_LGBKZ_RANGE optional
      !IV_CWREL type /SCMB/DE_CWREL optional
      !IT_MEINH_RANGE type TT_MEINH_RANGE optional
      !IT_TY2TQ_RANGE type TT_TY2TQ_RANGE optional
      !IT_SELECTED_WH_PRODUCTS type /SCWM/TT_PROD_MON_OUT optional
    exporting
      !ET_DATA type /SCWM/TT_PROD_UOM_MON_OUT .
  methods GET_SCUGUID
    importing
      !IV_LGNUM type /SCWM/LGNUM
    exporting
      !EV_SCUGUID type /SCMB/MDL_SCUGUID .
  methods QUAN_CONVERT
    importing
      !IV_MATID type /SCMB/MDL_MATID_CE
      !IV_S_QTY type /SCWM/DE_QUAN_DSP
      !IV_S_UOM type MEINS
      !IV_D_UOM type MEINS
    changing
      !CV_D_QTY type /SCWM/DE_QUAN_DSP .
  methods SET_CUSTOM_SELOPT
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
  PRIVATE SECTION.

    DATA mt_mat_nr_id_guid TYPE tt_prod .
    DATA mo_service TYPE REF TO /scwm/if_tm_global_info .
    DATA mt_entitled TYPE bup_partner_guid_t .
    DATA mv_lgnum TYPE /scwm/lgnum .
    DATA mv_scuguid TYPE /scmb/mdl_scuguid .
    DATA mo_isolated_doc TYPE REF TO lif_isolated_doc .
    DATA mv_scu TYPE /scmb/oe_entity .
    CLASS-DATA mv_show_wh_only TYPE c.
    CLASS-DATA mt_rng_sign01   TYPE ty_rng_sign01.
    CLASS-DATA mt_rng_sing01   TYPE ty_rng_sing01.
    CLASS-DATA mt_rng_box01    TYPE ty_rng_box01  .
    CLASS-DATA mt_rng_sign02   TYPE ty_rng_sign02 .
    CLASS-DATA mt_rng_sing02   TYPE ty_rng_sing02 .
    CLASS-DATA mt_rng_box02    TYPE ty_rng_box02  .
    CLASS-DATA mt_rng_sign03   TYPE ty_rng_sign03 .
    CLASS-DATA mt_rng_sing03   TYPE ty_rng_sing03 .
    CLASS-DATA mt_rng_box03    TYPE ty_rng_box03  .
    CLASS-DATA mt_rng_twomh    TYPE ty_rng_twomh  .
    CLASS-DATA mt_rng_disp     TYPE ty_rng_disp   .
    CLASS-DATA mt_rng_noslo    TYPE ty_rng_noslo  .
    CLASS-DATA mt_rng_nospo    TYPE ty_rng_nospo  .
    CLASS-DATA mt_rng_keepcr   TYPE ty_rng_keepcr .
    CLASS-DATA mt_rng_fragile  TYPE ty_rng_fragile.
    CLASS-DATA mt_rng_noncnv   TYPE ty_rng_noncnv .
    CLASS-DATA mt_rng_dirrpl   TYPE ty_rng_dirrpl.
    CLASS-DATA mt_rng_maxput   TYPE ty_rng_maxput.

    METHODS integrate_sapapo_data
      IMPORTING
        !it_sapapo_mattxt  TYPE /sapapo/mattxt_tab
        !it_sapapo_matpack TYPE /sapapo/matpack_tab
        !it_sapapo_matexec TYPE /sapapo/matexec_tab
        !iv_lgnum          TYPE /scwm/lgnum
        !iv_matid          TYPE /sapapo/matid
      CHANGING
        !cs_product        TYPE /scwm/s_prod_mon_out .
    METHODS create_list_of_wh_products
      IMPORTING
        !iv_lgnum          TYPE /scwm/lgnum
        !it_material       TYPE /sapapo/matkey_out_tab
        !it_sapapo_mattxt  TYPE /sapapo/mattxt_tab
        !it_sapapo_matpack TYPE /sapapo/matpack_tab
        !it_sapapo_matexec TYPE /sapapo/matexec_tab
        !iv_selection_mode TYPE c
        !it_wh_product     TYPE tt_lgnum_matlwh
      EXPORTING
        !et_data           TYPE /scwm/tt_prod_mon_out .
    METHODS fill_field_mtart_and_mmsta
      IMPORTING
         iv_lgnum       TYPE /scwm/lgnum
         it_matnr_range TYPE /scwm/if_af_material=>tt_matnr_range
         it_matid_range TYPE /scwm/if_af_material=>tt_m22id_range
      CHANGING
         ct_data        TYPE /scwm/tt_prod_mon_out .
    METHODS product_authority_check
      IMPORTING
        iv_lgnum  TYPE /scwm/lgnum OPTIONAL
        iv_matnr  TYPE /scwm/s_prod_strg_mon_out-matnr
        iv_actvt  TYPE activ_auth
      EXPORTING
        ev_failed TYPE abap_bool
      CHANGING
        ct_return TYPE bapiret2_t.
ENDCLASS.



CLASS ZCL_MON_PROD_BUFFER IMPLEMENTATION.


  METHOD CONSTRUCTOR.
    mo_isolated_doc = lcl_isolated_doc=>get_instance( ).

    TRY.
        CALL METHOD /sapapo/cl_lock_pr=>get_instance_mass_maint
          EXPORTING
            iv_appid    = 'PRODLWH'
          IMPORTING
            eo_instance = mo_lock_mass_pr.
      CATCH /scmb/cx_md_lock_system_error.
    ENDTRY.


    IF mo_service IS INITIAL.
      TRY.
          mo_service ?= /scwm/cl_tm_factory=>get_service( /scwm/cl_tm_factory=>sc_globals ).
        CATCH /scwm/cx_tm_factory.
          ASSERT 1 = 0.
      ENDTRY.
    ENDIF.



  ENDMETHOD.


  METHOD CREATE_LIST_OF_WH_PRODUCTS.
    DATA:
      ls_material         TYPE /sapapo/matkey_out,
      ls_wh_product       TYPE ty_lgnum_matlwh,
      ls_product          TYPE /scwm/s_prod_mon_out,
      lv_entitled         TYPE /scwm/de_entitled,
      lv_tabix            TYPE sytabix,
      lo_erp_stock_mapper TYPE REF TO /scwm/if_stockid_mapping,
      ls_entitled         TYPE bupa_partner_guid,
      lt_matnr_range      TYPE /scwm/if_af_material=>tt_matnr_range,
      ls_matnr_range      TYPE /scwm/if_af_material=>ty_matnr_range,
      lt_matid_range      TYPE /scwm/if_af_material=>tt_m22id_range,
      ls_matid_range      TYPE /scwm/if_af_material=>ty_m22id_range,
      ls_mat_nr_id_guid   TYPE ty_prod,
      lv_meins            TYPE /sapapo/meins.

    FIELD-SYMBOLS:
      <ls_material>   TYPE /sapapo/matkey_out,
      <ls_wh_product> TYPE /sapapo/dm_matlwh.


    CLEAR ls_matnr_range.
    CLEAR lt_matnr_range.
    CLEAR lt_matid_range.

    SORT mt_mat_nr_id_guid BY matnr.
    LOOP AT it_material ASSIGNING <ls_material>.
      LOOP AT mt_entitled INTO ls_entitled.
        "Do for every entitled in the lgnum
        CLEAR ls_product.
        MOVE-CORRESPONDING <ls_material> TO ls_product.     "#EC ENHOK
        lv_meins = ls_product-meins.
        ls_product-entitled = ls_entitled-partner.
        ls_product-entitled_id = ls_entitled-partner_guid.
        ls_product-scuguid     = mv_scuguid.

*       map matnr to matguid
        READ TABLE mt_mat_nr_id_guid INTO ls_mat_nr_id_guid WITH KEY matnr = <ls_material>-matnr BINARY SEARCH.

*       does the warehouse product exist on the DB
        READ TABLE it_wh_product INTO ls_wh_product WITH KEY matid = ls_mat_nr_id_guid-matguid
                                                                     lgnum = mv_lgnum
                                                                     entitled = ls_entitled-partner BINARY SEARCH.

        IF sy-subrc = 0.
          ls_product-wh_data_exists = TEXT-001.
          IF iv_selection_mode = sc_only_products_without_wh.
            CONTINUE.
          ENDIF.

          MOVE-CORRESPONDING ls_wh_product TO ls_product.
          ls_product-meins = lv_meins.
          ls_product-matid = <ls_material>-matid.
        ELSE.
          ls_product-wh_data_exists = TEXT-002.
          IF iv_selection_mode = sc_show_only_wh.
            CONTINUE.
          ENDIF.

          ls_product-no_wh_data = abap_true.
        ENDIF.

        me->integrate_sapapo_data(
          EXPORTING
            it_sapapo_matpack = it_sapapo_matpack
            it_sapapo_matexec = it_sapapo_matexec
            it_sapapo_mattxt  = it_sapapo_mattxt
            iv_lgnum          = iv_lgnum
            iv_matid          = ls_mat_nr_id_guid-matid
          CHANGING
            cs_product        = ls_product ).


        ls_matnr_range-sign = 'I'.
        ls_matnr_range-option = 'EQ'.
        ls_matnr_range-low = ls_product-matnr.
        APPEND ls_matnr_range TO lt_matnr_range.

        ls_matid_range-sign = 'I'.
        ls_matid_range-option = 'EQ'.
        ls_matid_range-low = ls_product-matid.
        APPEND ls_matid_range TO lt_matid_range.


        APPEND ls_product TO et_data.
      ENDLOOP. "at entitled
    ENDLOOP. "at materials

    SORT et_data BY matid scuguid entitled_id.

    CALL METHOD fill_field_mtart_and_mmsta
      EXPORTING
        iv_lgnum       = iv_lgnum
        it_matnr_range = lt_matnr_range
        it_matid_range = lt_matid_range
      CHANGING
        ct_data        = et_data.

  ENDMETHOD.


  METHOD FILL_FIELD_MTART_AND_MMSTA.
    DATA: lt_marc             TYPE TABLE OF /scwm/if_af_material=>ty_marc_mmsta,
          lo_stockid_map      TYPE REF TO /scwm/if_stockid_mapping,
          lv_plant            TYPE werks_d,
          lt_data             TYPE /scwm/tt_prod_mon_out,
          lo_saf              TYPE REF TO /scdl/cl_af_management,
          lo_material_service TYPE REF TO /scwm/if_af_material,
          lt_mara             TYPE /scwm/if_af_material=>tt_matid_guid22.

    FIELD-SYMBOLS: <fs_data> TYPE LINE OF /scwm/tt_prod_mon_out,
                   <fs_marc> TYPE /scwm/if_af_material=>ty_marc_mmsta,
                   <fs_mara> TYPE /scwm/if_af_material=>ty_matid_guid22.

    DATA: ls_entitled         TYPE bupa_partner_guid.
    DATA: ls_werks_range TYPE /scwm/if_af_material=>ty_werks_range,
          lt_werks_range TYPE /scwm/if_af_material=>tt_werks_range.
    TYPES:
      BEGIN OF ty_entitled_plant ,
        partner_guid TYPE  bu_partner_guid,
        plant        TYPE  werks_d,
      END OF ty_entitled_plant .
    DATA: ls_entitled_plant TYPE ty_entitled_plant,
          lt_entitled_plant TYPE TABLE OF ty_entitled_plant.

    CALL FUNCTION '/SCWM/GET_STOCKID_MAP_INSTANCE'
      IMPORTING
        eif_stockid_mapping = lo_stockid_map.

    LOOP AT mt_entitled INTO ls_entitled.
      TRY.
          lo_stockid_map->get_plant_by_partnerno(
            EXPORTING
              iv_wme_partno = ls_entitled-partner
            IMPORTING
              ev_erp_plant  = lv_plant ).
        CATCH /scwm/cx_stockid_map.
          CONTINUE.
      ENDTRY.
      ls_werks_range-sign = 'I'.
      ls_werks_range-option = 'EQ'.
      ls_werks_range-low = lv_plant.
      APPEND ls_werks_range TO lt_werks_range.

      ls_entitled_plant-partner_guid = ls_entitled-partner_guid.
      ls_entitled_plant-plant = lv_plant.
      APPEND ls_entitled_plant TO lt_entitled_plant.
    ENDLOOP.

    lo_saf = /scdl/cl_af_management=>get_instance( ).
    lo_material_service ?= lo_saf->get_service( EXPORTING iv_service = '/SCWM/IF_AF_MATERIAL' ).

    CALL METHOD lo_material_service->get_marc_mmsta
      EXPORTING
        it_matnr_range = it_matnr_range
        it_werks_range = lt_werks_range
      IMPORTING
        et_marc        = lt_marc.

    SORT lt_marc BY matnr werks.


    CALL METHOD lo_material_service->get_mara_mtart
      EXPORTING
        it_mat_range = it_matid_range
      IMPORTING
        et_matid     = lt_mara.

    SORT lt_mara BY scm_matid_guid22.

    LOOP AT ct_data ASSIGNING <fs_data>.

      CLEAR lv_plant.

      TRY.
          lv_plant = lt_entitled_plant[ partner_guid  = <fs_data>-entitled_id ]-plant.
        CATCH cx_sy_itab_line_not_found.
          CONTINUE.
      ENDTRY.

      READ TABLE lt_marc ASSIGNING <fs_marc> WITH KEY matnr = <fs_data>-matnr werks = lv_plant BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_data>-mmsta = <fs_marc>-mmsta.
      ELSE.
        CLEAR <fs_data>-mmsta.
      ENDIF.

      READ TABLE lt_mara ASSIGNING <fs_mara> WITH KEY scm_matid_guid22 = <fs_data>-matid.
      IF sy-subrc = 0.
        <fs_data>-mtart = <fs_mara>-mtart.
        <fs_data>-meins = <fs_mara>-meins.
      ELSE.
        CLEAR <fs_data>-mtart.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD GET_PROD_NODE_DATA.
    CONSTANTS  gc_auth_matkey(3) TYPE c VALUE 'MKY'.

    DATA:
      lt_matid_tab        TYPE tt_matid,
      lt_matnr            TYPE /scmb/mdl_matnr_tab,
      lt_sapapo_mattxt    TYPE TABLE OF /sapapo/mattxt_str,
      lt_sapapo_matpack   TYPE TABLE OF /sapapo/matpack_str,
      lt_sapapo_matexec   TYPE TABLE OF /sapapo/matexec_str,
      lv_langu            TYPE sy-langu,
      ls_requested        TYPE /sapapo/mat_selflags_str,
      ls_exclude          TYPE /sapapo/mat_selflags_str,
      ls_version          TYPE /scmb/mdl_planvrs,
      ls_vrsioid          TYPE ty_loc_vrsioid_str,
      lt_vrsioid          TYPE STANDARD TABLE OF ty_loc_vrsioid_str,
      lt_prodlwh          TYPE tt_lgnum_matlwh,
      lt_sapapo_marm      TYPE TABLE OF /sapapo/marm_out,
      lt_prod_uom         TYPE /scwm/tt_prod_uom_mon_out,
      ls_prod_uom         TYPE /scwm/s_prod_uom_mon_out,
      lt_prod_uom_temp    TYPE /scwm/tt_prod_uom_mon_out,
      lt_matid_meins      TYPE tt_matid_meins,
      lt_prodlwh_tmp      TYPE /sapapo/dm_matlwh_tab,
      ls_matlwh_id        TYPE /sapapo/dm_matlwh_id,
      lv_where            TYPE string,
      lt_where            TYPE tt_where,
      lt_prod_mon_out     TYPE /scwm/tt_prod_mon_out,
      lt_prod_mon_outtemp TYPE /scwm/tt_prod_mon_out,
      lt_backflush        TYPE TABLE OF dd07v,
      ls_backflush        TYPE dd07v,
      ls_kit_fixed        TYPE dd07v,
      lt_kit_fixed        TYPE TABLE OF dd07v,
      ls_t305rt           TYPE /scwm/s_t305rt,
      ls_t305qt           TYPE /scwm/s_t305qt,
      ls_twrkldgrt        TYPE /scwm/s_twrkldgrt,
      ls_tptdetindt       TYPE /scwm/s_tptdetindt,
      ls_tprocprflt       TYPE /scwm/s_tprocprflt,
      ls_matnr_range      TYPE ty_matnr_range,
      lt_matnr_range      TYPE tt_matnr_range,
      lv_selection_mode   TYPE c,
      lt_mata             TYPE TABLE OF /sapapo/matkey_out,
      ls_mara             TYPE /sapapo/matkey_out,
      lt_matid_entit      TYPE tt_matid_entit,
      lt_matid_entitid    TYPE tt_matid_entitid,
      lt_marm             TYPE TABLE OF /sapapo/marm_str,
      lt_material         TYPE /sapapo/matkey_out_tab,
      lv_failed           TYPE abap_bool,
      lt_return           TYPE bapiret2_t.


    FIELD-SYMBOLS:
      <ls_matid_meins>    TYPE ty_matid_meins,
      <ls_prod_uom>       TYPE /scwm/s_prod_uom_mon_out,
      <ls_matid_entit>    TYPE ty_matid_entit,
      <ls_prod>           TYPE /scwm/s_prod_mon_out,
      <ls_matid_tab>      TYPE ty_matid,
      <fs_mat_to_exclude> TYPE /scwm/if_af_material=>ty_matid_guid22,
      <fs_material>       TYPE /sapapo/matkey_out,
      <fs_prodlwh_tmp>    TYPE /sapapo/dm_matlwh,
      <fs_mat_nr_id_guid> TYPE ty_prod.

    DATA: ls_material TYPE /sapapo/matkey_out.

    DATA: lt_matid   TYPE SORTED TABLE OF /sapapo/matid_str WITH NON-UNIQUE KEY matid,
          lt_matguid TYPE SORTED TABLE OF ty_prod WITH NON-UNIQUE KEY matguid.

    CALL METHOD set_lgnum
      EXPORTING
        iv_lgnum = iv_lgnum.


    IF iv_show_wh_only EQ abap_true.
      lv_selection_mode = sc_show_only_wh.
    ELSEIF iv_show_non_wh_only = abap_true.
      lv_selection_mode = sc_only_products_without_wh.
    ELSEIF iv_show_every_prod = abap_true.
      lv_selection_mode = sc_every_product.
    ELSE.
      lv_selection_mode = sc_show_only_wh.
    ENDIF.

    lt_matnr_range = it_matnr_range.

    CALL METHOD mo_isolated_doc->get_prod_id
      EXPORTING
        iv_scuguid        = mv_scuguid
        it_entitled       = mt_entitled
        iv_selection_mode = lv_selection_mode
        it_matnr_range    = lt_matnr_range
      IMPORTING
        et_matid_tab      = lt_matid_tab. "char22


    CLEAR ls_exclude.
    IF NOT lt_matid_tab[] IS INITIAL.
      IF iv_uom_include EQ abap_false.
        ls_exclude-no_marm        = abap_true.
      ENDIF.
      ls_exclude-no_penalty1      = abap_true.
      ls_exclude-no_matvers_head  = abap_true.
      ls_exclude-no_matsbod       = abap_true.
      ls_exclude-no_matrgpt       = abap_true.
      ls_exclude-no_matgroup      = abap_true.
      ls_exclude-no_matinfo       = abap_true.
      ls_exclude-no_matapn        = abap_true.
      ls_exclude-no_mean          = abap_true.

* read product
      CALL METHOD mo_isolated_doc->sapapo_product_dm_read
        EXPORTING
          iv_langu      = sy-langu
          is_exclude    = ls_exclude
          it_matid      = lt_matid_tab
          it_matnr      = lt_matnr
        IMPORTING
          et_matkey_out = lt_material
          et_mattxt     = lt_sapapo_mattxt
          et_matpack    = lt_sapapo_matpack
          et_matexec    = lt_sapapo_matexec
          et_marm       = lt_marm.

      et_marm = lt_marm.

      IF it_matkl_range IS NOT INITIAL.
        DELETE lt_material WHERE matkl NOT IN it_matkl_range.
      ENDIF.

      IF it_whmgr_range IS NOT INITIAL.
        DELETE lt_material WHERE whmatgr NOT IN it_whmgr_range.
      ENDIF.

      IF it_qgrp_range IS NOT INITIAL.
        DELETE lt_material WHERE qgrp NOT IN it_qgrp_range.
      ENDIF.

      IF it_packgr_range IS NOT INITIAL.
        DELETE lt_material WHERE packgr NOT IN it_packgr_range.
      ENDIF.

      et_material = lt_material.
      MOVE-CORRESPONDING lt_material[] TO lt_matid[].

      lt_sapapo_mattxt = FILTER #( lt_sapapo_mattxt IN lt_matid WHERE matid = matid ).
      lt_sapapo_matpack = FILTER #( lt_sapapo_matpack IN lt_matid WHERE matid = matid ).
      lt_sapapo_matexec = FILTER #( lt_sapapo_matexec IN lt_matid WHERE matid = matid ).
      lt_marm = FILTER #( lt_marm IN lt_matid WHERE matid = matid ).

    ELSE.
      RETURN.
    ENDIF.

* buffer the mapping between Matnr Matid and Matguid

    CLEAR mt_mat_nr_id_guid.

    CALL METHOD mo_isolated_doc->buffer_mapping_mat_nr_id_guid
      EXPORTING
        it_material       = lt_material
      IMPORTING
        et_mat_nr_id_guid = mt_mat_nr_id_guid.

* read warehouse product fields from DB including fields which may be in the MARC (S/4)

    CALL METHOD mo_isolated_doc->read_matlwh_multi
      EXPORTING
        iv_lgnum          = iv_lgnum
        iv_scuguid        = mv_scuguid
        it_entitled       = mt_entitled
        it_mat_nr_id_guid = mt_mat_nr_id_guid
        it_material       = lt_material
      IMPORTING
        et_prod_lwh       = lt_prodlwh.

    IF iv_show_wh_only EQ 'X'.
      IF it_ptind_range IS NOT INITIAL.
        DELETE lt_prodlwh WHERE ptdetind NOT IN it_ptind_range.
      ENDIF.

      IF it_pcind_range IS NOT INITIAL.
        DELETE lt_prodlwh WHERE put_stra NOT IN it_pcind_range.
      ENDIF.

      IF it_rmind_range IS NOT INITIAL.
        DELETE lt_prodlwh WHERE rem_stra NOT IN it_rmind_range.
      ENDIF.

      IF it_ccind_range IS NOT INITIAL.
        DELETE lt_prodlwh WHERE ccind NOT IN it_ccind_range.
      ENDIF.

      IF it_rng_sign01 IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_hmsign01_whd NOT IN it_rng_sign01.
      ENDIF.
      IF it_rng_sing01 IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_hmsingle01_whd NOT IN it_rng_sing01.
      ENDIF.
      IF it_rng_box01  IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_hmbox01_whd NOT IN it_rng_box01.
      ENDIF.
      IF it_rng_sign02 IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_hmsign02_whd NOT IN it_rng_sign02.
      ENDIF.
      IF it_rng_sing02 IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_hmsingle02_whd NOT IN it_rng_sing02.
      ENDIF.
      IF it_rng_box02  IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_hmbox02_whd NOT IN it_rng_box02.
      ENDIF.
      IF it_rng_sign03 IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_hmsign03_whd NOT IN it_rng_sign03.
      ENDIF.
      IF it_rng_sing03 IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_hmsingle03_whd NOT IN it_rng_sing03.
      ENDIF.
      IF it_rng_box03  IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_hmbox03_whd NOT IN it_rng_box03.
      ENDIF.
      IF it_rng_twomh IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_twomh_whd NOT IN it_rng_twomh.
      ENDIF.
      IF it_rng_disp  IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_disp_whd NOT IN it_rng_disp.
      ENDIF.
      IF it_rng_noslo IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_noslo_whd NOT IN it_rng_noslo.
      ENDIF.
      IF it_rng_nospo IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_nospo_whd NOT IN it_rng_nospo.
      ENDIF.
      IF it_rng_keepcr IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_keepcar_whd NOT IN it_rng_keepcr.
      ENDIF.
      IF it_rng_fragile IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_fragile_whd NOT IN it_rng_fragile.
      ENDIF.
      IF it_rng_noncnv IS NOT INITIAL.
        DELETE lt_prodlwh WHERE zz1_nonconveyable_whd NOT IN it_rng_noncnv.
      ENDIF.

      IF it_lgbkz_range IS NOT INITIAL.
        DELETE lt_prodlwh WHERE lgbkz NOT IN it_lgbkz_range.
      ENDIF.

      IF ( it_ptind_range IS NOT INITIAL ) OR ( it_pcind_range IS NOT INITIAL )
        OR ( it_rmind_range IS NOT INITIAL ) OR ( it_ccind_range IS NOT INITIAL )
         OR ( it_lgbkz_range IS NOT INITIAL ) .
        lt_matguid = CORRESPONDING #( lt_prodlwh MAPPING matguid = matid EXCEPT matid ).
        mt_mat_nr_id_guid = FILTER #( mt_mat_nr_id_guid IN lt_matguid WHERE matguid = matguid ).
        REFRESH lt_matid.
        MOVE-CORRESPONDING mt_mat_nr_id_guid TO lt_matid.

        lt_sapapo_mattxt = FILTER #( lt_sapapo_mattxt IN lt_matid WHERE matid = matid ).
        lt_sapapo_matpack = FILTER #( lt_sapapo_matpack IN lt_matid WHERE matid = matid ).
        lt_sapapo_matexec = FILTER #( lt_sapapo_matexec IN lt_matid WHERE matid = matid ).
        et_material = FILTER #( et_material IN lt_matid WHERE matid = matid ).
      ENDIF.
    ENDIF.

    SORT et_material BY matid.
    SORT lt_prodlwh BY matid lgnum entitled.
    SORT lt_sapapo_matpack BY matid.
    SORT lt_sapapo_matexec BY matid.
    SORT lt_sapapo_mattxt BY matid.

*   create the output list depending of the option

    me->create_list_of_wh_products(
      EXPORTING
        iv_lgnum          = iv_lgnum
        it_material       = et_material
        it_sapapo_mattxt  = lt_sapapo_mattxt
        it_sapapo_matpack = lt_sapapo_matpack
        it_sapapo_matexec = lt_sapapo_matexec
        it_wh_product     = lt_prodlwh
        iv_selection_mode = lv_selection_mode
      IMPORTING
        et_data           = lt_prod_mon_outtemp ).

* filter output entries, if selection criteria have been entered

    CLEAR lt_where.
    CLEAR lv_where.
    lv_where = ' matnr is not initial ' ##NO_TEXT.

    APPEND lv_where TO lt_where.

    IF it_entit_range  IS INITIAL AND
       it_maktx_range  IS INITIAL AND
       it_matkl_range  IS INITIAL AND
       it_mtart_range IS INITIAL  AND
       it_mmsta_range IS INITIAL  AND
       it_whmgr_range  IS INITIAL AND
       it_qgrp_range   IS INITIAL AND
       it_packgr_range IS INITIAL AND
       it_ptind_range  IS INITIAL AND
       it_pcind_range  IS INITIAL AND
       it_rmind_range  IS INITIAL AND
       it_ccind_range  IS INITIAL AND
       it_lgbkz_range  IS INITIAL AND
       iv_cwrel        IS INITIAL.
      "do nothing
    ELSE.
      IF it_entit_range IS NOT INITIAL.
        lv_where =  ' and ENTITLED in IT_ENTIT_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_maktx_range IS NOT INITIAL.
        lv_where =  ' and MAKTX in IT_MAKTX_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_matkl_range IS NOT INITIAL.
        lv_where = ' and MATKL in IT_MATKL_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_whmgr_range IS NOT INITIAL.
        lv_where = ' and WHMATGR in IT_WHMGR_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_qgrp_range IS NOT INITIAL.
        lv_where =   ' and QGRP in IT_QGRP_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_mtart_range IS NOT INITIAL.
        lv_where =   ' and MTART in IT_MTART_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_mmsta_range IS NOT INITIAL.
        lv_where =   ' and MMSTA in IT_MMSTA_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_packgr_range IS NOT INITIAL.
        lv_where =  ' and PACKGR in IT_PACKGR_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_ptind_range IS NOT INITIAL.
        lv_where =' and PTDETIND in IT_PTIND_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_pcind_range IS NOT INITIAL.
        lv_where =  ' and PUT_STRA in IT_PCIND_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_rmind_range IS NOT INITIAL.
        lv_where =  ' and REM_STRA in IT_RMIND_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_ccind_range IS NOT INITIAL.
        lv_where =  ' and CCIND in IT_CCIND_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF it_lgbkz_range IS NOT INITIAL.
        lv_where = ' and LGBKZ in IT_LGBKZ_RANGE ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.
      IF iv_cwrel IS NOT INITIAL.
        lv_where =   ' and CWREL EQ IV_CWREL ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.

    ENDIF.

    LOOP AT lt_prod_mon_outtemp ASSIGNING <ls_prod> WHERE (lt_where)  .
      "warehouse data --- Process Block Profile Description
      IF <ls_prod>-procprfl IS NOT INITIAL.
        CALL FUNCTION '/SCWM/TPROCPRFLT_READ_SINGLE'
          EXPORTING
            iv_lgnum      = iv_lgnum
            iv_procprfl   = <ls_prod>-procprfl
          IMPORTING
            es_tprocprflt = ls_tprocprflt
          EXCEPTIONS
            not_found     = 1
            OTHERS        = 2.
        IF sy-subrc = 0.
          MOVE ls_tprocprflt-text TO <ls_prod>-procprflt.
        ENDIF.
      ENDIF.

      "warehouse data --- ProcTypeDet Ind Description
      IF <ls_prod>-ptdetind IS NOT INITIAL.
        CALL FUNCTION '/SCWM/TPTDETINDT_READ_SINGLE'
          EXPORTING
            iv_lgnum      = iv_lgnum
            iv_ptdetind   = <ls_prod>-ptdetind
          IMPORTING
            es_tptdetindt = ls_tptdetindt
          EXCEPTIONS
            not_found     = 1
            OTHERS        = 2.
        IF sy-subrc = 0.
          MOVE ls_tptdetindt-text TO <ls_prod>-ptdetindt.
        ENDIF.
      ENDIF.

      "warehouse data --- prod. load category Description
      IF <ls_prod>-wrkldgr IS NOT INITIAL.
        CALL FUNCTION '/SCWM/TWRKLDGRT_READ_SINGLE'
          EXPORTING
            iv_lgnum     = iv_lgnum
            iv_wrkldgr   = <ls_prod>-wrkldgr
          IMPORTING
            es_twrkldgrt = ls_twrkldgrt
          EXCEPTIONS
            not_found    = 1
            OTHERS       = 2.
        IF sy-subrc = 0.
          MOVE ls_twrkldgrt-text TO <ls_prod>-wrkldgrt.
        ENDIF.
      ENDIF.

      "putaway strategy text
      IF <ls_prod>-put_stra IS NOT INITIAL.
        CLEAR: ls_t305qt.
        CALL FUNCTION '/SCWM/T305QT_READ_SINGLE'
          EXPORTING
            iv_lgnum    = iv_lgnum
            iv_put_stra = <ls_prod>-put_stra
          IMPORTING
            es_t305qt   = ls_t305qt
          EXCEPTIONS
            not_found   = 1
            OTHERS      = 2.
        IF sy-subrc = 0.
          MOVE ls_t305qt-text TO <ls_prod>-put_stra_t.
        ENDIF.
      ENDIF.

      "removal strategy text
      IF <ls_prod>-rem_stra IS NOT INITIAL.
        CLEAR: ls_t305rt.
        CALL FUNCTION '/SCWM/T305RT_READ_SINGLE'
          EXPORTING
            iv_lgnum    = iv_lgnum
            iv_rem_stra = <ls_prod>-rem_stra
          IMPORTING
            es_t305rt   = ls_t305rt
          EXCEPTIONS
            not_found   = 1
            OTHERS      = 2.
        IF sy-subrc = 0.
          MOVE ls_t305rt-rem_strat TO <ls_prod>-rem_stra_t.
        ENDIF.
      ENDIF.

      IF <ls_prod>-kit_fixed_quan IS NOT INITIAL.
        CALL FUNCTION 'DDIF_DOMA_GET'
          EXPORTING
            name      = '/SCWM/DO_KIT_FIXED_QUAN_PROD'
            langu     = lv_langu
          TABLES
            dd07v_tab = lt_kit_fixed
          EXCEPTIONS
            OTHERS    = 1.

        IF sy-subrc = 0.
          READ TABLE lt_kit_fixed WITH KEY domvalue_l = <ls_prod>-kit_fixed_quan INTO ls_kit_fixed.
          IF sy-subrc = 0.
            IF  ls_kit_fixed-ddtext IS NOT INITIAL.
              MOVE ls_kit_fixed-ddtext TO <ls_prod>-kit_fixed_quant.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF <ls_prod>-backflush_prod IS NOT INITIAL.
        CALL FUNCTION 'DDIF_DOMA_GET'
          EXPORTING
            name      = '/SCWM/DO_BACKFLUSH_PROD'
            langu     = lv_langu
          TABLES
            dd07v_tab = lt_backflush
          EXCEPTIONS
            OTHERS    = 1.

        IF sy-subrc = 0.
          READ TABLE lt_backflush WITH KEY domvalue_l = <ls_prod>-backflush_prod INTO ls_backflush.
          IF sy-subrc = 0.
            IF  ls_backflush-ddtext IS NOT INITIAL.
              MOVE ls_backflush-ddtext TO <ls_prod>-backflush_prodt.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF <ls_prod>-sled_bbd EQ abap_true.
        <ls_prod>-sled_expd = abap_false.
      ELSE.
        <ls_prod>-sled_expd = abap_true.
      ENDIF.

      <ls_prod>-shelf_life_dur_iprkz = <ls_prod>-shelf_life_dur.
      <ls_prod>-shlf_lfe_req_min_iprkz = <ls_prod>-shlf_lfe_req_min.

*   STFAC, numc type has to contain 00 for batch processing
      IF <ls_prod>-stfac EQ '  '.
        <ls_prod>-stfac = '00'.
      ENDIF.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <ls_prod>-stfac
        IMPORTING
          output = <ls_prod>-stfac
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc <> 0.
*      Ignore
      ENDIF.

      "Check for warehouse product read authorization
      IF iv_show_non_wh_only = abap_true.
        CALL METHOD mo_isolated_doc->product_authority_check
          EXPORTING
            iv_matnr  = <ls_prod>-ext_matnr
            iv_actvt  = '03'
          IMPORTING
            ev_failed = lv_failed
          CHANGING
            ct_return = lt_return.
      ELSE.
        CALL METHOD mo_isolated_doc->product_authority_check
          EXPORTING
            iv_matnr  = <ls_prod>-ext_matnr
            iv_actvt  = '03'
            iv_lgnum  = mv_lgnum
          IMPORTING
            ev_failed = lv_failed
          CHANGING
            ct_return = lt_return.
      ENDIF.

      IF lv_failed = abap_true.
        CONTINUE.
      ENDIF.

*      CALL FUNCTION '/SAPAPO/MD_AUTHORITY_CORE_CHK'
*        EXPORTING
*          i_check_obj     = gc_auth_matkey "Product
*          i_actvt         = '03'           "Change
*          i_matnr         = <ls_prod>-ext_matnr
*        EXCEPTIONS
*          value_not_found = 1
*          no_authority    = 2
*          OTHERS          = 3.
*
*      IF sy-subrc <> 0.
*        CONTINUE.
*      ENDIF.

      APPEND <ls_prod> TO lt_prod_mon_out.

    ENDLOOP.

    SORT lt_prod_mon_out BY matnr.
    MOVE-CORRESPONDING lt_prod_mon_out TO et_data.

  ENDMETHOD.


  METHOD GET_SCUGUID.
    ev_scuguid = mo_isolated_doc->get_scuguid( iv_lgnum = iv_lgnum ).
  ENDMETHOD.


  METHOD GET_STYP_NODE_DATA.
    CONSTANTS  gc_auth_matkey(3) TYPE c VALUE 'MKY'.

    DATA:
      ls_prod_strg_mon_out TYPE /scwm/s_prod_strg_mon_out,
      lt_prodlwhst         TYPE /sapapo/dm_matlwhst_tab,
      lt_new_records       TYPE /sapapo/dm_matlwhst_tab,
      ls_new_record        TYPE /sapapo/dm_matlwhst,
      lt_prodlwhstmp       TYPE /sapapo/dm_matlwhst_tab,
      lt_prodlwhstid       TYPE /sapapo/dm_matlwhst_id_tab,
      ls_prodlwhstid       TYPE /sapapo/dm_matlwhst_id,
      ls_refdata           TYPE REF TO data,
      lv_where             TYPE string,
      lt_where             TYPE tt_where,
      lt_mat16             TYPE /scwm/tt_matid,
      lv_mat16             TYPE /scmb/mdl_matid,
      lt_matid_matnr       TYPE /scwm/tt_matid_matnr,
      ls_matid_matnr       TYPE /scwm/s_matid_matnr,
      lt_matlwh            TYPE /scwm/tt_prod_mon_out,
      lt_matid_entitid_tmp TYPE tt_matid_entitid,
      lt_data              TYPE /scwm/tt_prod_mon_out,
      lt_matid_tab         TYPE tt_matid,
      ls_exclude           TYPE /sapapo/mat_selflags_str,
      lt_matkey            TYPE TABLE OF /sapapo/matkey_str,
      ls_matlwhst          TYPE /sapapo/dm_matlwhst,
      ls_prodlwhst         TYPE /sapapo/dm_matlwhst,
      ls_matkey_for_con    TYPE /sapapo/matkey_str,
      lv_failed            TYPE abap_bool,
      lt_return            TYPE bapiret2_t.

    FIELD-SYMBOLS:
      <fs_matlwh>       TYPE /scwm/s_prod_mon_out,
      <ls_matlwhst>     TYPE /sapapo/dm_matlwhst,
      <lv_matid>        TYPE any,
      <ls_data>         TYPE any,
      <ls_matkey>       TYPE /sapapo/matkey_str,
      <fs_data>         TYPE /scwm/s_prod_mon_out,
      <fs_prodlwhst_id> TYPE  /sapapo/dm_matlwhst_id,
      <fs_prodlwhst>    TYPE /sapapo/dm_matlwhst.

    DATA(lo_mon_prod) = NEW /scwm/cl_mon_prod( ).

    lo_mon_prod->set_lgnum( iv_lgnum ).
    "==========================================
    CALL METHOD set_lgnum(
      EXPORTING
        iv_lgnum = iv_lgnum ).
    "==========================================


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
*      me->get_prod_node_data(
*        EXPORTING
*          iv_lgnum        = iv_lgnum
*          iv_show_wh_only = abap_true
*          it_matnr_range  = it_matnr_range
*          it_entit_range  = it_entit_range
*          it_maktx_range  = it_maktx_range
*          it_matkl_range  = it_matkl_range
*          it_whmgr_range  = it_whmgr_range
*          it_qgrp_range   = it_qgrp_range
*          it_packgr_range = it_packgr_range
*          it_ptind_range  = it_ptind_range
*          it_pcind_range  = it_pcind_range
*          it_rmind_range  = it_rmind_range
*          it_ccind_range  = it_ccind_range
*          it_lgbkz_range  = it_lgbkz_range
*          it_mtart_range  = it_mtart_range
*          it_mmsta_range  = it_mmsta_range
*          iv_cwrel        = iv_cwrel
*          it_rng_sign01   = it_rng_sign01
*          it_rng_sing01   = it_rng_sing01
*          it_rng_box01    = it_rng_box01
*          it_rng_sign02   = it_rng_sign02
*          it_rng_sing02   = it_rng_sing02
*          it_rng_box02    = it_rng_box02
*          it_rng_sign03   = it_rng_sign03
*          it_rng_sing03   = it_rng_sing03
*          it_rng_box03    = it_rng_box03
*          it_rng_twomh    = it_rng_twomh
*          it_rng_disp     = it_rng_disp
*          it_rng_noslo    = it_rng_noslo
*          it_rng_nospo    = it_rng_nospo
*        IMPORTING
*          et_data         = lt_matlwh ).
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

    CALL METHOD mo_isolated_doc->sapapo_matlwhst_read_multi_2
      EXPORTING
        it_key      = lt_prodlwhstid
      IMPORTING
        et_prodwhst = lt_prodlwhst.
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
*    IF it_rng_keepcr IS NOT INITIAL.
*      APPEND | and ZZ1_KEEPCAR_STT in IT_RNG_KEEPCR | TO lt_where.
*    ENDIF.
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
          CALL METHOD me->quan_convert
            EXPORTING
              iv_matid = lv_mat16
              iv_s_qty = ls_prod_strg_mon_out-repqty_plan
              iv_s_uom = <fs_matlwh>-meins
              iv_d_uom = ls_prod_strg_mon_out-repqty_uom_dsp
            CHANGING
              cv_d_qty = ls_prod_strg_mon_out-repqty_plan.
        ENDIF.

        IF ls_prod_strg_mon_out-maxqty_plan IS NOT INITIAL.
          CALL METHOD me->quan_convert
            EXPORTING
              iv_matid = lv_mat16
              iv_s_qty = ls_prod_strg_mon_out-maxqty_plan
              iv_s_uom = <fs_matlwh>-meins
              iv_d_uom = ls_prod_strg_mon_out-maxqty_uom_dsp
            CHANGING
              cv_d_qty = ls_prod_strg_mon_out-maxqty_plan.
        ENDIF.

        IF ls_prod_strg_mon_out-minqty_plan IS NOT INITIAL.
          CALL METHOD me->quan_convert
            EXPORTING
              iv_matid = lv_mat16
              iv_s_qty = ls_prod_strg_mon_out-minqty_plan
              iv_s_uom = <fs_matlwh>-meins
              iv_d_uom = ls_prod_strg_mon_out-minqty_uom_dsp
            CHANGING
              cv_d_qty = ls_prod_strg_mon_out-minqty_plan.
        ENDIF.

        IF ls_prod_strg_mon_out-repqty IS NOT INITIAL.
          CALL METHOD me->quan_convert
            EXPORTING
              iv_matid = lv_mat16
              iv_s_qty = ls_prod_strg_mon_out-repqty
              iv_s_uom = <fs_matlwh>-meins
              iv_d_uom = ls_prod_strg_mon_out-repqty_uom_dsp
            CHANGING
              cv_d_qty = ls_prod_strg_mon_out-repqty.
        ENDIF.

        IF ls_prod_strg_mon_out-maxqty IS NOT INITIAL.
          CALL METHOD me->quan_convert
            EXPORTING
              iv_matid = lv_mat16
              iv_s_qty = ls_prod_strg_mon_out-maxqty
              iv_s_uom = <fs_matlwh>-meins
              iv_d_uom = ls_prod_strg_mon_out-maxqty_uom_dsp
            CHANGING
              cv_d_qty = ls_prod_strg_mon_out-maxqty.
        ENDIF.

        IF ls_prod_strg_mon_out-minqty IS NOT INITIAL.
          CALL METHOD me->quan_convert
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
        mo_isolated_doc->product_authority_check(
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


  METHOD GET_UOM_NODE_DATA.
    DATA:
      lt_matid_tab         TYPE tt_matid,
      lt_matid_meins       TYPE tt_matid_meins,
      lt_matnr             TYPE /scmb/mdl_matnr_tab,
      lv_langu             TYPE sy-langu,
      ls_requested         TYPE /sapapo/mat_selflags_str,
      ls_exclude           TYPE /sapapo/mat_selflags_str,
      ls_version           TYPE /scmb/mdl_planvrs,
      lv_vrsioid           TYPE ty_loc_vrsioid_str,
      lt_vrsioid           TYPE STANDARD TABLE OF ty_loc_vrsioid_str,
      lv_where             TYPE string,
      lt_where             TYPE tt_where,
      lt_prod_uom_out      TYPE /scwm/tt_prod_uom_mon_out,
      lt_prod_uom_filtered TYPE /scwm/tt_prod_uom_mon_out,
      lt_prod_uom          TYPE /scwm/tt_prod_uom_mon_out,
      ls_prod_uom          TYPE /scwm/s_prod_uom_mon_out,
      lv_meins             TYPE /sapapo/meins,
      lt_entitled          TYPE /scwm/tt_entitled_2,
      ls_matid_by_ent      TYPE ty_matid_by_ent,
      lt_matid_by_ent      TYPE tt_matid_by_ent,
      lt_marm              TYPE /sapapo/marm_tab,
      lt_material          TYPE /sapapo/matkey_out_tab,
      lt_wh_product        TYPE /scwm/tt_prod_mon_out,
      lt_matlwh_id         TYPE /sapapo/dm_matlwh_id_tab,
      ls_matlwh_id         TYPE /sapapo/dm_matlwh_id,
      lv_failed            TYPE abap_bool,
      lt_return            TYPE bapiret2_t.

    FIELD-SYMBOLS:
      <ls_entitled>    TYPE /scwm/de_entitled,
      <ls_matid_meins> TYPE ty_matid_meins,
      <ls_prod_uom>    TYPE /scwm/s_prod_uom_mon_out,
      <fs_wh_product>  TYPE /scwm/s_prod_mon_out,
      <fs_material>    TYPE /sapapo/matkey_out,
      <ls_matid_tab>   TYPE ty_matid.


    CALL METHOD set_lgnum(
      EXPORTING
        iv_lgnum = iv_lgnum ).




    IF it_selected_wh_products IS NOT INITIAL.
      lt_wh_product   = it_selected_wh_products.

      CLEAR ls_exclude.
      ls_exclude-no_satnr         = abap_true.
      ls_exclude-no_matmap        = abap_true.
      ls_exclude-no_mattxt        = abap_true.
      ls_exclude-no_matpack       = abap_true.
      ls_exclude-no_matexec       = abap_true.
      ls_exclude-no_penalty1      = abap_true.
      ls_exclude-no_matvers_head  = abap_true.
      ls_exclude-no_matsbod       = abap_true.
      ls_exclude-no_matrgpt       = abap_true.
      ls_exclude-no_matgroup      = abap_true.
      ls_exclude-no_matinfo       = abap_true.
      ls_exclude-no_matapn        = abap_true.
      ls_exclude-no_rmatp         = abap_true.
      ls_exclude-no_mean          = abap_true.

      CLEAR lt_matid_tab.
      MOVE-CORRESPONDING lt_wh_product TO lt_matid_tab.
      SORT lt_matid_tab BY matid.
      DELETE ADJACENT DUPLICATES FROM lt_matid_tab.

      mo_isolated_doc->sapapo_product_dm_read(
        EXPORTING
          iv_langu      = sy-langu
          is_exclude    = ls_exclude
          it_matid      = lt_matid_tab
          it_matnr      = lt_matnr
        IMPORTING
          et_matkey_out = lt_material
          et_marm       = lt_marm ).


    ELSE.
      CLEAR lt_material.

      CALL METHOD me->get_prod_node_data
        EXPORTING
          iv_lgnum        = iv_lgnum
          iv_uom_include  = abap_true
          it_matnr_range  = it_matnr_range
          it_entit_range  = it_entit_range
          it_maktx_range  = it_maktx_range
          it_matkl_range  = it_matkl_range
          it_mtart_range  = it_mtart_range
          it_mmsta_range  = it_mmsta_range
          it_whmgr_range  = it_whmgr_range
          it_qgrp_range   = it_qgrp_range
          it_packgr_range = it_packgr_range
          it_ptind_range  = it_ptind_range
          it_pcind_range  = it_pcind_range
          it_rmind_range  = it_rmind_range
          it_ccind_range  = it_ccind_range
          it_lgbkz_range  = it_lgbkz_range
          iv_cwrel        = iv_cwrel
        IMPORTING
          et_data         = lt_wh_product
          et_prod_uom     = lt_prod_uom_out
          et_marm         = lt_marm
          et_material     = lt_material.
    ENDIF.


* integrate UOM data from table MARM into the output entries
    IF lt_marm IS NOT INITIAL.
      SORT lt_marm BY matid.

      MOVE-CORRESPONDING lt_marm TO lt_prod_uom.

      CLEAR lt_prod_uom_out.
      SORT lt_material BY   matid.
      LOOP AT lt_prod_uom ASSIGNING <ls_prod_uom>.

*     check authority
        mo_isolated_doc->product_authority_check(
          EXPORTING
            iv_lgnum  = mv_lgnum
            iv_matnr  = <ls_prod_uom>-matnr
            iv_actvt  = '03'           "Display
          IMPORTING
            ev_failed = lv_failed
          CHANGING
            ct_return = lt_return
        ).


        IF NOT lv_failed IS INITIAL.
          CONTINUE.
        ENDIF.

        LOOP AT lt_wh_product ASSIGNING <fs_wh_product> WHERE matid = <ls_prod_uom>-matid.
          <ls_prod_uom>-entitled = <fs_wh_product>-entitled.
          <ls_prod_uom>-matnr = <fs_wh_product>-matnr.

          READ TABLE lt_material  ASSIGNING <fs_material> WITH KEY matid =  <ls_prod_uom>-matid BINARY SEARCH.
          IF sy-subrc = 0.
            <ls_prod_uom>-basme  = <fs_material>-meins.
          ENDIF.

          APPEND <ls_prod_uom> TO lt_prod_uom_out.
        ENDLOOP.
      ENDLOOP.
    ENDIF.




    IF it_meinh_range IS INITIAL AND  it_ty2tq_range IS INITIAL.
      MOVE-CORRESPONDING lt_prod_uom_out TO et_data.
    ELSE.
      CLEAR lt_where.
      CLEAR lv_where.
      lv_where = ' matid is not initial ' ##NO_TEXT.

      APPEND lv_where TO lt_where.

      IF it_meinh_range IS NOT INITIAL.
        lv_where =   ' and meinh in it_meinh_range ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.

      IF it_ty2tq_range IS NOT INITIAL.
        lv_where =   ' and ty2tq in it_ty2tq_range ' ##NO_TEXT.
        APPEND lv_where TO lt_where.
      ENDIF.

      LOOP AT lt_prod_uom_out ASSIGNING <ls_prod_uom> WHERE (lt_where)  .
        MOVE-CORRESPONDING <ls_prod_uom>  TO ls_prod_uom.
        APPEND ls_prod_uom TO lt_prod_uom_filtered.
      ENDLOOP.

      MOVE-CORRESPONDING lt_prod_uom_filtered TO et_data.
    ENDIF.
  ENDMETHOD.


  METHOD INTEGRATE_SAPAPO_DATA.

    DATA:
      ls_sapapo_mattxt  TYPE /sapapo/mattxt_str,
      ls_sapapo_matpack TYPE /sapapo/matpack_str,
      ls_sapapo_matexec TYPE /sapapo/matexec_str,
      ls_mat_nr_id_guid TYPE ty_prod.

    IF it_sapapo_matpack IS NOT INITIAL.
      READ TABLE it_sapapo_matpack
      WITH KEY matid = iv_matid BINARY SEARCH
      INTO ls_sapapo_matpack.
      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING ls_sapapo_matpack
        TO cs_product.                                      "#EC ENHOK
      ENDIF.
    ENDIF.

    IF it_sapapo_matexec IS NOT INITIAL.
      READ TABLE it_sapapo_matexec
      WITH KEY matid = iv_matid BINARY SEARCH
      INTO ls_sapapo_matexec.
      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING ls_sapapo_matexec
        TO cs_product.                                      "#EC ENHOK
      ENDIF.
    ENDIF.

    IF it_sapapo_mattxt IS NOT INITIAL.
      READ TABLE it_sapapo_mattxt
      WITH KEY matid = iv_matid BINARY SEARCH
      INTO ls_sapapo_mattxt.
      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING ls_sapapo_mattxt
        TO cs_product.                                      "#EC ENHOK
      ENDIF.
    ENDIF.

    cs_product-lgnum = iv_lgnum.
  ENDMETHOD.


  METHOD PRODUCT_AUTHORITY_CHECK.
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


  METHOD QUAN_CONVERT.
    DATA: lv_batchid   TYPE /scwm/de_batchid,
          lv_quan_from TYPE  /scwm/de_quantity,
          lv_quan_to   TYPE  /scwm/de_quantity.

    lv_quan_from = iv_s_qty.

    TRY.
        CALL FUNCTION '/SCWM/MATERIAL_QUAN_CONVERT'
          EXPORTING
            iv_matid     = iv_matid
            iv_quan      = lv_quan_from
            iv_unit_from = iv_s_uom
            iv_unit_to   = iv_d_uom
            iv_batchid   = lv_batchid
          IMPORTING
            ev_quan      = lv_quan_to.

        cv_d_qty = lv_quan_to.

      CATCH /scwm/cx_md.
    ENDTRY.
  ENDMETHOD.


  METHOD SET_CUSTOM_SELOPT.
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


  METHOD SET_LGNUM.
    DATA:
      lr_scu_mgr TYPE REF TO /scmb/if_scu_mgr,
      lt_scuguid TYPE /scmb/scuguid_tab,
      lrt_entity TYPE /scmb/toentityref_tab,
      lr_scu     TYPE REF TO /scmb/if_scu.

    IF mv_lgnum IS INITIAL OR iv_lgnum <> mv_lgnum.
      CLEAR mt_entitled.

      mo_isolated_doc->set_lgnum(
        EXPORTING
          iv_lgnum    = iv_lgnum
        IMPORTING
          ev_lgnum    = mv_lgnum
          ev_scuguid  = mv_scuguid
          ev_scu      = mv_scu
          et_entitled = mt_entitled ).
    ENDIF.

    et_entitled_guid = mt_entitled.
    ev_scu = mv_scu.
    ev_scuguid = mv_scuguid.
  ENDMETHOD.


  METHOD UPDATE_LGNUM_MATLWH.
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


  METHOD WH_PROD_MASS_CHANGE.

    DATA: ls_data                   TYPE /scwm/s_prod_mon_out,
          ls_lock_mass_pr           TYPE /sapapo/matkey_lock,
          lt_lock_mass_pr           TYPE tt_lock_mass_pr,
          ls_return                 TYPE bapiret2,
          lt_return                 TYPE bapiret2_t,
          lv_rollback               TYPE abap_bool,
          lt_list_locked_prod       TYPE tt_lock_mass_pr,
          ls_matlwh                 TYPE /sapapo/ext_matlwh,
          lt_matlwh                 TYPE tt_ext_matlwh,
          ls_matlwhx                TYPE /sapapo/ext_matlwhx,
          lt_matlwhx                TYPE tt_ext_matlwhx,
          lv_logsys                 TYPE logsys,
          lv_logqs                  TYPE /sapapo/logqs,
          ls_matlwhst               TYPE /sapapo/ext_matlwhst,
          lt_matlwhst               TYPE tt_ext_matlwhst,
          ls_matlwhstx              TYPE /sapapo/ext_matlwhstx,
          lt_matlwhstx              TYPE tt_ext_matlwhstx,
          lv_lock_failed            TYPE abap_bool,
          lv_authority_check_failed TYPE abap_bool.

    FIELD-SYMBOLS: <fs_matkey>    TYPE /sapapo/ext_matkey,
                   <fs_matlwh>    TYPE /sapapo/ext_matlwh,
                   <fs_matlwhx>   TYPE /sapapo/ext_matlwhx,
                   <fs_matlwhst>  TYPE /sapapo/ext_matlwhst,
                   <fs_matlwhstx> TYPE /sapapo/ext_matlwhstx.

********************
*   Enqueue products
********************

    LOOP AT it_matkey ASSIGNING <fs_matkey>.

      CALL METHOD mo_isolated_doc->enqueue_optimistic
        EXPORTING
          iv_matnr        = <fs_matkey>-ext_matnr
          io_lock_mass_pr = mo_lock_mass_pr
        IMPORTING
          ev_failed       = lv_lock_failed
        CHANGING
          ct_return       = et_return.

      IF NOT lv_lock_failed IS INITIAL.
        CONTINUE.
      ENDIF.

      CLEAR ls_lock_mass_pr.
      ls_lock_mass_pr-mandt = sy-mandt.
      ls_lock_mass_pr-matnr = <fs_matkey>-ext_matnr.
      APPEND ls_lock_mass_pr TO lt_list_locked_prod.
    ENDLOOP.




********************************
*   Warehouse Products to create
********************************
    CLEAR lt_matlwh.
    CLEAR lt_matlwhst.
    CLEAR lt_matlwhx.
    SORT lt_list_locked_prod BY matnr.
    LOOP AT it_matlwh_create ASSIGNING <fs_matlwh>.
*     do not process products that could not be locked
      READ TABLE lt_list_locked_prod WITH KEY matnr = <fs_matlwh>-ext_matnr TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CALL METHOD mo_isolated_doc->product_authority_check
        EXPORTING
          iv_lgnum  = mv_lgnum
          iv_actvt  = '01'           "Create
          iv_matnr  = <fs_matlwh>-ext_matnr
        IMPORTING
          ev_failed = lv_authority_check_failed
        CHANGING
          ct_return = et_return.

      IF NOT lv_authority_check_failed IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE it_matlwhx ASSIGNING <fs_matlwhx> WITH KEY ext_matnr = <fs_matlwh>-ext_matnr
                                                            ext_entity = <fs_matlwh>-ext_entity
                                                            ext_entitled = <fs_matlwh>-ext_entitled  BINARY SEARCH.
      IF sy-subrc = 0.
        APPEND <fs_matlwhx> TO lt_matlwhx.

        CLEAR ls_matlwh.
        MOVE-CORRESPONDING <fs_matlwh> TO ls_matlwh.
        ls_matlwh-method = 'N'.
        APPEND ls_matlwh TO lt_matlwh.
      ELSE.
*       should never happen
        CONTINUE.
      ENDIF.
    ENDLOOP.




********************************
*   Warehouse Products to update
********************************

    LOOP AT it_matlwh_update ASSIGNING <fs_matlwh>.
*     do not process products that could not be locked
      READ TABLE lt_list_locked_prod WITH KEY matnr = <fs_matlwh>-ext_matnr TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CALL METHOD mo_isolated_doc->product_authority_check
        EXPORTING
          iv_lgnum  = mv_lgnum
          iv_actvt  = '02'           "Change
          iv_matnr  = <fs_matlwh>-ext_matnr
        IMPORTING
          ev_failed = lv_authority_check_failed
        CHANGING
          ct_return = et_return.

      IF NOT lv_authority_check_failed IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE it_matlwhx ASSIGNING <fs_matlwhx> WITH KEY ext_matnr = <fs_matlwh>-ext_matnr
                                                            ext_entity = <fs_matlwh>-ext_entity
                                                            ext_entitled = <fs_matlwh>-ext_entitled BINARY SEARCH.
      IF sy-subrc <> 0.
*       should never happen
        CONTINUE.
      ENDIF.

*     update of matlwh
      APPEND <fs_matlwhx> TO lt_matlwhx.

      CLEAR ls_matlwh.
      MOVE-CORRESPONDING <fs_matlwh> TO ls_matlwh.
      ls_matlwh-method = 'C'.
      APPEND ls_matlwh TO lt_matlwh.








*******************************
* storage type data to create
*******************************

      LOOP AT it_matlwhst_create ASSIGNING <fs_matlwhst> WHERE    ext_matnr = <fs_matlwh>-ext_matnr  AND
                                                          ext_entity = <fs_matlwh>-ext_entity AND
                                                          ext_entitled = <fs_matlwh>-ext_entitled.                                                            .
        READ TABLE it_matlwhstx ASSIGNING <fs_matlwhstx> WITH KEY ext_matnr = <fs_matlwhst>-ext_matnr
                                                                  ext_entity = <fs_matlwhst>-ext_entity
                                                                  ext_entitled = <fs_matlwhst>-ext_entitled
                                                                  lgtyp = <fs_matlwhst>-lgtyp BINARY SEARCH.
        IF sy-subrc = 0.
          CALL METHOD mo_isolated_doc->product_authority_check
            EXPORTING
              iv_lgnum  = mv_lgnum
              iv_actvt  = '01'           "Create
              iv_matnr  = <fs_matlwh>-ext_matnr
            IMPORTING
              ev_failed = lv_authority_check_failed
            CHANGING
              ct_return = et_return.

          IF NOT lv_authority_check_failed IS INITIAL.
            CONTINUE.
          ENDIF.

          APPEND <fs_matlwhstx> TO lt_matlwhstx.

          CLEAR ls_matlwhst.
          MOVE-CORRESPONDING <fs_matlwhst> TO ls_matlwhst.
          ls_matlwhst-method = 'N'.
          APPEND ls_matlwhst TO lt_matlwhst.
        ENDIF.
      ENDLOOP.

*******************************
* storage type data to update
*******************************

      LOOP AT it_matlwhst_update ASSIGNING <fs_matlwhst> WHERE    ext_matnr = <fs_matlwh>-ext_matnr  AND
                                                          ext_entity = <fs_matlwh>-ext_entity AND
                                                          ext_entitled = <fs_matlwh>-ext_entitled.                                                            .
        READ TABLE it_matlwhstx ASSIGNING <fs_matlwhstx> WITH KEY ext_matnr = <fs_matlwhst>-ext_matnr
                                                                  ext_entity = <fs_matlwhst>-ext_entity
                                                                  ext_entitled = <fs_matlwhst>-ext_entitled
                                                                  lgtyp = <fs_matlwhst>-lgtyp BINARY SEARCH.
        IF sy-subrc = 0.
          APPEND <fs_matlwhstx> TO lt_matlwhstx.

          CLEAR ls_matlwhst.
          MOVE-CORRESPONDING <fs_matlwhst> TO ls_matlwhst.
          ls_matlwhst-method = 'C'.
          APPEND ls_matlwhst TO lt_matlwhst.
        ENDIF.
      ENDLOOP.

    ENDLOOP. "at warehouse product to update






    IF NOT lt_matlwh IS INITIAL OR NOT lt_matlwhst IS INITIAL.
      CLEAR lt_return.
      CALL METHOD mo_isolated_doc->sapapo_dm_products_maintain
        EXPORTING
          it_ext_matkey       = it_matkey
          it_ext_matkeyx      = it_matkeyx
          it_ext_matlwh       = lt_matlwh
          it_ext_matlwhx      = lt_matlwhx
          it_ext_matlwhst     = lt_matlwhst
          it_ext_matlwhstx    = lt_matlwhstx
          it_list_locked_prod = lt_list_locked_prod
        IMPORTING
          et_return           = lt_return
          ev_abort            = ev_abort.

      APPEND LINES OF lt_return TO et_return.
    ENDIF.

    TRY.
        IF NOT mo_lock_mass_pr IS INITIAL.
          CALL METHOD mo_lock_mass_pr->dequeue
            EXPORTING
              it_master_data_objects = lt_list_locked_prod
              iv_maint_finished      = 'X'.
        ENDIF.
      CATCH /scmb/cx_md_lock_system_error.
    ENDTRY.

    ev_lines = lines( lt_matlwh ).
    ev_lines_st = lines( lt_matlwhst ).
  ENDMETHOD.
ENDCLASS.
