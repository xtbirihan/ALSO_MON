FUNCTION z_who_get.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IO_PROT) TYPE REF TO  /SCWM/CL_LOG OPTIONAL
*"     REFERENCE(IV_TO) TYPE  XFELD DEFAULT SPACE
*"     REFERENCE(IV_LOCK_WHO) TYPE  XFELD DEFAULT SPACE
*"     REFERENCE(IV_LOCK_TO) TYPE  XFELD DEFAULT SPACE
*"     REFERENCE(IV_WHOID) TYPE  /SCWM/DE_WHO OPTIONAL
*"     REFERENCE(IV_WHO_GUID) TYPE  /SCWM/DE_WHO_ID OPTIONAL
*"     REFERENCE(IT_WHORANGE) TYPE  RSDS_FRANGE_T OPTIONAL
*"     REFERENCE(IT_WHOID) TYPE  /SCWM/TT_WHOID OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_WHO) TYPE  /SCWM/S_WHO_INT
*"     REFERENCE(ET_WHO) TYPE  /SCWM/TT_WHO_INT
*"     REFERENCE(ET_WHOHU) TYPE  /SCWM/TT_WHOHU_INT
*"     REFERENCE(ET_ORDIM_O) TYPE  /SCWM/TT_ORDIM_O
*"     REFERENCE(ET_ORDIM_OS) TYPE  /SCWM/TT_ORDIM_OS
*"     REFERENCE(ET_ORDIM_C) TYPE  /SCWM/TT_ORDIM_C
*"     REFERENCE(ET_ORDIM_CS) TYPE  /SCWM/TT_ORDIM_CS
*"  RAISING
*"      /SCWM/CX_CORE
*"----------------------------------------------------------------------
  DATA: lt_whoid    TYPE /scwm/tt_whoid,
        lt_whoids   TYPE /scwm/tt_whoid,
        lt_ordim_o  TYPE /scwm/tt_ordim_o,
        lt_ordim_c  TYPE /scwm/tt_ordim_c,
        lt_ordim_os TYPE /scwm/tt_ordim_os,
        lt_ordim_cs TYPE /scwm/tt_ordim_cs.
  DATA: ls_whoid TYPE /scwm/s_whoid.
  DATA: lv_whoid TYPE /scwm/de_who,
        lv_mtxt  TYPE string,
        lt_who   TYPE /scwm/tt_who_int,
        lt_whohu TYPE /scwm/tt_whohu_int.
  FIELD-SYMBOLS: <who>   TYPE /scwm/s_who_int,
                 <whohu> TYPE /scwm/s_whohu.

  CLEAR: es_who, et_who, et_whohu, et_ordim_o, et_ordim_c.

  IF NOT iv_whoid IS INITIAL.
    READ TABLE gt_who INTO es_who WITH KEY lgnum = iv_lgnum
                                           who   = iv_whoid
                                  BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      IF es_who-db_lock IS INITIAL AND NOT iv_lock_who IS INITIAL.
        DELETE gt_who WHERE lgnum = iv_lgnum AND who   = iv_whoid.
        DELETE gt_whohu WHERE lgnum = iv_lgnum AND who   = iv_whoid.
        lv_whoid = iv_whoid.
      ELSE.
        IF et_whohu IS REQUESTED.
          READ TABLE gt_whohu TRANSPORTING NO FIELDS
                              WITH KEY lgnum = iv_lgnum
                                       who   = iv_whoid
                              BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            LOOP AT gt_whohu ASSIGNING <whohu> FROM sy-tabix.
              IF <whohu>-lgnum <> iv_lgnum OR <whohu>-who <> iv_whoid.
                EXIT.
              ENDIF.
              APPEND <whohu> TO et_whohu.
            ENDLOOP.
          ENDIF.
          IF es_who-type CA 'CD' AND "pick pack path
             es_who-topwhoid IS NOT INITIAL.
            READ TABLE gt_whohu TRANSPORTING NO FIELDS
                                WITH KEY lgnum = iv_lgnum
                                         who   = es_who-topwhoid
                                BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              LOOP AT gt_whohu ASSIGNING <whohu> FROM sy-tabix.
                IF <whohu>-lgnum <> iv_lgnum OR
                   <whohu>-who <> es_who-topwhoid.
                  EXIT.
                ENDIF.
                APPEND <whohu> TO et_whohu.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
        IF iv_to IS INITIAL.
          RETURN.
        ENDIF.
      ENDIF.
    ELSE.
      lv_whoid = iv_whoid.
    ENDIF.

    IF NOT lv_whoid IS INITIAL.
      TRY.
          CALL FUNCTION '/SCWM/WHO_SELECT'
            EXPORTING
              iv_to       = iv_to
              iv_lgnum    = iv_lgnum
              iv_who      = lv_whoid
              iv_lock_who = iv_lock_who
              iv_lock_to  = iv_lock_to
              io_prot     = io_prot
            IMPORTING
              es_who      = es_who
              et_whohu    = et_whohu
              et_ordim_o  = et_ordim_o
              et_ordim_c  = et_ordim_c.
        CATCH /scwm/cx_core.
      ENDTRY.
      APPEND es_who TO gt_who.
      APPEND LINES OF et_who TO gt_who.
      SORT gt_who BY lgnum who.
      APPEND LINES OF et_whohu TO gt_whohu.
      SORT gt_whohu BY lgnum who hukng.
      IF iv_to IS INITIAL.
        RETURN.
      ENDIF.
    ENDIF.
  ELSEIF NOT it_whoid IS INITIAL.
* coding identical to iv_whoid - just in LOOP
    LOOP AT it_whoid INTO ls_whoid.
      CHECK ls_whoid-who IS NOT INITIAL.

      READ TABLE gt_who ASSIGNING <who> WITH KEY lgnum = iv_lgnum
                                                 who   = ls_whoid-who
                                          BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        IF <who>-db_lock IS INITIAL AND NOT iv_lock_who IS INITIAL.
          DELETE gt_who WHERE lgnum = iv_lgnum AND
                              who   = ls_whoid-who.
          DELETE gt_whohu WHERE lgnum = iv_lgnum AND
                                who   = ls_whoid-who.
          APPEND ls_whoid TO lt_whoids.
        ELSE.
          APPEND <who> TO et_who.
          IF et_whohu IS REQUESTED.
            READ TABLE gt_whohu TRANSPORTING NO FIELDS
                                WITH KEY lgnum = iv_lgnum
                                         who   = ls_whoid-who
                                BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              LOOP AT gt_whohu ASSIGNING <whohu> FROM sy-tabix.
                IF <whohu>-lgnum <> iv_lgnum OR <whohu>-who <> ls_whoid-who.
                  EXIT.
                ENDIF.
                APPEND <whohu> TO et_whohu.
              ENDLOOP.
            ENDIF.
            IF <who>-type CA 'CD' AND "pick pack path
              <who>-topwhoid IS NOT INITIAL.
              READ TABLE gt_whohu TRANSPORTING NO FIELDS
                                  WITH KEY lgnum = iv_lgnum
                                           who   = <who>-topwhoid
                                BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                LOOP AT gt_whohu ASSIGNING <whohu> FROM sy-tabix.
                  IF <whohu>-lgnum <> iv_lgnum OR
                     <whohu>-who <> <who>-topwhoid.
                    EXIT.
                  ENDIF.
                  APPEND <whohu> TO et_whohu.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        APPEND ls_whoid TO lt_whoids.
      ENDIF.
      CHECK NOT iv_to IS INITIAL.
      APPEND ls_whoid TO lt_whoid.
    ENDLOOP.
    IF NOT lt_whoids IS INITIAL.
      SORT lt_whoids BY who.
      TRY.
          CALL FUNCTION '/SCWM/WHO_SELECT'
            EXPORTING
              iv_to       = iv_to
              iv_lgnum    = iv_lgnum
              it_who      = lt_whoids
              iv_lock_who = iv_lock_who
              iv_lock_to  = iv_lock_to
              io_prot     = io_prot
            IMPORTING
              et_who      = lt_who
              et_whohu    = lt_whohu
              et_ordim_o  = et_ordim_o
              et_ordim_c  = et_ordim_c.
        CATCH /scwm/cx_core.
      ENDTRY.
      APPEND LINES OF lt_who TO et_who.
      APPEND LINES OF lt_who TO gt_who.
      SORT gt_who BY lgnum who.
      APPEND LINES OF lt_whohu TO et_whohu.
      APPEND LINES OF lt_whohu TO gt_whohu.
      SORT gt_whohu BY lgnum who hukng.
    ENDIF.
    CHECK NOT iv_to IS INITIAL.
  ELSEIF NOT it_whorange IS INITIAL.
    IF et_whohu IS REQUESTED.
      CALL FUNCTION '/SCWM/WHO_RANGE_GET'
        EXPORTING
          iv_lgnum = iv_lgnum
          it_range = it_whorange
        IMPORTING
          et_who   = et_who
          et_whohu = et_whohu.
    ELSE.
      CALL FUNCTION '/SCWM/WHO_RANGE_GET'
        EXPORTING
          iv_lgnum = iv_lgnum
          it_range = it_whorange
        IMPORTING
          et_who   = et_who.
    ENDIF.
    CHECK NOT et_who IS INITIAL.
    IF NOT iv_lock_who IS INITIAL.
      LOOP AT et_who ASSIGNING <who>.
        ls_whoid-who = <who>-who.
        APPEND ls_whoid TO lt_whoid.
      ENDLOOP.
      CLEAR: et_who, et_whohu.
      TRY.
          CALL FUNCTION '/SCWM/WHO_SELECT'
            EXPORTING
              iv_to       = iv_to
              iv_lgnum    = iv_lgnum
              iv_lock_who = iv_lock_who
              iv_lock_to  = iv_lock_to
              it_who      = lt_whoid
            IMPORTING
              et_who      = et_who
              et_whohu    = et_whohu
              et_ordim_o  = et_ordim_o
              et_ordim_c  = et_ordim_c.
        CATCH /scwm/cx_core.
      ENDTRY.
    ENDIF.
    APPEND LINES OF et_who TO gt_who.
    SORT gt_who BY lgnum who ASCENDING db_lock DESCENDING.
    DELETE ADJACENT DUPLICATES FROM gt_who COMPARING lgnum who.
    IF NOT et_whohu IS INITIAL.
      APPEND LINES OF et_whohu TO gt_whohu.
      SORT gt_whohu BY lgnum who hukng.
      DELETE ADJACENT DUPLICATES FROM gt_whohu COMPARING who hukng.
    ENDIF.
    CHECK iv_lock_who IS INITIAL.
  ELSEIF iv_who_guid IS NOT INITIAL.
    READ TABLE gt_who INTO es_who WITH KEY whoid = iv_who_guid.
    CHECK NOT  sy-subrc IS INITIAL.
    TRY.
        CALL FUNCTION '/SCWM/WHO_SELECT'
          EXPORTING
            iv_to    = iv_to
            iv_lgnum = iv_lgnum
            iv_whoid = iv_who_guid
            io_prot  = io_prot
          IMPORTING
            es_who   = es_who.
      CATCH /scwm/cx_core.
    ENDTRY.
    READ TABLE gt_who TRANSPORTING NO FIELDS
                      WITH KEY lgnum = iv_lgnum
                               who   = iv_whoid
                      BINARY SEARCH.
    INSERT es_who INTO gt_who INDEX sy-tabix.
    IF iv_to IS INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

  CHECK NOT iv_to IS INITIAL.
  IF NOT iv_whoid IS INITIAL.
    CALL FUNCTION '/SCWM/TO_READ_WHO'
      EXPORTING
        iv_lgnum     = iv_lgnum
        iv_who       = iv_whoid
        iv_flglock   = iv_lock_to
      IMPORTING
        et_ordim_o   = et_ordim_o
        et_ordim_c   = et_ordim_c
        et_ordim_os  = et_ordim_os
        et_ordim_cs  = et_ordim_cs
      EXCEPTIONS
        wrong_input  = 1
        not_found    = 2
        foreign_lock = 3
        OTHERS       = 99.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_mtxt.
      IF NOT io_prot IS INITIAL.
        CALL METHOD io_prot->add_message( ).
      ENDIF.
      RAISE EXCEPTION TYPE /scwm/cx_core.
    ENDIF.
  ELSE.
    LOOP AT lt_whoid INTO ls_whoid.
      CLEAR: lt_ordim_o, lt_ordim_c, lt_ordim_os, lt_ordim_cs.
      CALL FUNCTION '/SCWM/TO_READ_WHO'
        EXPORTING
          iv_lgnum     = iv_lgnum
          iv_who       = ls_whoid-who
          iv_flglock   = iv_lock_to
        IMPORTING
          et_ordim_o   = lt_ordim_o
          et_ordim_c   = lt_ordim_c
          et_ordim_os  = lt_ordim_os
          et_ordim_cs  = lt_ordim_cs
        EXCEPTIONS
          wrong_input  = 1
          not_found    = 2
          foreign_lock = 3
          OTHERS       = 99.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_mtxt.
        IF NOT io_prot IS INITIAL.
          CALL METHOD io_prot->add_message( ).
        ENDIF.
        RAISE EXCEPTION TYPE /scwm/cx_core.
      ENDIF.

*     check whether ORDIM_O/_C data has been retrieved before
      READ TABLE lt_whoids TRANSPORTING NO FIELDS
           WITH KEY who = ls_whoid-who
           BINARY SEARCH.
      IF sy-subrc IS NOT INITIAL.
        APPEND LINES OF lt_ordim_o TO et_ordim_o.
        APPEND LINES OF lt_ordim_c TO et_ordim_c.
      ENDIF.

      APPEND LINES OF lt_ordim_os TO et_ordim_os.
      APPEND LINES OF lt_ordim_cs TO et_ordim_cs.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
