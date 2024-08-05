FUNCTION z_mon_prod_strg_data_mon.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IV_VARIANT) TYPE  VARIANT OPTIONAL
*"     REFERENCE(IV_MODE) TYPE  /SCWM/DE_MON_FM_MODE
*"     REFERENCE(IT_DATA_PARENT) TYPE  /SCWM/TT_PROD_MON_OUT OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_DATA) TYPE  /SCWM/TT_PROD_STRG_MON_OUT
*"     REFERENCE(EV_RETURNCODE) TYPE  XFELD
*"     REFERENCE(EV_VARIANT) TYPE  VARIANT
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
*& Copied from /SCWM/PROD_STRG_DATA_MON and added the new customer
*& fields handling
**********************************************************************
  TYPES:
        tt_matid             TYPE STANDARD TABLE OF /sapapo/matid_str .

  DATA:
    lt_matid         TYPE tt_matid,
    lt_matid_entit   TYPE tt_matid_entit,
    lt_matid_entitid TYPE tt_matid_entitid,
*    lo_mon_prod_services TYPE REF TO  zcl_mon_prod,
    lv_repid         TYPE sy-repid,
    lt_mapping       TYPE /scwm/tt_map_selopt2field,
    lv_question      TYPE string,
    lv_selection_ok  TYPE abap_bool,
    lv_answer(1),
    cs_fieldcat      TYPE lvc_s_fcat,
    lv_msg           TYPE string,
    lv_count_styp    TYPE i,
    ls_styp          TYPE /scwm/t301.
  CONSTANTS:
        lc_dynnr             TYPE dynnr VALUE '0200'.

  p_lgnum  = iv_lgnum.
  SET PARAMETER ID '/SCWM/LGN' FIELD iv_lgnum.

  lv_repid = sy-repid.

  lv_repid = sy-repid.
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
  PERFORM storage_type_mapping CHANGING lt_mapping.

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
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      DISPLAY LIKE 'S'.
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

*   the 3 selection parameters may have been changed before by the user....here we keep his choice.
    IF NOT g_nonwh2 IS INITIAL.
      CLEAR p_whonl2.
      p_nonwh2 = g_nonwh2.
      CLEAR p_whbot2.
    ENDIF.
    IF NOT g_whbot2 IS INITIAL.
      CLEAR p_whonl2.
      CLEAR p_nonwh2.
      p_whbot2 = g_whbot2.
    ENDIF.
  ENDIF.

  IF it_data_parent IS NOT INITIAL.
    CALL FUNCTION '/SCWM/FILL_SELOPT_BY_KEYS'
      EXPORTING
        iv_repid       = lv_repid
        it_mapping     = lt_mapping
        it_data_parent = it_data_parent.
  ENDIF.

  IF iv_mode = /scwm/cl_wme_monitor_srvc=>c_mode_selexec.
    p_lgnum = iv_lgnum.
*   show selection screen and use the selection criteria entered on
*   the screen. This screen can also be used for definition of a
*   variant (standard functionality of selection-screens)
    lv_selection_ok = abap_false.

    WHILE lv_selection_ok = abap_false.
      CALL SELECTION-SCREEN lc_dynnr STARTING AT 10 10.

      IF sy-subrc IS NOT INITIAL.
        MOVE 'X' TO ev_returncode.
        RETURN.
      ENDIF.

*     check that for additional option 2 or 3, the user entered a storage type
      IF NOT p_whonl2 IS INITIAL OR s_styp-low IS NOT INITIAL.
        lv_selection_ok = abap_true.

*       the 3 selection parameters must be kept in memory to keep the choice of the user
        g_whonl2 = p_whonl2.
        g_nonwh2 = p_nonwh2.
        g_whbot2 = p_whbot2.

*       determine count of provided storage types (multiple selection)
        DESCRIBE TABLE s_styp LINES lv_count_styp.

*       error that only one storage type is allowed
        IF p_whonl2 IS INITIAL AND s_styp-low IS NOT INITIAL AND s_styp-high IS NOT INITIAL.
          MESSAGE s257(/scwm/monitor) DISPLAY LIKE 'E'.
          lv_selection_ok = abap_false.
        ELSEIF p_whonl2 IS INITIAL AND lv_count_styp > 1.
          MESSAGE s257(/scwm/monitor) DISPLAY LIKE 'E'.
          lv_selection_ok = abap_false.
*       check for storage type validity
        ELSEIF p_whonl2 IS INITIAL.
          SELECT SINGLE * FROM /scwm/t301
                          INTO ls_styp
                          WHERE lgnum EQ iv_lgnum
                          AND lgtyp = s_styp-low.
          IF sy-subrc NE 0.
            MESSAGE s256(/scwm/monitor) DISPLAY LIKE 'E'.
            lv_selection_ok = abap_false.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE s256(/scwm/monitor) DISPLAY LIKE 'E'.
        lv_selection_ok = abap_false.
      ENDIF.
    ENDWHILE.
  ENDIF.

  IF s_matnr[] IS INITIAL AND
    s_entit[] IS INITIAL AND
    s_matkl[] IS INITIAL AND
    s_whmgr[] IS INITIAL AND
    s_ptind[] IS INITIAL AND
    s_pcind[] IS INITIAL AND
    s_rmind[] IS INITIAL AND
    s_ccind[] IS INITIAL AND
    p_cwrel IS INITIAL AND
    s_styp[]  IS INITIAL AND
    s_sbtyp[] IS INITIAL.
* no selection criterion of this node has been filled
* => display popup to continue
* Refresh mode
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

  CLEAR et_data.

  NEW zcl_mon_prod( )->get_styp_node_data(
    EXPORTING
      iv_lgnum                = iv_lgnum
      iv_lgtyp                = s_styp-low
      it_matnr_range          = s_matnr[]
      it_entit_range          = s_entit[]
      it_maktx_range          = s_maktx[]
      it_matkl_range          = s_matkl[]
      it_whmgr_range          = s_whmgr[]
      it_mtart_range          = s_mtart[]
      it_mmsta_range          = s_mmsta[]
      it_qgrp_range           = s_qgrp[]
      it_packgr_range         = s_packgr[]
      it_ptind_range          = s_ptind[]
      it_pcind_range          = s_pcind[]
      it_rmind_range          = s_rmind[]
      it_ccind_range          = s_ccind[]
      it_lgbkz_range          = s_lgbkz[]
      iv_cwrel                = p_cwrel
      it_styp_range           = s_styp[]
      it_sbtyp_range          = s_sbtyp[]
      it_selected_wh_products = it_data_parent
      iv_only_with_whst       = p_whonl2
      iv_only_without_whst    = p_nonwh2
      iv_both                 = p_whbot2
      it_rng_sign01           = s_sign01[]
      it_rng_sing01           = s_sing01[]
      it_rng_box01            = s_box01[]
      it_rng_sign02           = s_sign02[]
      it_rng_sing02           = s_sing02[]
      it_rng_box02            = s_box02[]
      it_rng_sign03           = s_sign03[]
      it_rng_sing03           = s_sing03[]
      it_rng_box03            = s_box03[]
      it_rng_twomh            = s_twomh[]
      it_rng_disp             = s_disp[]
      it_rng_noslo            = s_noslo[]
      it_rng_nospo            = s_nospo[]
      it_rng_dirrpl           = s_dirrpl[]
*      it_rng_keepcr           = s_keepcr[]
      it_rng_maxput           = s_maxput[]
    IMPORTING
      et_data                 = et_data ).

  LOOP AT ct_fieldcat INTO cs_fieldcat.
    IF cs_fieldcat-fieldname = 'MATID' OR cs_fieldcat-fieldname = 'MEINS'.
      MOVE 'X' TO cs_fieldcat-tech.
      MODIFY ct_fieldcat FROM cs_fieldcat.
    ENDIF.
    IF cs_fieldcat-fieldname = 'MMSTA'.
      IF go_service->is_classic_option( ) = abap_true.
        MOVE 'X' TO cs_fieldcat-tech.
        MODIFY ct_fieldcat FROM cs_fieldcat.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF et_data IS NOT INITIAL.
    SORT et_data BY matnr entitled lgtyp.
  ENDIF.
ENDFUNCTION.
