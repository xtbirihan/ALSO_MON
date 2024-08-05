interface ZIF_MON_WAVE_RELEASE_EXT
  public .

    METHODS before
      IMPORTING
        VALUE(iv_lgnum)           TYPE /scwm/lgnum
        VALUE(iv_rdoccat)         TYPE /scwm/de_doccat
        VALUE(it_wave_no)         TYPE /scwm/tt_wave_no OPTIONAL
        VALUE(it_wave_itm)        TYPE /scwm/tt_wave_itm OPTIONAL
        VALUE(iv_first)           TYPE xfeld OPTIONAL
        VALUE(iv_second)          TYPE xfeld OPTIONAL
        VALUE(iv_squit)           TYPE /scwm/rl03tsquit DEFAULT space
        VALUE(iv_ldest)           TYPE /scwm/lvs_ldest DEFAULT space
        VALUE(iv_bname)           TYPE /scwm/lvs_bname DEFAULT sy-uname
        VALUE(iv_procty_1st)      TYPE /scwm/de_procty_1st DEFAULT space
        VALUE(iv_kzgsm)           TYPE /scwm/rl03tgkzgsm DEFAULT 'X'
        VALUE(iv_kzvol)           TYPE /scwm/rl03tkzvol DEFAULT space
        VALUE(iv_kzanb)           TYPE /scwm/rl03tkzanb DEFAULT space
        VALUE(iv_set_on_hold)     TYPE xfeld OPTIONAL
        VALUE(iv_release_single)  TYPE xfeld OPTIONAL
        VALUE(iv_immediate)       TYPE xfeld OPTIONAL
        VALUE(iv_update_task)     TYPE /scwm/rl03averbu OPTIONAL
        VALUE(iv_commit_work)     TYPE /scwm/rl03acomit OPTIONAL
        VALUE(iv_from_simulation) TYPE xfeld OPTIONAL
      EXPORTING
        VALUE(et_ordim_o)         TYPE /scwm/tt_ordim_o_int
        VALUE(et_ordim_o_1st)     TYPE /scwm/tt_ordim_o_int
        VALUE(et_bapiret)         TYPE bapiret2_t
        VALUE(ev_severity)        TYPE bapi_mtype .

    METHODS after
      IMPORTING
        VALUE(iv_lgnum)           TYPE /scwm/lgnum
        VALUE(iv_rdoccat)         TYPE /scwm/de_doccat
        VALUE(it_wave_no)         TYPE /scwm/tt_wave_no OPTIONAL
        VALUE(it_wave_itm)        TYPE /scwm/tt_wave_itm OPTIONAL
        VALUE(iv_first)           TYPE xfeld OPTIONAL
        VALUE(iv_second)          TYPE xfeld OPTIONAL
        VALUE(iv_squit)           TYPE /scwm/rl03tsquit DEFAULT space
        VALUE(iv_ldest)           TYPE /scwm/lvs_ldest DEFAULT space
        VALUE(iv_bname)           TYPE /scwm/lvs_bname DEFAULT sy-uname
        VALUE(iv_procty_1st)      TYPE /scwm/de_procty_1st DEFAULT space
        VALUE(iv_kzgsm)           TYPE /scwm/rl03tgkzgsm DEFAULT 'X'
        VALUE(iv_kzvol)           TYPE /scwm/rl03tkzvol DEFAULT space
        VALUE(iv_kzanb)           TYPE /scwm/rl03tkzanb DEFAULT space
        VALUE(iv_set_on_hold)     TYPE xfeld OPTIONAL
        VALUE(iv_release_single)  TYPE xfeld OPTIONAL
        VALUE(iv_immediate)       TYPE xfeld OPTIONAL
        VALUE(iv_update_task)     TYPE /scwm/rl03averbu OPTIONAL
        VALUE(iv_commit_work)     TYPE /scwm/rl03acomit OPTIONAL
        VALUE(iv_from_simulation) TYPE xfeld OPTIONAL
      EXPORTING
        VALUE(et_ordim_o)         TYPE /scwm/tt_ordim_o_int
        VALUE(et_ordim_o_1st)     TYPE /scwm/tt_ordim_o_int
        VALUE(et_bapiret)         TYPE bapiret2_t
        VALUE(ev_severity)        TYPE bapi_mtype .
endinterface.
