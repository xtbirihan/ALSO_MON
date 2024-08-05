FUNCTION z_who_merge.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IV_WCR) TYPE  /SCWM/DE_WCR OPTIONAL
*"     REFERENCE(IV_REASON_CODE) TYPE  CHAR4 OPTIONAL
*"     REFERENCE(IV_UPDATE) TYPE  XFELD DEFAULT 'X'
*"     REFERENCE(IV_COMMIT) TYPE  XFELD DEFAULT ' '
*"     REFERENCE(IV_SIMULATE) TYPE  XFELD DEFAULT ' '
*"     REFERENCE(IV_SET_ON_HOLD) TYPE  /SCWM/DE_WO_SET_HOLD_STATUS
*"       DEFAULT SPACE
*"     REFERENCE(IT_WHO) TYPE  /SCWM/TT_WHOID
*"  EXPORTING
*"     REFERENCE(EV_SEVERITY) TYPE  BAPI_MTYPE
*"     REFERENCE(ET_BAPIRET) TYPE  BAPIRETTAB
*"     REFERENCE(ET_WHO) TYPE  /SCWM/TT_WHO
*"----------------------------------------------------------------------
********************************************************************
*& Key          : <TBIRIHAN>-January 17, 2024
*& Request No.  : GAP-063 / GAP-064
*& Original Object: /SCWM/WHO_MERGE
********************************************************************
*& Description  :
********************************************************************
  DATA: lv_lines       TYPE sytabix,
        lv_lines1      TYPE sytabix,
        lv_lines2      TYPE sytabix,
        lv_whoid       TYPE /scwm/de_who,
        lv_exclog_hndl TYPE balloghndl,
        lv_mtext       TYPE string,
        lv_severity    TYPE bapi_mtype,
        lv_who_txt     TYPE /scwm/de_who,
        lv_ppp         TYPE xfeld.
  DATA: ls_whoid       TYPE /scwm/s_whoid,
        ls_who_to      TYPE /scwm/s_ordim_o_int,
        ls_who         TYPE /scwm/who,
        ls_change_att  TYPE /scwm/s_to_change_att,
        ls_changed     TYPE /scwm/s_changed,
        ls_range       TYPE rsds_frange,
        ls_selopt      TYPE rsdsselopt,
        ls_bapiret     TYPE bapiret2,
        ls_wrkl        TYPE /scwm/s_wrkl_int,
        ls_to_new      TYPE /scwm/s_ordim_o_int,
        ls_who1        TYPE /scwm/who,
        ls_ewl_message TYPE /scwm/if_api_message=>ys_message ##NEEDED.
  DATA: lt_who_to         TYPE /scwm/tt_ordim_o_int,
        lt_ordim_o        TYPE /scwm/tt_ordim_o,
        lt_open_to        TYPE /scwm/tt_ordim_o,
        lt_conf_to        TYPE /scwm/tt_ordim_c,
        lt_who_new        TYPE /scwm/tt_who_int,
        lt_whohu_new      TYPE /scwm/tt_whohu_int,
        lt_who_orig       TYPE /scwm/tt_who_int,
        lt_whohu          TYPE /scwm/tt_whohu_int,
        lt_to_new         TYPE /scwm/tt_ordim_o_int,
        lt_change_att     TYPE /scwm/tt_to_change_att,
        lt_change_att_int TYPE /scwm/tt_to_change_att_int,
        ls_change_att_int TYPE /scwm/s_to_change_att_int,
        lt_changed        TYPE /scwm/tt_changed,
        lt_changed_int    TYPE /scwm/tt_changed,
        lt_range          TYPE rsds_frange_t,
        lt_bapiret        TYPE bapirettab,
        lt_who_sav        TYPE /scwm/tt_who_int,
        lt_whohu_sav      TYPE /scwm/tt_whohu_int,
        lt_ordim_c        TYPE /scwm/tt_ordim_c,            "#EC NEEDED
        lt_inv            TYPE /scwm/tt_ordim_o_int,        "#EC NEEDED
        lt_to_new1        TYPE /scwm/tt_ordim_o_int,
        lt_to_change      TYPE /scwm/tt_to_change.
  DATA: lo_log         TYPE REF TO /scwm/cl_log.
  FIELD-SYMBOLS: <to>       TYPE /scwm/s_ordim_o_int,
                 <ordim_o>  TYPE /scwm/ordim_o,
                 <fs_who>   TYPE /scwm/s_who_int,
                 <fs_whohu> TYPE /scwm/s_whohu,
                 <to_new1>  TYPE /scwm/s_ordim_o_int.

  CREATE OBJECT lo_log.

  READ TABLE it_who INTO ls_whoid INDEX 1.
  lv_whoid = ls_whoid-who.
  " create exception log entry for start of merge
  WRITE ls_whoid-who TO lv_who_txt.
  MESSAGE i516(/scwm/who) INTO lv_mtext WITH lv_who_txt.
  lo_log->add_message( ).

  TRY.
      " check importing parameters
      IF iv_lgnum IS INITIAL OR
         it_who   IS INITIAL.
        MESSAGE e405(/scwm/who) INTO lv_mtext.
        lo_log->add_message( ).
        RAISE EXCEPTION TYPE /scwm/cx_core.
      ENDIF.

      ls_range-fieldname = 'WHO'.
      ls_selopt-sign = 'I'.
      ls_selopt-option = 'EQ'.
      LOOP AT it_who INTO ls_whoid.
        ls_selopt-low = ls_whoid-who.
        APPEND ls_selopt TO ls_range-selopt_t.
      ENDLOOP.
      APPEND ls_range TO lt_range.
      DATA: lt_whohu2 TYPE  /scwm/tt_whohu_int.
      CALL FUNCTION '/SCWM/WHO_GET'
        EXPORTING
          iv_lgnum    = iv_lgnum
          iv_to       = 'X'
          iv_lock_who = 'X'
          iv_lock_to  = 'X'
          it_whorange = lt_range
        IMPORTING
          et_who      = lt_who_orig
          et_whohu    = lt_whohu2
          et_ordim_o  = lt_ordim_o
          et_ordim_c  = lt_conf_to.
      " -->> this line will be tested to get rid of Z function module tbirihan
      CLEAR: gt_who, gt_whohu.
      APPEND LINES OF lt_who_orig TO gt_who.
      SORT gt_who BY lgnum who.
      APPEND LINES OF lt_whohu2 TO gt_whohu.
      SORT gt_whohu BY lgnum who hukng.
      " --<< this line will be tested to get rid of Z function module tbirihan
      " gt_who = lt_who_orig.
      " check whether WOs contain PI docs
      " => WOs with PI Docs cannot be merged
      READ TABLE lt_who_orig TRANSPORTING NO FIELDS
           WITH KEY flginv = abap_true.
      IF sy-subrc IS INITIAL.
        MESSAGE e549(/scwm/who) INTO lv_mtext.
        lo_log->add_message( ).
        RAISE EXCEPTION TYPE /scwm/cx_core.
      ENDIF.

      " merge of pick, pack and pass WOs is forbidden!
      READ TABLE lt_who_orig ASSIGNING <fs_who>
           WITH KEY type = wmegc_wcr_ppp_sd.
      IF sy-subrc IS INITIAL.
        lv_ppp = abap_true.
      ELSE.
        READ TABLE lt_who_orig ASSIGNING <fs_who>
             WITH KEY type = wmegc_wcr_ppp_ud.
        IF sy-subrc IS INITIAL.
          lv_ppp = abap_true.
        ENDIF.
      ENDIF.
      IF lv_ppp IS NOT INITIAL.
        WRITE <fs_who>-who TO lv_who_txt.
        MESSAGE e424(/scwm/who) WITH sy-msgv1 INTO lv_mtext.
        lo_log->add_message( ).
        RAISE EXCEPTION TYPE /scwm/cx_core.
      ENDIF.

      " merge of different Higher-Level Warehouse Order is forbidden!
      SORT lt_who_orig DESCENDING BY topwhoid.
      READ TABLE lt_who_orig ASSIGNING <fs_who> INDEX 1.
      IF sy-subrc IS INITIAL AND
         <fs_who>-topwhoid IS NOT INITIAL.
        WRITE <fs_who>-who TO lv_who_txt.
        MESSAGE e431(/scwm/who) WITH sy-msgv1 INTO lv_mtext.
        lo_log->add_message( ).
        RAISE EXCEPTION TYPE /scwm/cx_core.
      ENDIF.

      LOOP AT lt_ordim_o ASSIGNING <ordim_o>.
        MOVE-CORRESPONDING <ordim_o> TO ls_who_to.
        CLEAR: ls_who_to-who, ls_who_to-wcr, ls_who_to-huid.
        APPEND ls_who_to TO lt_who_to.
      ENDLOOP.

      " get SGUID_HU_TOP for open WTs
      PERFORM get_sguid_hu_top USING iv_lgnum
                            CHANGING lt_who_to.

      IF lt_who_to IS INITIAL.
        MESSAGE w403(/scwm/who) INTO lv_mtext.
        lo_log->add_message( ).
      ENDIF.

      " create log entries stating that WHO will be merged
      LOOP AT it_who INTO ls_whoid.
        CLEAR: lt_whohu, lt_open_to.
        WRITE ls_whoid-who TO lv_who_txt.
        READ TABLE gt_who ASSIGNING <fs_who> WITH KEY who = ls_whoid-who
                                             BINARY SEARCH.
        IF sy-subrc <> 0.
          MESSAGE e050(/scwm/who) INTO lv_mtext WITH iv_lgnum ls_whoid-who.
          lo_log->add_message( ).
          RAISE EXCEPTION TYPE /scwm/cx_core.
        ENDIF.
        READ TABLE gt_whohu TRANSPORTING NO FIELDS
                            WITH KEY who = ls_whoid-who
                            BINARY SEARCH.
        LOOP AT gt_whohu ASSIGNING <fs_whohu> FROM sy-tabix.
          IF <fs_whohu>-who <> ls_whoid-who. EXIT. ENDIF.
          APPEND <fs_whohu> TO lt_whohu.
        ENDLOOP.
        LOOP AT lt_ordim_o ASSIGNING <ordim_o>
                           WHERE who = ls_whoid-who.
          APPEND <ordim_o> TO lt_open_to.
        ENDLOOP.
        TRY.
            PERFORM who_delete USING   iv_simulate lt_whohu
                                       lt_open_to lt_conf_to
                               CHANGING <fs_who>.

            MESSAGE i506(/scwm/who) INTO lv_mtext WITH lv_who_txt iv_reason_code.
            lo_log->add_message( ).
          CATCH /scwm/cx_core.
            lo_log->add_message( ).
            RAISE EXCEPTION TYPE /scwm/cx_core.
        ENDTRY.
      ENDLOOP.

      " check whether one of the TOs has a source resource
      " if so, the warehouse order created has to contain
      " this resource
      " by moving this resource into the field PRSRC of
      " the TO this could be achieved (PRSRC = SRSRC)
      LOOP AT lt_who_to ASSIGNING <to> WHERE srsrc IS NOT INITIAL.
        EXIT.
      ENDLOOP.
      IF sy-subrc IS INITIAL.
        " enter resource in WHO
        MOVE: <to>-srsrc TO <to>-prsrc.
        " create protocol entry for pre-assigned resource
        MESSAGE i053(/scwm/who) INTO lv_mtext WITH <to>-prsrc.
        lo_log->add_message( ).
      ENDIF.
      UNASSIGN <to>.

      " create exception log entry for start of WCR
      DESCRIBE TABLE lt_who_to LINES lv_lines.
      MESSAGE i517(/scwm/who) INTO lv_mtext WITH lv_lines.
      lo_log->add_message( ).

      lt_who_sav = gt_who.
      lt_whohu_sav = gt_whohu.

      gs_data-who_change = 'X'.

      " clear WO buffer to prevent duplicate entries
      CLEAR: gt_who, gt_whohu.

      " fill field WCR in LT_WHO_TO if predefined in WPT of WT
      IF iv_wcr IS INITIAL.
        PERFORM split_merge_wpt_wcr_det USING iv_lgnum
                                     CHANGING lt_who_to.
      ENDIF.

      PERFORM get_bin_at CHANGING  lt_who_to.

      CALL FUNCTION '/SCWM/WHO_CREATE'
        EXPORTING
          iv_lgnum       = iv_lgnum
          iv_wcr         = iv_wcr
          iv_set_on_hold = iv_set_on_hold
          it_to          = lt_who_to
        IMPORTING
          et_to          = lt_to_new
          et_who         = lt_who_new
          et_whohu       = lt_whohu_new
        EXCEPTIONS
          input_error    = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_mtext.
        lo_log->add_message( ).
        RAISE EXCEPTION TYPE /scwm/cx_core.
      ELSE.
        DESCRIBE TABLE lt_to_new LINES lv_lines1.
        DESCRIBE TABLE lt_who_to LINES lv_lines2.
        CLEAR: gt_who, gt_whohu.
        gt_who = lt_who_sav.
        gt_whohu =  lt_whohu_sav.
        " add created WOs to log
        PERFORM add_created_wos2log USING lt_who_new lt_to_new
                                          lo_log.
      ENDIF.

      " check relevance for subsystem settings
      CLEAR lt_to_new1.
      LOOP AT lt_to_new ASSIGNING <to_new1>.
        READ TABLE lt_who_new INTO ls_who1 WITH KEY
                                   who = <to_new1>-who.
        IF sy-subrc = 0.
          IF ls_who1-status = space.
            <to_new1>-action = wmegc_to_activate.
            APPEND <to_new1> TO lt_to_new1.
          ELSE.
            APPEND <to_new1> TO lt_to_new1.
          ENDIF.
        ENDIF.
      ENDLOOP.
      PERFORM check_subsystem_rel USING iv_lgnum
                                        lt_whohu_new
                                        lt_who_new
                                        lt_to_new.

      SORT lt_who_to BY lgnum tanum.

      " change destination + prces + procs Andriyan Yordanov 13.10.2023
      lcl_storage_cntr_set_wt_dest=>change_wt_dest_str_control(
        EXPORTING
          iv_lgnum     = iv_lgnum
        IMPORTING
          et_to_change = lt_to_change
        CHANGING
          ct_to        = lt_to_new ).
      " end ANdriyan Yordanov

      " change destination Andriyan Yordanov 13.10.2023
      IF lt_to_change IS NOT INITIAL.
        " we should change destination of the task
        CALL FUNCTION '/SCWM/TO_CHANGE'
          EXPORTING
            iv_lgnum       = iv_lgnum
            iv_qname       = sy-uname
            iv_update_task = abap_false
            iv_commit_work = abap_false
            it_change      = lt_to_change
          IMPORTING
            ev_severity    = lv_severity.
      ENDIF.
      " end Andriyan Yordanov

      " update TOs with new WHO number
      LOOP AT lt_to_new ASSIGNING <to>.
        " ---> added by tbirihan 21.06.2023
        " Basing on the previous new internal table we should skip the APPEND instruction
        " (or put a CONTINUE statement at the beginning of the loop) in case the current WT <to>-tanum is one of the new created ones.
        READ TABLE lt_who_to WITH KEY lgnum = <to>-lgnum
                                      tanum = <to>-tanum
                             TRANSPORTING NO FIELDS
                             BINARY SEARCH.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
        " ---<< added by tbirihan 21.06.2023
        MOVE: 'WHO'       TO ls_changed-fieldname,
              <to>-who    TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed.
        MOVE: 'HUID'      TO ls_changed-fieldname,
              <to>-huid   TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed.
        MOVE: 'WHOSEQ'    TO ls_changed-fieldname,
              <to>-whoseq TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed.
        MOVE: 'WCR'       TO ls_changed-fieldname,
              <to>-wcr    TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed.
        MOVE: 'QUEUE'     TO ls_changed-fieldname,
              <to>-queue  TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed.
        MOVE: 'DLOGPOS_EXT_WT'     TO ls_changed-fieldname,
               <to>-dlogpos_ext_wt TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed.
        MOVE: 'DSTGRP'             TO ls_changed-fieldname,
               <to>-dstgrp         TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed.
        MOVE: 'PRCES'              TO ls_changed-fieldname, " added update PRces + prcocs
               <to>-prces          TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed_int.
        " Start: 2023/10/24 BSUGAREV - Update tasks dimenstions
        MOVE: 'SHIPHUID'      TO ls_changed-fieldname,
              <to>-shiphuid   TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed_int.

        MOVE: 'WEIGHT'        TO ls_changed-fieldname,
               <to>-weight    TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed_int.

        MOVE: 'UNIT_W'        TO ls_changed-fieldname,
               <to>-unit_w    TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed_int.

        MOVE: 'VOLUM'         TO ls_changed-fieldname,
               <to>-volum     TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed_int.

        MOVE: 'UNIT_V'        TO ls_changed-fieldname,
               <to>-unit_v    TO ls_changed-value_c.
        APPEND ls_changed TO lt_changed_int.
        " End: 2023/10/24 BSUGAREV

        "handle potential EEW fields
        PERFORM to_change_check_eew_fields USING <to> lt_who_to
                                        CHANGING lt_changed.

        MOVE: <to>-tanum  TO ls_change_att-tanum,
              lt_changed TO ls_change_att-tt_changed.
        APPEND ls_change_att TO lt_change_att.


        ls_change_att_int-tanum = <to>-tanum.
        APPEND LINES OF lt_changed_int TO ls_change_att_int-tt_changed.
        APPEND ls_change_att_int TO lt_change_att_int.

        CLEAR: ls_change_att, ls_changed, lt_changed, ls_change_att_int,
               lt_changed_int.
      ENDLOOP.
      SET UPDATE TASK LOCAL.
      CALL FUNCTION '/SCWM/TO_CHANGE_ATT'
        EXPORTING
          iv_lgnum       = iv_lgnum
          iv_simulate    = iv_simulate
          iv_update_task = 'X'
          iv_commit_work = space
          it_change_att  = lt_change_att
        IMPORTING
          et_bapiret     = lt_bapiret
          ev_severity    = lv_severity.
      IF lt_bapiret IS NOT INITIAL.
        DELETE lt_bapiret WHERE type CN 'EAX'.
        IF lines( lt_bapiret ) > 0.
          READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<fs_bapiret>) INDEX 1.
          "add error message to log (e.g. in case of missing authority)
          MESSAGE ID <fs_bapiret>-id TYPE <fs_bapiret>-type NUMBER <fs_bapiret>-number
                  WITH <fs_bapiret>-message_v1 <fs_bapiret>-message_v2
                       <fs_bapiret>-message_v3 <fs_bapiret>-message_v4
                  INTO lv_mtext.
          lo_log->add_message( ).
        ENDIF.
        MESSAGE e406(/scwm/who) WITH lv_whoid INTO lv_mtext.
        lo_log->add_message( ).
        RAISE EXCEPTION TYPE /scwm/cx_core.
      ENDIF.

      GET TIME STAMP FIELD DATA(lv_tstmp).

      LOOP AT lt_change_att_int ASSIGNING FIELD-SYMBOL(<ls_hcnage_proc>).
        <ls_hcnage_proc>-seqno = sy-tabix.
      ENDLOOP.

      CALL FUNCTION '/SCWM/TO_CHANGE_ATT_UPD' IN UPDATE TASK
        EXPORTING
          iv_lgnum  = iv_lgnum
          iv_tstmp  = lv_tstmp
          it_change = lt_change_att_int.

      LOOP AT lt_who_new ASSIGNING <fs_who>.
        MOVE-CORRESPONDING <fs_who> TO ls_who.
        APPEND ls_who TO et_who.
      ENDLOOP.
    CATCH /scwm/cx_core.
      MESSAGE e404(/scwm/who) WITH lv_whoid INTO lv_mtext.
      lo_log->add_message( ).
      " dequeue
      LOOP AT it_who INTO ls_whoid.
        CALL FUNCTION 'DEQUEUE_/SCWM/EWHO'
          EXPORTING
            lgnum = iv_lgnum
            who   = ls_whoid-who.
      ENDLOOP.
      CALL FUNCTION '/SCWM/WHO_INIT'.

      CALL FUNCTION '/SCWM/HUMAIN_REFRESH'.

      ROLLBACK WORK.

      et_bapiret  = lo_log->get_prot( ).
      ev_severity = lo_log->get_severity( ).
      PERFORM who_save_exception_log USING iv_lgnum lv_whoid lo_log.
      RETURN.
  ENDTRY.

  " dequeue
  IF NOT iv_simulate IS INITIAL.
    LOOP AT it_who INTO ls_whoid.
      CALL FUNCTION 'DEQUEUE_/SCWM/EWHO'
        EXPORTING
          lgnum = iv_lgnum
          who   = ls_whoid-who.
      CALL FUNCTION '/SCWM/WHO_INIT'.
    ENDLOOP.

    "return log and severity but do not save it when simulating
    et_bapiret  = lo_log->get_prot( ).
    ev_severity = lo_log->get_severity( ).
    RETURN.
  ENDIF.

  " save the log and filling exporting parameters
  CHECK NOT iv_update IS INITIAL.

  et_bapiret  = lo_log->get_prot( ).
  ev_severity = lo_log->get_severity( ).
  PERFORM who_save_exception_log USING iv_lgnum lv_whoid lo_log.

  " update labour management data
  IF gt_who IS NOT INITIAL.
    CLEAR: lt_ordim_o, lt_ordim_c.
    LOOP AT gt_who ASSIGNING <fs_who> WHERE updkz = 'D'.
      PERFORM wrkl_who_update USING wmegc_wrkl_delete
                                    lt_ordim_o
                                    lt_ordim_c
                                    lt_inv
                                    abap_false
                           CHANGING <fs_who>
                                    ls_wrkl
                                    ls_ewl_message.
    ENDLOOP.
  ENDIF.

  APPEND LINES OF lt_who_new TO gt_who.
  APPEND LINES OF lt_whohu_new TO gt_whohu.
  SORT gt_who BY lgnum who.
  SORT gt_whohu BY lgnum who hukng.
  IF NOT lt_whohu_new IS INITIAL.
    /scwm/cl_wm_packing=>set_data_changed( ).
    gs_data-save_pack = 'X'.
  ENDIF.
  " tables should be sorted as new WHO must have bigger number
  PERFORM who_db_update.
  CHECK NOT iv_commit IS INITIAL.
  COMMIT WORK.
  /scwm/cl_tm=>cleanup( ).
ENDFUNCTION.
