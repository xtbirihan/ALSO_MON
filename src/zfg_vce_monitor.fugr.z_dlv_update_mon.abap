FUNCTION z_dlv_update_mon.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IT_DATA) TYPE  STANDARD TABLE
*"----------------------------------------------------------------------
********************************************************************
*& Key          : <AAHMEDOV>-Oct 20, 2023
*& Request No.  : "GAP-012 - Outbound_VCE_carrier_software_integration"
********************************************************************
*& Description  :
********************************************************************

  DATA:
    lt_dlv_upd TYPE ztt_vce_dlv_upd_fields,
    lv_tzone   TYPE  tznzone.

  FIELD-SYMBOLS:
      <ls_mon_ship_calc>        TYPE zstr_mon_ship_calc.

  TRY.
      NEW /scwm/cl_dlv_management_prd( )->query( "
        EXPORTING
          it_docno        = VALUE /scwm/dlv_docno_itemno_tab( FOR <ls_data> IN it_data
                                          ( CONV /scwm/dlv_docno_itemno_str( CORRESPONDING #( <ls_data> ) ) ) )
          is_read_options = VALUE /scwm/dlv_query_contr_str( data_retrival_only = abap_true )
        IMPORTING
          et_headers      = DATA(lt_headers)
      ).

      DATA(lv_hu_has_track_nr) = zcl_vce_request_utils=>check_hu_has_tracking_num(
        EXPORTING
          it_docid_r  = VALUE rseloption( FOR <ls_dlv_hdr> IN lt_headers
                                           ( sign   = wmegc_sign_inclusive
                                             option = wmegc_option_eq
                                             low    = <ls_dlv_hdr>-docid  ) )                  " SELECT-OPTIONS Table
          iv_huidtype = zif_wme_c=>gs_huidart-v                 " Handling Unit Identification Type
      ).

      IF lv_hu_has_track_nr IS NOT INITIAL.
        MESSAGE s036(zmc_out) WITH lt_headers[ 1 ]-docno DISPLAY LIKE wmegc_severity_err.
        RETURN.
      ENDIF.
    CATCH /scdl/cx_delivery. " Exception Class of Delivery
      RETURN.
  ENDTRY.

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

  LOOP AT it_data ASSIGNING <ls_mon_ship_calc>.

    CONVERT DATE <ls_mon_ship_calc>-cutoff_date
            TIME <ls_mon_ship_calc>-cutoff_time
            INTO TIME STAMP DATA(lv_cutoff_tmstmp) TIME ZONE lv_tzone.

*    APPEND VALUE ztt_vce_dlv_upd_fields( docno = <ls_mon_ship_calc>-docno
*                    bupartner = <ls_mon_ship_calc>-bupartner
*                    cutofftime = lv_cutoff_tmstmp ) TO lt_dlv_upd.

    APPEND CORRESPONDING #( <ls_mon_ship_calc> ) TO lt_dlv_upd.

  ENDLOOP.

  IF lines( lt_dlv_upd ) < 0.
    MESSAGE s032(/scwm/monitor) DISPLAY LIKE 'E'.
    RETURN.
  ELSEIF lines( lt_dlv_upd ) > 1.
    MESSAGE s013(/scwm/monitor) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  SORT lt_dlv_upd BY docno ASCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_dlv_upd.

  IF sy-subrc EQ 0.
    "there are adjacent duplicates
*      msg please select unique deliveries
    MESSAGE s673(/sehs/ba_misc1) DISPLAY LIKE wmegc_severity_war.
    RETURN.
  ENDIF.

  CALL FUNCTION 'Z_VCE_DLV_UPDATE'
    EXPORTING
      iv_lgnum      = iv_lgnum
      it_dlv_update = lt_dlv_upd.

ENDFUNCTION.
