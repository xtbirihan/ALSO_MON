FUNCTION z_new_proposal_mon.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IT_DATA) TYPE  STANDARD TABLE
*"  EXCEPTIONS
*"      NOT_SUPPORTED
*"----------------------------------------------------------------------
********************************************************************
*& Key          : <AAHMEDOV>-Dec 1, 2023
*& Request No.  : "GAP-012 - Outbound_VCE_carrier_software_integration"
********************************************************************
*& Description  :
********************************************************************

  DATA:
    ls_response      TYPE zif_vce_shipment_calc_model=>ty_response,
    lt_ship_calc     TYPE zcl_crud_ztout_ship_calc=>tt_ship_calc,
    lt_docno_del_r   TYPE rseloption,
    lc_pallet        TYPE zde_vce_hutype VALUE 'PALLET',
    lc_parcel        TYPE zde_vce_hutype VALUE 'PARCEL',
    lv_bp_name       TYPE bu_name1,
    lv_carrno        TYPE bu_partner,
    lv_carrno_1      TYPE bu_partner VALUE '10240049',
    lv_carrno_2      TYPE bu_partner VALUE '10080044',
    lv_carrno_search TYPE bu_partner,
    lo_ship_calc     TYPE REF TO zcl_vce_shipment_calculation,
    ls_request_data  TYPE zif_vce_shipment_calc_model=>ty_request.

  TRY.
      NEW /scwm/cl_dlv_management_prd( )->query( "
        EXPORTING
          it_docid        = VALUE #( FOR <ls_data> IN it_data
                                        ( CONV /scwm/dlv_docid_item_str( CORRESPONDING #( <ls_data> ) ) ) )
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

      IF lv_hu_has_track_nr EQ abap_true.
        MESSAGE s036(zmc_out) WITH lt_headers[ 1 ]-docno DISPLAY LIKE wmegc_severity_err.
        RETURN.
      ENDIF.
    CATCH /scdl/cx_delivery. " Exception Class of Delivery
      RETURN.
  ENDTRY.

  CALL SELECTION-SCREEN lc_dyn_np STARTING AT 10 10
                                   ENDING AT 130 30.

  IF p_scond IS INITIAL
    AND so_adsrv IS INITIAL.
    "add message: please enter values
    MESSAGE s068(/accgo/br_true_up) DISPLAY LIKE wmegc_severity_war.
    RETURN.
  ENDIF.

  "this is the real request/response
  "uncomment when we get data from VCE
  IF 1 EQ 2 .

    TRY.
        lo_ship_calc = NEW zcl_vce_shipment_calculation( iv_lgnum = iv_lgnum ).
      CATCH zcx_core_exception. " Superclass for CORE exception classes
    ENDTRY.

    lo_ship_calc->build_request_data(
      EXPORTING
        iv_input = lt_headers[ 1 ]-docid
      IMPORTING
        es_data  = ls_request_data
    ).

    ls_request_data-shipping_condition = p_scond.
    ls_request_data-additional_services = VALUE #( FOR <s_addsrv> IN so_adsrv
                                                   ( CONV string( <s_addsrv>-low ) ) ).

    ls_request_data-customer_shipping_condition = p_fcarr.

    lo_ship_calc->send_post_request( is_data = ls_request_data ).

    lo_ship_calc->process_response( ).

  ENDIF.

  "get delivery data locally in order to test the new proposal logic
  "delete when VCE response delivers data
  LOOP AT lt_headers ASSIGNING FIELD-SYMBOL(<ls_header>).

    GET TIME STAMP FIELD DATA(lv_timestamp).

    lv_carrno = VALUE bu_partner( <ls_header>-partyloc[ party_role = /scdl/if_dl_partyloc_c=>sc_party_role_carr ]-partyno OPTIONAL ). "ALPHA = IN

    SHIFT lv_carrno LEFT DELETING LEADING '0'.

    CASE lv_carrno.
      WHEN lv_carrno_1.
        lv_carrno_search = lv_carrno_2.
      WHEN lv_carrno_2.
        lv_carrno_search = lv_carrno_1.
      WHEN OTHERS.
    ENDCASE.

    APPEND VALUE #( docno = <ls_header>-docno
                    counter = 1
                    is_pref = abap_true
                    hutype = COND #( WHEN sy-tabix MOD 2 EQ 0 THEN lc_pallet
                                     ELSE lc_parcel )
                    bupartner = lv_carrno_search
                    cutofftime = lv_timestamp ) TO lt_ship_calc.

    APPEND VALUE #( sign = wmegc_sign_inclusive
                    option = wmegc_option_eq
                    low = <ls_header>-docno ) TO lt_docno_del_r.

  ENDLOOP.

  IF lt_docno_del_r IS NOT INITIAL.

    zcl_crud_ztout_ship_calc=>delete(
      EXPORTING
        it_docno_r = lt_docno_del_r
      IMPORTING
        ev_suc     = DATA(lv_suc)                 " Checkbox
    ).

    zcl_crud_ztout_ship_calc=>modify( EXPORTING it_ship_calc = lt_ship_calc
                                      IMPORTING ev_suc       = lv_suc ).

  ENDIF.

*  CLEAR: p_fcarr,
*          p_scond,
*          so_adsrv.

ENDFUNCTION.
