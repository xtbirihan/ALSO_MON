FUNCTION z_mon_prod_data_mon.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IV_VARIANT) TYPE  VARIANT OPTIONAL
*"     REFERENCE(IV_MODE) TYPE  /SCWM/DE_MON_FM_MODE DEFAULT '1'
*"  EXPORTING
*"     REFERENCE(EV_RETURNCODE) TYPE  XFELD
*"     REFERENCE(EV_VARIANT) TYPE  VARIANT
*"     REFERENCE(ET_DATA) TYPE  /SCWM/TT_PROD_MON_OUT
*"  CHANGING
*"     REFERENCE(CT_TAB_RANGE) TYPE  RSDS_TRANGE OPTIONAL
*"     REFERENCE(CT_FIELDCAT) TYPE  LVC_T_FCAT OPTIONAL
*"  RAISING
*"      /SCWM/CX_MON_NOEXEC
*"----------------------------------------------------------------------
**********************************************************************
*& Key           : LH-021223
*& Request No.   : GAP-37-40 – "Additional Product Master Fields”
**********************************************************************
*& Description (short)
*& Copied from /SCWM/PROD_DATA_MON and added the new customer
*& fields handling
**********************************************************************
  DATA:
    lv_repid     TYPE sy-repid,
    lt_mapping   TYPE /scwm/tt_map_selopt2field,
    lv_question  TYPE string,
    lv_answer(1).

  FIELD-SYMBOLS: <fs_fieldcat>  TYPE lvc_s_fcat.

  CONSTANTS:
        lc_dynnr            TYPE dynnr VALUE '0100'.



  lv_repid = sy-repid.
* if iv_mode = 3 then only display popup and exit
  IF iv_mode = 3.
    CALL FUNCTION 'RS_VARIANT_CATALOG'
      EXPORTING
        report               = lv_repid
        dynnr                = lc_dynnr
      IMPORTING
        sel_variant          = ev_variant
      EXCEPTIONS
        no_report            = 1
        report_not_existent  = 2
        report_not_supplied  = 3
        no_variants          = 4
        no_variant_selected  = 5
        variant_not_existent = 6
        OTHERS               = 99.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      DISPLAY LIKE 'S'.
    ENDIF.
    RETURN.
  ENDIF.
* initialization
  PERFORM initialization USING lv_repid
                        CHANGING et_data.

  PERFORM prod_mapping CHANGING lt_mapping.

  p_lgnum  = iv_lgnum.
  IF NOT iv_variant IS INITIAL.
*   Use the selection criteria from a pre-defined variant without
*   presenting a selection screen
    CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
      EXPORTING
        report               = lv_repid
        variant              = iv_variant
      EXCEPTIONS
        variant_not_existent = 1
        variant_obsolete     = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      "DISPLAY LIKE 'S'.
    ENDIF.
  ENDIF.

  IF ct_tab_range IS NOT INITIAL.
*   the table it_tab_range contains the selection criteria, which
*   have been passed to the function module
*   these selection criteria should be visible in the selection screen
    CALL FUNCTION '/SCWM/RANGETAB2SELOPT'
      EXPORTING
        iv_repid     = lv_repid
        iv_lgnum     = iv_lgnum
        it_mapping   = lt_mapping
      CHANGING
        ct_tab_range = ct_tab_range.
  ENDIF.

*   the 3 selection parameters may have been changed before by the user....here we keep his choice.
  IF NOT g_nonwh IS INITIAL.
    CLEAR: p_whonly, p_whboth.
    p_nonwh = g_nonwh.
  ENDIF.

  IF NOT g_whboth IS INITIAL.
    CLEAR: p_whonly, p_nonwh.
    p_whboth = g_whboth.
  ENDIF.

  IF NOT g_whonly IS INITIAL.
    CLEAR: p_whboth, p_nonwh.
    p_whonly = g_whonly.
  ENDIF.

  IF iv_mode = 1.
*   show selection screen and use the selection criteria entered on
*   the screen. This screen can also be used for definition of a
*   variant (standard functionality of selection-screens)
    p_lgnum = iv_lgnum.

    "CALL SELECTION-SCREEN lc_dynnr STARTING AT 10 10.
    CALL SELECTION-SCREEN lc_dynnr STARTING AT 10 10
                                   ENDING AT 130 30.
    IF sy-subrc IS NOT INITIAL.
      MOVE 'X' TO ev_returncode.
      RETURN.
    ENDIF.

*   the 3 selection parameters must be kept in memory to keep the choice of the user
    g_whonly = p_whonly.
    g_nonwh = p_nonwh.
    g_whboth = p_whboth.
  ENDIF.

* Check whether selection criteria of the parent nodes are filled
  IF s_matnr[]  IS INITIAL AND
     s_entit[]  IS INITIAL AND
     s_maktx[]  IS INITIAL AND  "description
     s_matkl[]  IS INITIAL AND  "mat group
     s_whmgr[]  IS INITIAL AND  "wh prod group
     s_qgrp[]   IS INITIAL AND  "quality inspection group
     s_packgr[] IS INITIAL AND "packing group
     s_ptind[]  IS INITIAL AND  "prce det ind
     s_pcind[]  IS INITIAL AND  "putaway control ind
     s_rmind[]  IS INITIAL AND  "removla control ind
     s_ccind[]  IS INITIAL AND  "cycle counting ind
     s_lgbkz[]  IS INITIAL AND  "storage section ind
     p_cwrel    IS INITIAL.       "catch weight
* no selection criterion of this node has been filled
* => display popup to continue
    IF iv_mode = /scwm/cl_wme_monitor_srvc=>c_mode_selexec.
      lv_question = TEXT-006. "select might take long
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question         = lv_question
          default_button        = '2'
          display_cancel_button = ' '
          popup_type            = 'ICON_MESSAGE_WARNING'
        IMPORTING
          answer                = lv_answer
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.

      IF sy-subrc <> 0 OR lv_answer = '2'.
        ev_returncode = 'X'.
        RETURN.
      ENDIF.

    ENDIF.
  ENDIF.

  CALL FUNCTION '/SCWM/SELOPT2RANGETAB'
    EXPORTING
      iv_repid     = lv_repid
      it_mapping   = lt_mapping
    IMPORTING
      et_tab_range = ct_tab_range.

  zcl_mon_prod=>set_custom_selopt(
    iv_show_wh_only = p_whonly
    it_rng_sign01  = VALUE #( FOR <la> IN s_sign01 ( CORRESPONDING #( <la> ) ) )
    it_rng_sing01  = VALUE #( FOR <lb> IN s_sing01 ( CORRESPONDING #( <lb> ) ) )
    it_rng_box01   = VALUE #( FOR <lc> IN s_box01  ( CORRESPONDING #( <lc> ) ) )
    it_rng_sign02  = VALUE #( FOR <ld> IN s_sign02 ( CORRESPONDING #( <ld> ) ) )
    it_rng_sing02  = VALUE #( FOR <le> IN s_sing02 ( CORRESPONDING #( <le> ) ) )
    it_rng_box02   = VALUE #( FOR <lf> IN s_box02  ( CORRESPONDING #( <lf> ) ) )
    it_rng_sign03  = VALUE #( FOR <lg> IN s_sign03 ( CORRESPONDING #( <lg> ) ) )
    it_rng_sing03  = VALUE #( FOR <lh> IN s_sing03 ( CORRESPONDING #( <lh> ) ) )
    it_rng_box03   = VALUE #( FOR <li> IN s_box03  ( CORRESPONDING #( <li> ) ) )
    it_rng_twomh   = VALUE #( FOR <lj> IN s_twomh  ( CORRESPONDING #( <lj> ) ) )
    it_rng_disp    = VALUE #( FOR <lk> IN s_disp   ( CORRESPONDING #( <lk> ) ) )
    it_rng_noslo   = VALUE #( FOR <ll> IN s_noslo  ( CORRESPONDING #( <ll> ) ) )
    it_rng_nospo   = VALUE #( FOR <lm> IN s_nospo  ( CORRESPONDING #( <lm> ) ) )
    it_rng_keepcr  = VALUE #( FOR <ln> IN s_keepcr ( CORRESPONDING #( <ln> ) ) )
    it_rng_fragile = VALUE #( FOR <lo> IN s_frag   ( CORRESPONDING #( <lo> ) ) )
    it_rng_noncnv  = VALUE #( FOR <lp> IN s_noncnv ( CORRESPONDING #( <lp> ) ) ) ).

  TRY.
      CLEAR et_data.

      mo_prod_service->get_prod_node_data(
        EXPORTING
          iv_lgnum            = iv_lgnum
          it_matnr_range      = s_matnr[]
          it_mtart_range      = s_mtart[]
          it_mmsta_range      = s_mmsta[]
          it_entit_range      = s_entit[]
          it_maktx_range      = s_maktx[]
          it_matkl_range      = s_matkl[]
          it_whmgr_range      = s_whmgr[]
          it_qgrp_range       = s_qgrp[]
          it_packgr_range     = s_packgr[]
          it_ptind_range      = s_ptind[]
          it_pcind_range      = s_pcind[]
          it_rmind_range      = s_rmind[]
          it_ccind_range      = s_ccind[]
          it_lgbkz_range      = s_lgbkz[]
          iv_cwrel            = p_cwrel
          iv_show_wh_only     = p_whonly
          iv_show_non_wh_only = p_nonwh
          iv_show_every_prod  = p_whboth
        IMPORTING
          et_data             = et_data ).
*      CALL METHOD mo_mon_prod_service->get_prod_node_data
*        EXPORTING
*          iv_lgnum            = iv_lgnum
*          it_matnr_range      = s_matnr[]
*          it_mtart_range      = s_mtart[]
*          it_mmsta_range      = s_mmsta[]
*          it_entit_range      = s_entit[]
*          it_maktx_range      = s_maktx[]
*          it_matkl_range      = s_matkl[]
*          it_whmgr_range      = s_whmgr[]
*          it_qgrp_range       = s_qgrp[]
*          it_packgr_range     = s_packgr[]
*          it_ptind_range      = s_ptind[]
*          it_pcind_range      = s_pcind[]
*          it_rmind_range      = s_rmind[]
*          it_ccind_range      = s_ccind[]
*          it_lgbkz_range      = s_lgbkz[]
*          iv_cwrel            = p_cwrel
*          iv_show_wh_only     = p_whonly
*          iv_show_non_wh_only = p_nonwh
*          iv_show_every_prod  = p_whboth
*          it_rng_sign01       = s_sign01[]
*          it_rng_sing01       = s_sing01[]
*          it_rng_box01        = s_box01[]
*          it_rng_sign02       = s_sign02[]
*          it_rng_sing02       = s_sing02[]
*          it_rng_box02        = s_box02[]
*          it_rng_sign03       = s_sign03[]
*          it_rng_sing03       = s_sing03[]
*          it_rng_box03        = s_box03[]
*          it_rng_twomh        = s_twomh[]
*          it_rng_disp         = s_disp[]
*          it_rng_noslo        = s_noslo[]
*          it_rng_nospo        = s_nospo[]
*          it_rng_keepcr       = s_keepcr[]
*          it_rng_fragile      = s_frag[]
*          it_rng_noncnv       = s_noncnv[]
*        IMPORTING
*          et_data             = et_data.

      IF et_data IS NOT INITIAL.
        SORT et_data BY matnr entitled.
      ENDIF.

      LOOP AT ct_fieldcat ASSIGNING <fs_fieldcat>.
        IF <fs_fieldcat>-fieldname = 'MATID' OR <fs_fieldcat>-fieldname = 'EXT_MATNR'.
          <fs_fieldcat>-tech = 'X'.
        ENDIF.
        IF <fs_fieldcat>-fieldname = 'MMSTA'.
          IF go_service->is_classic_option( ) = abap_true.
            <fs_fieldcat>-tech = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDTRY.
ENDFUNCTION.
