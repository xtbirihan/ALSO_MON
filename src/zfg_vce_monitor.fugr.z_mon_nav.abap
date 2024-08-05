FUNCTION z_mon_nav.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DOCNO) TYPE  /SCWM/TT_DOCNO
*"----------------------------------------------------------------------

  DATA: lv_lgnum       TYPE /scwm/lgnum,
        lv_monitor     TYPE /scwm/de_monitor,
        ls_opt         TYPE ctu_params,
        ls_bdcdata_fld TYPE bdcdata,
        ls_bdcdata_scr TYPE bdcdata,
        lt_bdcdata     TYPE TABLE OF bdcdata.

  GET PARAMETER ID '/SCWM/LGN' FIELD lv_lgnum.

  zcl_param=>get_parameter(
    EXPORTING
      iv_lgnum     = lv_lgnum
      iv_process   = zif_param_const=>c_zmon_0001
      iv_parameter = zif_param_const=>c_mon_zpack
    IMPORTING
      ev_constant  = DATA(lv_mon_name) ).

  SET PARAMETER ID zif_param_const=>c_monitor FIELD lv_mon_name.

  ls_bdcdata_scr-program  = '/SCWM/R_WME_MONITOR'.
  ls_bdcdata_scr-dynpro   = '0001'.
  ls_bdcdata_scr-dynbegin = abap_true.
  APPEND ls_bdcdata_scr TO lt_bdcdata.

  ls_bdcdata_fld-fnam = 'BDC_OKCODE'.
  ls_bdcdata_fld-fval = |=%_GC 305 25|.
  APPEND ls_bdcdata_fld TO lt_bdcdata.

  ls_bdcdata_scr-program  = '/SCWM/SAPLWIP_DELIVERY_OUT'.
  ls_bdcdata_scr-dynpro   = '0100'.
  ls_bdcdata_scr-dynbegin = abap_true.
  APPEND ls_bdcdata_scr TO lt_bdcdata.

  ls_bdcdata_fld-fnam = 'BDC_CURSOR'.
  ls_bdcdata_fld-fval = 'S_DOCNO-LOW'.
  APPEND ls_bdcdata_fld TO lt_bdcdata.

  ls_bdcdata_fld-fnam = 'BDC_OKCODE'.
  ls_bdcdata_fld-fval = |=%006|.
  APPEND ls_bdcdata_fld TO lt_bdcdata.

  ls_bdcdata_fld-fnam = 'P_DB'.
  ls_bdcdata_fld-fval = abap_true.
  APPEND ls_bdcdata_fld TO lt_bdcdata.

  "**********************************************************************
  "open screen for entering multiple values:
  ls_bdcdata_scr-program  = 'SAPLALDB'.
  ls_bdcdata_scr-dynpro   = '3000'.
  ls_bdcdata_scr-dynbegin = abap_true.
  APPEND ls_bdcdata_scr TO lt_bdcdata.

  ls_bdcdata_fld-fnam = 'BDC_OKCODE'.
  ls_bdcdata_fld-fval = '=ACPT'.
  APPEND ls_bdcdata_fld TO lt_bdcdata.

  ls_bdcdata_fld-fnam = 'BDC_CURSOR'.
  ls_bdcdata_fld-fval = |RSCSEL_255-SLOW_I(01)|.
  APPEND ls_bdcdata_fld TO lt_bdcdata.

  LOOP AT it_docno ASSIGNING FIELD-SYMBOL(<ls_data>).

    ls_bdcdata_fld-fnam = |RSCSEL_255-SLOW_I(0{ sy-tabix })|.
    ls_bdcdata_fld-fval = <ls_data>-docno.
    APPEND ls_bdcdata_fld TO lt_bdcdata.

  ENDLOOP.
  "**********************************************************************

  ls_bdcdata_scr-program  = '/SCWM/SAPLWIP_DELIVERY_OUT'.
  ls_bdcdata_scr-dynpro   = '0100'.
  ls_bdcdata_scr-dynbegin = abap_true.
  APPEND ls_bdcdata_scr TO lt_bdcdata.

  ls_bdcdata_fld-fnam = 'BDC_CURSOR'.
  ls_bdcdata_fld-fval = 'S_DOCNO-LOW'.
  APPEND ls_bdcdata_fld TO lt_bdcdata.

  ls_bdcdata_fld-fnam = 'BDC_OKCODE'.
  ls_bdcdata_fld-fval = '=CRET'.
  APPEND ls_bdcdata_fld TO lt_bdcdata.

  ls_bdcdata_fld-fnam = 'P_DB'.
  ls_bdcdata_fld-fval = abap_true.
  APPEND ls_bdcdata_fld TO lt_bdcdata.

  ls_opt-dismode = 'E'.  ""-> use P if you don't want to display report screens
  ls_opt-updmode = 'L'.
  ls_opt-defsize = 'X'.
  ls_opt-nobinpt = 'X'.

  CALL TRANSACTION zif_param_const=>c_monitor USING lt_bdcdata OPTIONS FROM ls_opt.

  CLEAR: lv_monitor.

  SET PARAMETER ID '/SCWM/MON' FIELD lv_monitor.

ENDFUNCTION.
