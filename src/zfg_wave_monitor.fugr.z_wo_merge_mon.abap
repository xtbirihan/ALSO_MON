FUNCTION z_wo_merge_mon .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IT_DATA) TYPE  STANDARD TABLE
*"----------------------------------------------------------------------
********************************************************************
*& Key          : <TBIRIHAN>-January 17, 2024
*& Request No.  : GAP-063 / GAP-064
*& Original Object: /SCWM/WO_MERGE_MON
********************************************************************
*& Description  :
********************************************************************

  DATA: lv_rc     TYPE char1,
        lv_wcr    TYPE /scwm/twcr-wcr,
        lv_reason TYPE /scwm/treason-reason,
        lv_lines  TYPE sytabix,
        lv_subrc  TYPE sysubrc.
  DATA: ls_who  TYPE /scwm/who,
        ls_head TYPE /lime/pi_head.
  DATA: lt_tanum    TYPE /scwm/tt_tanum,
        lt_who      TYPE /scwm/tt_who,
        lt_whoid    TYPE /scwm/tt_whoid,
        lt_whoid_pi TYPE /scwm/tt_whoid,
        lt_bapiret  TYPE bapirettab.
  FIELD-SYMBOLS: <fs_wo> TYPE any.

  " move WO data to internal table for WO processing
  LOOP AT it_data ASSIGNING <fs_wo>.
    MOVE-CORRESPONDING <fs_wo> TO ls_who.
    " determine whether WTs or PI docs are part of WO
    IF ls_who-flgto IS NOT INITIAL.
      " only WOs of same kind can be merged
      IF lt_whoid_pi IS NOT INITIAL.
        MESSAGE s551(/scwm/who) DISPLAY LIKE 'E'.
        RETURN.
      ELSE.
        APPEND ls_who-who TO lt_whoid.
      ENDIF.
    ELSEIF ls_who-flginv IS NOT INITIAL.
      " only WOs of same kind can be merged
      IF lt_whoid IS NOT INITIAL.
        MESSAGE s551(/scwm/who) DISPLAY LIKE 'E'.
        RETURN.
      ELSE.
        APPEND ls_who-who TO lt_whoid_pi.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lt_whoid IS NOT INITIAL.
    " at least two warehouse orders should be selected
    DESCRIBE TABLE lt_whoid LINES lv_lines.
    IF lv_lines = 0 OR lv_lines < 2.
      MESSAGE s535(/scwm/who) DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    " ask user for WO creation rule
    PERFORM wcr_reason_get USING iv_lgnum gc_get_reason
                        CHANGING lv_wcr lv_reason lv_subrc.
    CHECK lv_subrc IS INITIAL.

    CALL FUNCTION 'Z_WHO_MERGE'
      EXPORTING
        iv_lgnum       = iv_lgnum
        iv_wcr         = lv_wcr
        iv_reason_code = lv_reason
        iv_update      = abap_true
        iv_commit      = abap_true
        iv_simulate    = abap_false
        iv_set_on_hold = abap_false
        it_who         = lt_whoid
      IMPORTING
        et_bapiret     = lt_bapiret
        et_who         = lt_who.

  ELSEIF lt_whoid_pi IS NOT INITIAL.
    " at least two warehouse orders should be selected
    DESCRIBE TABLE lt_whoid_pi LINES lv_lines.
    IF lv_lines = 0 OR lv_lines < 2.
      MESSAGE s535(/scwm/who) DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    " ask user for WO creation rule
    PERFORM wcr_reason_get USING iv_lgnum gc_no_reason
                        CHANGING lv_wcr lv_reason lv_subrc.
    CHECK lv_subrc IS INITIAL.

    " fill header info
    ls_head-lgnum        = iv_lgnum.
    ls_head-process_type = wmegc_scwm.
    " bundle WOs with PI Docs
    CALL FUNCTION '/SCWM/PI_DOCUMENT_BUNDLE'
      EXPORTING
        is_head    = ls_head
        it_who     = lt_whoid_pi
        iv_wcr     = lv_wcr
      IMPORTING
        et_bapiret = lt_bapiret.
  ELSE.
    " both are initial
    MESSAGE s535(/scwm/who) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF lt_bapiret IS NOT INITIAL.
    PERFORM log_display_bapiret USING lt_bapiret.
  ENDIF.
ENDFUNCTION.
