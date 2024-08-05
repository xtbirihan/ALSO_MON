FUNCTION z_mon_prod_strg_mass_change.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IT_DATA) TYPE  /SCWM/TT_PROD_STRG_MON_OUT
*"  EXPORTING
*"     REFERENCE(ET_DATA) TYPE  /SCWM/TT_PROD_STRG_MON_OUT
*"     REFERENCE(EV_RETURNCODE) TYPE  XFELD
*"     REFERENCE(EV_VARIANT) TYPE  VARIANT
*"----------------------------------------------------------------------
**********************************************************************
*& Key           : LH-021223
*& Request No.   : GAP-37-40 – "Additional Product Master Fields”
**********************************************************************
*& Description (short)
*& Copied from /SCWM/PROD_STRG_MASS_CHANGE and added the new customer
*& fields handling
**********************************************************************
  DATA:
    ls_matkey           TYPE /sapapo/ext_matkey,
    lt_matkey           TYPE TABLE OF /sapapo/ext_matkey,
    ls_matkeyx          TYPE /sapapo/ext_matkeyx,
    lt_matkeyx          TYPE TABLE OF /sapapo/ext_matkeyx,
    ls_matlwh           TYPE /sapapo/ext_matlwh,
    lt_matlwh           TYPE TABLE OF /sapapo/ext_matlwh,
    ls_matlwhx          TYPE  /sapapo/ext_matlwhx,
    lt_matlwhx          TYPE TABLE OF /sapapo/ext_matlwhx,
    ls_matlwhst         TYPE /sapapo/ext_matlwhst,
    lt_matlwhst_create  TYPE TABLE OF /sapapo/ext_matlwhst,
    lt_matlwhst_update  TYPE TABLE OF /sapapo/ext_matlwhst,
    ls_matlwhstx        TYPE /sapapo/ext_matlwhstx,
    lt_matlwhstx        TYPE TABLE OF /sapapo/ext_matlwhstx,
    ct_return           TYPE bapiret2_t,
    lv_logsys           TYPE logsys,
    lv_logqs            TYPE /sapapo/logqs,
    lv_error            TYPE boolean,
    lt_return           TYPE bapiret2_t,
    ls_return           TYPE bapiret2,
    lt_return_mass_chge TYPE bapiret2_t,
    ls_data             TYPE /scwm/s_prod_strg_mon_out,
    lr_scu_mgr          TYPE REF TO /scmb/if_scu_mgr,
    lv_entity           TYPE /scmb/oe_entity,
    lv_rollback         TYPE abap_bool,
    lv_status           TYPE abap_bool,
    ls_log              TYPE bal_s_log,
    ls_display_profile  TYPE bal_s_prof,
    lo_log              TYPE REF TO /scwm/cl_log,
    lr_scu              TYPE REF TO /scmb/if_scu,
    lt_scuguid          TYPE /scmb/scuguid_tab,
    lrt_entity          TYPE /scmb/toentityref_tab,
    lv_scuguid          TYPE /scmb/mdl_scuguid,
    lv_lines_create     TYPE int8,
    lv_lines_update     TYPE int8,
    lv_lines            TYPE int8,
    lv_abort            TYPE boolean,
    lv_text_question    TYPE string,
    lv_nswer            TYPE string.
  TYPES:
    BEGIN OF t_mat,
      matnr TYPE /sapapo/matnr,
      matid TYPE /sapapo/matid,
      meins LIKE /sapapo/ext_matkey-meins,
    END OF t_mat.

  DATA:
    lv_answer(1),
    lv_msg           TYPE string,
    ls_matkeyid      TYPE /sapapo/matkey_str,
    lt_matid         TYPE t_mat,
    lv_repqty        TYPE /scwm/de_repqty,
    lv_maxqty        TYPE /scwm/de_maxqty,
    lv_minqty        TYPE /scwm/de_minqty,
    ls_bapiret       TYPE bapiret2,
    lv_upd_fld_count TYPE i,
    lv_msg_count     TYPE i.

  DATA: lv_return            TYPE boolean VALUE ' '.
  DATA: ls_lock_mass_pr      TYPE /sapapo/matkey_lock.
  DATA: lt_lock_mass_pr      TYPE tt_lock_mass_pr.
  DATA: lref_lock_mass_pr          TYPE REF TO /scmb/if_md_lock_mass_maint,
        lo_foreign_lock            TYPE REF TO /scmb/cx_md_lock_foreign_lock,
        lo_system_error            TYPE REF TO /scmb/cx_md_lock_system_error,
        lv_no_st_type_data_entries TYPE abap_bool,
        lv_create_only             TYPE abap_bool.

  CONSTANTS:
    c_qu15_ini_value TYPE /scwm/de_repqty VALUE IS INITIAL,
    c_dec5_ini_value TYPE /scwm/de_splitth VALUE IS INITIAL.

  FIELD-SYMBOLS:
        <return>             TYPE bapiret2.
* Check importing data ------------------------------------------------
* Check if one line was selected at least
  IF lines( it_data ) = 0.
    MESSAGE s002(/scwm/monitor) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  p_mandt2 = sy-mandt.
  p_lgnum2 = iv_lgnum.
  CALL SELECTION-SCREEN '0220' STARTING AT 10 10
                               ENDING AT 130 33.
  IF sy-subrc <> 0.
*   Action was canceled
    RETURN.
  ENDIF.
  p_mandt2 = sy-mandt.
  p_lgnum2 = iv_lgnum.

  CONDENSE p_sectin NO-GAPS.
  CONDENSE p_sectif NO-GAPS.
  CONDENSE p_bintyp NO-GAPS.
  CONDENSE p_bintyf NO-GAPS.
  CONDENSE p_maxfib NO-GAPS.
  CONDENSE p_maxfif NO-GAPS.
  CONDENSE p_binsrc NO-GAPS.
  CONDENSE p_splitp NO-GAPS.
  CONDENSE p_norpln NO-GAPS.
  CONDENSE p_reqqtu NO-GAPS.
  CONDENSE p_minqtu NO-GAPS.
  CONDENSE p_maxqtu NO-GAPS.
  CONDENSE p_rmmqtf NO-GAPS.
  CONDENSE p_res017 NO-GAPS.
  CONDENSE p_quancl NO-GAPS.
  CONDENSE p_quancp NO-GAPS.
  CONDENSE p_seqput NO-GAPS.
  CONDENSE p_seqpuf NO-GAPS.
  CONDENSE p_skippt NO-GAPS.
  CONDENSE p_skippf NO-GAPS.

  IF p_sectin IS INITIAL AND p_res001 EQ abap_false AND
    p_sectif IS INITIAL AND p_res002 EQ abap_false AND
    p_bintyp IS INITIAL AND p_res003 EQ abap_false AND
    p_bintyf IS INITIAL AND p_res004 EQ abap_false AND
    p_maxfib IS INITIAL AND p_res005 EQ abap_false AND
    p_maxfif IS INITIAL AND p_res006 EQ abap_false AND
    p_binsrc IS INITIAL AND p_res007 EQ abap_false AND
    p_splitt IS INITIAL AND p_res008 EQ abap_false AND
    p_splitp IS INITIAL AND p_res009 EQ abap_false AND
    p_norpln IS INITIAL AND p_res010 EQ abap_false AND
    p_repqty IS INITIAL AND p_reqqtu IS INITIAL AND p_res011 EQ abap_false AND
    p_minqty IS INITIAL AND p_minqtu IS INITIAL AND p_res013 EQ abap_false AND
    p_maxqty IS INITIAL AND p_maxqtu IS INITIAL AND p_res015 EQ abap_false AND
    p_rmmqtf IS INITIAL AND p_res017 EQ abap_false AND
    p_permxq IS INITIAL AND p_res018 EQ abap_false AND
    p_quancl IS INITIAL AND p_res019 EQ abap_false AND
    p_quancp IS INITIAL AND p_res020 EQ abap_false AND
    p_seqput IS INITIAL AND p_res021 EQ abap_false AND
    p_seqpuf IS INITIAL AND p_res022 EQ abap_false AND
    p_skippt IS INITIAL AND p_res023 EQ abap_false AND
    p_skippf IS INITIAL AND p_res024 EQ abap_false AND
    p_maxput IS INITIAL AND p_resmpu EQ abap_false AND
    p_dirrpl IS INITIAL AND p_resdrp EQ abap_false.

    CLEAR lv_no_st_type_data_entries.
    LOOP AT it_data INTO ls_data WHERE no_whstdata = 'X'.
      lv_no_st_type_data_entries = abap_true.
      EXIT.
    ENDLOOP.

    IF lv_no_st_type_data_entries IS INITIAL.
*   nothig to change -> return
      RETURN.
    ELSE.
      lv_text_question = TEXT-025.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question         = lv_text_question
          display_cancel_button = abap_false
          popup_type            = 'ICON_MESSAGE_WARNING'
          text_button_1         = TEXT-019
          text_button_2         = TEXT-020
          titlebar              = TEXT-021
        IMPORTING
          answer                = lv_answer
        EXCEPTIONS
          text_not_found        = 1.

      IF sy-subrc <> 0 OR lv_answer = '2'.
        RETURN.
      ELSE.
        lv_create_only = abap_true.
      ENDIF.

      CLEAR lv_answer.
    ENDIF.
  ENDIF.

  CLEAR lv_return.
  PERFORM perform_checks_sto_type_data USING iv_lgnum lv_return.

  IF NOT lv_return IS INITIAL.
    RETURN.
  ENDIF.

*****************************
* retrieve supply chain unit
*****************************

  CALL METHOD mo_prod_service->set_lgnum
    EXPORTING
      iv_lgnum = iv_lgnum
    IMPORTING
      ev_scu   = lv_entity.

*************************************************************
* prepare tables of storage type data to create and to update
*************************************************************
  LOOP AT it_data INTO ls_data.
    CLEAR:  ls_matkey,
            ls_matkeyx,
            ls_matlwh,
            ls_matlwhx,
            ls_matlwhst,
            ls_matlwhstx,
            lv_upd_fld_count.
    lv_upd_fld_count = 0.

    IF lv_create_only = abap_true AND ls_data-no_whstdata IS INITIAL.
      CONTINUE.
    ENDIF.

    MOVE-CORRESPONDING ls_data TO ls_matlwhst  ##ENH_OK.
    ls_matlwhst-ext_matnr      = ls_data-matnr.
    ls_matlwhst-ext_entitled   = ls_data-entitled.
    ls_matlwhst-ext_entity     = lv_entity.

    ls_matlwhstx-ext_matnr     = ls_data-matnr.
    ls_matlwhstx-ext_entitled  = ls_data-entitled.
    ls_matlwhstx-ext_entity    = lv_entity.
    ls_matlwhstx-lgtyp         = ls_data-lgtyp.

    ls_matlwh-ext_matnr        = ls_data-matnr.
    ls_matlwh-ext_entitled     = ls_data-entitled.
    ls_matlwh-ext_entity       = lv_entity.

    ls_matlwhx-ext_matnr       = ls_data-matnr.
    ls_matlwhx-ext_entitled    = ls_data-entitled.
    ls_matlwhx-ext_entity      = lv_entity.

    ls_matkey-ext_matnr        = ls_data-matnr.
    ls_matkey-method           = ''.

    ls_matkeyx-ext_matnr       = ls_data-matnr.

    CLEAR lt_return.

    zcl_mon_prod=>set_params_mass_change(
      iv_dirrpl = p_dirrpl
      iv_resdrp = p_resdrp
      iv_maxput = p_maxput
      iv_resmpu = p_resmpu ).

    DATA(lo_mon_prod_service) = NEW /scwm/cl_mon_prod( ). " new zcl_mon_prod( ).
    PERFORM change_matlwhx_record USING ls_data lo_mon_prod_service
                                  CHANGING lv_upd_fld_count ls_matlwhst ls_matlwhstx ls_matkey ls_matkeyx lt_return.

    lv_error = abap_false.
    LOOP AT lt_return INTO ls_return WHERE
      type = 'E' OR type = 'A'.
      lv_error = abap_true.
      EXIT.
    ENDLOOP.

    IF lv_error IS INITIAL.
      IF ls_data-no_whstdata = 'X'.
        APPEND ls_matlwhst TO lt_matlwhst_create.
      ELSE.
        APPEND ls_matlwhst TO lt_matlwhst_update.
      ENDIF.

      APPEND ls_matlwhstx TO lt_matlwhstx.

      APPEND ls_matlwh TO lt_matlwh.
      APPEND ls_matlwhx TO lt_matlwhx.

      APPEND ls_matkey TO lt_matkey.
      APPEND ls_matkeyx TO lt_matkeyx.
    ELSE.
      APPEND LINES OF lt_return TO lt_return_mass_chge.
    ENDIF.
  ENDLOOP.

  SORT lt_matkey BY ext_matnr.
  SORT lt_matkeyx BY ext_matnr.
  SORT lt_matlwh BY ext_matnr ext_entity ext_entitled.
  SORT lt_matlwhx BY ext_matnr ext_entity ext_entitled.
  SORT lt_matlwhst_create BY ext_matnr ext_entity ext_entitled  lgtyp.
  SORT lt_matlwhst_update BY ext_matnr ext_entity ext_entitled  lgtyp.
  SORT lt_matlwhstx BY ext_matnr ext_entity ext_entitled  lgtyp.

  DELETE ADJACENT DUPLICATES FROM lt_matkey.
  DELETE ADJACENT DUPLICATES FROM lt_matkeyx.
  DELETE ADJACENT DUPLICATES FROM lt_matlwh.
  DELETE ADJACENT DUPLICATES FROM lt_matlwhx.
  DELETE ADJACENT DUPLICATES FROM lt_matlwhst_create.
  DELETE ADJACENT DUPLICATES FROM lt_matlwhst_update.
  DELETE ADJACENT DUPLICATES FROM lt_matlwhstx.
  DESCRIBE TABLE lt_matlwhst_create LINES lv_lines_create.
  DESCRIBE TABLE lt_matlwhst_update LINES lv_lines_update.
  lv_lines = lv_lines_create + lv_lines_update.

* popup about creation of not existing records
  IF NOT lines( lt_matlwhst_create ) IS INITIAL AND gv_display_popup_creation_st = abap_false AND lv_create_only IS INITIAL.
    gv_display_popup_creation_st = abap_true.
    lv_text_question = TEXT-023.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        text_question         = lv_text_question
        display_cancel_button = abap_false
        popup_type            = 'ICON_MESSAGE_WARNING'
        text_button_1         = TEXT-019
        text_button_2         = TEXT-020
        titlebar              = TEXT-021
      IMPORTING
        answer                = lv_answer
      EXCEPTIONS
        text_not_found        = 1.

    IF sy-subrc <> 0 OR lv_answer = '2'.
      RETURN.
    ENDIF.

    CLEAR lv_answer.
  ENDIF.

* pop up about the changed records
  IF lv_lines IS NOT INITIAL.
    MESSAGE w185(/scwm/monitor) WITH lv_upd_fld_count lv_lines INTO lv_msg.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        text_question         = lv_msg
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

  CLEAR lt_return.
  mo_prod_service->wh_prod_mass_change(
    EXPORTING
      it_matkey          = lt_matkey
      it_matkeyx         = lt_matkeyx
      it_matlwh_update   = lt_matlwh
      it_matlwhx         = lt_matlwhx
      it_matlwhst_create = lt_matlwhst_create
      it_matlwhst_update = lt_matlwhst_update
      it_matlwhstx       = lt_matlwhstx
    IMPORTING
      et_return          = lt_return
      ev_abort           = lv_abort
      ev_lines_st        = lv_lines ).

  APPEND LINES OF lt_return TO lt_return_mass_chge.

* Display log
  PERFORM display_final_log USING iv_lgnum lv_abort lt_return_mass_chge lv_lines.

ENDFUNCTION.
