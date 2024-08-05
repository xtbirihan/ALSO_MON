FUNCTION z_rough_bin_determination.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     VALUE(IV_RDOCCAT) TYPE  /SCWM/DE_DOCCAT
*"     VALUE(IT_WAVE_NO) TYPE  /SCWM/TT_WAVE_NO
*"----------------------------------------------------------------------
********************************************************************
*& Key          : <TBIRIHAN>-January 17, 2024
*& Request No.  : GAP-062
********************************************************************
*& Description  :
********************************************************************
  TYPES: BEGIN OF lty_docno,
           docno TYPE /scwm/de_docno_r,
         END OF lty_docno,
         ltty_docno TYPE STANDARD TABLE OF lty_docno WITH DEFAULT KEY,
         BEGIN OF lty_docno_itemno,
           docno  TYPE /scwm/de_docno_r,
           itemno TYPE /scwm/de_itemno_r,
         END OF lty_docno_itemno,
         ltty_docno_itemno TYPE SORTED TABLE OF lty_docno_itemno
                           WITH UNIQUE KEY docno itemno.

  DATA:
    lt_wavehdr      TYPE /scwm/tt_wavehdr_int,
    lt_waveitm      TYPE /scwm/tt_waveitm_int,
    lt_waveitm_curr TYPE /scwm/tt_waveitm_int,
    lt_bapiret      TYPE bapirettab,
    lv_severity     TYPE bapi_mtype.

  DATA:
    ls_t300_md   TYPE /scwm/s_t300_md,
    lt_selection TYPE /scwm/dlv_selection_tab,
    lt_data      TYPE /scwm/tt_wip_whritem_out.

  DATA:
    lv_dummymsg      TYPE bapi_msg,
    ls_t333          TYPE /scwm/t333,
    ls_dlv_data      TYPE /scwm/s_wip_whritem_out,
    lt_docid         TYPE /scwm/dlv_docid_item_tab,
    lt_docid_all     TYPE /scwm/dlv_docid_item_tab,
    lt_item_keys     TYPE /scwm/tt_dlv_log_item_keys,
    lt_item_rbd_keys TYPE /scwm/tt_dlv_log_item_keys.

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

  DELETE lt_wavehdr WHERE status NE 'E'.
  IF lt_wavehdr IS INITIAL.
    RETURN.
  ENDIF.

* Warehouse  Get SC Unit location number
  CALL FUNCTION '/SCWM/T300_MD_READ_SINGLE'
    EXPORTING
      iv_lgnum   = iv_lgnum
    IMPORTING
      es_t300_md = ls_t300_md
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.
  IF sy-subrc EQ 0.
    APPEND VALUE #( fieldname = /scdl/if_dl_logfname_c=>sc_locationid_wh_h
                    sign      = wmegc_sign_inclusive
                    option    = wmegc_option_eq
                    low       = ls_t300_md-scuguid
     ) TO lt_selection.
  ENDIF.

  DATA(lt_docno) = VALUE ltty_docno( FOR GROUPS grp_docno OF ls_waveitm IN lt_waveitm
                                     GROUP BY ls_waveitm-docno
                                    ( docno = grp_docno ) ).

  DATA(lt_docno_itemno) = VALUE ltty_docno_itemno( FOR GROUPS grp_docno_itemno OF ls_waveitm IN lt_waveitm
                                                   GROUP BY ( docno = ls_waveitm-docno
                                                              itemno = ls_waveitm-itemno )
                                                 ( docno  = grp_docno_itemno-docno
                                                   itemno = grp_docno_itemno-itemno ) ).

  lt_selection = VALUE #( BASE lt_selection FOR <lv_docno> IN lt_docno
                        ( fieldname = /scdl/if_dl_logfname_c=>sc_docno_h
                          sign      = wmegc_sign_inclusive
                          option    = wmegc_option_eq
                          low       = <lv_docno>
                          high      = ' '  ) ).

  CALL FUNCTION '/SCWM/WHRITEM_MON_OUT_COMMON'
    EXPORTING
      iv_lgnum     = iv_lgnum
      it_selection = lt_selection
    IMPORTING
      et_data      = lt_data.

  lt_data = FILTER #( lt_data IN lt_docno_itemno WHERE docno_h = docno
                                                   AND itemno  = itemno ).

* Log init
  IF go_log IS BOUND.
    go_log->init( ).
  ELSE.
    go_log = NEW #( ).
  ENDIF.

  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
    MOVE-CORRESPONDING <ls_data> TO ls_dlv_data.

    IF ls_dlv_data-docid IS INITIAL OR ls_dlv_data-itemid IS INITIAL.
      CONTINUE.
    ENDIF.

    APPEND VALUE #( docid  = ls_dlv_data-docid
                    itemid = ls_dlv_data-itemid
                    doccat = ls_dlv_data-doccat
                  ) TO lt_docid_all.
    " filter: doccat
    IF ls_dlv_data-doccat <> wmegc_doccat_pdo.
      MESSAGE ID '/SCWM/DELIVERY'
        TYPE /scwm/cl_dm_message_no=>sc_msgty_info
        NUMBER '551'
        WITH ls_dlv_data-doccat
        INTO lv_dummymsg.
      go_log->add_message( ).
      CONTINUE.
    ENDIF.

    " performance filter: whse process type for rough bin det. only
    IF ls_dlv_data-procty IS INITIAL.
      MESSAGE ID '/SCWM/DELIVERY'
        TYPE /scwm/cl_dm_message_no=>sc_msgty_info
        NUMBER '552'
        INTO lv_dummymsg.
      go_log->add_message( ).
      CONTINUE.
    ELSE.
      CALL FUNCTION '/SCWM/T333_READ_SINGLE'
        EXPORTING
          iv_lgnum    = iv_lgnum
          iv_procty   = ls_dlv_data-procty
        IMPORTING
          es_t333     = ls_t333
        EXCEPTIONS
          not_found   = 1
          wrong_input = 2
          OTHERS      = 3.
      IF sy-subrc <> 0.
        MESSAGE ID '/SCWM/DELIVERY'
          TYPE /scwm/cl_dm_message_no=>sc_msgty_info
          NUMBER '553'
          WITH ls_dlv_data-procty
          INTO lv_dummymsg.
        go_log->add_message( ).
        CONTINUE.
      ENDIF.
      IF ls_t333-pld = abap_false.
        MESSAGE ID '/SCWM/DELIVERY'
          TYPE /scwm/cl_dm_message_no=>sc_msgty_info
          NUMBER '554'
          WITH ls_dlv_data-procty
          INTO lv_dummymsg.
        go_log->add_message( ).
        CONTINUE.
      ENDIF.
    ENDIF.
    APPEND VALUE #( docid  = ls_dlv_data-docid
                    itemid = ls_dlv_data-itemid
                    doccat = ls_dlv_data-doccat
                  ) TO lt_docid.
  ENDLOOP.

  DATA(lo_prd_man) = NEW /scwm/cl_dlv_management_prd( ).
  DATA(lo_message) = NEW /scwm/cl_dm_message_no( ).

  lo_prd_man->det_pickloc_stag_door(
    EXPORTING
      iv_whno                    = iv_lgnum
      iv_internal_commit_control = abap_true
      iv_package_size            = 1000
      iv_det_rbd                 = abap_true
      iv_det_stga_door           = abap_false
      iv_doccat                  = wmegc_doccat_pdo
      it_docid_itemid            = lt_docid
    IMPORTING
      et_entries_not_changed_err = DATA(lt_entries_not_changed_err)
      et_lock_errors             = DATA(lt_lock_errors)
      et_entries_saved           = DATA(lt_entries_saved)
      et_entries_stga            = DATA(lt_entries_stga)          "stga/door executed
      et_entries_rbd             = DATA(lt_entries_rbd)           "rbd executed
      et_entries_rbd_not_found   = DATA(lt_entries_rbd_not_found) "rbd execute but no bin found
      eo_message                 = lo_message ).

  DATA(lt_docid_tmp) = lt_docid_all.
  SORT lt_docid_tmp BY docid.
  DELETE ADJACENT DUPLICATES FROM lt_docid_tmp COMPARING docid.
  DATA(lv_headers) = lines( lt_docid_tmp ).
  DATA(lv_lines)   = lines( lt_docid_all ).

  MESSAGE
    ID '/SCWM/DELIVERY'
    TYPE /scwm/cl_dm_message_no=>sc_msgty_info
    NUMBER '543'
    WITH lv_lines lv_headers
    INTO lv_dummymsg.
  go_log->add_message( ).

  SORT lt_entries_rbd BY itemid.
  SORT lt_entries_rbd_not_found BY itemid.

  LOOP AT lt_docid_all ASSIGNING FIELD-SYMBOL(<ls_docid>).
    READ TABLE lt_entries_rbd_not_found WITH KEY itemid = <ls_docid>-itemid TRANSPORTING NO FIELDS BINARY SEARCH.
    IF sy-subrc <> 0.
      READ TABLE lt_entries_rbd WITH KEY itemid = <ls_docid>-itemid TRANSPORTING NO FIELDS BINARY SEARCH.
      IF sy-subrc <> 0.
        "item skipped for rbd
        READ TABLE lt_data ASSIGNING FIELD-SYMBOL(<ls_dlv_data>) WITH KEY itemid = <ls_docid>-itemid.
        ASSERT CONDITION sy-subrc = 0.

        APPEND INITIAL LINE TO lt_item_rbd_keys ASSIGNING FIELD-SYMBOL(<ls_refkey>).
        <ls_refkey>-doccat = <ls_dlv_data>-doccat.
        <ls_refkey>-itemno = <ls_dlv_data>-itemno.
        WRITE <ls_dlv_data>-docno_h TO <ls_refkey>-docno.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lt_item_rbd_keys IS NOT INITIAL.
    lv_lines = lines( lt_item_rbd_keys ).
    MESSAGE
      ID '/SCWM/DELIVERY'
      TYPE /scwm/cl_dm_message_no=>sc_msgty_info
      NUMBER '560'
      WITH lv_lines
      INTO lv_dummymsg.
    go_log->add_message( ).
  ENDIF.

  IF lt_entries_rbd IS NOT INITIAL.
    CLEAR lt_item_keys.
    LOOP AT lt_entries_rbd ASSIGNING <ls_docid>.
      READ TABLE lt_data ASSIGNING <ls_dlv_data> WITH KEY itemid = <ls_docid>-itemid.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_item_keys ASSIGNING <ls_refkey>.
      <ls_refkey>-doccat = <ls_dlv_data>-doccat.
      <ls_refkey>-itemno = <ls_dlv_data>-itemno.
      WRITE <ls_dlv_data>-docno_h TO <ls_refkey>-docno.
    ENDLOOP.

    lv_lines = lines( lt_entries_rbd ).
    MESSAGE ID '/SCWM/DELIVERY'
      TYPE /scwm/cl_dm_message_no=>sc_msgty_info
      NUMBER '555'
      WITH lv_lines
      INTO lv_dummymsg.
    go_log->add_message( ).
  ENDIF.

  IF lt_entries_rbd_not_found IS NOT INITIAL.
    CLEAR lt_item_keys.
    LOOP AT lt_entries_rbd_not_found ASSIGNING <ls_docid>.
      READ TABLE lt_data ASSIGNING <ls_dlv_data> WITH KEY itemid = <ls_docid>-itemid.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_item_keys ASSIGNING <ls_refkey>.
      <ls_refkey>-doccat = <ls_dlv_data>-doccat.
      <ls_refkey>-itemno = <ls_dlv_data>-itemno.
      WRITE <ls_dlv_data>-docno_h TO <ls_refkey>-docno.
    ENDLOOP.

    lv_lines = lines( lt_entries_rbd_not_found ).
    MESSAGE ID '/SCWM/DELIVERY'
      TYPE /scwm/cl_dm_message_no=>sc_msgty_info
      NUMBER '559'
      WITH lv_lines
      INTO lv_dummymsg.
    go_log->add_message( ).
  ENDIF.

  IF lt_lock_errors IS NOT INITIAL.
    CLEAR lt_item_keys.
    LOOP AT lt_lock_errors ASSIGNING <ls_docid>.
      READ TABLE lt_data ASSIGNING <ls_dlv_data> WITH KEY itemid = <ls_docid>-itemid.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_item_keys ASSIGNING <ls_refkey>.
      <ls_refkey>-doccat = <ls_dlv_data>-doccat.
      <ls_refkey>-itemno = <ls_dlv_data>-itemno.
      WRITE <ls_dlv_data>-docno_h TO <ls_refkey>-docno.
    ENDLOOP.

    lv_lines = lines( lt_lock_errors ).
    MESSAGE ID '/SCWM/DELIVERY'
      TYPE /scwm/cl_dm_message_no=>sc_msgty_error
      NUMBER '535'
      WITH lv_lines
      INTO lv_dummymsg.
    go_log->add_message( ).
  ENDIF.

  IF lt_entries_not_changed_err IS NOT INITIAL.
    CLEAR lt_item_keys.
    LOOP AT lt_entries_not_changed_err ASSIGNING <ls_docid>.
      READ TABLE lt_data ASSIGNING <ls_dlv_data> WITH KEY itemid = <ls_docid>-itemid.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_item_keys ASSIGNING <ls_refkey>.
      <ls_refkey>-doccat = <ls_dlv_data>-doccat.
      <ls_refkey>-itemno = <ls_dlv_data>-itemno.
      WRITE <ls_dlv_data>-docno_h TO <ls_refkey>-docno.
    ENDLOOP.

    lv_lines = lines( lt_entries_not_changed_err ).
    MESSAGE ID '/SCWM/DELIVERY'
      TYPE /scwm/cl_dm_message_no=>sc_msgty_error
      NUMBER '541'
      WITH lv_lines
      INTO lv_dummymsg.
    go_log->add_message( ).
  ENDIF.

ENDFUNCTION.
