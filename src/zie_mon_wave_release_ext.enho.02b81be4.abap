"Name: \FU:/SCWM/WAVE_RELEASE_EXT\SE:BEGIN\EI
ENHANCEMENT 0 ZIE_MON_WAVE_RELEASE_EXT.

DATA(lo_wave_release) =  NEW zcl_mon_wave_release_ext( ).
DATA: lt_bapiret_ext  TYPE bapiret2_t,
      lt_ordim_o      TYPE  /scwm/tt_ordim_o_int,
      lt_ordim_o_1st  TYPE  /scwm/tt_ordim_o_int,
      lv_severity_ext TYPE  bapi_mtype.

lo_wave_release->zif_mon_wave_release_ext~before(
  EXPORTING
    iv_lgnum           = iv_lgnum
    iv_rdoccat         = iv_rdoccat
    it_wave_no         = it_wave_no
    it_wave_itm        = it_wave_itm
    iv_first           = iv_first
    iv_second          = iv_second
    iv_squit           = iv_squit
    iv_ldest           = iv_ldest
    iv_bname           = iv_bname
    iv_procty_1st      = iv_procty_1st
    iv_kzgsm           = iv_kzgsm
    iv_kzvol           = iv_kzvol
    iv_kzanb           = iv_kzanb
    iv_set_on_hold     = iv_set_on_hold
    iv_release_single  = iv_release_single
    iv_immediate       = iv_immediate
    iv_update_task     = iv_update_task
    iv_commit_work     = iv_commit_work
    iv_from_simulation = iv_from_simulation
  IMPORTING
    et_ordim_o         = lt_ordim_o
    et_ordim_o_1st     = lt_ordim_o_1st
    et_bapiret         = lt_bapiret_ext
    ev_severity        = lv_severity_ext
).
IF lt_bapiret_ext IS NOT INITIAL.
  APPEND LINES OF lt_bapiret_ext TO et_bapiret.
ENDIF.
ENDENHANCEMENT.
