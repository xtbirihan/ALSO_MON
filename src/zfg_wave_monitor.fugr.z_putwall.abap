FUNCTION z_putwall.
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
*& Request No.   : TE1K900125 Main Request / GAP-062/ GAP-049
*& Author        : Tugay Birihan
*& e-mail        : tugay.birihan@qinlox.com
*& Date          : 06.04.2023
**********************************************************************
*& Description (short)
*	After the merge the system should check the new WOs from each AA . For AA1  -  if there are two or more WOs from AA1, it should take the one with lowest volume and
* if there are two or more WOs from AA2 then it should  take the WO with smallest volume and run the cuboid algorithm for the WTs in both WOs to see
* if they can be packed together into a shipping HU.
* If they can be packed together, the system should change the pack proposal of the WO from AA1 to a “tote” and unlock it,
* the system should change the packaging material of the WO from AA2 to the determined packaging material determined from the cuboid algorithm,
* but the WO itself should remain blocked. All other WOs (if there are any) should be unblocked.
**********************************************************************
  CONSTANTS: c_reason TYPE char4 VALUE 'DELT'.
  TYPES:
    BEGIN OF ty_reduced_quan,
      rdoccat TYPE  /scwm/de_doccat,
      rdocid  TYPE  /scwm/de_docid,
      ritmid  TYPE  /scwm/de_itmid,
      vsolm   TYPE  /scwm/ltap_vsolm,
      nistm   TYPE  /scwm/ltap_nistm,
    END OF ty_reduced_quan,
    tty_reduced_quan TYPE STANDARD TABLE OF ty_reduced_quan WITH EMPTY KEY.

  TYPES:
    BEGIN OF lty_min_volume,
      who        TYPE  /scwm/de_who,
      areawho    TYPE /scwm/de_aarea,
      sum_volum  TYPE /scwm/s_wo_det_mon_out-sum_volum,
      unit_v     TYPE /scwm/s_wo_det_mon_out-unit_v,
      sum_weight TYPE /scwm/s_wo_det_mon_out-sum_weight,
      unit_w     TYPE /scwm/s_wo_det_mon_out-unit_w,
    END OF lty_min_volume.
  DATA:
    lt_min_volume           TYPE TABLE OF lty_min_volume,
    lt_who_sel              TYPE TABLE OF /scwm/who,
    lt_selection_parameters TYPE ztt_select_option.
  DATA:
    lt_wavehdr  TYPE /scwm/tt_wavehdr_int,
    lt_waveitm  TYPE /scwm/tt_waveitm_int,
    lt_bapiret  TYPE bapirettab,
    lv_severity TYPE bapi_mtype.
  DATA:
    lr_wcr    TYPE ztt_wcr,
    lr_aawho  TYPE /scwm/tt_areawho_r,
    lr_who    TYPE /scwm/tt_who_r,
    lr_status TYPE ztt_status.
  DATA:
    lt_whoid        TYPE /scwm/tt_whoid,
    lt_who_merge    TYPE /scwm/tt_who,
    lt_to_delivery  TYPE tty_reduced_quan,
    ls_whohu        TYPE /scwm/whohu,
    lt_who_list     TYPE /scwm/tt_who,
    ls_who_l        TYPE /scwm/who,
    lt_packmat      TYPE /scwm/tt_who_pmat,
    lt_packmat_aa01 TYPE /scwm/tt_who_pmat,
    lt_tasks        TYPE /scwm/tt_ordim_o_int,
    lt_tasks_aa01   TYPE /scwm/tt_ordim_o_int.
  DATA:
    lt_to         TYPE /scwm/tt_to_det_mon,
    lt_who_unhold TYPE /scwm/tt_who.

  TYPES: BEGIN OF lty_who_delivery,
           rdocid TYPE  /scwm/de_docid.
           INCLUDE STRUCTURE /scwm/who.
  TYPES: END OF lty_who_delivery.
  DATA: lt_who_delivery TYPE TABLE OF lty_who_delivery.
  DATA: lt_who_list_delivery TYPE TABLE OF lty_who_delivery,
        ls_who_list_delivery TYPE lty_who_delivery.

  DATA(lo_log) = NEW lcl_log_helper( ).

  WAIT UP TO 5 SECONDS.
  IF zcl_switch=>get_switch_state( iv_lgnum = iv_lgnum
                                   iv_devid = zif_switch_const=>c_zout_011 ) EQ abap_false.
    RETURN.
  ENDIF.

  zcl_param=>get_parameter(
    EXPORTING
      iv_lgnum     = iv_lgnum
      iv_process   = zif_param_const=>c_zout_0002
      iv_parameter = zif_param_const=>c_putwall_wocr
    IMPORTING
      et_list      = DATA(lt_wocr_params) ).

  PERFORM check_parameters TABLES lt_wocr_params
                           USING  iv_lgnum
                                  zif_switch_const=>c_putwall
                                  zif_switch_const=>c_zout_011.
  IF lt_wocr_params IS INITIAL.
    RETURN.
  ENDIF.

  "Field level switch on/off
  DATA(lt_switch_fields) = VALUE ztt_switch_fields( ( field       = zif_switch_const=>c_putwall
                                                      field_value = zif_whse_order=>wo_cr-bshc ) ).

  IF zcl_switch=>get_switch_state( iv_lgnum  = iv_lgnum
                                   iv_devid  = zif_switch_const=>c_zout_011
                                   it_fields = lt_switch_fields ) EQ abap_false.
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
    lo_log->save_applog(
      EXPORTING
        is_log       = VALUE #( extnumber = |{ TEXT-002 } { iv_lgnum }|
                                object    = zif_whse_order=>log-object
                                subobject = zif_whse_order=>log-subobject_wave_release )
      IMPORTING
        ev_loghandle = DATA(lv_log_handle) ) ##NO_TEXT.                 " Log Handle
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
                                                                    ( low    = wmegc_wo_in_process ) )
                                                r_aarea    = lr_aawho
                                                                    )
    IMPORTING
      et_to      = lt_to.

  SELECT wo~*
          FROM  /scwm/who AS wo
          INNER JOIN @lt_to  AS to ##ITAB_KEY_IN_SELECT
             ON wo~who  = to~who
     WHERE wo~lgnum      EQ @iv_lgnum   AND
           wo~wcr        IN @lr_wcr     AND
           wo~status     IN @lr_status  AND
           wo~areawho    IN @lr_aawho
          INTO TABLE @DATA(lt_who).
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  SORT lt_who BY lgnum who wcr wave status areawho.
  DELETE ADJACENT DUPLICATES FROM  lt_who COMPARING lgnum who wcr wave status areawho.

  SORT lt_who BY who.
  LOOP AT lt_to ASSIGNING FIELD-SYMBOL(<ls_tasks>).
    READ TABLE lt_who WITH KEY who = <ls_tasks>-who TRANSPORTING NO FIELDS BINARY SEARCH.
    IF sy-subrc NE 0.
      <ls_tasks>-reason = c_reason.
    ENDIF.
  ENDLOOP.
  DELETE lt_to WHERE reason = c_reason.


  DATA(lt_who_temp) = lt_who.
  SORT lt_who_temp BY areawho.

  LOOP AT lr_aawho ASSIGNING FIELD-SYMBOL(<ls_aarea>).
    READ TABLE lt_who_temp TRANSPORTING NO FIELDS WITH KEY areawho = <ls_aarea>-low BINARY SEARCH.
    IF sy-subrc NE 0.
      DATA(lv_return) = abap_true.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF lv_return IS NOT INITIAL.
    RETURN.
  ENDIF.

  lt_to_delivery = VALUE tty_reduced_quan(
                        FOR GROUPS <group_key> OF <g> IN lt_to GROUP BY ( rdoccat = <g>-rdoccat ritmid = <g>-ritmid  )
                        LET coll_line = REDUCE #( INIT line TYPE ty_reduced_quan FOR <m> IN GROUP <group_key>
                                          NEXT line-rdoccat = <m>-rdoccat
                                               line-rdocid  = <m>-rdocid
                                               line-ritmid  = <m>-ritmid
                                               line-vsolm = line-vsolm + <m>-vsolm
                                               line-nistm = line-nistm + <m>-nistm )
                             IN ( coll_line ) ) .


  DATA(lo_bom_prd) = /scwm/cl_dlv_management_prd=>get_instance( ).


  DATA(lt_docid) = VALUE /scwm/dlv_docid_item_tab( FOR ls_delivery IN lt_to_delivery
                                                (  doccat = ls_delivery-rdoccat
                                                   docid  = ls_delivery-rdocid  ) ).
  SORT lt_docid BY doccat docid.
  DELETE ADJACENT DUPLICATES FROM lt_docid COMPARING doccat docid.
  TRY.
      lo_bom_prd->query(
        EXPORTING
          is_include_data = VALUE /scwm/dlv_query_incl_str_prd( head_status = abap_true )
          is_read_options = VALUE #( )
          it_docid        = lt_docid
        IMPORTING
          et_headers      = DATA(lt_delivery_header)
          eo_message      = DATA(lo_message) ).
    CATCH /scdl/cx_delivery.

      lo_log->collect_msg( ).
      lo_log->save_applog(
        EXPORTING
          is_log       = VALUE #( extnumber = |{ TEXT-002 } { iv_lgnum }|
                                  object    = zif_whse_order=>log-object
                                  subobject = zif_whse_order=>log-subobject_wave_release )
        IMPORTING
          ev_loghandle = lv_log_handle ) ##NO_TEXT.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDTRY.
  CLEAR: lr_who.
  LOOP AT lt_to_delivery ASSIGNING FIELD-SYMBOL(<ls_to_delivery>).
    DATA(lt_status) = VALUE #( lt_delivery_header[ docid = <ls_to_delivery>-rdocid ]-status OPTIONAL ).
    DATA(lv_planning_picking) = VALUE #( lt_status[ status_type = /scdl/if_dl_status_c=>sc_t_planning_picking ]-status_value OPTIONAL ).
    IF lv_planning_picking NE 9.
      LOOP AT lt_to ASSIGNING FIELD-SYMBOL(<ls_to>) WHERE rdocid = <ls_to_delivery>-rdocid.
        COLLECT VALUE /scwm/s_who_r( sign = wmegc_sign_inclusive option = wmegc_option_eq low = <ls_to>-who ) INTO lr_who.
      ENDLOOP.
    ENDIF.
    CLEAR: lt_status, lv_planning_picking.
  ENDLOOP.
  IF lr_who IS NOT INITIAL.
    DELETE lt_who WHERE who IN lr_who.
  ENDIF.

  lt_who_temp = lt_who.
  SORT lt_who_temp BY areawho.
  LOOP AT lr_aawho ASSIGNING <ls_aarea>.
    READ TABLE lt_who_temp TRANSPORTING NO FIELDS WITH KEY areawho = <ls_aarea>-low BINARY SEARCH.
    IF sy-subrc NE 0.
      lv_return = abap_true.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF lv_return IS NOT INITIAL.
    RETURN.
  ENDIF.


  lt_who_delivery = CORRESPONDING #( lt_who ).
  LOOP AT lt_who_delivery ASSIGNING FIELD-SYMBOL(<fs_who_delivery>).
    READ TABLE lt_to INTO DATA(ls_to) WITH KEY who = <fs_who_delivery>-who.
    IF sy-subrc EQ 0.
      <fs_who_delivery>-rdocid = ls_to-rdocid.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_who_delivery INTO DATA(ls_who)
       GROUP BY ( areawho = ls_who-areawho
                  rdocid  = ls_who-rdocid
                  size  = GROUP SIZE
                  index = GROUP INDEX )
                ASCENDING
                REFERENCE INTO DATA(group_ref).
    LOOP AT GROUP group_ref ASSIGNING FIELD-SYMBOL(<ls_group>).
      lt_whoid = VALUE #( BASE lt_whoid ( who = <ls_group>-who ) ).
    ENDLOOP.

    IF group_ref->size EQ 1.
      APPEND <ls_group> TO lt_who_list_delivery.
    ENDIF.
    IF group_ref->size > 1.
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
        lo_log->append_sy_msg_at_end(
          CHANGING
            ct_msg = lt_bapiret ).
      ENDIF.
      LOOP AT lt_bapiret INTO DATA(ls_bapiret) WHERE type CA 'EAX'.
        EXIT.
      ENDLOOP.
      IF sy-subrc NE 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
        LOOP AT GROUP group_ref ASSIGNING <ls_group>.
          APPEND <ls_group> TO lt_who_list_delivery.
        ENDLOOP.
      ENDIF.
      IF lt_bapiret IS NOT INITIAL.
        APPEND LINES OF lt_bapiret  TO et_bapiret.
        lo_log->append_sy_msg_at_end(
          CHANGING
            ct_msg = lt_bapiret ).
      ENDIF.
      LOOP AT lt_who_merge ASSIGNING FIELD-SYMBOL(<fs_who_merge>).
        MOVE-CORRESPONDING <fs_who_merge> TO ls_who_list_delivery.
        ls_who_list_delivery-rdocid =  group_ref->rdocid.
        APPEND ls_who_list_delivery TO lt_who_list_delivery.
        CLEAR: ls_who_list_delivery.
      ENDLOOP.
    ENDIF.

    CLEAR: lt_bapiret, lt_who_merge, lt_whoid.
  ENDLOOP.

  DATA(lt_carton_mat) = NEW zcl_packmmat_algo( iv_lgnum = iv_lgnum )->get_pmat_carton( ).
  SORT lt_carton_mat BY matid.
  DATA(lo_pmat) = NEW zcl_ship_pmat_real_algorithm( ).
  DATA(lt_pmat_ids) = NEW zcl_packmmat_algo( iv_lgnum )->get_pmat_planned_shipping( ).
  lt_packmat = VALUE #( BASE lt_packmat FOR <ls_pmat_ids> IN lt_pmat_ids ( pmat_guid = <ls_pmat_ids>-matid ) ).


  LOOP AT lt_who_list_delivery INTO DATA(ls_who_list_d)
       GROUP BY ( rdocid  = ls_who_list_d-rdocid
                  size  = GROUP SIZE
                  index = GROUP INDEX )
                ASCENDING
                REFERENCE INTO DATA(group_ref_delivery).

    CLEAR: lt_who_list, lt_who_unhold, lv_return, lt_who_sel, lt_tasks, lt_bapiret,
           lt_min_volume, lt_tasks_aa01, lt_packmat_aa01.

    LOOP AT GROUP group_ref_delivery ASSIGNING FIELD-SYMBOL(<ls_group_delivery>).
      lt_who_list = VALUE #( BASE lt_who_list ( CORRESPONDING #( <ls_group_delivery> ) ) ).
    ENDLOOP.


    LOOP AT lt_who_list ASSIGNING FIELD-SYMBOL(<fs_who>).
      CALL FUNCTION '/SCWM/WHOHU_SELECT'
        EXPORTING
          iv_lgnum  = iv_lgnum
          iv_whoid  = <fs_who>-who
          iv_hukng  = '001'
        IMPORTING
          es_whohu  = ls_whohu
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      READ TABLE lt_carton_mat WITH  KEY matid = ls_whohu-pmat_guid TRANSPORTING NO FIELDS BINARY SEARCH.
      IF sy-subrc EQ 0.
        <fs_who>-areawho = c_reason.
      ENDIF.
      CLEAR: ls_whohu.
    ENDLOOP.
    READ TABLE lt_who_list WITH KEY areawho = c_reason TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      lt_who_unhold = VALUE #( BASE lt_who_unhold FOR <wl> IN lt_who_list WHERE ( areawho = c_reason ) ( who = <wl>-who ) ).
      PERFORM who_hold_unhold TABLES lt_who_unhold USING iv_lgnum CHANGING lo_log.
      CLEAR: lt_who_unhold.
    ENDIF.
    DELETE lt_who_list WHERE areawho = c_reason.
    LOOP AT lr_aawho ASSIGNING <ls_aarea>.
      READ TABLE lt_who_list TRANSPORTING NO FIELDS WITH KEY areawho = <ls_aarea>-low BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_return = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_return IS NOT INITIAL.
      PERFORM who_hold_unhold TABLES lt_who_list USING iv_lgnum CHANGING lo_log.
      CONTINUE.
    ENDIF.

    CLEAR: lt_to.
    NEW zcl_whse_order(
      iv_lgnum = iv_lgnum
      )->to_data_select(
      EXPORTING
        it_who = CORRESPONDING #( lt_who_list )
      IMPORTING
        et_to  = lt_to ).

    LOOP AT lt_to INTO DATA(ls_to_list)
       GROUP BY ( areawho = ls_to_list-areawho
                  rdocid  = ls_to_list-rdocid
                  size  = GROUP SIZE
                  index = GROUP INDEX )
                ASCENDING
                REFERENCE INTO DATA(group_ref_list).

      lt_selection_parameters  = VALUE #( BASE lt_selection_parameters
                                        ( field = zif_whse_order=>wo_mapping_fieldname-who
                                          select_options = VALUE #( FOR ls_who_sel IN GROUP group_ref_list (
                                          sign = wmegc_sign_inclusive option = wmegc_option_eq low = ls_who_sel-who
                                          ) ) ) ).

      NEW zcl_whse_order(
        iv_lgnum = iv_lgnum
        it_selection_parameters = lt_selection_parameters
        )->wo_data_select(
        IMPORTING
          et_who     = DATA(lt_who_volume)
          et_ordim_o = DATA(lt_ordim_o_volume)
          et_ordim_c = DATA(lt_ordim_c_volume)
      ).
      SORT lt_ordim_o_volume BY sum_volum.
      DATA(ls_ordim_o_volume) = VALUE #( lt_ordim_o_volume[ 1 ] OPTIONAL ).
      IF ls_ordim_o_volume IS NOT INITIAL.
        APPEND VALUE #( who        = ls_ordim_o_volume-who
                        areawho    = group_ref_list->areawho
                        sum_volum  = ls_ordim_o_volume-sum_volum
                        unit_v     = ls_ordim_o_volume-unit_v
                        sum_weight = ls_ordim_o_volume-sum_weight
                        unit_w     = ls_ordim_o_volume-unit_w
                        ) TO lt_min_volume.

        READ TABLE lt_who_list ASSIGNING FIELD-SYMBOL(<ls_who_list>) WITH KEY who =  ls_ordim_o_volume-who.
        IF sy-subrc EQ 0.
          APPEND <ls_who_list> TO lt_who_sel.
        ENDIF.
      ENDIF.
      CLEAR: lt_selection_parameters, lt_who_volume, lt_ordim_o_volume, lt_ordim_c_volume, ls_ordim_o_volume.
    ENDLOOP.

    CLEAR: lt_to.
    NEW zcl_whse_order(
      iv_lgnum = iv_lgnum
      )->to_data_select(
      EXPORTING
        it_who = CORRESPONDING #( lt_who_sel )
      IMPORTING
        et_to  = lt_to ).

    lt_tasks = CORRESPONDING #( lt_to ).
    IF line_exists( lt_tasks[ 1 ] ).
      DATA(ls_tasks) = lt_tasks[ 1 ].
      ls_tasks-lgnum = iv_lgnum.
      MODIFY lt_tasks FROM ls_tasks TRANSPORTING lgnum WHERE lgnum IS INITIAL.
    ENDIF.

    CLEAR: lt_bapiret.
    lo_pmat->determine_pmat_for_tasks(
      EXPORTING
        it_to          = lt_tasks
        it_packmat     = lt_packmat
      IMPORTING
        es_pack_output = DATA(ls_pack_output)
        et_bapiret     = lt_bapiret
    ).
    IF lt_bapiret IS NOT INITIAL.
      APPEND LINES OF lt_bapiret TO et_bapiret.
      lo_log->append_sy_msg_at_end(
        CHANGING
          ct_msg = lt_bapiret ).
    ENDIF.

    IF lines( ls_pack_output-shipping ) NE 1.
      PERFORM who_hold_unhold TABLES lt_who_list USING iv_lgnum CHANGING lo_log.
      CLEAR: ls_pack_output.
      CONTINUE.
    ENDIF.

    DATA(ls_palet)    = VALUE #( ls_pack_output-pallet[ 1 ] OPTIONAL ).
    DATA(ls_carton)   = VALUE #( ls_pack_output-carton[ 1 ] OPTIONAL ).
    IF ls_palet-pmatid IS NOT INITIAL OR ls_carton-pmatid IS NOT INITIAL.
      PERFORM who_hold_unhold TABLES lt_who_list USING iv_lgnum CHANGING lo_log.
      CLEAR: ls_pack_output, ls_palet, ls_carton.
      CONTINUE.
    ENDIF.

    DATA(ls_shipping) = VALUE #( ls_pack_output-shipping[ 1 ] OPTIONAL ).
    IF ls_shipping-pmatid IS INITIAL.
      CLEAR: ls_pack_output, ls_shipping.
      PERFORM who_hold_unhold TABLES lt_who_list USING iv_lgnum CHANGING lo_log.
      CONTINUE.
    ENDIF.

    DATA(lt_pmat) = NEW zcl_packmmat_algo( iv_lgnum )->get_pmat_totes( ).

    SORT lt_min_volume BY who.
    lt_tasks_aa01   = VALUE #( FOR ls_task IN lt_tasks WHERE ( aarea = zif_whse_order=>wo_aarea-aa01 ) ( ls_task ) ).
    lt_packmat_aa01 = VALUE #( BASE lt_packmat_aa01 FOR <ls_pmat> IN lt_pmat ( pmat_guid = <ls_pmat>-matid ) ).

    lo_pmat->determine_pmat_for_tasks(
      EXPORTING
        it_to                      = lt_tasks_aa01
        it_packmat                 = lt_packmat_aa01
        iv_use_only_supplied_pmats = abap_true
      IMPORTING
        es_pack_output             = DATA(ls_pmat_min)
        et_bapiret                 = lt_bapiret
    ).
    IF lt_bapiret IS NOT INITIAL.
      APPEND LINES OF lt_bapiret TO et_bapiret.
      lo_log->append_sy_msg_at_end(
        CHANGING
          ct_msg = lt_bapiret ).
    ENDIF.

    IF lines( ls_pmat_min-shipping ) NE 1.
      PERFORM who_hold_unhold TABLES lt_who_list USING iv_lgnum CHANGING lo_log.
      CLEAR: ls_pack_output.
      CONTINUE.
    ENDIF.

    ls_palet    = VALUE #( ls_pmat_min-pallet[ 1 ] OPTIONAL ).
    ls_carton   = VALUE #( ls_pmat_min-carton[ 1 ] OPTIONAL ).
    IF ls_palet-pmatid IS NOT INITIAL OR ls_carton-pmatid IS NOT INITIAL.
      PERFORM who_hold_unhold TABLES lt_who_list USING iv_lgnum CHANGING lo_log.
      CLEAR: ls_pack_output, ls_palet, ls_carton.
      CONTINUE.
    ENDIF.

    DATA(ls_pmat) = VALUE #( ls_pmat_min-shipping[ 1 ] OPTIONAL ).
    IF ls_pmat-pmatid IS INITIAL.
      CLEAR: ls_pmat_min, ls_pmat.
      PERFORM who_hold_unhold TABLES lt_who_list USING iv_lgnum CHANGING lo_log.
      CONTINUE.
    ENDIF.

    IF ls_pmat IS INITIAL.
      CLEAR: ls_pmat_min, ls_pmat.
      PERFORM who_hold_unhold TABLES lt_who_list USING iv_lgnum CHANGING lo_log.
      CONTINUE.
    ENDIF.

    LOOP AT lt_who_list ASSIGNING <ls_who_list>.
      READ TABLE lt_min_volume ASSIGNING FIELD-SYMBOL(<ls_min_volume>) WITH KEY who = <ls_who_list>-who BINARY SEARCH.
      IF sy-subrc EQ 0.
        CASE <ls_min_volume>-areawho.

          WHEN zif_whse_order=>wo_aarea-aa01.

            PERFORM who_db_update_putwall USING iv_lgnum <ls_who_list>-who ls_pmat-pmatid CHANGING lo_log.
            lt_who_unhold = VALUE /scwm/tt_who( ( who = <ls_who_list>-who ) ).
            PERFORM who_hold_unhold TABLES lt_who_unhold USING iv_lgnum CHANGING lo_log.

          WHEN zif_whse_order=>wo_aarea-aa02.

            PERFORM who_db_update_putwall USING iv_lgnum <ls_who_list>-who ls_shipping-pmatid CHANGING lo_log.

          WHEN OTHERS.
        ENDCASE.
      ELSE.
        lt_who_unhold = VALUE /scwm/tt_who( ( who = <ls_who_list>-who ) ).
        PERFORM who_hold_unhold TABLES lt_who_unhold USING iv_lgnum CHANGING lo_log.
      ENDIF.
      CLEAR: lt_who_unhold.
    ENDLOOP.

    CLEAR: ls_pack_output, ls_palet, ls_carton, ls_shipping, ls_pmat_min, ls_pmat.
  ENDLOOP.

  lo_log->save_applog(
    EXPORTING
      is_log       = VALUE #( extnumber = |{ TEXT-002 } { iv_lgnum }|
                              object    = zif_whse_order=>log-object
                              subobject = zif_whse_order=>log-subobject_wave_release )
    IMPORTING
      ev_loghandle = lv_log_handle ) ##NO_TEXT.                 " Log Handle

ENDFUNCTION.


FORM who_hold_unhold TABLES pt_who_list TYPE /scwm/tt_who
                     USING iv_lgnum TYPE  /scwm/lgnum
                     CHANGING co_log TYPE REF TO lcl_log_helper.
********************************************************************
*& Key          : <TBIRIHAN>-January 16, 2024
*& Request No.  : GAP-049 Can-dispatchable productS, Jiffy bag and Putwall management
********************************************************************
*& Description  :
********************************************************************

  CALL FUNCTION '/SCWM/WHO_HOLD_UNHOLD'
    EXPORTING
      iv_lgnum  = iv_lgnum
      iv_unhold = abap_true
      it_who    = VALUE /scwm/tt_whoid( FOR ls_who_list IN pt_who_list[]
                                           ( who = ls_who_list-who ) )
    EXCEPTIONS
      OTHERS    = 99.
  IF sy-subrc NE 0.
    co_log->collect_msg( ).
  ELSE.
    LOOP AT pt_who_list[] INTO DATA(ls_list).
      MESSAGE s417(/scwm/who) WITH ls_list-who INTO DATA(lv_mtext).
      co_log->collect_msg( ).
    ENDLOOP.

  ENDIF.
ENDFORM.

FORM who_db_update_putwall USING iv_lgnum TYPE /scwm/lgnum
                                 iv_who   TYPE /scwm/de_who
                                 iv_matid TYPE /scwm/de_matid
   CHANGING co_log TYPE REF TO lcl_log_helper.
********************************************************************
*& Key          : <TBIRIHAN>-January 16, 2024
*& Request No.  : GAP-049 Can-dispatchable productS, Jiffy bag and Putwall management
********************************************************************
*& Description  :
********************************************************************

  DATA: lt_who_aarea   TYPE  /scwm/tt_who_int,
        lt_whohu_aarea TYPE  /scwm/tt_whohu_int.

  DATA: lt_ordim_o    TYPE /scwm/tt_ordim_o,
        lt_change_att TYPE /scwm/tt_to_change_att,
        lt_bapiret    TYPE bapirettab,
        lv_severity   TYPE bapi_mtype.

  TRY.
      CALL FUNCTION '/SCWM/WHO_SELECT'
        EXPORTING
          iv_lgnum = iv_lgnum
          it_who   = VALUE /scwm/tt_whoid( ( who = iv_who ) )
        IMPORTING
          et_who   = lt_who_aarea
          et_whohu = lt_whohu_aarea.
    CATCH /scwm/cx_core.
  ENDTRY.

  CLEAR: lt_who_aarea. "this was empty in standard during update
  IF line_exists( lt_whohu_aarea[ 1 ] ).
    ASSIGN lt_whohu_aarea[ 1 ] TO FIELD-SYMBOL(<fs_whohu_aarea>).
    <fs_whohu_aarea>-updkz = 'U'.
    <fs_whohu_aarea>-pmat_guid = iv_matid.

    CALL FUNCTION '/SCWM/WHO_DB_UPDATE'
      IN UPDATE TASK
      EXPORTING
        it_who   = lt_who_aarea
        it_whohu = lt_whohu_aarea.

    COMMIT WORK AND WAIT.
  ENDIF.

  TRY.
      CALL FUNCTION '/SCWM/WHO_SELECT'
        EXPORTING
          iv_to      = abap_true
          iv_lgnum   = iv_lgnum
          iv_who     = iv_who
        IMPORTING
          et_ordim_o = lt_ordim_o.
    CATCH /scwm/cx_core.
  ENDTRY.

  LOOP AT lt_ordim_o ASSIGNING FIELD-SYMBOL(<fs_ordim_o>).
    APPEND VALUE #( tanum = <fs_ordim_o>-tanum
                    tt_changed =
                      VALUE /scwm/tt_changed(
                      ( fieldname = zif_whse_order=>wo_att_fieldname-who            value_c = <fs_ordim_o>-who )
                      ( fieldname = zif_whse_order=>wo_att_fieldname-huid           value_c = <fs_ordim_o>-huid )
                      ( fieldname = zif_whse_order=>wo_att_fieldname-whoseq         value_c = <fs_ordim_o>-whoseq )
                      ( fieldname = zif_whse_order=>wo_att_fieldname-zzputwall      value_c = abap_true )
                      ( fieldname = zif_whse_order=>wo_att_fieldname-dlogpos_ext_wt value_c = <fs_ordim_o>-dlogpos_ext_wt )
                      ( fieldname = zif_whse_order=>wo_att_fieldname-dstgrp         value_c = <fs_ordim_o>-dstgrp )
                      )  ) TO lt_change_att.
  ENDLOOP.

  CALL FUNCTION '/SCWM/TO_CHANGE_ATT'
    EXPORTING
      iv_lgnum       = iv_lgnum
      iv_simulate    = VALUE /scwm/simulate( )
      iv_update_task = 'X'
      iv_commit_work = space
      it_change_att  = lt_change_att
    IMPORTING
      et_bapiret     = lt_bapiret
      ev_severity    = lv_severity.
  IF lt_bapiret IS NOT INITIAL.
    co_log->append_sy_msg_at_end(
      CHANGING
        ct_msg = lt_bapiret ).
  ENDIF.
  LOOP AT lt_bapiret ASSIGNING FIELD-SYMBOL(<fs_bapiret2>) WHERE type CA 'EAX'.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.
ENDFORM.
