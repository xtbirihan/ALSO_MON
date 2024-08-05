FUNCTION z_hu_resend_shipreq.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IT_DATA) TYPE  STANDARD TABLE
*"----------------------------------------------------------------------
********************************************************************
*& Key          : <AAHMEDOV>-Dec 8, 2023
*& Request No.  : "GAP-012 - Outbound_VCE_carrier_software_integration"
********************************************************************
*& Description  :
********************************************************************

  " check number of selected rows
  DATA(lv_lines) = lines( it_data ).
  IF lv_lines EQ 0.
    MESSAGE s032(/scwm/monitor) DISPLAY LIKE wmegc_severity_err.
    RETURN.
  ELSEIF lv_lines GT 1.
    MESSAGE s013(/scwm/monitor) DISPLAY LIKE wmegc_severity_err.
    RETURN.
  ENDIF.

  DATA(ls_hu_mon) = CONV /scwm/s_huhdr_mon( it_data[ 1 ] ).
  DATA(lv_huident) = ls_hu_mon-huident.
  DATA(lv_huid) = ls_hu_mon-hu_guid_ext.

  IF zcl_vce_request_utils=>check_hu_has_tracking_num(
    EXPORTING
      it_huid_r   = VALUE rseloption( ( sign   = wmegc_sign_inclusive
                                      option = wmegc_option_eq
                                      low    = lv_huid ) )
      iv_huidtype = zif_wme_c=>gs_huidart-v                 " Handling Unit Identification Type
  ) EQ abap_true.

    MESSAGE s039(zmc_out) WITH lv_huident DISPLAY LIKE wmegc_severity_err.
    RETURN.
  ENDIF.

  zcl_vce_request=>send_ship_request(
    iv_lgnum   = iv_lgnum                 " Warehouse Number/Warehouse Complex
    iv_huident = lv_huident                 " Handling Unit Identification
  ).

  COMMIT WORK.

ENDFUNCTION.
