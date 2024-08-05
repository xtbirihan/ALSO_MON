*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_isolated_doc DEFINITION CREATE PRIVATE FINAL.
  PUBLIC SECTION.
    INTERFACES lif_isolated_doc.

    CLASS-METHODS:
      get_instance
        RETURNING VALUE(ro_instance) TYPE REF TO lif_isolated_doc.

  PRIVATE SECTION.
    CLASS-DATA:
      so_instance TYPE REF TO lif_isolated_doc.
    DATA:
      mo_erp_stock_mapper TYPE REF TO /scwm/if_stockid_mapping.

    METHODS:
      constructor.
ENDCLASS.

CLASS lcl_isolated_doc IMPLEMENTATION.

  METHOD constructor.
    mo_erp_stock_mapper = /scwm/cl_erp_stock_mapper=>get_instance( ).
  ENDMETHOD.

  METHOD get_instance.
    IF so_instance IS NOT BOUND.
      CREATE OBJECT so_instance TYPE lcl_isolated_doc.
    ENDIF.
    ro_instance = so_instance.
  ENDMETHOD.

  METHOD lif_isolated_doc~set_lgnum.
    DATA:
      lr_scu_mgr TYPE REF TO /scmb/if_scu_mgr,
      lt_scuguid TYPE /scmb/scuguid_tab,
      lrt_entity TYPE /scmb/toentityref_tab,
      lr_scu     TYPE REF TO /scmb/if_scu,
      lt_mapping TYPE /scmb/scu_mapping_out_tab,
      ls_mapping TYPE /scmb/scu_mapping_out_str.

    ev_lgnum = iv_lgnum.
    ev_scuguid = lif_isolated_doc~get_scuguid( iv_lgnum = iv_lgnum ).

*   get entitled
    lif_isolated_doc~get_entitled(
      EXPORTING
        iv_lgnum = iv_lgnum
      IMPORTING
        et_entitled = et_entitled ).

*   get supply chain unit
    CLEAR lt_scuguid.
    APPEND ev_scuguid TO lt_scuguid.

    lr_scu_mgr = /scmb/cl_scu_system=>so_scu_mgr.
    IF lr_scu_mgr IS BOUND.
      lrt_entity = lr_scu_mgr->get_scus_by_scuguid( it_scuguid = lt_scuguid ).
    ENDIF.

    CLEAR: lt_mapping, ls_mapping.
    READ TABLE lrt_entity INTO lr_scu INDEX 1.
    IF sy-subrc EQ 0.
      lt_mapping = lr_scu->get_mapping( ).
      READ TABLE lt_mapping WITH KEY scuguid = ev_scuguid
      INTO ls_mapping.
      IF sy-subrc IS INITIAL.
        ev_scu = ls_mapping-ext_entity.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD lif_isolated_doc~get_entitled.
    DATA:
      lt_entitled_tmp TYPE /scwm/tt_entitled,
      ls_entitled_tmp TYPE /scwm/s_entitled,
      lt_entitled     TYPE bu_partner_t,
      ls_entitled     TYPE bupa_partner.


    lt_entitled_tmp = mo_erp_stock_mapper->get_erp_entitled_by_lgnum( EXPORTING iv_lgnum = iv_lgnum ).

    LOOP AT lt_entitled_tmp INTO ls_entitled_tmp.
      ls_entitled-partner = ls_entitled_tmp-entitled.
      APPEND ls_entitled TO lt_entitled.
    ENDLOOP.

    CALL FUNCTION 'BUP_PARTNER_GUID_CONVERT'
      EXPORTING
        it_partner      = lt_entitled
      IMPORTING
        et_partner_guid = et_entitled.

  ENDMETHOD.

  METHOD lif_isolated_doc~get_scuguid.
    DATA:
          ls_t300_md TYPE /scwm/s_t300_md.

    CALL FUNCTION '/SCWM/T300_MD_READ_SINGLE'
      EXPORTING
        iv_lgnum   = iv_lgnum
      IMPORTING
        es_t300_md = ls_t300_md
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.

    IF sy-subrc <> 0 OR ls_t300_md-scuguid IS INITIAL.
      MESSAGE e005(/scwm/md) WITH iv_lgnum .
    ELSE.
      MOVE ls_t300_md-scuguid TO rv_scuguid.
    ENDIF.
  ENDMETHOD.

  METHOD lif_isolated_doc~dm_matid_get.
    DATA:
          ls_message TYPE scx_t100key.

    CALL FUNCTION '/SAPAPO/DM_MATID_GET'
      EXPORTING
        i_matnr_rtab  = it_matnr_rtab
      IMPORTING
        e_matid_tab   = et_matid
      EXCEPTIONS
        no_material   = 1
        not_qualified = 2.

    IF sy-subrc = 1.
      RAISE EXCEPTION TYPE lcx_no_material.
    ENDIF.

    IF sy-subrc = 2.
      RAISE EXCEPTION TYPE lcx_not_qualified.
    ENDIF.
  ENDMETHOD.

  METHOD lif_isolated_doc~sapapo_product_dm_read.
    DATA: lv_package_size type INT4 value 9000,
          lv_rec_count    type INT4,
          lv_matid_count  type INT4,
          ls_matid        type /SAPAPO/DM_MATLWH_ID,
          lt_matid1       type /SAPAPO/DM_MATLWH_ID_TAB,
          lt_matkey_out   type /SAPAPO/MATKEY_OUT_TAB,
          lt_mattxt       type /SAPAPO/MATTXT_TAB,
          lt_matpack      type /SAPAPO/MATPACK_TAB,
          lt_matexec      type /SAPAPO/MATEXEC_TAB,
          lt_marm         type /SAPAPO/MARM_TAB.

    DESCRIBE TABLE it_matid LINES lv_rec_count.

    IF lv_rec_count > lv_package_size.
      lv_matid_count = 0.
      CLEAR ls_matid.
      CLEAR lt_matid1[].
      LOOP AT it_matid INTO ls_matid.
        APPEND ls_matid TO lt_matid1.
        lv_matid_count = lv_matid_count + 1.
        IF lv_matid_count = lv_package_size.
          IF NOT lt_matid1 IS INITIAL.
            CALL FUNCTION '/SAPAPO/DM_PRODUCTS_READ'
      EXPORTING
        iv_langu      = iv_langu
        is_exclude    = is_exclude
      TABLES
                it_matid      = lt_matid1
                it_matnr      = it_matnr
              et_matkey_out = lt_matkey_out
              et_mattxt     = lt_mattxt
              et_matpack    = lt_matpack
              et_matexec    = lt_matexec
              et_marm       = lt_marm
             EXCEPTIONS
              OTHERS        = 0.
             APPEND LINES OF lt_matkey_out TO et_matkey_out.
             APPEND LINES OF lt_mattxt TO et_mattxt.
             APPEND LINES OF lt_matpack TO et_matpack.
             APPEND LINES OF lt_matexec TO et_matexec.
             APPEND LINES OF lt_marm TO et_marm.
          ENDIF.
          CLEAR lv_matid_count.
          CLEAR lt_matid1[].
        ENDIF.
      ENDLOOP.
      IF lt_matid1 IS NOT INITIAL.
         CALL FUNCTION '/SAPAPO/DM_PRODUCTS_READ'
            EXPORTING
              iv_langu      = iv_langu
              is_exclude    = is_exclude
            TABLES
              it_matid      = lt_matid1
              it_matnr      = it_matnr
              et_matkey_out = lt_matkey_out
              et_mattxt     = lt_mattxt
              et_matpack    = lt_matpack
              et_matexec    = lt_matexec
              et_marm       = lt_marm
             EXCEPTIONS
              OTHERS        = 0.
             APPEND LINES OF lt_matkey_out TO et_matkey_out.
             APPEND LINES OF lt_mattxt TO et_mattxt.
             APPEND LINES OF lt_matpack TO et_matpack.
             APPEND LINES OF lt_matexec TO et_matexec.
             APPEND LINES OF lt_marm TO et_marm.
      ENDIF.
    ELSE.
      CALL FUNCTION '/SAPAPO/DM_PRODUCTS_READ'
        EXPORTING
          iv_langu      = iv_langu
          is_exclude    = is_exclude
        TABLES
          it_matid      = it_matid
        it_matnr      = it_matnr
        et_matkey_out = et_matkey_out
        et_mattxt     = et_mattxt
        et_matpack    = et_matpack
        et_matexec    = et_matexec
        et_marm       = et_marm
      EXCEPTIONS
        OTHERS        = 0.
    ENDIF.

  ENDMETHOD.

  METHOD lif_isolated_doc~read_matlwh_multi.
    DATA: lt_prodlwh_tmp      TYPE /sapapo/dm_matlwh_tab,
          lt_mat_lgnum        TYPE /scwm/tt_material_lgnum,
          lo_cl_af_product    TYPE REF TO /scwm/if_af_product,
          ls_req_fields       TYPE /scwm/s_mat_req_fields,
          lt_material         TYPE /sapapo/matkey_out_tab,
          lt_matid            TYPE /scwm/tt_matid,
          lt_matnr            TYPE /scmb/mdl_matnr_tab,
          ls_mat_nr_id_guid   TYPE ty_prod,
          lt_mat_guid         TYPE /scwm/s_material_global,
          ls_material_global  TYPE /scwm/s_material_global,
          lt_material_global  TYPE /scwm/tt_material_global,
          ls_material_lgnum   TYPE /scwm/s_material_lgnum,
          lt_material_lgnum   TYPE /scwm/tt_material_lgnum,
          ls_lgnum_prod       TYPE ty_lgnum_matlwh,
          lt_lgnum_prod_tmp   TYPE tt_lgnum_matlwh,
          lt_lgnum_prod       TYPE tt_lgnum_matlwh,
          lt_matlwh_id        TYPE /sapapo/dm_matlwh_id_tab,
          ls_entitled         TYPE bupa_partner_guid,
          lt_mat_nr_id_guid   TYPE tt_prod,
          lv_plant            TYPE werks_d,
          lo_material_service TYPE REF TO /scwm/if_af_material,
          lo_stockid_map      TYPE REF TO /scwm/if_stockid_mapping,
          lo_service          TYPE REF TO /scwm/if_tm_global_info.

    FIELD-SYMBOLS: <ls_entitled>       TYPE bupa_partner_guid,
                   <fs_material>       TYPE /sapapo/matkey_out,
                   <fs_prodlwh_tmp>    TYPE /sapapo/dm_matlwh,
                   <fs_lgnum_prod>     TYPE ty_lgnum_matlwh,
                   <fs_mat_nr_id_guid> TYPE ty_prod,
                   <fs_material_lgnum> TYPE /scwm/s_material_lgnum.

    DATA: lv_package_size type INT4 value 9000,
          lv_rec_count    type INT4,
          lv_matid_count  type INT4,
          ls_matlwh_id    type /SAPAPO/DM_MATLWH_ID,
          lt_matlwh_id1   type /SAPAPO/DM_MATLWH_ID_TAB.
"          lt_prodlwh_tmp1 type /sapapo/dm_matlwh_tab.



    DATA(lo_saf) = /scdl/cl_af_management=>get_instance( ).
    lo_material_service ?= lo_saf->get_service( EXPORTING iv_service = /scwm/if_af_material=>sc_me_as_service ).
    TRY.
        lo_service ?= /scwm/cl_tm_factory=>get_service( /scwm/cl_tm_factory=>sc_globals ).
      CATCH /scwm/cx_tm_factory.
        ASSERT 1 = 0.
    ENDTRY.
    lo_material_service->clean_buffers( ).

    CALL FUNCTION '/SCWM/GET_STOCKID_MAP_INSTANCE'
      IMPORTING
        eif_stockid_mapping = lo_stockid_map.

    CLEAR et_prod_lwh.
    CLEAR lt_matlwh_id.
    CLEAR lt_prodlwh_tmp.

    LOOP AT it_material ASSIGNING <fs_material>.
      APPEND <fs_material>-matid TO lt_matlwh_id.
    ENDLOOP.

*   ideal would be the use of FM /SCWM/MATERIAL_READ_MULTIPLE
*   but it returns an empty record even if there is no record on the DB
*   Here we need to recognize if a wh product exists in the DB or not
*   -> use of FM '/SAPAPO/MATLWH_READ_MULTI_2' and method lo_material_service->get_marc_fields instead

    DESCRIBE TABLE lt_matlwh_id LINES lv_rec_count.

    IF lv_rec_count > lv_package_size.
      lv_matid_count = 0.
      CLEAR ls_matlwh_id.
      CLEAR lt_matlwh_id1[].
      LOOP AT lt_matlwh_id INTO ls_matlwh_id.
        APPEND ls_matlwh_id TO lt_matlwh_id1.
        lv_matid_count = lv_matid_count + 1.
        IF lv_matid_count = lv_package_size.
          IF NOT lt_matlwh_id1 IS INITIAL.
            CALL FUNCTION '/SAPAPO/MATLWH_READ_MULTI_2'
                EXPORTING
                  it_key              = lt_matlwh_id1
      IMPORTING
        et_locprodwh        = lt_prodlwh_tmp
      EXCEPTIONS
        interface_incorrect = 1
        data_not_found      = 2
        OTHERS              = 3.
          ENDIF.
          CLEAR lv_matid_count.
          CLEAR lt_matlwh_id1[].
        ENDIF.
      ENDLOOP.
      IF lt_matlwh_id1 IS NOT INITIAL.
          CALL FUNCTION '/SAPAPO/MATLWH_READ_MULTI_2'
              EXPORTING
                it_key              = lt_matlwh_id1
              IMPORTING
                et_locprodwh        = lt_prodlwh_tmp
              EXCEPTIONS
                interface_incorrect = 1
                data_not_found      = 2
                OTHERS              = 3.
      ENDIF.
    ELSE.
      CALL FUNCTION '/SAPAPO/MATLWH_READ_MULTI_2'
        EXPORTING
          it_key              = lt_matlwh_id
        IMPORTING
          et_locprodwh        = lt_prodlwh_tmp
        EXCEPTIONS
          interface_incorrect = 1
          data_not_found      = 2
          OTHERS              = 3.

    ENDIF.

    lt_mat_nr_id_guid = it_mat_nr_id_guid.
    SORT lt_mat_nr_id_guid BY matid.
    LOOP AT it_entitled ASSIGNING <ls_entitled>.

      CLEAR lt_material_global.
      CLEAR lt_material_lgnum.
      CLEAR lt_lgnum_prod_tmp.
      CLEAR lt_lgnum_prod.
      CLEAR ls_material_global.
      CLEAR ls_material_lgnum.

      LOOP AT lt_prodlwh_tmp ASSIGNING <fs_prodlwh_tmp> WHERE scuguid = iv_scuguid AND entitled_id = <ls_entitled>-partner_guid.
*     mapping matid - matnr
        READ TABLE lt_mat_nr_id_guid WITH KEY matid = <fs_prodlwh_tmp>-matid ASSIGNING <fs_mat_nr_id_guid> BINARY SEARCH.
        ls_material_global-matid = <fs_mat_nr_id_guid>-matguid.
        ls_material_global-matnr = <fs_mat_nr_id_guid>-matnr.
        APPEND ls_material_global TO lt_material_global.

        MOVE-CORRESPONDING <fs_prodlwh_tmp> TO ls_material_lgnum.
        ls_material_lgnum-matid = <fs_mat_nr_id_guid>-matguid.
        ls_material_lgnum-lgnum = iv_lgnum.
        ls_material_lgnum-entitled = <ls_entitled>-partner.
        APPEND ls_material_lgnum TO lt_material_lgnum.

*       Saving user and date/time values of the warehouse product  "Note 2799873
        MOVE-CORRESPONDING ls_material_lgnum TO ls_lgnum_prod.
        ls_lgnum_prod-createuser = <fs_prodlwh_tmp>-createuser.
        ls_lgnum_prod-createutc  = <fs_prodlwh_tmp>-createutc.
        ls_lgnum_prod-changeuser = <fs_prodlwh_tmp>-changeuser.
        ls_lgnum_prod-changeutc  = <fs_prodlwh_tmp>-changeutc.
        APPEND ls_lgnum_prod TO lt_lgnum_prod_tmp.
      ENDLOOP.


** in S4 HANA, some special fields of the warehouse product must be retrieved from MARC
      IF lo_service->is_s4h_stack( ) = abap_true.
        TRY.
            lo_stockid_map->get_plant_by_partnerno(
              EXPORTING
                iv_wme_partno = <ls_entitled>-partner
              IMPORTING
                ev_erp_plant = lv_plant ).
          CATCH /scwm/cx_stockid_map.
        ENDTRY.

        lo_material_service->get_marc_fields(
          EXPORTING
            iv_lgnum     = iv_lgnum
            iv_plant     = lv_plant
            iv_entitled  = <ls_entitled>-partner
            it_matglobal = lt_material_global
          CHANGING
            ct_matlwh    = lt_material_lgnum ).
      ENDIF.

      CLEAR ls_lgnum_prod.                        "Note 2799873

      LOOP AT lt_material_lgnum ASSIGNING <fs_material_lgnum>.
        READ TABLE lt_lgnum_prod_tmp WITH KEY matid = <fs_material_lgnum>-matid ASSIGNING <fs_lgnum_prod> BINARY SEARCH.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING <fs_material_lgnum> TO ls_lgnum_prod.
          ls_lgnum_prod-createuser  = <fs_lgnum_prod>-createuser.
          ls_lgnum_prod-createutc   = <fs_lgnum_prod>-createutc.
          ls_lgnum_prod-changeuser  = <fs_lgnum_prod>-changeuser.
          ls_lgnum_prod-changeutc   = <fs_lgnum_prod>-changeutc.
          APPEND ls_lgnum_prod TO lt_lgnum_prod.
        ENDIF.
      ENDLOOP.

      APPEND LINES OF lt_lgnum_prod TO et_prod_lwh.

    ENDLOOP.

  ENDMETHOD.

  METHOD lif_isolated_doc~buffer_mapping_mat_nr_id_guid.
    DATA: lt_matnr          TYPE /scmb/mdl_matnr_tab,
          ls_mat_nr_id_guid TYPE ty_prod,
          lt_material       TYPE /sapapo/matkey_out_tab.

    FIELD-SYMBOLS:
      <fs_material>       TYPE /sapapo/matkey_out,
      <fs_mat_nr_id_guid> TYPE ty_prod.

    CLEAR et_mat_nr_id_guid.

    lt_material = it_material.
    SORT lt_material BY matnr.

    LOOP AT lt_material ASSIGNING <fs_material>.
      APPEND <fs_material>-matnr TO lt_matnr .
    ENDLOOP.

*  mapping Matnr - Matguid

    DATA(lo_stock_fields) = NEW /scwm/cl_ui_stock_fields( ).
    lo_stock_fields->prefetch_matid_by_no(
      EXPORTING
        it_matnr       = lt_matnr
      IMPORTING
        et_matid_matnr = DATA(lt_matid_matnr) ).

    LOOP AT lt_matid_matnr ASSIGNING FIELD-SYMBOL(<ls_matid_matnr>).
      ls_mat_nr_id_guid-matnr = <ls_matid_matnr>-matnr.
      ls_mat_nr_id_guid-matguid = <ls_matid_matnr>-matid.

      READ TABLE lt_material WITH KEY matnr = ls_mat_nr_id_guid-matnr ASSIGNING <fs_material> BINARY SEARCH.
      ls_mat_nr_id_guid-matid = <fs_material>-matid.

      APPEND ls_mat_nr_id_guid TO et_mat_nr_id_guid.
    ENDLOOP.


  ENDMETHOD.


  METHOD lif_isolated_doc~sapapo_matlwhst_read_multi_2.
    CALL FUNCTION '/SAPAPO/MATLWHST_READ_MULTI_2'
      EXPORTING
        it_key              = it_key
      IMPORTING
        et_locprodwhst      = et_prodwhst
      EXCEPTIONS
        interface_incorrect = 1
        data_not_found      = 2
        OTHERS              = 3.
  ENDMETHOD.

  METHOD lif_isolated_doc~get_prod_id.
    TYPES:
      BEGIN OF lty_entitled_map,
        entitled_id TYPE /scwm/de_entitled_id,
        entitled    TYPE /scwm/de_entitled,
      END OF lty_entitled_map.

    DATA:
      lt_prodlwhid        TYPE /sapapo/dm_matlwh_id_tab,
      ls_prodlwhid        TYPE /sapapo/dm_matlwh_id,
      lt_prodlwh          TYPE /sapapo/dm_matlwh_tab,
      lt_matid_tab        TYPE tt_matid,
      ls_mat_range        TYPE ty_matnr_range,
      wa_range            TYPE rsds_range,
      lt_matno_nogap      TYPE /sapapo/mat_nr_rtab,
      ls_matno            TYPE /sapapo/mat_nr_rstr,
      lt_matid            TYPE /sapapo/matid_tab,
      ls_matid            TYPE /sapapo/matid_str,
      lt_entitled         TYPE /scwm/tt_entitled_2,
      ls_entitled         TYPE /scwm/de_entitled,
      ls_entitled_map     TYPE lty_entitled_map,
      lt_entitled_map     TYPE TABLE OF lty_entitled_map,
      lv_tabix            TYPE sytabix,
      lv_multi_read_ok    TYPE abap_bool,
      lt_matnr_range      TYPE tt_matnr_range,
      ls_matnr_range      TYPE ty_matnr_range,
      lt_matid_range      TYPE tt_matid_range,
      ls_matid_range      TYPE ty_matid_range,
      lt_whse_product_ids TYPE /sapapo/dm_matlwh_id_tab,
      lt_entitled_id      TYPE /scmb/mdl_prt_id_tab,
      ls_entitled_id      TYPE /scmb/mdl_prtid_str,
      lt_scuguid          TYPE /scmb/scuguid_tab,
      lv_scuguid          TYPE guid_16,
      lt_field            TYPE /sapapo/matloctd_field_tab,
      ls_field            TYPE /sapapo/matloctd_field_struct,
      lt_wheretab         TYPE rsds_where_tab,
      ls_where            TYPE rsdswhere,
      lv_scuguid_txt(32)  TYPE c,
      lx_no_material      TYPE REF TO lcx_no_material,
      lx_not_qualified    TYPE REF TO lcx_not_qualified,
      lv_val              TYPE string,
      lv_line             TYPE string.

    FIELD-SYMBOLS:
      <ls_prodlwh>  TYPE /sapapo/dm_matlwh,
      <ls_entitled> TYPE bupa_partner_guid,
      <ls_matid>    TYPE /sapapo/matid_str,
      <fs_matid>    TYPE /sapapo/matid.


    CLEAR: et_matid_tab, lt_entitled_id, lt_scuguid, lt_field.

    IF iv_selection_mode = /scwm/cl_mon_prod=>sc_show_only_wh.

*     read products having a whse product in the DB
      CLEAR lt_matid_tab.
      LOOP AT it_entitled ASSIGNING <ls_entitled>.
        ls_entitled_id-partner_guid = <ls_entitled>-partner_guid.
        APPEND ls_entitled_id TO lt_entitled_id.
      ENDLOOP.

      APPEND iv_scuguid TO lt_scuguid.

      ls_field-field = 'MATID'.
      APPEND ls_field TO lt_field.
      ls_field-field = 'SCUGUID'.
      APPEND ls_field TO lt_field.
      ls_field-field = 'ENTITLED_ID'.
      APPEND ls_field TO lt_field.

      WRITE iv_scuguid TO lv_scuguid_txt.
      lv_val = cl_abap_dyn_prg=>quote( lv_scuguid_txt ).
      CONCATENATE 'SCUGUID = ' lv_val INTO lv_line RESPECTING BLANKS.
      ls_where-line = lv_line.
      APPEND ls_where TO lt_wheretab.


      /sapapo/cl_matlwh_reader=>read_matlwh_forall_id(
      EXPORTING
        it_scuguid = lt_scuguid
        it_field = lt_field
        it_wheretab = lt_wheretab
        it_entitled_id = lt_entitled_id
      IMPORTING
        et_id =  lt_whse_product_ids ).

*     no  selection on matnr
      IF it_matnr_range IS INITIAL.
        MOVE-CORRESPONDING lt_whse_product_ids[] TO et_matid_tab.
      ELSE.
*       selection of all products from the database in the matnr range
        TRY.
            lif_isolated_doc~dm_matid_get(
              EXPORTING
                it_matnr_rtab  = it_matnr_range
              IMPORTING
                et_matid   = lt_matid
            ).
          CATCH lcx_no_material INTO lx_no_material.
          CATCH lcx_not_qualified INTO lx_not_qualified.
        ENDTRY.

*       only product having a warehouse product are taken over
        SORT lt_whse_product_ids BY matid.
        LOOP AT lt_matid ASSIGNING <fs_matid>.
          READ TABLE lt_whse_product_ids WITH KEY matid = <fs_matid> BINARY SEARCH TRANSPORTING NO FIELDS .
          IF sy-subrc = 0.
            APPEND <fs_matid> TO et_matid_tab.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ELSE.
*     must select all products respecting the condition on matnr
      lt_matnr_range = it_matnr_range.

      IF lt_matnr_range IS INITIAL.
        ls_matnr_range-sign = 'I'.
        ls_matnr_range-option = 'CP'.
        ls_matnr_range-low = '*'.
        APPEND ls_matnr_range TO lt_matnr_range.
      ENDIF.


      LOOP AT lt_matnr_range INTO ls_mat_range.
        MOVE-CORRESPONDING ls_mat_range TO ls_matno.
        APPEND ls_matno TO lt_matno_nogap.
      ENDLOOP.


      TRY.
          lif_isolated_doc~dm_matid_get(
            EXPORTING
              it_matnr_rtab  = lt_matno_nogap
            IMPORTING
              et_matid   = lt_matid
          ).
        CATCH lcx_no_material INTO lx_no_material.
        CATCH lcx_not_qualified INTO lx_not_qualified.
      ENDTRY.

      LOOP AT lt_matid INTO ls_matid.
        APPEND  ls_matid-matid TO  et_matid_tab.
      ENDLOOP.
    ENDIF.

    SORT et_matid_tab BY matid.
    DELETE ADJACENT DUPLICATES FROM et_matid_tab.

  ENDMETHOD.


  METHOD lif_isolated_doc~enqueue_optimistic.
    DATA: ls_return       TYPE bapiret2,
          ls_lock_mass_pr TYPE /sapapo/matkey_lock,
          lt_lock_mass_pr TYPE tt_lock_mass_pr.

    CLEAR ev_failed.

    CLEAR ls_lock_mass_pr.
    CLEAR lt_lock_mass_pr.
    ls_lock_mass_pr-mandt = sy-mandt.
    ls_lock_mass_pr-matnr = iv_matnr.
    APPEND ls_lock_mass_pr TO lt_lock_mass_pr.
    TRY .
        CALL METHOD io_lock_mass_pr->enqueue_optimistic
          EXPORTING
            it_master_data_objects = lt_lock_mass_pr[]
            iv_new_selection       = 'X'.
      CATCH /scmb/cx_md_lock_foreign_lock /scmb/cx_md_lock_system_error.
        CLEAR ls_return.
        ls_return-type = 'W'.
        ls_return-id = '/SCWM/MONITOR'.
        ls_return-number = 254.
        ls_return-message_v1 = iv_matnr.
        APPEND ls_return TO ct_return.

        ev_failed = abap_true.
    ENDTRY.
  ENDMETHOD.

  METHOD lif_isolated_doc~product_authority_check.
    CONSTANTS:
      gc_auth_matkey(3) TYPE c VALUE 'MKY' ##NO_TEXT.

    DATA: ls_return       TYPE bapiret2.
    DATA: lv_prod_check_failed TYPE abap_bool,
          lo_af_whse_auth      TYPE REF TO /scwm/if_af_whse_auth.

    CLEAR ev_failed.

    " Perform additional checks on /SCWM/PROD
    IF iv_lgnum IS NOT INITIAL.
      TRY.
          lo_af_whse_auth ?= /scmb/cl_af_factory=>get_instance( )->get_service( /scwm/if_af_whse_auth=>sc_me_as_a_service ).

          lv_prod_check_failed = lo_af_whse_auth->check_for_warehouse_product(
            EXPORTING iv_lgnum   = iv_lgnum
                      iv_actvt   = iv_actvt
                      iv_product = iv_matnr ).
        CATCH /scmb/cx_af_factory.
          lv_prod_check_failed = abap_true.
      ENDTRY.
    ENDIF.

    CALL FUNCTION '/SAPAPO/MD_AUTHORITY_CORE_CHK'
      EXPORTING
        i_check_obj     = gc_auth_matkey "Product
        i_actvt         = iv_actvt           "Create
        i_matnr         = iv_matnr
      EXCEPTIONS
        value_not_found = 1
        no_authority    = 2
        OTHERS          = 3.

    IF sy-subrc <> 0 OR lv_prod_check_failed = abap_true.
      CLEAR ls_return.
      ls_return-type = 'W'.
      ls_return-id = '/SCWM/MONITOR'.
      ls_return-number = 253.
      ls_return-message_v1 = iv_matnr.
      APPEND ls_return TO ct_return.

      ev_failed = abap_true.
    ENDIF.

  ENDMETHOD.



  METHOD lif_isolated_doc~sapapo_dm_products_maintain.
    DATA: lv_rollback    TYPE abap_bool,
          ls_return      TYPE bapiret2,
          lt_ext_matlwh  TYPE tt_ext_matlwh,
          lt_ext_matlwhx TYPE tt_ext_matlwhx..

*     -> use local memory for update task
    SET UPDATE TASK LOCAL.

    CLEAR et_return.
    lt_ext_matlwh = it_ext_matlwh.
    lt_ext_matlwhx = it_ext_matlwhx.

    CALL FUNCTION '/SAPAPO/DM_PRODUCTS_MAINTAIN'
      EXPORTING
        if_logqs          = space
        if_map_use        = '0'
        if_syn_post       = abap_true
        if_class_maintain = space
        if_caller         = 'MASS'
      TABLES
        it_ext_matkey     = it_ext_matkey
        it_ext_matkeyx    = it_ext_matkeyx
        it_ext_matlwh     = lt_ext_matlwh
        it_ext_matlwhx    = lt_ext_matlwhx
        it_ext_matlwhst   = it_ext_matlwhst
        it_ext_matlwhstx  = it_ext_matlwhstx
        et_return         = et_return
      EXCEPTIONS
        OTHERS            = 0.

    lv_rollback = abap_false.
    LOOP AT et_return INTO ls_return WHERE
      type = 'E' OR type = 'A'.
      lv_rollback = abap_true.
      EXIT.
    ENDLOOP.

    IF lv_rollback = abap_true.
      ROLLBACK WORK.
      ev_abort = abap_true.
    ELSE.
      COMMIT WORK.
      CLEAR ev_abort.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
