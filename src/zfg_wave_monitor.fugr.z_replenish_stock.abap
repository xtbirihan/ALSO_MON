FUNCTION z_replenish_stock.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     VALUE(IV_RDOCCAT) TYPE  /SCWM/DE_DOCCAT
*"     VALUE(IT_WAVE_NO) TYPE  /SCWM/TT_WAVE_NO
*"  EXPORTING
*"     VALUE(ET_BAPIRET) TYPE  BAPIRETTAB
*"----------------------------------------------------------------------
**********************************************************************
*& Request No.   : TE1K900125 Main Request / GAP-062
*& Author        : Tugay Birihan
*& e-mail        : tugay.birihan@qinlox.com
*& Module Cons.  : Sevil Rasim
*& Date          : 06.04.2023
**********************************************************************
*& Description (short)
*& Standard monitor does not replenish stock,
*& If replenishment is needed then fill the stocks:
*& 1- this function module is called inside copied standard function modules and program.
**********************************************************************
  DATA:
    lt_wavehdr  TYPE /scwm/tt_wavehdr_int,
    lt_waveitm  TYPE /scwm/tt_waveitm_int,
    lt_bapiret  TYPE bapirettab,
    lv_severity TYPE bapi_mtype.

  DATA:
    lt_repl  TYPE /scwm/tt_repl_int,
    lt_lgtyp TYPE /scwm/tt_lgtyp,
    lt_tap   TYPE /scwm/tt_ltap_vb.

  CALL FUNCTION '/SCWM/WAVE_SELECT_EXT'
    EXPORTING
      iv_lgnum    = iv_lgnum
      iv_rdoccat  = iv_rdoccat
      it_wave     = it_wave_no
    IMPORTING
      et_wavehdr  = lt_wavehdr
      et_waveitm  = lt_waveitm
      et_bapiret  = lt_bapiret
      ev_severity = lv_severity.

  DELETE lt_wavehdr WHERE status NE 'E'.
  IF lt_wavehdr IS INITIAL.
    RETURN.
  ENDIF.

  DATA(lr_wave) = VALUE /scwm/rt_wave( FOR ls_wavehdr IN lt_wavehdr
                                     ( sign   = wmegc_sign_inclusive
                                       option = wmegc_option_eq
                                       low    = ls_wavehdr-wave ) ).
  IF lr_wave IS NOT INITIAL.
    DELETE lt_waveitm WHERE wave NOT IN lr_wave.
  ENDIF.

  IF lt_waveitm IS INITIAL.
    RETURN.
  ENDIF.

  SELECT lgtyp FROM /scwm/trepa INTO TABLE @lt_lgtyp
    WHERE lgnum = @iv_lgnum
      AND str_repl = @wmegc_repl_orderdriven.

  LOOP AT lt_waveitm INTO DATA(ls_waveitm)
       GROUP BY ( wave  = ls_waveitm-wave
                  owner = ls_waveitm-owner
                  size  = GROUP SIZE
                  index = GROUP INDEX )
                ASCENDING
                REFERENCE INTO DATA(group_ref).

    CLEAR: lt_bapiret, lv_severity, lt_repl.

    CALL FUNCTION '/SCWM/REPLENISHMENT_CALC'
      EXPORTING
        iv_lgnum      = iv_lgnum
        iv_str_repl   = wmegc_repl_orderdriven
        iv_entitled   = group_ref->owner
        it_lgtyp      = lt_lgtyp
        it_lgpla      = VALUE /scwm/tt_lgpla( )
        it_matid      = VALUE /scwm/tt_matid( )
        it_psa        = VALUE /scwm/tt_psa( )
        ir_gi_date    = VALUE rseloption( )
        iv_picktime   = VALUE tzntstmps( )
        it_wave       = VALUE /scwm/tt_wave_no( ( lgnum = iv_lgnum wave = group_ref->wave ) )
        iv_nowave_sel = VALUE xfeld( )
        iv_no_min     = VALUE xfeld( )
        iv_use_max    = abap_false
        iv_exceed_max = abap_true
      IMPORTING
        et_repl       = lt_repl
        et_bapiret    = lt_bapiret
        ev_severity   = lv_severity.

    IF lt_bapiret IS NOT INITIAL.
*       Nothing to do
      APPEND LINES OF lt_bapiret TO et_bapiret.
      LOOP AT lt_bapiret ASSIGNING FIELD-SYMBOL(<fs_bapiret2>) WHERE type CA 'EAX'.
        EXIT.
      ENDLOOP.
      IF sy-subrc EQ 0.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF lv_severity CA 'EAX'.
      CONTINUE.
    ENDIF.
    IF lt_repl IS NOT INITIAL.
      CALL FUNCTION '/SCWM/REPLENISHMENT_ADD'
        IMPORTING
          et_tap      = lt_tap
          et_bapiret  = lt_bapiret
          ev_severity = lv_severity
        CHANGING
          ct_repl     = lt_repl.

      LOOP AT lt_bapiret ASSIGNING <fs_bapiret2> WHERE type CA 'EAX'.
        EXIT.
      ENDLOOP.
      IF sy-subrc NE 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.
    IF lt_bapiret IS NOT INITIAL.
      APPEND LINES OF lt_bapiret TO et_bapiret.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
