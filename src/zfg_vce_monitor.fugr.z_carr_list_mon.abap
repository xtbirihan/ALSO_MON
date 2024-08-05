FUNCTION z_carr_list_mon.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IV_VARIANT) TYPE  VARIANT OPTIONAL
*"     REFERENCE(IV_MODE) TYPE  /SCWM/DE_MON_FM_MODE DEFAULT '1'
*"     REFERENCE(IT_DATA_PARENT) TYPE  /SCWM/TT_WIP_WHRHEAD_OUT
*"       OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_RETURNCODE) TYPE  XFELD
*"     REFERENCE(EV_VARIANT) TYPE  VARIANT
*"     REFERENCE(ET_DATA) TYPE  ZTT_MON_SHIP_CALC
*"  CHANGING
*"     REFERENCE(CT_TAB_RANGE) TYPE  RSDS_TRANGE OPTIONAL
*"----------------------------------------------------------------------
**********************************************************************
*& Key           : <AAHMEDOV>-Aug 1, 2023
*& Request No.   : GAP-012: Outbound_VCE_carrier_software_integration
**********************************************************************

  DATA: lo_ui_stock_fields TYPE REF TO /scwm/cl_ui_stock_fields,
        lv_tzone           TYPE  tznzone,
        lv_date            TYPE zde_cutoff_date,
        lv_time            TYPE zde_cutoff_time.

  CLEAR et_data.

  lo_ui_stock_fields = NEW #( ).

  IF iv_mode = 1. "with sel screen

    CALL SELECTION-SCREEN lc_dynnr STARTING AT 10 10
                                   ENDING AT 130 30.

    DATA(lt_docno_r) = VALUE rseloption( FOR <ls_docno> IN so_docno
       (  sign   = <ls_docno>-sign
          option = <ls_docno>-option
          low    = <ls_docno>-low
          high   = <ls_docno>-high ) ).

  ELSEIF iv_mode = 2. "without sel screen

    lt_docno_r = VALUE rseloption( FOR <ls_data_parent> IN it_data_parent
       ( sign   = wmegc_sign_inclusive
        option = wmegc_option_eq
        low    = <ls_data_parent>-docno_h ) ).

  ENDIF.

  zcl_crud_ztout_ship_calc=>select_by_docno(
    EXPORTING
      it_docno_r   = lt_docno_r
    IMPORTING
      et_ship_calc = DATA(lt_data) ).                " MON Structure: Carrier proposals per delivery

  CALL FUNCTION '/SCWM/LGNUM_TZONE_READ'
    EXPORTING
      iv_lgnum        = iv_lgnum
    IMPORTING
      ev_tzone        = lv_tzone
    EXCEPTIONS
      interface_error = 1
      data_not_found  = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  SORT lt_data BY docno ASCENDING.

  DATA(lt_bp_mapping) = zcl_crud_ztout_map_carr=>select_multi_by_carr(
      iv_lgnum       = iv_lgnum
      it_carr_selopt = VALUE #( FOR <l> IN lt_data
                              ( sign = wmegc_sign_inclusive option = wmegc_option_eq low = <l>-bupartner ) ) ).
  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).

    DATA(lv_bp) = VALUE #( lt_bp_mapping[ carr = <ls_data>-bupartner hutype = <ls_data>-hutype ]-bupartner OPTIONAL ).

    DATA(lv_partner_text) = lo_ui_stock_fields->get_partner_text_by_no( lv_bp ).

    APPEND INITIAL LINE TO et_data ASSIGNING FIELD-SYMBOL(<ls_ship_calc_mon>).

    CONVERT TIME STAMP <ls_data>-cutofftime TIME ZONE lv_tzone INTO DATE lv_date TIME lv_time.

    MOVE-CORRESPONDING <ls_data> TO <ls_ship_calc_mon>.

    <ls_ship_calc_mon>-cutoff_date = lv_date.
    <ls_ship_calc_mon>-cutoff_time = lv_time.
    <ls_ship_calc_mon>-bupartner_text = lv_partner_text.
  ENDLOOP.

ENDFUNCTION.
