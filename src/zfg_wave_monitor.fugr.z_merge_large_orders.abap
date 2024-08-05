FUNCTION z_merge_large_orders.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     VALUE(IV_RDOCCAT) TYPE  /SCWM/DE_DOCCAT
*"     VALUE(IT_WAVE_NO) TYPE  /SCWM/TT_WAVE_NO
*"  TABLES
*"      ET_BAPIRET TYPE  BAPIRET2_T OPTIONAL
*"----------------------------------------------------------------------
**********************************************************************
*& Request No.   : TE1K900125 Main Request / GAP-062 / GAP-064
*& Author        : Tugay Birihan
*& e-mail        : tugay.birihan@qinlox.com
*& Module Cons.  : Sevil Rasim
*& Date          : 06.04.2023
**********************************************************************
*& Description (short)
*& Standard monitor does not replenish stock,
*1.	The optimization will be triggered in the logic for GAP 62 (WO Optimization) on wave release.
*2.	The system will find the WOs having a given creation rule (BSCH – that will be taken from the switch framework) and having status “B”
*3.	After finding them the system will check if all WTs for a given delivery are created – and if yes – will try to merge the WOs for a delivery with same AA.
*   After the merge, regardless of the success of the merge, the system should unblock the WOs.
*   If there is only one WO for a given AA and it is blocked but the WTs for the delivery are created – the system should unblock it.
*4.	The exception is the putawall WOs – GAP 49.
*   The system should check if the  WOs AA are relevant for  putwall process
*   and  disregard them as the blocking and unblocking of them will be managed by the putwalll process (GAP 49).
**********************************************************************
  TYPES: BEGIN OF ty_reduced_quan,
           rdoccat TYPE  /scwm/de_doccat,
           rdocid  TYPE  /scwm/de_docid,
           ritmid  TYPE  /scwm/de_itmid,
           who     TYPE  /scwm/de_who,
           vsolm   TYPE  /scwm/ltap_vsolm,
           nistm   TYPE  /scwm/ltap_nistm,
         END OF ty_reduced_quan,
         tty_reduced_quan TYPE STANDARD TABLE OF ty_reduced_quan WITH EMPTY KEY.

  TYPES: BEGIN OF ty_delivery_collect,
           rdoccat TYPE  /scwm/de_doccat,
           rdocid  TYPE  /scwm/de_docid,
           vsolm   TYPE  /scwm/ltap_vsolm,
           nistm   TYPE  /scwm/ltap_nistm,
         END OF ty_delivery_collect,
         tty_delivery_collect TYPE STANDARD TABLE OF ty_delivery_collect WITH EMPTY KEY.

  WAIT UP TO 5 SECONDS.
  DATA:
    lt_wavehdr  TYPE /scwm/tt_wavehdr_int,
    lt_waveitm  TYPE /scwm/tt_waveitm_int,
    lt_bapiret  TYPE bapirettab,
    lv_severity TYPE bapi_mtype.

  DATA:
    lr_wcr         TYPE ztt_wcr,
    lr_wcr_putwall TYPE ztt_wcr,
    lr_aawho       TYPE /scwm/tt_areawho_r,
    lr_who         TYPE /scwm/tt_who_r,
    lr_status      TYPE ztt_status.

  DATA:
    lt_whoid          TYPE /scwm/tt_whoid,
    lt_who_merge      TYPE /scwm/tt_who,
    lt_delivery_items TYPE /scwm/dlv_item_out_prd_tab,
    lt_to_delivery    TYPE tty_reduced_quan.

  DATA:
    lt_delivery_to_collect TYPE tty_delivery_collect,
    lv_qty                 TYPE /scdl/dl_quantity.

  DATA: lt_to TYPE /scwm/tt_to_det_mon.

  DATA(lo_log) = NEW lcl_log_helper( ).

  IF zcl_switch=>get_switch_state( iv_lgnum = iv_lgnum
                                   iv_devid = zif_switch_const=>c_zout_010 ) EQ abap_false.
    RETURN.
  ENDIF.

  zcl_param=>get_parameter(
    EXPORTING
      iv_lgnum     = iv_lgnum
      iv_process   = zif_param_const=>c_zout_0002
      iv_parameter = zif_param_const=>c_largeorders_wocr
    IMPORTING
      et_list      = DATA(lt_wocr_params) ).

  PERFORM check_parameters TABLES lt_wocr_params
                           USING  iv_lgnum
                                  zif_switch_const=>c_largeorders
                                  zif_switch_const=>c_zout_010.
  IF lt_wocr_params IS INITIAL.
    RETURN.
  ENDIF.


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
  IF lt_bapiret IS NOT INITIAL.
    APPEND LINES OF lt_bapiret TO et_bapiret.
    lo_log->append_sy_msg_at_end(
      CHANGING
        ct_msg = lt_bapiret ).
  ENDIF.

  IF lv_severity CA 'EAX'.
    lo_log->collect_msg( ).
    lo_log->save_applog(
      EXPORTING
        is_log       = VALUE #( extnumber = |{ TEXT-002 } { iv_lgnum }|
                                object    = zif_whse_order=>log-object
                                subobject = zif_whse_order=>log-subobject_wave_release )
      IMPORTING
        ev_loghandle = DATA(lv_log_handle) ) ##NO_TEXT.
    RETURN.
  ENDIF.

  zcl_param=>get_parameter(
    EXPORTING
      iv_lgnum     = iv_lgnum
      iv_process   = zif_param_const=>c_zout_0002
      iv_parameter = zif_param_const=>c_putwall_aarea
    IMPORTING
      et_list      = DATA(lt_aarea_params) ).

  lr_aawho  = VALUE /scwm/tt_areawho_r( BASE lr_aawho FOR ls_aarea_params IN lt_aarea_params
                                      ( sign = wmegc_sign_inclusive option = wmegc_option_eq low = ls_aarea_params ) ).

  lr_wcr    = VALUE ztt_wcr( BASE lr_wcr FOR ls_wocr_params IN lt_wocr_params
                           ( sign = wmegc_sign_inclusive option = wmegc_option_eq low = ls_wocr_params ) ).

  lr_status = VALUE ztt_status( ( sign = wmegc_sign_inclusive option = wmegc_option_eq low = wmegc_to_inactiv  ) ).


  CALL FUNCTION '/SCWM/TO_GET_WIP'
    EXPORTING
      iv_lgnum   = iv_lgnum
      iv_open    = abap_true
      is_selcrit = VALUE /scwm/s_to_selcrit_mon( r_rdocid = VALUE #( FOR ls_waveitm IN lt_waveitm ( sign   = wmegc_sign_inclusive
                                                                                                    option = wmegc_option_eq
                                                                                                    low    = ls_waveitm-rdocid ) )
                                                 r_tostat = VALUE #(  sign   = wmegc_sign_inclusive
                                                                      option = wmegc_option_eq
                                                                    ( low    = wmegc_to_open )
                                                                    ( low    = wmegc_to_confirmed )
                                                                    ( low    = wmegc_to_inactiv )
                                                                    ( low    = wmegc_to_canceled )
                                                                    ( low    = wmegc_wo_in_process ) ) )
    IMPORTING
      et_to      = lt_to.

  SELECT wo~*
          FROM  /scwm/who AS wo
          INNER JOIN @lt_to  AS to ##ITAB_KEY_IN_SELECT
             ON wo~who  = to~who
     WHERE wo~lgnum      EQ @iv_lgnum   AND
           wo~wcr        IN @lr_wcr     AND
           wo~status     IN @lr_status
          INTO TABLE @DATA(lt_who).
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
  SORT lt_who BY lgnum who wcr wave status areawho.
  DELETE ADJACENT DUPLICATES FROM  lt_who COMPARING lgnum who wcr wave status areawho.

  zcl_param=>get_parameter(
    EXPORTING
      iv_lgnum     = iv_lgnum
      iv_process   = zif_param_const=>c_zout_0002
      iv_parameter = zif_param_const=>c_putwall_wocr
    IMPORTING
      et_list      = DATA(lt_putwall_wocr_params) ).

  PERFORM check_parameters TABLES lt_putwall_wocr_params
                           USING  iv_lgnum
                                  zif_switch_const=>c_putwall
                                  zif_switch_const=>c_zout_011.
  IF lt_putwall_wocr_params IS NOT INITIAL.
    lr_wcr_putwall   = VALUE ztt_wcr( BASE lr_wcr_putwall FOR ls_putwall_wocr_params IN lt_putwall_wocr_params
                                    ( sign = wmegc_sign_inclusive option = wmegc_option_eq low = ls_putwall_wocr_params ) ).

    LOOP AT lt_to ASSIGNING FIELD-SYMBOL(<ls_to>) WHERE aarea IN lr_aawho
                                                    AND wcr   IN lr_wcr_putwall.
      LOOP AT lr_aawho ASSIGNING FIELD-SYMBOL(<ls_aarea>) WHERE low NE <ls_to>-aarea.
        DATA(ls_to) = VALUE #(  lt_to[ rdocid = <ls_to>-rdocid aarea =  <ls_aarea>-low  wcr = <ls_to>-wcr ] OPTIONAL ).
        IF ls_to IS NOT INITIAL.
          COLLECT VALUE /scwm/s_who_r(   sign = wmegc_sign_inclusive option = wmegc_option_eq low = <ls_to>-who ) INTO lr_who.
        ENDIF.
        CLEAR: ls_to.
      ENDLOOP.
    ENDLOOP.
    IF lr_who IS NOT INITIAL.
      DELETE lt_who WHERE who IN lr_who.
      DELETE lt_to WHERE who IN lr_who.
    ENDIF.
    IF lt_who IS INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

  lt_to_delivery = VALUE tty_reduced_quan(
                        FOR GROUPS <group_key> OF <g> IN lt_to
                        GROUP BY ( rdoccat = <g>-rdoccat rdocid = <g>-rdocid ritmid  = <g>-ritmid who = <g>-who )
                        LET coll_line = REDUCE #( INIT line TYPE ty_reduced_quan FOR <m> IN GROUP <group_key>
                                          NEXT line-rdoccat = <m>-rdoccat
                                               line-rdocid  = <m>-rdocid
                                               line-ritmid  = <m>-ritmid
                                               line-who     = <m>-who
                                               line-vsolm = line-vsolm + <m>-vsolm
                                               line-nistm = line-nistm + <m>-nistm )
                             IN ( coll_line ) ) .

  DATA(ls_read_options) =
    VALUE /scwm/dlv_query_contr_str(
      data_retrival_only      = abap_true
      mix_in_object_instances = abap_true
      item_part_select        = abap_true  ).


  lt_delivery_to_collect = VALUE tty_delivery_collect(
                           FOR GROUPS <group_key1> OF <g1> IN lt_to_delivery
                           GROUP BY ( rdoccat = <g1>-rdoccat rdocid = <g1>-rdocid  )
                           LET coll_line1 = REDUCE #( INIT line1 TYPE ty_delivery_collect FOR <m1> IN GROUP <group_key1>
                                            NEXT line1-rdoccat = <m1>-rdoccat
                                                line1-rdocid  = <m1>-rdocid
                                                line1-vsolm = line1-vsolm + <m1>-vsolm
                                                line1-nistm = line1-nistm + <m1>-nistm )
                                            IN ( coll_line1 ) ) .

  DATA(lt_docid) = CORRESPONDING /scwm/dlv_docid_item_tab( lt_delivery_to_collect MAPPING doccat = rdoccat docid = rdocid EXCEPT itemid ).

  DATA(lo_bom_prd) = /scwm/cl_dlv_management_prd=>get_instance( ).

  TRY.
      lo_bom_prd->query(
        EXPORTING
          it_docid        = lt_docid
          is_include_data = VALUE /scwm/dlv_query_incl_str_prd( head_status = abap_true )
          is_read_options = VALUE #( )
        IMPORTING
          et_headers      = DATA(lt_delivery_headers)
          et_items        = lt_delivery_items ).

    CATCH /scdl/cx_delivery.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      lo_log->collect_msg( ).
  ENDTRY.
  SORT lt_delivery_items BY docid itemid.

  CLEAR: lr_who.

  LOOP AT lt_delivery_to_collect ASSIGNING FIELD-SYMBOL(<ls_delivery_to_collect>).
    DATA(lt_status) = VALUE #( lt_delivery_headers[ docid = <ls_delivery_to_collect>-rdocid ]-status OPTIONAL ).
    DATA(lv_planning_picking) = VALUE #( lt_status[ status_type = /scdl/if_dl_status_c=>sc_t_planning_picking ]-status_value OPTIONAL ).
    IF lv_planning_picking NE 9.
      LOOP AT lt_to_delivery ASSIGNING FIELD-SYMBOL(<ls_to_delivery>) WHERE rdocid = <ls_delivery_to_collect>-rdocid.
        COLLECT VALUE /scwm/s_who_r( sign = wmegc_sign_inclusive option = wmegc_option_eq low = <ls_to_delivery>-who ) INTO lr_who.
      ENDLOOP.
    ENDIF.
    CLEAR: lt_status, lv_planning_picking.
  ENDLOOP.
  IF lr_who[] IS NOT INITIAL.
    DELETE lt_who WHERE who IN lr_who.
    DELETE lt_to WHERE who IN lr_who.
  ENDIF.

* UM Start 15.01.2024
* As the following LOOP is based on the LT_TO table, remove from it all the WTs not related to the WHOs in table LT_WHO
  CLEAR: lr_who.
  LOOP AT lt_who ASSIGNING FIELD-SYMBOL(<ls_who>).
    COLLECT VALUE /scwm/s_who_r( sign = wmegc_sign_inclusive option = wmegc_option_eq low = <ls_who>-who ) INTO lr_who.
  ENDLOOP.
  DELETE lt_to WHERE who NOT IN lr_who.
* UM End 15.01.2024

  SORT lt_to BY who aarea.
  DELETE ADJACENT DUPLICATES FROM lt_to COMPARING who aarea.

  LOOP AT lt_to INTO DATA(ls_to_grp)
       GROUP BY ( rdocid  = ls_to_grp-rdocid
                  areawho = ls_to_grp-areawho
                  size  = GROUP SIZE
                  index = GROUP INDEX )
                ASCENDING
                REFERENCE INTO DATA(group_ref).
    LOOP AT GROUP group_ref ASSIGNING FIELD-SYMBOL(<ls_group>).
      lt_whoid = VALUE #( BASE lt_whoid ( who = <ls_group>-who ) ).
    ENDLOOP.
    " If there is only one WO for a given AA and it is blocked but the WTs for the delivery are created – the system should unblock it.
    IF group_ref->size EQ 1.
      PERFORM unhold_who  USING iv_lgnum <ls_group>-who CHANGING lo_log.

    ENDIF.
* After finding them the system will check if all WTs for a given delivery are created – and if yes – will try to merge the WOs for a delivery with same AA.
* After the merge, regardless of the success of the merge, the system should unblock the WOs.
    IF group_ref->size > 1.
      SET UPDATE TASK LOCAL.
      CALL FUNCTION 'Z_WHO_MERGE'
        EXPORTING
          iv_lgnum       = iv_lgnum
          iv_wcr         = VALUE /scwm/de_wcr( )
          iv_reason_code = VALUE char4( )
          iv_update      = abap_true
          iv_commit      = abap_true
          it_who         = lt_whoid
        IMPORTING
          et_bapiret     = lt_bapiret
          et_who         = lt_who_merge.
      IF lt_bapiret IS NOT INITIAL.
        APPEND LINES OF lt_bapiret  TO et_bapiret.
        lo_log->append_sy_msg_at_end(
          CHANGING
            ct_msg = lt_bapiret ).
      ENDIF.

      LOOP AT lt_who_merge ASSIGNING FIELD-SYMBOL(<ls_whoid>).
        PERFORM unhold_who USING iv_lgnum <ls_whoid>-who CHANGING lo_log.
      ENDLOOP.
    ENDIF.

    CLEAR: lt_bapiret, lt_who_merge, lt_whoid.
  ENDLOOP.

  lo_log->save_applog(
    EXPORTING
      is_log       = VALUE #( extnumber = |{ TEXT-002 } { iv_lgnum }|
                              object    = zif_whse_order=>log-object
                              subobject = zif_whse_order=>log-subobject_wave_release )
    IMPORTING
      ev_loghandle = lv_log_handle ) ##NO_TEXT.                 " Log Handle
ENDFUNCTION.
FORM unhold_who USING iv_lgnum TYPE /scwm/lgnum iv_who TYPE /scwm/de_who
                CHANGING co_log TYPE REF TO lcl_log_helper.
********************************************************************
*& Key          : <TBIRIHAN>-January 17, 2024
*& Request No.  : GAP-062 / GAP-064
********************************************************************
*& Description  :
********************************************************************

  SET UPDATE TASK LOCAL.
  CALL FUNCTION '/SCWM/WHO_HOLD_UNHOLD'
    EXPORTING
      iv_lgnum  = iv_lgnum
      iv_unhold = abap_true
      it_who    = VALUE /scwm/tt_whoid( ( who = iv_who ) )
    EXCEPTIONS
      OTHERS    = 99.
  IF sy-subrc NE 0.
    co_log->collect_msg( ).
  ELSE.
    MESSAGE s417(/scwm/who) WITH iv_who INTO DATA(lv_mtext).
    co_log->collect_msg( ).
  ENDIF.

ENDFORM.
FORM check_parameters TABLES pt_params TYPE ztt_param_list
                       USING iv_lgnum  TYPE /scwm/lgnum
                             iv_field  TYPE zde_field
                             iv_devid  TYPE zde_devid.
********************************************************************
*& Key          : <TBIRIHAN>-January 17, 2024
*& Request No.  : GAP-062 / GAP-064
********************************************************************
*& Description  :
********************************************************************

  LOOP AT pt_params ASSIGNING FIELD-SYMBOL(<fs_params>).
    DATA(lt_switch_fields) = VALUE ztt_switch_fields( ( field       = iv_field
                                                        field_value = <fs_params> ) ).

    IF zcl_switch=>get_switch_state( iv_lgnum  = iv_lgnum
                                     iv_devid  = iv_devid
                                     it_fields = lt_switch_fields ) EQ abap_false.
      <fs_params> = abap_true.
    ENDIF.
    CLEAR: lt_switch_fields.
  ENDLOOP.
  DELETE pt_params[] WHERE table_line EQ abap_true.

ENDFORM.
