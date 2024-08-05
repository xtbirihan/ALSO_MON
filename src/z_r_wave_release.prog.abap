*&---------------------------------------------------------------------*
*& Report  /SCWM/R_WAVE_RELEASE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
**********************************************************************
*& Request No.   : TE1K900125 Main Request / GAP-062
*& Author        : Tugay Birihan
*& e-mail        : tugay.birihan@qinlox.com
*& Module Cons.  : Sevil Rasim
*& Date          : 06.04.2023
**********************************************************************
*& Description (short)
*& Standard report '/SCWM/R_WAVE_RELEASE' copied to new report 'Z_R_WAVE_RELEASE'
*& During background procesing do not use standard if rough bin determination and replenishment is needed:
*& 1-Report name changed in badi /SCWM/EX_WAVE_SAVE
**********************************************************************

REPORT  z_r_wave_release.

DATA: lt_wave_no  TYPE /scwm/tt_wave_no,
      lt_bapiret  TYPE bapiret2_t,
      lt_bapiret2 TYPE bapiret2_t,
      lt_log      TYPE bapiret2_t.

DATA: ls_wave_no TYPE /scwm/s_wave_no.

DATA: lv_wave                 TYPE /scwm/de_wave,
      lv_rdoccat              TYPE /scwm/de_doccat,
      lv_parameter_1          TYPE symsgv,
      lv_parameter_2          TYPE symsgv,
      lv_msgtext              TYPE bapi_msg ##NEEDED,
      lv_lock_error           TYPE xfeld,
      lv_check_for_jobs       TYPE boole_d,
      lv_release_wave         TYPE boole_d VALUE abap_true,
      lv_waiting_time         TYPE i VALUE 1,
      lv_waiting_time_text(2) TYPE c,
      lt_release_jobs         TYPE /scwm/tt_wave_release_job.

DATA: lo_tm_trace TYPE REF TO /scwm/if_tm_trace,
      lo_tm       TYPE REF TO /scwm/if_tm.

FIELD-SYMBOLS: <bapiret> TYPE bapiret2.

START-OF-SELECTION.

  PARAMETERS: p_lgnum TYPE /scwm/lgnum.

  SELECT-OPTIONS: s_wave FOR lv_wave MATCHCODE OBJECT /scwm/sh_wave.

  PARAMETERS: p_first  TYPE xfeld,
              p_second TYPE xfeld.

END-OF-SELECTION.

  ls_wave_no-lgnum = p_lgnum.

  SELECT wave rdoccat FROM /scwm/wavehdr INTO (lv_wave, lv_rdoccat)
    WHERE lgnum =  p_lgnum AND
          wave  IN s_wave.
    ls_wave_no-lgnum = p_lgnum.
    ls_wave_no-wave = lv_wave.

    APPEND ls_wave_no TO lt_wave_no.

  ENDSELECT.

  IF sy-subrc = 0.

* Set TM Trace values
    CLEAR: lv_parameter_1, lv_parameter_2.

    TRY.

*   TM Trace - Initialization
        IF lo_tm_trace IS NOT BOUND.

*     The database table /SCWM/TRACE_ACT does not have any foreign keys
*     -> therefore we agreed with Katrin Kraemer that the warehouse
*     number can be set to *** in case of multiple warehouse number
*     processings in one transaction!
          IF lo_tm IS NOT BOUND.
            IF p_lgnum IS NOT INITIAL.
              lo_tm ?= /scwm/cl_tm_factory=>get_service(
                /scwm/cl_tm_factory=>sc_manager ).
              lo_tm->set_whno( iv_whno = p_lgnum ).
              lo_tm->start_transaction( ).
            ENDIF.
          ENDIF.

          lo_tm_trace ?= /scwm/cl_tm_factory=>get_service(
            /scwm/cl_tm_factory=>sc_trace ).
        ENDIF.

*   Proceed in case GO_TM_TRACE is instantiated
        IF lo_tm_trace IS BOUND.

          DESCRIBE TABLE lt_wave_no.
          WRITE sy-tfill TO lv_parameter_1 LEFT-JUSTIFIED.
          CONCATENATE
            'Waves (' lv_parameter_1 ')' INTO lv_parameter_2. "#EC NOTEXT

*     Function/ method &1 called with &2 parameters
          lo_tm_trace->log_event(
            iv_event  = /scwm/if_tm_c=>sc_event_call_function_method
            iv_param2 = '/SCWM/R_WAVE_RELEASE->/SCWM/WAVE_RELEASE_EXT'
            iv_param3 = lv_parameter_2 ).

        ENDIF. " IF go_tm_trace IS BOUND

      CATCH /scwm/cx_tm_factory.
*   Could not instantiate TM_TRACE. TM_TRACE skipped
        MESSAGE ID '/SCWM/WAVE' TYPE 'W' NUMBER '035' INTO lv_msgtext.
    ENDTRY.

    IF sy-batch = abap_true.

      CALL FUNCTION '/SCWM/WAVE_CLEANUP'
        EXPORTING
          iv_lgnum   = p_lgnum
          iv_rdoccat = lv_rdoccat.

      CALL FUNCTION '/SCWM/WAVE_SELECT'
        EXPORTING
          it_wave       = lt_wave_no
          iv_flglock    = 'X'
        IMPORTING
          ev_lock_error = lv_lock_error
          et_bapiret    = lt_bapiret.

      APPEND LINES OF lt_bapiret TO lt_log.

      IF lv_lock_error = abap_true.
        lv_check_for_jobs = abap_true.
      ENDIF.

      "if it is not possible to lock the wave for the automatic release, retry periodically
      "so that the release job doesn't just finish without releasing the wave
      "we only wait for 2 hours (128 minutes to be exact -> 2^7 )
      WHILE lv_lock_error = abap_true AND lv_waiting_time <= 64.

        CLEAR lv_lock_error.
        WRITE lv_waiting_time TO lv_waiting_time_text.
        MESSAGE i217(/scwm/wave) WITH lv_waiting_time_text INTO lv_msgtext.
        APPEND VALUE #( id = '/SCWM/WAVE' type = 'I' number = 217 message_v1 = lv_waiting_time_text )
          TO lt_log.
        WAIT UP TO lv_waiting_time * 60 SECONDS.

        CALL FUNCTION '/SCWM/WAVE_SELECT'
          EXPORTING
            it_wave       = lt_wave_no
            iv_flglock    = 'X'
          IMPORTING
            ev_lock_error = lv_lock_error
            et_bapiret    = lt_bapiret.

        APPEND LINES OF lt_bapiret TO lt_log.

        "lengthen the waiting time in order to keep the system load for polling low.
        "if we already had to wait several minutes it is most probable that a user forgot
        "to unlock the wave in the UI so we just double the time to wait even longer
        lv_waiting_time = lv_waiting_time * 2.

      ENDWHILE.

      IF lv_lock_error = abap_true.
        "finally we were not able to lock the wave after some serious waiting so we give up here
        lv_release_wave = abap_false.
        MESSAGE i218(/scwm/wave) INTO lv_msgtext.
        APPEND VALUE #( id = '/SCWM/WAVE' type = 'I' number = 218 )
          TO lt_log.

      ELSEIF lv_check_for_jobs = abap_true.
        "finally we were able to to lock the wave. however, there might have been some user interaction
        "which made the currently running job obsolete, so we check if there is already a new one
        CALL FUNCTION '/SCWM/WAVE_GET_RELEASE_JOB'
          EXPORTING
            it_waves        = lt_wave_no
          IMPORTING
            et_release_jobs = lt_release_jobs.

        IF lines( lt_release_jobs ) > 0.
          lv_release_wave = abap_false.
          "New release job detected, aborting wave release
          MESSAGE i221(/scwm/wave) INTO lv_msgtext.
          APPEND VALUE #( id = '/SCWM/WAVE' type = 'I' number = 221 )
            TO lt_log.
        ENDIF.
      ENDIF.

      IF lv_release_wave = abap_true.

        CALL FUNCTION 'Z_ROUGH_BIN_DETERMINATION'
          EXPORTING
            iv_lgnum   = p_lgnum
            iv_rdoccat = lv_rdoccat
            it_wave_no = lt_wave_no.

        CALL FUNCTION '/SCWM/WAVE_RELEASE'
          EXPORTING
            it_wave_no = lt_wave_no
            iv_first   = p_first
            iv_second  = p_second
            iv_ldest   = ' '
          IMPORTING
            et_bapiret = lt_bapiret.

        APPEND LINES OF lt_bapiret TO lt_log.

        CALL FUNCTION '/SCWM/WAVE_SAVE'
          EXPORTING
            iv_update_task = abap_false
            iv_commit_work = 'X'
          IMPORTING
            et_bapiret     = lt_bapiret.

        CALL FUNCTION 'Z_REPLENISH_STOCK'
          EXPORTING
            iv_lgnum   = p_lgnum
            iv_rdoccat = lv_rdoccat
            it_wave_no = lt_wave_no
          IMPORTING
            et_bapiret = lt_bapiret2.
        IF lt_bapiret2 IS NOT INITIAL.
          APPEND LINES OF lt_bapiret2 TO lt_bapiret.
        ENDIF.

        CLEAR: lt_bapiret2.
        CALL FUNCTION 'Z_MERGE_LARGE_ORDERS'
          IN BACKGROUND TASK
          AS SEPARATE UNIT
          EXPORTING
            iv_lgnum   = p_lgnum
            iv_rdoccat = lv_rdoccat
            it_wave_no = lt_wave_no.

        CLEAR: lt_bapiret2.
        CALL FUNCTION 'Z_PUTWALL'
          IN BACKGROUND TASK
          AS SEPARATE UNIT
          EXPORTING
            iv_lgnum   = p_lgnum
            iv_rdoccat = lv_rdoccat
            it_wave_no = lt_wave_no.

        COMMIT WORK."background task commit added 06.11.2023
        APPEND LINES OF lt_bapiret TO lt_log.

        LOOP AT lt_log ASSIGNING <bapiret>.
          MESSAGE ID <bapiret>-id
                  TYPE 'I'
                  NUMBER <bapiret>-number
                  WITH <bapiret>-message_v1
                       <bapiret>-message_v2
                       <bapiret>-message_v3
                       <bapiret>-message_v4.

        ENDLOOP.
      ENDIF.
    ELSE.
      CALL FUNCTION '/SCWM/WAVE_RELEASE_EXT'
        EXPORTING
          iv_lgnum       = p_lgnum
          iv_rdoccat     = lv_rdoccat
          it_wave_no     = lt_wave_no
          iv_first       = p_first
          iv_second      = p_second
          iv_ldest       = ' '
          iv_commit_work = 'X'.
    ENDIF.

  ENDIF.
