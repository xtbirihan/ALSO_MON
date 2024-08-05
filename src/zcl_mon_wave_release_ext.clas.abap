class ZCL_MON_WAVE_RELEASE_EXT definition
  public
  final
  create public .

public section.

  interfaces ZIF_MON_WAVE_RELEASE_EXT .

  methods CHECK_PARAMETERS
    importing
      !IV_DEVID type ZDE_DEVID optional
      !IT_SWITCH_FIELDS type ZTT_SWITCH_FIELDS optional
    returning
      value(RV_CHECK) type XFELD .
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_MON_WAVE_RELEASE_EXT IMPLEMENTATION.


  METHOD check_parameters.
********************************************************************
*& Key          : <TBIRIHAN>-January 17, 2024
*& Request No.  : GAP-062
********************************************************************
*& Description  :
********************************************************************
    " Switch on/off for sorter.
    IF zcl_switch=>get_switch_state( iv_lgnum = /scwm/cl_tm=>sv_lgnum
                                     iv_devid = iv_devid ) EQ abap_false.
      RETURN.
    ENDIF.

    IF zcl_switch=>get_switch_state( iv_lgnum  = /scwm/cl_tm=>sv_lgnum
                                     iv_devid  = iv_devid
                                     it_fields = it_switch_fields  ) EQ abap_false.
      RETURN.
    ENDIF.

    rv_check = abap_true.
  ENDMETHOD.


  METHOD zif_mon_wave_release_ext~after.
********************************************************************
*& Key          : <TBIRIHAN>-January 17, 2024
*& Request No.  : GAP-062
********************************************************************
*& Description  :
********************************************************************
    DATA: lt_bapiret 	TYPE bapiret2_t.

    DATA(lv_mon) = /scwm/cl_wme_monitor_srvc=>mv_monitor.

    IF me->check_parameters( iv_devid = zif_switch_const=>c_zmon_001
                             it_switch_fields = VALUE ztt_switch_fields( ( field       = zif_switch_const=>c_monname
                                                                           field_value = lv_mon ) )  ) EQ abap_false.
      RETURN.
    ENDIF.

    CALL FUNCTION 'Z_REPLENISH_STOCK'
      EXPORTING
        iv_lgnum   = iv_lgnum
        iv_rdoccat = iv_rdoccat
        it_wave_no = it_wave_no
      IMPORTING
        et_bapiret = lt_bapiret.
    IF lt_bapiret IS NOT INITIAL.
      APPEND LINES OF lt_bapiret TO et_bapiret.
    ENDIF.

    CLEAR: lt_bapiret.
    CALL FUNCTION 'Z_MERGE_LARGE_ORDERS'
      IN BACKGROUND TASK
      AS SEPARATE UNIT
      EXPORTING
        iv_lgnum   = iv_lgnum
        iv_rdoccat = iv_rdoccat
        it_wave_no = it_wave_no.

    CLEAR: lt_bapiret.
    CALL FUNCTION 'Z_PUTWALL'
      IN BACKGROUND TASK
      AS SEPARATE UNIT
      EXPORTING
        iv_lgnum   = iv_lgnum
        iv_rdoccat = iv_rdoccat
        it_wave_no = it_wave_no.
    COMMIT WORK.
  ENDMETHOD.


  METHOD zif_mon_wave_release_ext~before.
********************************************************************
*& Key          : <TBIRIHAN>-January 17, 2024
*& Request No.  : GAP-062
********************************************************************
*& Description  :
********************************************************************

    DATA(lv_mon) = /scwm/cl_wme_monitor_srvc=>mv_monitor.

    IF me->check_parameters( iv_devid = zif_switch_const=>c_zmon_001
                             it_switch_fields = VALUE ztt_switch_fields( ( field       = zif_switch_const=>c_monname
                                                                           field_value = lv_mon ) )  ) EQ abap_false.
      RETURN.
    ENDIF.

    CALL FUNCTION 'Z_ROUGH_BIN_DETERMINATION'
      EXPORTING
        iv_lgnum   = iv_lgnum
        iv_rdoccat = iv_rdoccat
        it_wave_no = it_wave_no.

  ENDMETHOD.
ENDCLASS.
