FUNCTION z_mon_prod_attr_mass_change.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IT_DATA) TYPE  /SCWM/TT_PROD_MON_OUT
*"  EXPORTING
*"     REFERENCE(ET_DATA) TYPE  /SCWM/TT_PROD_MON_OUT
*"     REFERENCE(EV_RETURNCODE) TYPE  XFELD
*"     REFERENCE(EV_VARIANT) TYPE  VARIANT
*"----------------------------------------------------------------------
**********************************************************************
*& Key           : LH-021223
*& Request No.   : GAP-37-40 – "Additional Product Master Fields”
**********************************************************************
*& Description (short)
*& Copied from /SCWM/PROD_ATTR_MASS_CHANGE and added the new customer
*& fields handling
**********************************************************************
  DATA:
    ls_material                TYPE /sapapo/ext_matkey,
    ls_matkey                  TYPE /sapapo/ext_matkey,
    lt_material                LIKE TABLE OF ls_material,
    lt_matkey                  LIKE TABLE OF ls_matkey,
    ls_matkeyx                 TYPE /sapapo/ext_matkeyx,
    lt_matkeyx                 LIKE TABLE OF ls_matkeyx,
    ct_return                  TYPE bapiret2_t,
    ls_matlwh                  TYPE /sapapo/ext_matlwh,
    ls_matlwh_create           TYPE /sapapo/matlwh,
    lt_matlwh_create           LIKE TABLE OF ls_matlwh,
    lt_matlwh_update           LIKE TABLE OF ls_matlwh,
    lv_logsys                  TYPE logsys,
    lv_logqs                   TYPE /sapapo/logqs,
    ls_matlwhx                 TYPE /sapapo/ext_matlwhx,
    lt_return                  TYPE bapiret2_t,
    ls_return                  TYPE bapiret2,
    lt_matlwhx                 TYPE TABLE OF /sapapo/ext_matlwhx,
    lv_matlwh_flag             TYPE bool VALUE  abap_true,
    ls_data                    TYPE /scwm/s_prod_mon_out,
    ls_matlwhid                TYPE /sapapo/dm_matlwhst_id,
    lt_scuguid                 TYPE /scmb/scuguid_tab,
    lr_scu_mgr                 TYPE REF TO /scmb/if_scu_mgr,
    lr_scu                     TYPE REF TO /scmb/if_scu,
    lrt_entity                 TYPE /scmb/toentityref_tab,
    ls_scu_ids                 LIKE LINE OF gt_scu_ids,
    lv_entity                  TYPE /scmb/oe_entity,
    lv_rollback                TYPE abap_bool,
    lv_lines                   TYPE int8,
    lv_lines_create            TYPE int8,
    lv_lines_update            TYPE int8,
    lv_abort                   TYPE xfeld,
    lv_answer(1),
    lv_msg                     TYPE string,
    lv_status                  TYPE abap_bool,
    ls_log                     TYPE bal_s_log,
    ls_display_profile         TYPE bal_s_prof,
    lo_log                     TYPE REF TO /scwm/cl_log,
    lv_upd_fld_count           TYPE i,
    lv_return                  TYPE boolean,
    ls_lock_mass_pr            TYPE /sapapo/matkey_lock,
    lt_lock_mass_pr            TYPE tt_lock_mass_pr,
    lref_lock_mass_pr          TYPE REF TO /scmb/if_md_lock_mass_maint,
    lo_foreign_lock            TYPE REF TO /scmb/cx_md_lock_foreign_lock,
    lo_system_error            TYPE REF TO /scmb/cx_md_lock_system_error,
    lv_count_no_wh_data        TYPE int8,
    lv_count_no_wh_data_string TYPE string,
    lv_text_question           TYPE string,
    lv_no_wh_data_entries      TYPE abap_bool,
    lv_create_only             TYPE abap_bool.



  FIELD-SYMBOLS:
    <ls_data>     TYPE /scwm/s_prod_mon_out,
    <ls_material> TYPE /sapapo/ext_matkey,
    <return>      TYPE bapiret2.

  CLEAR gt_data.
  APPEND LINES OF it_data TO gt_data.

* Check if one line was selected at least
  IF lines( it_data ) = 0.
    MESSAGE s002(/scwm/monitor) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  p_mandt1 = sy-mandt.
  p_lgnum1 = iv_lgnum.


  IF /scwm/cl_wme_monitor_srvc_ce=>is_cloud_wm( ) = abap_true.
    p_ccindc = p_ccind.
    p_pstrac = p_pstra.
    p_blockc = p_block.
    p_rstrac = p_rstra.
    p_ptdinc = p_ptdind.

    " only fields relevant for Cloud WM
    CALL SELECTION-SCREEN '0123' STARTING AT 10 3.
    p_ccind = p_ccindc.   p_ccires = p_ccirec.
    p_pstra = p_pstrac.   p_pstres = p_pstrec.
    p_block = p_blockc.   p_blores = p_blorec.
    p_rstra = p_rstrac.   p_rstres = p_rstrec.
    p_ptdind = p_ptdinc.  p_ptdres = p_ptdrec.
*   new fields
    p_prprfl = p_prprfc.  p_prpres = p_ppresc.
    p_puomwh = p_puomwc.  p_puores = p_puresc.
    p_lgbkz = p_lgbkzc.   p_lgbres = p_lgresc.
    p_lptyp = p_lptypc.   p_lptres = p_lpresc.
    p_skdtgr = p_sktgrc.  p_skdres = p_skresc.
*    p_l2skr = p_l2skrc.   p_12sres = p_12resc.
    p_drdtgr = p_drdtgc.  p_drdres = p_drresc.

  ELSEIF go_service->is_s4h_stack( ) = abap_true.
* The document batch field of the whse product can not be changed in S4
    CALL SELECTION-SCREEN '0122' STARTING AT 10 3
                                 ENDING AT 130 45.
  ELSE.
    CALL SELECTION-SCREEN '0120' STARTING AT 10 3
                                 ENDING AT 130 45.
  ENDIF.

  IF sy-subrc <> 0.
*   Action was canceled
    RETURN.
  ENDIF.

  p_mandt1 = sy-mandt.
  p_lgnum1 = iv_lgnum.

  MOVE-CORRESPONDING it_data TO lt_material.

  PERFORM condense_parameters.

* check parameters of the selection screen

  CLEAR lv_create_only.
  IF p_prprfl  IS INITIAL AND p_prpres EQ abap_false AND
     p_ptdind  IS INITIAL AND p_ptdres EQ abap_false AND
     p_wkldgr  IS INITIAL AND p_wklres EQ abap_false AND
     p_ccind   IS INITIAL AND p_ccires EQ abap_false AND
     p_ccindf  IS INITIAL AND p_ccindr EQ abap_false AND
     p_bkflpd  IS INITIAL AND p_bkfres EQ abap_false AND
     p_vasvcp  IS INITIAL AND p_vasres EQ abap_false AND
     p_docbth  IS INITIAL AND p_docres EQ abap_false AND
     p_mapfwh  IS INITIAL AND p_mapres EQ abap_false AND
     p_quameh  IS INITIAL AND p_quares EQ abap_false AND
     p_puomwh  IS INITIAL AND p_puores EQ abap_false AND
     "correlation fix: KIT_FIXED_QUAN
     "Inspection interval :  PRFRQ
     "Goods receipt block: SSQSS
     p_pstra   IS INITIAL AND p_pstres EQ abap_false AND
     p_pstraf  IS INITIAL AND p_pstrar EQ abap_false AND
     p_lgbkz   IS INITIAL AND p_lgbres EQ abap_false AND
     p_lptyp   IS INITIAL AND p_lptres EQ abap_false AND
     p_block   IS INITIAL AND p_blores EQ abap_false AND
     p_rstra   IS INITIAL AND p_rstres EQ abap_false AND
     p_rstraf  IS INITIAL AND p_rstrar EQ abap_false AND
     p_skdtgr  IS INITIAL AND p_skdres EQ abap_false AND
     p_l2skr   IS INITIAL AND p_12sres EQ abap_false AND
     p_drdtgr  IS INITIAL AND p_drdres EQ abap_false AND
     p_qgrpwh  IS INITIAL AND p_qgwres EQ abap_false AND
     p_concst  IS INITIAL AND p_conres EQ abap_false AND
     p_demqty  IS INITIAL AND p_demres EQ abap_false AND
     p_dmqtyf  IS INITIAL AND p_dmqtyr EQ abap_false AND
     p_nosoi   IS INITIAL AND p_nosres EQ abap_false AND
     p_nosoif  IS INITIAL AND p_nosoir EQ abap_false AND
     p_rsqty   IS INITIAL AND p_rsqres EQ abap_false AND
     p_rsqtyf  IS INITIAL AND p_rsqtyr EQ abap_false AND
     p_demtyp  IS INITIAL AND p_detres EQ abap_false AND
     p_ratidm  IS INITIAL AND p_ratres EQ abap_false AND
     p_wghtid  IS INITIAL AND p_wghres EQ abap_false AND
     p_wghidf  IS INITIAL AND p_wghidr EQ abap_false AND
     p_volind  IS INITIAL AND p_volres EQ abap_false AND
     p_volidf  IS INITIAL AND p_volidr EQ abap_false AND
     p_lgthid  IS INITIAL AND p_lgtres EQ abap_false AND
     p_lgtidf  IS INITIAL AND p_lgtidr EQ abap_false AND
     p_wdthid  IS INITIAL AND p_wdtres EQ abap_false AND
     p_wdtidf  IS INITIAL AND p_wdtidr EQ abap_false AND
     p_hghtid  IS INITIAL AND p_hghres EQ abap_false AND
     p_hghidf  IS INITIAL AND p_hghidr EQ abap_false AND
     p_twomh   IS INITIAL AND p_twores EQ abap_false AND
     p_disp    IS INITIAL AND p_disres EQ abap_false AND
     p_noslo   IS INITIAL AND p_nosres EQ abap_false AND
     p_nospo   IS INITIAL AND p_nosres EQ abap_false AND
**********************************************************************
    "aahmedov-<17.05.23> - GAP 37&40 keep carton change
 p_keepcr IS INITIAL.
**********************************************************************
*     p_sing01  IS INITIAL AND p_sinres EQ abap_false AND
*     p_box01   IS INITIAL AND p_boxres EQ abap_false AND
*     p_sign02  IS INITIAL AND p_sg2res EQ abap_false AND
*     p_sing02  IS INITIAL AND p_sn2res EQ abap_false AND
*     p_box02   IS INITIAL AND p_bx2res EQ abap_false AND
*     p_sign03  IS INITIAL AND p_sg3res EQ abap_false AND
*     p_sing03  IS INITIAL AND p_sn3res EQ abap_false AND
*     p_box03   IS INITIAL AND p_bx3res EQ abap_false.


    CLEAR lv_no_wh_data_entries.
    LOOP AT it_data INTO ls_data WHERE no_wh_data = 'X'.
      lv_no_wh_data_entries = abap_true.
      EXIT.
    ENDLOOP.

    IF lv_no_wh_data_entries IS INITIAL.
*   nothig to change -> return
      RETURN.
    ELSE.
      lv_text_question = TEXT-024.

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
* check the values entered into the selection screen fields
  PERFORM perform_checks USING iv_lgnum CHANGING lv_return.
  IF lv_return IS NOT INITIAL.
    RETURN.
  ENDIF.
**********************************
* build tables matkey and matkeyx
*********************************
  LOOP AT lt_material ASSIGNING <ls_material>.
    MOVE-CORRESPONDING <ls_material> TO ls_matkey.
    ls_matkey-method   = ''.
    APPEND ls_matkey TO lt_matkey.
    ls_matkeyx-ext_matnr       = <ls_material>-ext_matnr.
    APPEND ls_matkeyx TO lt_matkeyx.
  ENDLOOP.
  IF lt_matkey IS NOT INITIAL.
    SORT lt_matkey BY ext_matnr.
    DELETE ADJACENT DUPLICATES FROM lt_matkey COMPARING ext_matnr.
  ENDIF.
  IF lt_matkeyx IS NOT INITIAL.
    SORT lt_matkeyx BY ext_matnr.
    DELETE ADJACENT DUPLICATES FROM lt_matkeyx COMPARING ext_matnr.
  ENDIF.


*****************************
* retrieve supply chain unit
*****************************

  CALL METHOD mo_prod_service->set_lgnum
    EXPORTING
      iv_lgnum = iv_lgnum
    IMPORTING
      ev_scu   = lv_entity.




************************************************
* build table of wh prod to create and to update
************************************************
  CLEAR lt_matlwh_create.
  CLEAR lt_matlwh_update.
  LOOP AT it_data INTO ls_data WHERE scuguid IS NOT INITIAL.
    IF lv_create_only = abap_true AND ls_data-no_wh_data IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR ls_matlwh.
    CLEAR ls_matlwhx.
    CLEAR lv_upd_fld_count.
    lv_upd_fld_count = 0.


    MOVE-CORRESPONDING ls_data TO ls_matlwh ##ENH_OK.
    ls_matlwh-ext_entitled  = ls_data-entitled.
    ls_matlwh-ext_entity    = lv_entity.

    ls_matlwhx-ext_entitled = ls_data-entitled.
    ls_matlwhx-ext_entity   = lv_entity.
    ls_matlwhx-ext_matnr    = ls_data-ext_matnr.

    zcl_mon_prod=>set_params_mass_change(
      iv_twomh  = p_twomh
      iv_twores = p_twores
      iv_disp   = p_disp
      iv_disres = p_disres
      iv_noslo  = p_noslo
      iv_nosres = p_nosres
      iv_nospo  = p_nospo
      iv_keepcr = p_keepcr ).

    PERFORM change_matlwh_record CHANGING lv_upd_fld_count ls_matlwh ls_matlwhx.

*     Does the warehouse data view exist ?
    IF ls_data-no_wh_data EQ abap_true.
      APPEND ls_matlwh TO lt_matlwh_create.
      APPEND ls_matlwhx TO lt_matlwhx.
    ELSE.
      APPEND ls_matlwh TO lt_matlwh_update.
      APPEND ls_matlwhx TO lt_matlwhx.
    ENDIF.
  ENDLOOP.


  SORT lt_matkey BY ext_matnr.
  SORT lt_matlwh_create BY ext_matnr.
  SORT lt_matlwh_update BY ext_matnr.
  SORT lt_matlwhx BY  ext_matnr  ext_entitled ext_entity.

  DELETE ADJACENT DUPLICATES FROM lt_matkey.
  DELETE ADJACENT DUPLICATES FROM lt_matlwh_create.
  DELETE ADJACENT DUPLICATES FROM lt_matlwh_update.
  DELETE ADJACENT DUPLICATES FROM lt_matlwhx.
  DESCRIBE TABLE lt_matlwh_create LINES lv_lines_create.
  DESCRIBE TABLE lt_matlwh_update LINES lv_lines_update.





* popup about creation of not existing records
  IF NOT lines( lt_matlwh_create ) IS INITIAL AND gv_display_popup_creation = abap_false AND lv_create_only IS INITIAL.
    gv_display_popup_creation = abap_true.
    lv_text_question = TEXT-022.

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



* Pop up about changed records
  lv_lines = lv_lines_create + lv_lines_update.
  IF lv_lines IS NOT INITIAL.
    MESSAGE w184(/scwm/monitor) WITH lv_upd_fld_count lv_lines INTO lv_msg.

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
* Product mass change
  CALL METHOD mo_prod_service->wh_prod_mass_change(
    EXPORTING
      it_matkey        = lt_matkey
      it_matkeyx       = lt_matkeyx
      it_matlwh_create = lt_matlwh_create
      it_matlwh_update = lt_matlwh_update
      it_matlwhx       = lt_matlwhx
    IMPORTING
      et_return        = lt_return
      ev_abort         = lv_abort
      ev_lines         = lv_lines ).


* Display log
  PERFORM display_final_log USING iv_lgnum lv_abort lt_return lv_lines.

ENDFUNCTION.
