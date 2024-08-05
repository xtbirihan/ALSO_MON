FUNCTION z_hu_cancel_req.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IT_DATA) TYPE  STANDARD TABLE
*"----------------------------------------------------------------------
********************************************************************
*& Key          : <AAHMEDOV>-Dec 11, 2023
*& Request No.  : "GAP-012 - Outbound_VCE_carrier_software_integration"
********************************************************************
*& Description  :
********************************************************************

  DATA(lt_hu_mon) = CONV /scwm/tt_huhdr_mon( it_data ).

  zcl_crud_huident=>select_by_huid_huidtyp(
    EXPORTING
      it_huid_r     = VALUE rseloption( FOR GROUPS OF <ls_guid_hu> IN lt_hu_mon
                        GROUP BY <ls_guid_hu>-hu_guid_ext
                       ( sign   = wmegc_sign_inclusive option = wmegc_option_eq low    = <ls_guid_hu>-hu_guid_ext ) )
      it_huidtype_r = VALUE #( ( sign = wmegc_sign_inclusive option = wmegc_option_eq low = zif_wme_c=>gs_huidart-v ) )                 " Handling Unit Identification Type
    IMPORTING
      et_huident    = DATA(lt_huident)                 " HU: Alternative Identifiers
  ).

  IF lt_huident IS INITIAL.
    "No suitable
    MESSAGE s042(zmc_out) DISPLAY LIKE wmegc_severity_err.
    RETURN.
  ENDIF.

  zcl_vce_request=>send_cancel_request(
    iv_lgnum   = iv_lgnum                 " Warehouse Number/Warehouse Complex
    it_guid_hu = VALUE #( FOR <ls_huident> IN lt_huident ( guid_hu = <ls_huident>-huid ) )                  " Table of HU GUIDs
  ).

  COMMIT WORK.

ENDFUNCTION.
